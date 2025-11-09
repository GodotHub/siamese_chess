#include "rule_standard.hpp"
#include <godot_cpp/classes/resource_loader.hpp>
#include <godot_cpp/classes/packed_scene.hpp>
#include <random>
#include <queue>
#include <unordered_set>
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
	if (generate_valid_move(_state, group).size() == 0)
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
		else if (fen_splited[0][i] >= '1' && fen_splited[0][i] <= '9')
		{
			pointer.x += fen_splited[0][i] - '0';
		}
		else
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
	for (int i = 6; i < fen_splited.size(); i++)
	{
		int type = fen_splited[i][0];
		int64_t bit = fen_splited[i].substr(1).hex_to_int();
		state->set_bit(type, bit);
	}
	return state;
}

godot::Ref<State> RuleStandard::create_initial_state()
{
	return parse("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1 ^0 v0");
}

godot::Ref<State> RuleStandard::create_random_state(int piece_count)
{
	std::mt19937_64 rng(time(nullptr));
	godot::PackedInt32Array type = {'P', 'N', 'B', 'R', 'Q', 'W', 'X', 'Y'};
	godot::PackedInt32Array pieces;
	pieces.push_back('K');
	pieces.push_back('k');
	for (int i = 2; i < piece_count; i++)
	{
		int piece = type[rng() % type.size()];
		pieces.push_back(piece);
		pieces.push_back(piece + 32);	// 黑方
	}
	pieces.resize(64);
	while (true)
	{
		godot::Ref<State> new_state = parse("8/8/8/8/8/8/8/8 w - - 0 1");
		bool valid_pawn = true;
		for (int i = 0; i < pieces.size(); i++)
		{
			int k = rng() % (i + 1);
			std::swap(pieces[i], pieces[k]);
		}
		for (int i = 0; i < 64; i++)
		{
			if ((pieces[i] & 95) == 'P' && (i <= 7 || i >= 56))
			{
				valid_pawn = false;
				break;
			}
			if (pieces[i] != 0)
			{
				new_state->add_piece(i % 8 + i / 8 * 16, pieces[i]);
			}
		}
		if (!valid_pawn)
		{
			continue;
		}
		if (is_check(new_state, 0) || is_check(new_state, 1))
		{
			continue;
		}

		return new_state;
	}
	return nullptr;
}

godot::Ref<State> RuleStandard::mirror_state(godot::Ref<State> _state)
{
	godot::Ref<State> output = memnew(State);
	for (State::PieceIterator iter = _state->piece_iterator_begin(); !iter.end(); iter.next())
	{
		int _from = iter.pos();
		int from_mirrored = (_from >> 4 << 4) | (7 - (_from & 0xF));
		int from_piece = iter.piece();
		output->add_piece(from_mirrored, from_piece);
	}
	output->set_turn(_state->get_turn());
	output->set_castle(_state->get_castle());
	output->set_en_passant(_state->get_en_passant());
	output->set_step_to_draw(_state->get_step_to_draw());
	output->set_round(_state->get_round());
	output->set_king_passant(_state->get_king_passant());
	return output;
}

godot::Ref<State> RuleStandard::rotate_state(godot::Ref<State> _state)
{
	godot::Ref<State> output = memnew(State);
	for (State::PieceIterator iter = _state->piece_iterator_begin(); !iter.end(); iter.next())
	{
		int _from = iter.pos();
		int from_rotated = Chess::to_x88(63 - Chess::to_64(_from));
		int from_piece = iter.piece();
		output->add_piece(from_rotated, from_piece);
	}
	output->set_turn(_state->get_turn());
	output->set_castle(_state->get_castle());
	output->set_en_passant(_state->get_en_passant());
	output->set_step_to_draw(_state->get_step_to_draw());
	output->set_round(_state->get_round());
	output->set_king_passant(_state->get_king_passant());
	return output;
}

godot::Ref<State> RuleStandard::swap_group(godot::Ref<State> _state)
{
	
	godot::Ref<State> output = memnew(State);
	for (State::PieceIterator iter = _state->piece_iterator_begin(); !iter.end(); iter.next())
	{
		int _from = iter.pos();
		int from_piece = iter.piece();
		int from_piece_fliped = Chess::group(from_piece) == 0 ? from_piece + 32 : from_piece - 32;
		output->add_piece(_from, from_piece_fliped);
	}
	output->set_turn(1 - _state->get_turn());
	output->set_castle(_state->get_castle());
	output->set_en_passant(_state->get_en_passant());
	output->set_step_to_draw(_state->get_step_to_draw());
	output->set_round(_state->get_round());
	output->set_king_passant(_state->get_king_passant());
	return output;
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
	if (_state->get_bit('^'))
	{
		output.push_back("^" + godot::String::num(_state->get_bit('^')));
	}
	if (_state->get_bit('v'))
	{
		output.push_back("v" + godot::String::num(_state->get_bit('v')));
	}
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
	int to = Chess::to(_move);
	int to_piece = _state->get_piece(to);
	int flag = false;
	godot::PackedInt32Array *directions = nullptr;
	if ((from_piece & 95) == 'P')
	{
		int front = from_piece == 'P' ? -16 : 16;
		bool on_start = (from >> 4) == (from_piece == 'P' ? 6 : 1);
		bool on_end = (from >> 4) == (from_piece == 'P' ? 1 : 6);
		if (!_state->has_piece(from + front))
		{
			if (on_end)
			{
				flag = flag || _move == Chess::create(from, from + front, _group == 0 ? 'Q' : 'q');
				flag = flag || _move == Chess::create(from, from + front, _group == 0 ? 'R' : 'r');
				flag = flag || _move == Chess::create(from, from + front, _group == 0 ? 'N' : 'n');
				flag = flag || _move == Chess::create(from, from + front, _group == 0 ? 'B' : 'b');
			}
			else
			{
				flag = flag || _move == Chess::create(from, from + front, 0);
				if (!_state->has_piece(from + front + front) && on_start)
				{
					flag = flag || _move == Chess::create(from, from + front + front, 0);
				}
			}
		}
		if (_state->has_piece(from + front + 1) && !Chess::is_same_group(from_piece, _state->get_piece(from + front + 1)) || ((from >> 4) == 3 || (from >> 4) == 4) && _state->get_en_passant() == from + front + 1)
		{
			if (on_end)
			{
				flag = flag || _move == Chess::create(from, from + front + 1, _group == 0 ? 'Q' : 'q');
				flag = flag || _move == Chess::create(from, from + front + 1, _group == 0 ? 'R' : 'r');
				flag = flag || _move == Chess::create(from, from + front + 1, _group == 0 ? 'N' : 'n');
				flag = flag || _move == Chess::create(from, from + front + 1, _group == 0 ? 'B' : 'b');
			}
			else
			{
				flag = flag || _move == Chess::create(from, from + front + 1, 0);
			}
		}
		if (_state->has_piece(from + front - 1) && !Chess::is_same_group(from_piece, _state->get_piece(from + front - 1)) || ((from >> 4) == 3 || (from >> 4) == 4) && _state->get_en_passant() == from + front - 1)
		{
			if (on_end)
			{
				flag = flag || _move == Chess::create(from, from + front - 1, _group == 0 ? 'Q' : 'q');
				flag = flag || _move == Chess::create(from, from + front - 1, _group == 0 ? 'R' : 'r');
				flag = flag || _move == Chess::create(from, from + front - 1, _group == 0 ? 'N' : 'n');
				flag = flag || _move == Chess::create(from, from + front - 1, _group == 0 ? 'B' : 'b');
			}
			else
			{
				flag = flag || _move == Chess::create(from, from + front - 1, 0);
			}
		}
		if (!flag)
		{
			return false;
		}
		godot::Ref<State>test_state = _state->duplicate();
		apply_move(test_state, _move);
		return !is_check(test_state, 1 - _group);
	}
	else if ((from_piece & 95) == 'K' || (from_piece & 95) == 'Q')
	{
		directions = &directions_eight_way;
	}
	else if ((from_piece & 95) == 'R')
	{
		directions = &directions_straight;
	}
	else if ((from_piece & 95) == 'N')
	{
		directions = &directions_horse;
	}
	else if ((from_piece & 95) == 'B')
	{
		directions = &directions_diagonal;
	}
	if (!directions)	//这种情况下不可能有着法
	{
		return false;
	}
	for (int i = 0; i < directions->size(); i++)
	{
		int to = from + (*directions)[i];
		int to_piece = _state->get_piece(to);
		while (!(to & 0x88) && (!to_piece || !Chess::is_same_group(from_piece, to_piece)))
		{
			flag = flag || _move == Chess::create(from, to, 0);
			if (!(to & 0x88) && to_piece && !Chess::is_same_group(from_piece, to_piece))
			{
				break;
			}
			if ((from_piece & 95) == 'K' || (from_piece & 95) == 'N')
			{
				break;
			}
			to += (*directions)[i];
			to_piece = _state->get_piece(to);
			if (!(from_piece == 'R' && to_piece == 'K' || from_piece == 'r' && to_piece == 'k'))
			{
				continue;
			}
			if ((from & 15) >= 4 && (from_piece == 'R' && (_state->get_castle() & 8) || from_piece == 'r' && (_state->get_castle() & 2)))
			{
				flag = flag || _move == Chess::create(to, from_piece == 'R' ? Chess::g1() : Chess::g8(), 'K');
			}
			else if ((from & 15) <= 3 && (from_piece == 'R' && (_state->get_castle() & 4) || from_piece == 'r' && (_state->get_castle() & 1)))
			{
				flag = flag || _move == Chess::create(to,from_piece == 'R' ? Chess::c1() : Chess::c8(), 'Q');
			}
		}
	}

	if (!flag)
	{
		return false;
	}
	godot::Ref<State>test_state = _state->duplicate();
	apply_move(test_state, _move);
	return !is_check(test_state, 1 - _group);
}

bool RuleStandard::is_check(godot::Ref<State> _state, int _group)
{
	for (State::PieceIterator iter = _state->piece_iterator_begin(); !iter.end(); iter.next())
	{
		int _from = iter.pos();
		int from_piece = iter.piece();
		if (_group != Chess::group(from_piece))
		{
			continue;
		}
		godot::PackedInt32Array *directions = nullptr;
		if ((from_piece & 95) == 'P')
		{
			int front = from_piece == 'P' ? -16 : 16;
			bool on_start = (_from >> 4) == (from_piece == 'P' ? 6 : 1);
			bool on_end = (_from >> 4) == (from_piece == 'P' ? 1 : 6);
			if (is_enemy(_state, _from, _from + front + 1) && (_state->get_piece(_from + front + 1) & 95) == 'K'
			|| !((_from + front + 1) & 0x88) && on_end && _state->get_king_passant() != -1 && abs(_state->get_king_passant() - (_from + front + 1)) <= 1)
			{
				return true;
			}
			if (is_enemy(_state, _from, _from + front - 1) && (_state->get_piece(_from + front - 1) & 95) == 'K'
			|| !((_from + front - 1) & 0x88) && on_end && _state->get_king_passant() != -1 && abs(_state->get_king_passant() - (_from + front - 1)) <= 1)
			{
				return true;
			}
			continue;
		}
		else if ((from_piece & 95) == 'K' || (from_piece & 95) == 'Q')
		{
			directions = &directions_eight_way;
		}
		else if ((from_piece & 95) == 'R')
		{
			directions = &directions_straight;
		}
		else if ((from_piece & 95) == 'N')
		{
			directions = &directions_horse;
		}
		else if ((from_piece & 95) == 'B')
		{
			directions = &directions_diagonal;
		}
		if (!directions)
		{
			continue;
		}
		for (int i = 0; i < directions->size(); i++)
		{
			int to = _from;
			int to_piece = _state->get_piece(to);
			while (true)
			{
				to += (*directions)[i];
				if (to & 0x88)
				{
					break;
				}
				if (_state->get_king_passant() != -1 && abs(to - _state->get_king_passant()) <= 1 && (to >> 4) == _group * 7)
				{
					return true;
				}
				to_piece = _state->get_piece(to);
				if (to_piece && (to_piece & 95) != 'W')
				{
					if (!Chess::is_same_group(from_piece, to_piece) && (to_piece & 95) == 'K')
					{
						return true;
					}
					break;
				}
				if ((from_piece & 95) == 'K' || (from_piece & 95) == 'N')
				{
					break;
				}
			}
		}
	}
	return false;
}

bool RuleStandard::is_blocked(godot::Ref<State> _state, int _from, int _to)
{
	if (_to & 0x88)
	{
		return true;
	}
	int from_piece = _state->get_piece(_from);
	int from_group = Chess::group(from_piece);
	if ((_state->get_piece(_to) & 95) == 'W' || (_state->get_piece(_to) & 95) == 'X')
	{
		return false;
	}
	if (_state->has_piece(_to) && Chess::is_same_group(from_piece, _state->get_piece(_to)))
	{
		return true;
	}
	if ((_state->get_piece(_to) & 95) == 'Y')
	{
		return true;
	}
	if (_state->get_bit('#') & Chess::mask(Chess::to_64(_to)))
	{
		return true;
	}
	return false;
}

bool RuleStandard::is_enemy(godot::Ref<State> _state, int _from, int _to)
{
	return _state->has_piece(_to) && (_state->get_piece(_to) & 95) != 'W' && (!Chess::is_same_group(_state->get_piece(_from), _state->get_piece(_to)) || (_state->get_piece(_to) & 95) == 'X');
}

bool RuleStandard::is_en_passant(godot::Ref<State> _state, int _from, int _to)
{
	return ((_from >> 4) == 3 || (_from >> 4) == 4) && _state->get_en_passant() == _to;
}

godot::PackedInt32Array RuleStandard::generate_premove(godot::Ref<State> _state, int _group)
{
	godot::PackedInt32Array output;
	for (State::PieceIterator iter = _state->piece_iterator_begin(); !iter.end(); iter.next())
	{
		int _from = iter.pos();
		int from_piece = iter.piece();
		if (_group != Chess::group(from_piece))
		{
			continue;
		}
		godot::PackedInt32Array *directions = nullptr;
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
			directions = &directions_eight_way;
		}
		else if ((from_piece & 95) == 'R')
		{
			directions = &directions_straight;
		}
		else if ((from_piece & 95) == 'N')
		{
			directions = &directions_horse;
		}
		else if ((from_piece & 95) == 'B')
		{
			directions = &directions_diagonal;
		}
		if (!directions)
		{
			continue;
		}
		for (int i = 0; i < directions->size(); i++)
		{
			int to = _from + (*directions)[i];
			while (!(to & 0x88))
			{
				output.push_back(Chess::create(_from, to, 0));
				if ((from_piece & 95) == 'K' || (from_piece & 95) == 'N')
				{
					break;
				}
				to += (*directions)[i];
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

godot::PackedInt32Array RuleStandard::generate_move(godot::Ref<State> _state, int _group)
{
	godot::PackedInt32Array output;
	for (State::PieceIterator iter = _state->piece_iterator_begin(); !iter.end(); iter.next())
	{
		int _from = iter.pos();
		int from_piece = iter.piece();
		if (_group != Chess::group(from_piece))
		{
			continue;
		}
		godot::PackedInt32Array *directions = nullptr;
		if ((from_piece & 95) == 'P')
		{
			int front = from_piece == 'P' ? -16 : 16;
			bool on_start = (_from >> 4) == (from_piece == 'P' ? 6 : 1);
			bool on_end = (_from >> 4) == (from_piece == 'P' ? 1 : 6);
			int to_1 = _from + front;
			int to_2 = _from + front + 1;
			int to_3 = _from + front - 1;
			bool on_low = _state->get_bit('v') & Chess::mask(Chess::to_64(_from));
			
			if (!is_blocked(_state, _from, to_1) && !is_enemy(_state, _from, to_1))
			{
				if (on_end)
				{
					output.push_back(Chess::create(_from, to_1, _group == 0 ? 'Q' : 'q'));
					output.push_back(Chess::create(_from, to_1, _group == 0 ? 'R' : 'r'));
					output.push_back(Chess::create(_from, to_1, _group == 0 ? 'N' : 'n'));
					output.push_back(Chess::create(_from, to_1, _group == 0 ? 'B' : 'b'));
				}
				else
				{
					output.push_back(Chess::create(_from, to_1, 0));
					if (!_state->has_piece(to_1 + front) && on_start)
					{
						output.push_back(Chess::create(_from, to_1 + front, 0));
					}
				}
			}
			if (!is_blocked(_state, _from, to_2) && (is_enemy(_state, _from, to_2) || is_en_passant(_state, _from, to_2)))
			{
				if (on_end)
				{
					output.push_back(Chess::create(_from, to_2, _group == 0 ? 'Q' : 'q'));
					output.push_back(Chess::create(_from, to_2, _group == 0 ? 'R' : 'r'));
					output.push_back(Chess::create(_from, to_2, _group == 0 ? 'N' : 'n'));
					output.push_back(Chess::create(_from, to_2, _group == 0 ? 'B' : 'b'));
				}
				else
				{
					output.push_back(Chess::create(_from, to_2, 0));
				}
			}
			if (!is_blocked(_state, _from, to_3) && (is_enemy(_state, _from, to_3) || is_en_passant(_state, _from, to_3)))
			{
				if (on_end)
				{
					output.push_back(Chess::create(_from, to_3, _group == 0 ? 'Q' : 'q'));
					output.push_back(Chess::create(_from, to_3, _group == 0 ? 'R' : 'r'));
					output.push_back(Chess::create(_from, to_3, _group == 0 ? 'N' : 'n'));
					output.push_back(Chess::create(_from, to_3, _group == 0 ? 'B' : 'b'));
				}
				else
				{
					output.push_back(Chess::create(_from, to_3, 0));
				}
			}
			continue;
		}
		else if ((from_piece & 95) == 'K' || (from_piece & 95) == 'Q')
		{
			directions = &directions_eight_way;
		}
		else if ((from_piece & 95) == 'R')
		{
			directions = &directions_straight;
		}
		else if ((from_piece & 95) == 'N')
		{
			directions = &directions_horse;
		}
		else if ((from_piece & 95) == 'B')
		{
			directions = &directions_diagonal;
		}
		if (!directions)
		{
			continue;
		}
		for (int i = 0; i < directions->size(); i++)
		{
			int to = _from;
			int to_piece = _state->get_piece(to);
			while (true)
			{
				to += (*directions)[i];
				if (to & 0x88)
				{
					break;
				}
				to_piece = _state->get_piece(to);
				if ((to_piece & 95) == 'Y')
				{
					break;
				}
				if (is_blocked(_state, _from, to))
				{
					if ((from_piece & 95) == 'R' && (to_piece & 95) == 'K')
					{
						if ((_from & 15) >= 4 && (_group == 0 && (_state->get_castle() & 8) || _group == 1 && (_state->get_castle() & 2)))
						{
							output.push_back(Chess::create(to, _group == 0 ? Chess::g1() : Chess::g8(), 'K'));
						}
						else if ((_from & 15) <= 3 && (_group == 0 && (_state->get_castle() & 4) || _group == 1 && (_state->get_castle() & 1)))
						{
							output.push_back(Chess::create(to,_group == 0 ? Chess::c1() : Chess::c8(), 'Q'));
						}
					}
					break;
				}
				output.push_back(Chess::create(_from, to, 0));
				if ((from_piece & 95) == 'K' || (from_piece & 95) == 'N' || to_piece && (to_piece & 95) != 'W')
				{
					break;
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
		godot::Ref<State>test_state = _state->duplicate();
		apply_move(test_state, move_list[i]);
		if (!is_check(test_state, 1 - _group))
		{
			output.push_back(move_list[i]);
		}
	}
	return output;
}

godot::PackedInt32Array RuleStandard::generate_explore_move(godot::Ref<State> _state, int _group)
{
	godot::PackedInt32Array move_list = generate_valid_move(_state, _group);
	if (_state->get_bit(_group == 0 ? 'K' : 'k'))
	{
		uint64_t from_bit = _state->get_bit(_group == 0 ? 'K' : 'k');
		int from = 0;
		while (from_bit != 1 && from_bit != 0)
		{
			from_bit >>= 1;
			from += 1;
		}
		from = from % 8 + from / 8 * 16;
		godot::PackedInt32Array king_move;

		std::queue<int> q;
		std::unordered_set<int> closed;
		godot::PackedInt32Array *direction = &directions_eight_way;
		closed.insert(from);
		q.push(from);
		while (!q.empty())
		{
			int cur = q.front();
			q.pop();
			for (int i = 0; i < direction->size(); i++)
			{
				int next = cur + (*direction)[i];
				int move = Chess::create(from, next, 0);
				if (!closed.count(next) && !is_blocked(_state, cur, next) && !is_enemy(_state, cur, next))
				{
					godot::Ref<State>test_state = _state->duplicate();
					apply_move(test_state, move);
					if (!is_check(test_state, 1 - _group))
					{
						if (!move_list.has(move))
						{
							king_move.push_back(move);
						}
						q.push(next);
					}
				}
				closed.insert(next);
			}
		}
		move_list.append_array(king_move);
	}
	return move_list;
}

godot::PackedInt32Array	RuleStandard::generate_king_path(godot::Ref<State> _state, int _from, int _to)
{
	std::vector<std::pair<int, godot::PackedInt32Array>> dp(64, std::make_pair(0x7FFFFFFF, godot::PackedInt32Array()));
	std::vector<bool> shortest(64, false);
	dp[Chess::to_64(_from)].first = 0;
	godot::PackedInt32Array *direction = &directions_eight_way;
	for (int i = 0; i < 64; i++)
	{
		int min_node = 0;
		int min_step = 0x7FFFFFFF;
		for (int j = 0; j < 64; j++)
		{
			if (dp[j].first < min_step && !shortest[j])
			{
				min_node = j;
				min_step = dp[j].first;
			}
		}
		shortest[min_node] = true;
		for (int j = 0; j < direction->size(); j++)
		{
			bool is_diagonal = abs((*direction)[j]) != 1 && abs((*direction)[j]) != 16;
			int step = is_diagonal ? 11 : 10;
			int next_x88 = Chess::to_x88(min_node) + (*direction)[j];

			if ((next_x88 & 0x88) || is_blocked(_state, Chess::to_x88(min_node), next_x88) || is_enemy(_state, Chess::to_x88(min_node), next_x88))
			{
				continue;
			}
			godot::Ref<State>test_state = _state->duplicate();
			apply_move(test_state, Chess::create(Chess::to_x88(min_node), next_x88, 0));
			if (is_check(test_state, 1 - Chess::group(_state->get_piece(_from))))
			{
				continue;
			}
			int next = Chess::to_64(next_x88);
			if (!shortest[next])
			{
				if (min_step + step < dp[next].first)
				{
					dp[next].first = min_step + step;
					dp[next].second = dp[min_node].second.duplicate();
					dp[next].second.push_back(Chess::to_x88(next));
				}
			}
		}
	}
	return dp[Chess::to_64(_to)].second;
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
	int from = Chess::from(_move);
	int from_piece = _state->get_piece(from);
	int from_group = Chess::group(from_piece);
	int to = Chess::to(_move);
	int to_piece = _state->get_piece(to);
	bool dont_move = false;
	bool has_grafting = false;
	bool has_en_passant = false;
	bool has_king_passant = false;
	if (to_piece)	//在apply_move阶段其实就默许了吃同阵营棋子的情况。
	{
		_state->capture_piece(to);
		_state->set_step_to_draw(0);	// 吃子时重置50步和棋
	}
	if ((to_piece & 95) == 'W')
	{
		has_grafting = true;
	}
	if (_state->get_king_passant() != -1 && abs(_state->get_king_passant() - to) <= 1)
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
		if ((from & 15) >= 4)
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
		else if ((from & 15) <= 3)
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
			if (to == Chess::g1())
			{
				_state->move_piece(Chess::h1(), Chess::f1());
				_state->set_king_passant(Chess::f1());
			}
			if (to == Chess::c1())
			{
				_state->move_piece(Chess::a1(), Chess::d1());
				_state->set_king_passant(Chess::d1());
			}
			if (to == Chess::g8())
			{
				_state->move_piece(Chess::h8(), Chess::f8());
				_state->set_king_passant(Chess::f8());
			}
			if (to == Chess::c8())
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
		if (to - from == front * 2)
		{
			has_en_passant = true;
			_state->set_en_passant(from + front);
		}
		if (((from >> 4) == 3 || (from >> 4) == 4) && to == _state->get_en_passant())
		{
			int captured = to - front;
			_state->capture_piece(captured);
		}
		if (Chess::extra(_move))
		{
			dont_move = true;
			_state->capture_piece(from);
			_state->add_piece(to, Chess::extra(_move));
		}
	}
	if (!dont_move)
	{
		_state->move_piece(from, to);
	}
	if (has_grafting)
	{
		_state->add_piece(from, to_piece);
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


godot::Dictionary RuleStandard::apply_move_custom(godot::Ref<State> _state, int _move)
{
	godot::Dictionary output;
	int from = Chess::from(_move);
	int from_piece = _state->get_piece(from);
	int from_group = Chess::group(from_piece);
	int to = Chess::to(_move);
	int to_piece = _state->get_piece(to);
	if ((to_piece & 95) == 'W')
	{
		output["type"] = "grafting";
		output["from"] = from;
		output["to"] = to;
		return output;	//移花接木机制有特殊动作
	}
	if (to_piece)
	{
		output["type"] = "capture";
		output["from"] = from;
		output["to"] = to;
		return output;	//双方共同进行演出
	}
	if ((from_piece & 95) == 'K')
	{
		if (Chess::extra(_move))
		{
			if (to == Chess::g1())
			{
				output["type"] = "castle";
				output["from_king"] = Chess::e1();
				output["to_king"] = Chess::g1();
				output["from_rook"] = Chess::h1();
				output["to_rook"] = Chess::f1();
				return output; //王车易位，王和车分开进行
			}
			if (to == Chess::c1())
			{
				output["type"] = "castle";
				output["from_king"] = Chess::e1();
				output["to_king"] = Chess::c1();
				output["from_rook"] = Chess::a1();
				output["to_rook"] = Chess::d1();
				return output;
			}
			if (to == Chess::g8())
			{
				output["type"] = "castle";
				output["from_king"] = Chess::e8();
				output["to_king"] = Chess::g8();
				output["from_rook"] = Chess::h8();
				output["to_rook"] = Chess::f8();
				return output;
			}
			if (to == Chess::c8())
			{
				output["type"] = "castle";
				output["from_king"] = Chess::e8();
				output["to_king"] = Chess::c8();
				output["from_rook"] = Chess::a8();
				output["to_rook"] = Chess::d8();
				return output;
			}
		}
		if (to % 16 < from % 16 - 1 || to % 16 > from % 16 + 1 || to / 16 < from / 16 - 1 || to / 16 > from / 16 + 1)
		{
			output["type"] = "king_explore";
			output["from"] = from;
			output["path"] = generate_king_path(_state, from, to);
			return output;
		}
	}
	if ((from_piece & 95) == 'P')
	{
		int front = from_piece == 'P' ? -16 : 16;
		if (((from >> 4) == 3 || (from >> 4) == 4) && to == _state->get_en_passant())
		{
			int captured = to - front;
			output["type"] = "en_passant";
			output["from"] = from;
			output["to"] = to;
			output["captured"] = captured;
			return output;
		}
		if (Chess::extra(_move))
		{
			output["type"] = "promotion";
			output["from"] = from;
			output["to"] = to;
			output["piece"] = Chess::extra(_move);
			return output;
		}
	}
	output["type"] = "move";
	output["from"] = from;
	output["to"] = to;
	return output;
}

uint64_t RuleStandard::perft(godot::Ref<State> _state, int _depth, int group)
{
	if (_depth == 0)
	{
		return 1ULL;
	}
	godot::PackedInt32Array move_list = generate_valid_move(_state, group);
	uint64_t cnt = 0;
	if (_depth == 1)
	{
		return move_list.size();
	}
	for (int i = 0; i < move_list.size(); i++)
	{
		godot::Ref<State> test_state = _state->duplicate();
		apply_move(test_state, move_list[i]);
		cnt += perft(test_state, _depth - 1, 1 - group);
	}
	return cnt;
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
	godot::ClassDB::bind_method(godot::D_METHOD("create_initial_state"), &RuleStandard::create_initial_state);
	godot::ClassDB::bind_method(godot::D_METHOD("create_random_state"), &RuleStandard::create_random_state);
	godot::ClassDB::bind_method(godot::D_METHOD("mirror_state"), &RuleStandard::mirror_state);
	godot::ClassDB::bind_method(godot::D_METHOD("rotate_state"), &RuleStandard::rotate_state);
	godot::ClassDB::bind_method(godot::D_METHOD("swap_group"), &RuleStandard::swap_group);
	godot::ClassDB::bind_method(godot::D_METHOD("stringify"), &RuleStandard::stringify);
	godot::ClassDB::bind_method(godot::D_METHOD("is_check"), &RuleStandard::is_check);
	godot::ClassDB::bind_method(godot::D_METHOD("is_move_valid"), &RuleStandard::is_move_valid);
	godot::ClassDB::bind_method(godot::D_METHOD("generate_premove"), &RuleStandard::generate_premove);
	godot::ClassDB::bind_method(godot::D_METHOD("generate_move"), &RuleStandard::generate_move);
	godot::ClassDB::bind_method(godot::D_METHOD("generate_valid_move"), &RuleStandard::generate_valid_move);
	godot::ClassDB::bind_method(godot::D_METHOD("generate_explore_move"), &RuleStandard::generate_explore_move);
	godot::ClassDB::bind_method(godot::D_METHOD("generate_king_path"), &RuleStandard::generate_king_path);
	godot::ClassDB::bind_method(godot::D_METHOD("get_move_name"), &RuleStandard::get_move_name);
	godot::ClassDB::bind_method(godot::D_METHOD("name_to_move"), &RuleStandard::name_to_move);
	godot::ClassDB::bind_method(godot::D_METHOD("apply_move"), &RuleStandard::apply_move); 
	godot::ClassDB::bind_method(godot::D_METHOD("apply_move_custom"), &RuleStandard::apply_move_custom);
	godot::ClassDB::bind_method(godot::D_METHOD("perft"), &RuleStandard::perft);
}
