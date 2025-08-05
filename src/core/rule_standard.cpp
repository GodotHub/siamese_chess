#include "rule_standard.hpp"
#include <godot_cpp/classes/resource_loader.hpp>
#include <godot_cpp/classes/packed_scene.hpp>
#include "state.hpp"
#include "chess.hpp"
#include "transposition_table.hpp"

RuleStandard::RuleStandard()
{
	directions_diagonal = {-17, -15, 15, 17};
	directions_straight = {-16, -1, 1, 16};
	directions_eight_way = {-17, -16, -15, -1, 1, 15, 16, 17};
	directions_horse = {33, 31, 18, 14, -33, -31, -18, -14};
}

godot::String RuleStandard::get_end_type(godot::Ref<State>_state)
{
	int group = _state->get_turn();
	godot::PackedInt32Array move_list = generate_valid_move(_state, group);
	if (!move_list.size())
	{
		if (is_check(_state, 1 - group))
		{
			return group == 0 ? "checkmate_black" : "checkmate_white";
		}
		else
		{
			return group == 0 ? "stalemate_black" : "stalemate_white";
		}
	}
	if (_state->has_history(_state->get_zobrist()) == 3)
	{
		return "threefold_repetition";	// 三次重复局面
	}
	if (_state->get_step_to_draw() == 50)
	{
		return "50_moves";
	}
	return "";
}

godot::Ref<State>RuleStandard::parse(godot::String _str)
{
	godot::Ref<State>state = memnew(State);
	godot::Vector2i pointer = godot::Vector2i(0, 0);
	godot::PackedStringArray fen_splited = _str.split(" ");
	if (fen_splited.size() < 6)
	{
		return nullptr;
	}
	for (int i = 0; i < fen_splited[0].length(); i++)
	{
		if (fen_splited[0][i] == '/')	//太先进了竟然是char32
		{
			pointer.x = 0;
			pointer.y += 1;
		}
		else if (fen_splited[0][i] >= '0' && fen_splited[0][i] <= '9')
		{
			pointer.x += fen_splited[0][i] - '0';
		}
		else if (fen_splited[0][i])
		{
			state->add_piece(pointer.x + pointer.y * 16, fen_splited[0][i]);
			pointer.x += 1;
		}
	}
	if (pointer.x != 8 || pointer.y != 7)
	{
		return nullptr;
	}
	if (fen_splited[1] != "w" && fen_splited[1] != "b")
	{
		return nullptr;
	}
	if (!fen_splited[4].is_valid_int())
	{
		return nullptr;
	}
	if (!fen_splited[5].is_valid_int())
	{
		return nullptr;
	}
	state->set_turn(fen_splited[1] == "w" ? 0 : 1);
	state->set_castle((int(fen_splited[2].contains("K")) << 3) + (int(fen_splited[2].contains("Q")) << 2) + (int(fen_splited[2].contains("k")) << 1) + int(fen_splited[2].contains("q")));
	state->set_en_passant(Chess::to_position_int(fen_splited[3]));
	state->set_step_to_draw(fen_splited[4].to_int());
	state->set_round(fen_splited[5].to_int());
	return state;
}

godot::String RuleStandard::stringify(godot::Ref<State>_state)
{
	int null_counter = 0;
	godot::PackedStringArray chessboard;
	for (int i = 0; i < 8; i++)
	{
		godot::String line = "";
		for (int j = 0; j < 8; j++)
		{
			if (_state->get_piece((i << 4) + j))
			{
				if (null_counter)
				{
					line += null_counter + '0';
					null_counter = 0;
				}
				line += _state->get_piece((i << 4) + j);
			}
			else
			{
				null_counter += 1;
			}
		}
		if (null_counter)
		{
			line += null_counter + '0';
			null_counter = 0;
		}
		chessboard.append(line);
	}
	godot::PackedStringArray output = {godot::String("/").join(chessboard)};
	output.push_back(_state->get_turn() == 0 ? "w" : "b");
	output.push_back("");
	output[2] += (_state->get_castle() & 8) ? "K" : "";
	output[2] += (_state->get_castle() & 4) ? "Q" : "";
	output[2] += (_state->get_castle() & 2) ? "k" : "";
	output[2] += (_state->get_castle() & 1) ? "q" : "";
	if (!output[2])
	{
		output[2] = "-";
	}
	output.push_back(_state->get_en_passant() ? Chess::to_position_name(_state->get_en_passant()) : "-");
	output.push_back(godot::String::num(_state->get_step_to_draw(), 0));
	output.push_back(godot::String::num(_state->get_round(), 0));
	// king_passant是为了判定是否违规走子，临时记录的，这里不做转换
	return godot::String(" ").join(output);
}

bool RuleStandard::is_move_valid(godot::Ref<State>_state, int _group, int _move)
{
	int from = Chess::from(_move);
	int from_piece = _state->get_piece(from);
	if (!from_piece || _group != Chess::group(from_piece))
	{
		return false;
	}
	godot::Ref<State>test_state = _state->duplicate();
	apply_move(test_state, _move);
	return !is_check(test_state, 1 - _group);
}

bool RuleStandard::is_check(godot::Ref<State> _state, int _group)
{
	for (int _from_1 = 0; _from_1 < 8; _from_1++)
	{
		for (int _from_2 = 0; _from_2 < 8; _from_2++)
		{
			int _from = (_from_1 << 4) + _from_2;
			if (!_state->has_piece(_from))
			{
				continue;
			}
			int from_piece = _state->get_piece(_from);
			if (_group != Chess::group(from_piece))
			{
				continue;
			}
			godot::PackedInt32Array directions;
			if ((from_piece & 95) == 'P')
			{
				int front = from_piece == 'P' ? -16 : 16;
				bool on_start = (_from >> 4) == (from_piece == 'P' ? 6 : 1);
				bool on_end = (_from >> 4) == (from_piece == 'P' ? 1 : 6);
				if (_state->has_piece(_from + front + 1) && !Chess::is_same_group(from_piece, _state->get_piece(_from + front + 1)) && (_state->get_piece(_from + front + 1) & 95) == 'K'
				|| !((_from + front + 1) & 0x88) && on_end && _state->get_king_passant() != -1 && abs(_state->get_king_passant() - (_from + front + 1)) <= 1)
				{
					return true;
				}
				if (_state->has_piece(_from + front - 1) && !Chess::is_same_group(from_piece, _state->get_piece(_from + front - 1)) && (_state->get_piece(_from + front - 1) & 95) == 'K'
				|| !((_from + front - 1) & 0x88) && on_end && _state->get_king_passant() != -1 && abs(_state->get_king_passant() - (_from + front - 1)) <= 1)
				{
					return true;
				}
				continue;
			}
			else if ((from_piece & 95) == 'K' || (from_piece & 95) == 'Q')
			{
				directions = directions_eight_way;
			}
			else if ((from_piece & 95) == 'R')
			{
				directions = directions_straight;
			}
			else if ((from_piece & 95) == 'N')
			{
				directions = directions_horse;
			}
			else if ((from_piece & 95) == 'B')
			{
				directions = directions_diagonal;
			}

			for (int i = 0; i < directions.size(); i++)
			{
				int to = _from + directions[i];
				int to_piece = _state->get_piece(to);
				while (!(to & 0x88) && (!to_piece || !Chess::is_same_group(from_piece, to_piece)))
				{
					if (_state->get_king_passant() != -1 && abs(to - _state->get_king_passant()) <= 1 && (to >> 4) == _group * 7)
					{
						return true;
					}
					if (!(to & 0x88) && to_piece && !Chess::is_same_group(from_piece, to_piece))
					{
						if ((to_piece & 95) == 'K')
						{
							return true;
						}
						break;
					}
					if ((from_piece & 95) == 'K' || (from_piece & 95) == 'N')
					{
						break;
					}
					to += directions[i];
					to_piece = _state->get_piece(to);
				}
			}
		}
	}
	return false;
}

godot::PackedInt32Array RuleStandard::generate_premove(godot::Ref<State>_state, int _group)
{
	godot::PackedInt32Array output;
	for (int _from_1 = 0; _from_1 < 8; _from_1++)
	{
		for (int _from_2 = 0; _from_2 < 8; _from_2++)
		{
			int _from = (_from_1 << 4) + _from_2;
			if (!_state->has_piece(_from))
			{
				continue;
			}
			int from_piece = _state->get_piece(_from);
			if (_group != Chess::group(from_piece))
			{
				continue;
			}
			godot::PackedInt32Array directions;
			if ((from_piece & 95) == 'P')
			{
				int front = _group == 0 ? -16 : 16;
				bool on_start = (_from >> 4) == (_group == 0 ? 6 : 1);
				bool on_end = (_from >> 4) == (_group == 0 ? 1 : 6);
				if (on_end)
				{
					output.push_back(Chess::create(_from, _from + front, _group == 0 ? 'Q' : 'q'));
					output.push_back(Chess::create(_from, _from + front, _group == 0 ? 'R' : 'r'));
					output.push_back(Chess::create(_from, _from + front, _group == 0 ? 'N' : 'n'));
					output.push_back(Chess::create(_from, _from + front, _group == 0 ? 'B' : 'b'));
					if (!((_from + front + 1) & 0x88))
					{
						output.push_back(Chess::create(_from, _from + front + 1, _group == 0 ? 'Q' : 'q'));
						output.push_back(Chess::create(_from, _from + front + 1, _group == 0 ? 'R' : 'r'));
						output.push_back(Chess::create(_from, _from + front + 1, _group == 0 ? 'N' : 'n'));
						output.push_back(Chess::create(_from, _from + front + 1, _group == 0 ? 'B' : 'b'));
					}
					if (!((_from + front - 1) & 0x88))
					{
						output.push_back(Chess::create(_from, _from + front - 1, _group == 0 ? 'Q' : 'q'));
						output.push_back(Chess::create(_from, _from + front - 1, _group == 0 ? 'R' : 'r'));
						output.push_back(Chess::create(_from, _from + front - 1, _group == 0 ? 'N' : 'n'));
						output.push_back(Chess::create(_from, _from + front - 1, _group == 0 ? 'B' : 'b'));
					}
				}
				else
				{
					output.push_back(Chess::create(_from, _from + front, 0));
					if (!((_from + front + 1) & 0x88))
					{
						output.push_back(Chess::create(_from, _from + front + 1, 0));
					}
					if (!((_from + front - 1) & 0x88))
					{
						output.push_back(Chess::create(_from, _from + front - 1, 0));
					}
					if (on_start)
					{
						output.push_back(Chess::create(_from, _from + front + front, 0));
					}
				}
				continue;
			}
			else if ((from_piece & 95) == 'K' || (from_piece & 95) == 'Q')
			{
				directions = directions_eight_way;
			}
			else if ((from_piece & 95) == 'R')
			{
				directions = directions_straight;
			}
			else if ((from_piece & 95) == 'N')
			{
				directions = directions_horse;
			}
			else if ((from_piece & 95) == 'B')
			{
				directions = directions_diagonal;
			}
			for (int i = 0; i < directions.size(); i++)
			{
				int to = _from + directions[i];
				while (!(to & 0x88))
				{
					output.push_back(Chess::create(_from, to, 0));
					if ((from_piece & 95) == 'K' || (from_piece & 95) == 'N')
					{
						break;
					}
					to += directions[i];
				}
			}
		}
	}
	if (_group == 0 && (_state->get_castle() & 8) && !_state->has_piece(Chess::g1()) && !_state->has_piece(Chess::f1()))
	{
		output.push_back(Chess::create(Chess::e1(), Chess::g1(), 'K'));
	}
	if (_group == 0 && (_state->get_castle() & 4) && !_state->has_piece(Chess::c1()) && !_state->has_piece(Chess::d1()))
	{
		output.push_back(Chess::create(Chess::e1(), Chess::c1(), 'Q'));
	}
	if (_group == 1 && (_state->get_castle() & 2) && !_state->has_piece(Chess::g8()) && !_state->has_piece(Chess::f8()))
	{
		output.push_back(Chess::create(Chess::e8(), Chess::g8(), 'k'));
	}
	if (_group == 1 && (_state->get_castle() & 1) && !_state->has_piece(Chess::c8()) && !_state->has_piece(Chess::d8()))
	{
		output.push_back(Chess::create(Chess::e8(), Chess::c8(), 'q'));
	}
	return output;
}

godot::PackedInt32Array RuleStandard::generate_move(godot::Ref<State>_state, int _group)
{
	godot::PackedInt32Array output;
	for (int _from_1 = 0; _from_1 < 8; _from_1++)
	{
		for (int _from_2 = 0; _from_2 < 8; _from_2++)
		{
			int _from = (_from_1 << 4) + _from_2;
			if (!_state->has_piece(_from))
			{
				continue;
			}
			int from_piece = _state->get_piece(_from);
			if (_group != Chess::group(from_piece))
			{
				continue;
			}
			godot::PackedInt32Array directions;
			if ((from_piece & 95) == 'P')
			{
				int front = from_piece == 'P' ? -16 : 16;
				bool on_start = (_from >> 4) == (from_piece == 'P' ? 6 : 1);
				bool on_end = (_from >> 4) == (from_piece == 'P' ? 1 : 6);
				if (!_state->has_piece(_from + front))
				{
					if (on_end)
					{
						output.push_back(Chess::create(_from, _from + front, _group == 0 ? 'Q' : 'q'));
						output.push_back(Chess::create(_from, _from + front, _group == 0 ? 'R' : 'r'));
						output.push_back(Chess::create(_from, _from + front, _group == 0 ? 'N' : 'n'));
						output.push_back(Chess::create(_from, _from + front, _group == 0 ? 'B' : 'b'));
					}
					else
					{
						output.push_back(Chess::create(_from, _from + front, 0));
						if (!_state->has_piece(_from + front + front) && on_start)
						{
							output.push_back(Chess::create(_from, _from + front + front, 0));
						}
					}
				}
				if (_state->has_piece(_from + front + 1) && !Chess::is_same_group(from_piece, _state->get_piece(_from + front + 1)) || ((_from >> 4) == 3 || (_from >> 4) == 4) && _state->get_en_passant() == _from + front + 1)
				{
					if (on_end)
					{
						output.push_back(Chess::create(_from, _from + front + 1, _group == 0 ? 'Q' : 'q'));
						output.push_back(Chess::create(_from, _from + front + 1, _group == 0 ? 'R' : 'r'));
						output.push_back(Chess::create(_from, _from + front + 1, _group == 0 ? 'N' : 'n'));
						output.push_back(Chess::create(_from, _from + front + 1, _group == 0 ? 'B' : 'b'));
					}
					else
					{
						output.push_back(Chess::create(_from, _from + front + 1, 0));
					}
				}
				if (_state->has_piece(_from + front - 1) && !Chess::is_same_group(from_piece, _state->get_piece(_from + front - 1)) || ((_from >> 4) == 3 || (_from >> 4) == 4) && _state->get_en_passant() == _from + front - 1)
				{
					if (on_end)
					{
						output.push_back(Chess::create(_from, _from + front - 1, _group == 0 ? 'Q' : 'q'));
						output.push_back(Chess::create(_from, _from + front - 1, _group == 0 ? 'R' : 'r'));
						output.push_back(Chess::create(_from, _from + front - 1, _group == 0 ? 'N' : 'n'));
						output.push_back(Chess::create(_from, _from + front - 1, _group == 0 ? 'B' : 'b'));
					}
					else
					{
						output.push_back(Chess::create(_from, _from + front - 1, 0));
					}
				}
				continue;
			}
			else if ((from_piece & 95) == 'K' || (from_piece & 95) == 'Q')
			{
				directions = directions_eight_way;
			}
			else if ((from_piece & 95) == 'R')
			{
				directions = directions_straight;
			}
			else if ((from_piece & 95) == 'N')
			{
				directions = directions_horse;
			}
			else if ((from_piece & 95) == 'B')
			{
				directions = directions_diagonal;
			}

			for (int i = 0; i < directions.size(); i++)
			{
				int to = _from + directions[i];
				int to_piece = _state->get_piece(to);
				while (!(to & 0x88) && (!to_piece || !Chess::is_same_group(from_piece, to_piece)))
				{
					output.push_back(Chess::create(_from, to, 0));
					if (!(to & 0x88) && to_piece && !Chess::is_same_group(from_piece, to_piece))
					{
						break;
					}
					if ((from_piece & 95) == 'K' || (from_piece & 95) == 'N')
					{
						break;
					}
					to += directions[i];
					to_piece = _state->get_piece(to);
					if (!(from_piece == 'R' && to_piece == 'K' || from_piece == 'r' && to_piece == 'k'))
					{
						continue;
					}
					if ((_from & 15) >= 4 && (from_piece == 'R' && (_state->get_castle() & 8) || from_piece == 'r' && (_state->get_castle() & 2)))
					{
						output.push_back(Chess::create(to, from_piece == 'R' ? Chess::g1() : Chess::g8(), 'K'));
					}
					else if ((_from & 15) <= 3 && (from_piece == 'R' && (_state->get_castle() & 4) || from_piece == 'r' && (_state->get_castle() & 1)))
					{
						output.push_back(Chess::create(to,from_piece == 'R' ? Chess::c1() : Chess::c8(), 'Q'));
					}
				}
			}
		}
	}
	return output;
}

godot::PackedInt32Array RuleStandard::generate_valid_move(godot::Ref<State>_state, int _group)
{
	godot::PackedInt32Array move_list = generate_move(_state, _group);
	godot::PackedInt32Array output;
	for (int i = 0; i < move_list.size(); i++)
	{
		if (is_move_valid(_state, _group, move_list[i]))
		{
			output.push_back(move_list[i]);
		}
	}
	return output;
}

godot::String RuleStandard::get_move_name(godot::Ref<State> _state, int move)
{
	int from = Chess::get_singleton()->from(move);
	int to = Chess::get_singleton()->to(move);
	int from_piece = _state->get_piece(from);
	int extra = Chess::get_singleton()->extra(move);
	int group = Chess::group(from_piece);
	if ((from_piece & 95) == 'K' && extra)
	{
		if ((extra & 95) == 'K')
		{
			return "O-O";
		}
		else if ((extra & 95) == 'Q')
		{
			return "O-O-O";
		}
	}
	godot::String ans;
	if ((from_piece & 95) != 'P')
	{
		ans += (from_piece & 95);
	}

	godot::PackedInt32Array move_list = generate_valid_move(_state, group);
	godot::PackedInt32Array same_to;
	bool has_same_piece = false;
	bool has_same_col = false;
	bool has_same_row = false;
	for (int i = 0; i < move_list.size(); i++)
	{
		int _from = Chess::get_singleton()->from(move_list[i]);
		if (_from != from && _state->get_piece(_from) == from_piece && Chess::get_singleton()->to(move_list[i]) == to)
		{
			has_same_piece = true;
			if ((_from & 0xF0) == (from & 0xF0))
			{
				has_same_row = true;
			}
			if ((_from & 0x0F) == (from & 0x0F))
			{
				has_same_col = true;
			}
		}
	}
	if (has_same_piece)
	{
		if (has_same_row || !has_same_row && !has_same_col)
		{
			ans += (from & 0x0F) + 'a';
		}
		if (has_same_col)
		{
			ans +=  7 - (from >> 4) + '1';
		}
	}
	if (_state->get_piece(to) && ((from_piece & 95) != 'P'))
	{
		ans += 'x';
	}
	ans += (to & 0x0F) + 'a';
	ans +=  7 - (to >> 4) + '1';
	if (_state->get_piece(to) && ((from_piece & 95) == 'P') || to == _state->get_en_passant())
	{
		ans += 'x';
	}
	if (extra)
	{
		ans += '=';
		ans += (extra & 95);
	}
	godot::Ref<State> next_state = _state->duplicate();
	apply_move(next_state, move);
	if (is_check(next_state, group))
	{
		if (generate_valid_move(next_state, 1 - group).size() == 0)
		{
			ans += '#';
		}
		else
		{
			ans += '+';
		}
	}
	return ans;
}

int RuleStandard::name_to_move(godot::Ref<State> _state, godot::String _name)
{
	godot::PackedInt32Array move_list = generate_move(_state, _state->get_turn());
	for (int i = 0; i < move_list.size(); i++)
	{
		godot::String name = get_move_name(_state, move_list[i]);
		if (name == _name)
		{
			return move_list[i];
		}
	}
	return -1;
}

void RuleStandard::apply_move(godot::Ref<State>_state, int _move)
{
	_state->push_history(_state->get_zobrist());	// 上一步的局面
	if (_state->get_turn() == 1)
	{
		_state->set_round(_state->get_round() + 1);
		_state->set_turn(0);
	}
	else if (_state->get_turn() == 0)
	{
		_state->set_turn(1);
	}
	_state->set_step_to_draw(_state->get_step_to_draw() + 1);
	int from_piece = _state->get_piece(Chess::from(_move));
	int from_group = Chess::group(from_piece);
	int to_piece = _state->get_piece(Chess::to(_move));
	bool dont_move = false;
	bool has_en_passant = false;
	bool has_king_passant = false;
	if (to_piece)
	{
		_state->capture_piece(Chess::to(_move));
		_state->set_step_to_draw(0);	// 吃子时重置50步和棋
	}
	if (_state->get_king_passant() != -1 && abs(_state->get_king_passant() - Chess::to(_move)) <= 1)
	{
		if (from_group == 0)
		{
			if (_state->get_piece(Chess::c8()) == 'k')
			{
				_state->capture_piece(Chess::c8());
			}
			if (_state->get_piece(Chess::g8()) == 'k')
			{
				_state->capture_piece(Chess::g8());
			}
		}
		else
		{
			if (_state->get_piece(Chess::c1()) == 'K')
			{
				_state->capture_piece(Chess::c1());
			}
			if (_state->get_piece(Chess::g1()) == 'K')
			{
				_state->capture_piece(Chess::g1());
			}
		}
	}
	if ((from_piece & 95) == 'R')	// 哪边的车动过，就不能往那个方向易位
	{
		if ((Chess::from(_move) & 15) >= 4)
		{
			if (from_group == 0)
			{
				_state->set_castle(_state->get_castle() & 7);
			}
			else
			{
				_state->set_castle(_state->get_castle() & 13);
			}
		}
		else if ((Chess::from(_move) & 15) <= 3)
		{
			if (from_group == 0)
			{
				_state->set_castle(_state->get_castle() & 11);
			}
			else
			{
				_state->set_castle(_state->get_castle() & 14);
			}
		}
	}
	if ((from_piece & 95) == 'K')
	{
		if (from_group == 0)
		{
			_state->set_castle(_state->get_castle() & 3);
		}
		else
		{
			_state->set_castle(_state->get_castle() & 12);
		}
		if (Chess::extra(_move))
		{
			if (Chess::to(_move) == Chess::g1())
			{
				_state->move_piece(Chess::h1(), Chess::f1());
				_state->set_king_passant(Chess::f1());
			}
			if (Chess::to(_move) == Chess::c1())
			{
				_state->move_piece(Chess::a1(), Chess::d1());
				_state->set_king_passant(Chess::d1());
			}
			if (Chess::to(_move) == Chess::g8())
			{
				_state->move_piece(Chess::h8(), Chess::f8());
				_state->set_king_passant(Chess::f8());
			}
			if (Chess::to(_move) == Chess::c8())
			{
				_state->move_piece(Chess::a8(), Chess::d8());
				_state->set_king_passant(Chess::d8());
			}
			has_king_passant = true;
		}
	}
	if ((from_piece & 95) == 'P')
	{
		int front = from_piece == 'P' ? -16 : 16;
		_state->set_step_to_draw(0);	// 移动兵时重置50步和棋
		if (Chess::to(_move) - Chess::from(_move) == front * 2)
		{
			has_en_passant = true;
			_state->set_en_passant(Chess::from(_move) + front);
		}
		if (((Chess::from(_move) >> 4) == 3 || (Chess::from(_move) >> 4) == 4) && Chess::to(_move) == _state->get_en_passant())
		{
			int captured = Chess::to(_move) - front;
			_state->capture_piece(captured);
		}
		if (Chess::extra(_move))
		{
			dont_move = true;
			_state->capture_piece(Chess::from(_move));
			_state->add_piece(Chess::to(_move), Chess::extra(_move));
		}
	}
	if (!dont_move)
	{
		_state->move_piece(Chess::from(_move), Chess::to(_move));
	}

	if (!has_en_passant)
	{
		_state->set_en_passant(-1);
	}
	if (!has_king_passant)
	{
		_state->set_king_passant(-1);
	}
}


void RuleStandard::apply_move_custom(godot::Ref<State> _state, int _move, godot::Callable _callback_add_piece, godot::Callable _callback_capture_piece, godot::Callable _callback_move_piece)
{
	int from_piece = _state->get_piece(Chess::from(_move));
	int from_group = Chess::group(from_piece);
	int to_piece = _state->get_piece(Chess::to(_move));
	bool dont_move = false;
	bool has_en_passant = false;
	bool has_king_passant = false;
	if (to_piece)
	{
		_callback_capture_piece.call(Chess::to(_move));
	}
	if (_state->get_king_passant() != -1 && abs(_state->get_king_passant() - Chess::to(_move)) <= 1)
	{
		if (from_group == 0)
		{
			if (_state->get_piece(Chess::c8()) == 'k')
			{
				_callback_capture_piece.call(Chess::c8());
			}
			if (_state->get_piece(Chess::g8()) == 'k')
			{
				_callback_capture_piece.call(Chess::g8());
			}
		}
		else
		{
			if (_state->get_piece(Chess::c1()) == 'K')
			{
				_callback_capture_piece.call(Chess::c1());
			}
			if (_state->get_piece(Chess::g1()) == 'K')
			{
				_callback_capture_piece.call(Chess::g1());
			}
		}
	}
	if ((from_piece & 95) == 'K')
	{
		if (Chess::extra(_move))
		{
			if (Chess::to(_move) == Chess::g1())
			{
				_callback_move_piece.call(Chess::h1(), Chess::f1());
			}
			if (Chess::to(_move) == Chess::c1())
			{
				_callback_move_piece.call(Chess::a1(), Chess::d1());
			}
			if (Chess::to(_move) == Chess::g8())
			{
				_callback_move_piece.call(Chess::h8(), Chess::f8());
			}
			if (Chess::to(_move) == Chess::c8())
			{
				_callback_move_piece.call(Chess::a8(), Chess::d8());
			}
		}
	}
	if ((from_piece & 95) == 'P')
	{
		int front = from_piece == 'P' ? -16 : 16;
		if (((Chess::from(_move) >> 4) == 3 || (Chess::from(_move) >> 4) == 4) && Chess::to(_move) == _state->get_en_passant())
		{
			int captured = Chess::to(_move) - front;
			_callback_capture_piece.call(captured);
		}
		if (Chess::extra(_move))
		{
			dont_move = true;
			_callback_capture_piece.call(Chess::from(_move));
			_callback_add_piece.call(Chess::to(_move), Chess::extra(_move));
		}
	}
	if (!dont_move)
	{
		_callback_move_piece.call(Chess::from(_move), Chess::to(_move));
	}
}

RuleStandard *RuleStandard::get_singleton()
{
	static RuleStandard *singleton = memnew(RuleStandard);
	return singleton;
}

void RuleStandard::_bind_methods()
{
	godot::ClassDB::bind_method(godot::D_METHOD("get_end_type"), &RuleStandard::get_end_type);
	godot::ClassDB::bind_method(godot::D_METHOD("parse"), &RuleStandard::parse);
	godot::ClassDB::bind_method(godot::D_METHOD("stringify"), &RuleStandard::stringify);
	godot::ClassDB::bind_method(godot::D_METHOD("is_check"), &RuleStandard::is_check);
	godot::ClassDB::bind_method(godot::D_METHOD("is_move_valid"), &RuleStandard::is_move_valid);
	godot::ClassDB::bind_method(godot::D_METHOD("generate_premove"), &RuleStandard::generate_premove);
	godot::ClassDB::bind_method(godot::D_METHOD("generate_move"), &RuleStandard::generate_move);
	godot::ClassDB::bind_method(godot::D_METHOD("generate_valid_move"), &RuleStandard::generate_valid_move);
	godot::ClassDB::bind_method(godot::D_METHOD("get_move_name"), &RuleStandard::get_move_name);
	godot::ClassDB::bind_method(godot::D_METHOD("name_to_move"), &RuleStandard::name_to_move);
	godot::ClassDB::bind_method(godot::D_METHOD("apply_move"), &RuleStandard::apply_move);
	godot::ClassDB::bind_method(godot::D_METHOD("apply_move_custom"), &RuleStandard::apply_move_custom);
}
