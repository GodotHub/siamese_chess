#include "rule_standard.hpp"
#include <godot_cpp/classes/resource_loader.hpp>
#include <godot_cpp/classes/packed_scene.hpp>
#include "state.hpp"
#include "chess.hpp"
#include "transposition_table.hpp"

RuleStandard::RuleStandard()
{
	WIN = 50000;
	THRESHOLD = 20000;

	piece_value = {
		{'K', 60000},
		{'Q', 929},
		{'R', 479},
		{'B', 320},
		{'N', 280},
		{'P', 100},
		{'k', -60000},
		{'q', -929},
		{'r', -479},
		{'b', -320},
		{'n', -280},
		{'p', -100}
	};
	directions_diagonal = {-17, -15, 15, 17};
	directions_straight = {-16, -1, 1, 16};
	directions_eight_way = {-17, -16, -15, -1, 1, 15, 16, 17};
	directions_horse = {33, 31, 18, 14, -33, -31, -18, -14};
	position_value = {
		{'K', {
		4,  54,  47, -99, -99,  60,  83, -62,
		-32,  10,  55,  56,  56,  55,  10,   3,
		-62,  12, -57,  44, -67,  28,  37, -31,
		-55,  50,  11,  -4, -19,  13,   0, -49,
		-55, -43, -52, -28, -51, -47,  -8, -50,
		-47, -42, -43, -79, -64, -32, -29, -32,
		-4,   3, -14, -50, -57, -18,  13,   4,
		17,  30,  -3, -14,   6,  -1,  40,  18
		}},
		{'Q', {
		6,   1,  -8,-104,  69,  24,  88,  26,
		14,  32,  60, -10,  20,  76,  57,  24,
		-2,  43,  32,  60,  72,  63,  43,   2,
		1, -16,  22,  17,  25,  20, -13,  -6,
		-14, -15,  -2,  -5,  -1, -10, -20, -22,
		-30,  -6, -13, -11, -16, -11, -16, -27,
		-36, -18,   0, -19, -15, -15, -21, -38,
		-39, -30, -31, -13, -31, -36, -34, -42
		}},
		{'R', {
		35,  29,  33,   4,  37,  33,  56,  50,
		55,  29,  56,  67,  55,  62,  34,  60,
		19,  35,  28,  33,  45,  27,  25,  15,
		0,   5,  16,  13,  18,  -4,  -9,  -6,
		-28, -35, -16, -21, -13, -29, -46, -30,
		-42, -28, -42, -25, -25, -35, -26, -46,
		-53, -38, -31, -26, -29, -43, -44, -53,
		-30, -24, -18,   5,  -2, -18, -31, -32
		}},
		{'B', {
		-59, -78, -82, -76, -23,-107, -37, -50,
		-11,  20,  35, -42, -39,  31,   2, -22,
		-9,  39, -32,  41,  52, -10,  28, -14,
		25,  17,  20,  34,  26,  25,  15,  10,
		13,  10,  17,  23,  17,  16,   0,   7,
		14,  25,  24,  15,   8,  25,  20,  15,
		19,  20,  11,   6,   7,   6,  20,  16,
		-7,   2, -15, -12, -14, -15, -10, -10
		}},
		{'N', {
		-66, -53, -75, -75, -10, -55, -58, -70,
		-3,  -6, 100, -36,   4,  62,  -4, -14,
		10,  67,   1,  74,  73,  27,  62,  -2,
		24,  24,  45,  37,  33,  41,  25,  17,
		-1,   5,  31,  21,  22,  35,   2,   0,
		-18,  10,  13,  22,  18,  15,  11, -14,
		-23, -15,   2,   0,   2,   0, -23, -20,
		-74, -23, -26, -24, -19, -35, -22, -69
		}},
		{'P', {
		0,   0,   0,   0,   0,   0,   0,   0,
		78,  83,  86,  73, 102,  82,  85,  90,
		7,  29,  21,  44,  40,  31,  44,   7,
		-17,  16,  -2,  15,  14,   0,  15, -13,
		-26,   3,  10,   9,   6,   1,   0, -23,
		-22,   9,   5, -11, -10,  -2,   3, -19,
		-31,   8,  -7, -37, -36, -14,   3, -31,
		0,   0,   0,   0,   0,   0,   0,   0
		}},
		{'k', {
		17, -30,   3,  14,  -6,   1, -40, -18,
		4,  -3,  14,  50,  57,  18, -13,  -4,
		47,  42,  43,  79,  64,  32,  29,  32,
		55,  43,  52,  28,  51,  47,   8,  50,
		55, -50, -11,   4,  19, -13,   0,  49,
		62, -12,  57, -44,  67, -28, -37,  31,
		32, -10, -55, -56, -56, -55, -10,  -3,
		-4, -54, -47,  99,  99, -60, -83,  62,
		}},
		{'q', {
		39,  30,  31,  13,  31,  36,  34,  42,
		36,  18,   0,  19,  15,  15,  21,  38,
		30,   6,  13,  11,  16,  11,  16,  27,
		14,  15,   2,   5,   1,  10,  20,  22,
		-1,  16, -22, -17, -25, -20,  13,   6,
		2, -43, -32, -60, -72, -63, -43,  -2,
		-14, -32, -60,  10, -20, -76, -57, -24,
		-6,  -1,   8, 104, -69, -24, -88, -26
		}},
		{'r', {
		30,  24,  18,  -5,   2,  18,  31,  32,
		53,  38,  31,  26,  29,  43,  44,  53,
		42,  28,  42,  25,  25,  35,  26,  46,
		28,  35,  16,  21,  13,  29,  46,  30,
		0,  -5, -16, -13, -18,   4,   9,   6,
		-19, -35, -28, -33, -45, -27, -25, -15,
		-55, -29, -56, -67, -55, -62, -34, -60,
		-35, -29, -33,  -4, -37, -33, -56, -50,
		}},
		{'b', {
		7,  -2,  15,  12,  14,  15,  10,  10,
		-19, -20, -11,  -6,  -7,  -6, -20, -16,
		-14, -25, -24, -15,  -8, -25, -20, -15,
		-13, -10, -17, -23, -17, -16,   0,  -7,
		-25, -17, -20, -34, -26, -25, -15, -10,
		9, -39,  32, -41, -52,  10, -28,  14,
		11, -20, -35,  42,  39, -31,  -2,  22,
		59,  78,  82,  76,  23, 107,  37,  50,
		}},
		{'n', {
		74,  23,  26,  24,  19,  35,  22,  69,
		23,  15,  -2,   0,  -2,   0,  23,  20,
		18, -10, -13, -22, -18, -15, -11,  14,
		1,  -5, -31, -21, -22, -35,  -2,   0,
		-24, -24, -45, -37, -33, -41, -25, -17,
		-10, -67,  -1, -74, -73, -27, -62,   2,
		3,   6,-100,  36,  -4, -62,   4,  14,
		66,  53,  75,  75,  10,  55,  58,  70,
		}},
		{'p', {
		0,   0,   0,   0,   0,   0,   0,   0,
		31,  -8,   7,  37,  36,  14,  -3,  31,
		22,  -9,  -5,  11,  10,   2,  -3,  19,
		26,  -3, -10,  -9,  -6,  -1,   0,  23,
		17, -16,   2, -15, -14,   0, -15,  13,
		-7, -29, -21, -44, -40, -31, -44,  -7,
		-78, -83, -86, -73,-102, -82, -85, -90,
		0,   0,   0,   0,   0,   0,   0,   0,
		}}
	};

	piece_mapping_instance = {
		{'K', "res://scene/piece_king.tscn"},
		{'Q', "res://scene/piece_queen.tscn"},
		{'R', "res://scene/piece_rook.tscn"},
		{'N', "res://scene/piece_knight.tscn"},
		{'B', "res://scene/piece_bishop.tscn"},
		{'P', "res://scene/piece_pawn.tscn"},
		{'k', "res://scene/piece_king.tscn"},
		{'q', "res://scene/piece_queen.tscn"},
		{'r', "res://scene/piece_rook.tscn"},
		{'n', "res://scene/piece_knight.tscn"},
		{'b', "res://scene/piece_bishop.tscn"},
		{'p', "res://scene/piece_pawn.tscn"},
	};

	piece_mapping_group = {
		{'K', 1},
		{'Q', 1},
		{'R', 1},
		{'N', 1},
		{'B', 1},
		{'P', 1},
		{'k', -1},
		{'q', -1},
		{'r', -1},
		{'n', -1},
		{'b', -1},
		{'p', -1},
	};
}

godot::String RuleStandard::get_end_type(godot::Ref<State>_state)
{
	int group = _state->get_extra(0);
	godot::PackedInt32Array move_list = generate_valid_move(_state, group);
	if (!move_list.size())
	{
		int null_move_check = quies(_state, -WIN, WIN, 1 - group);
		if (abs(null_move_check) >= 500)
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
	if (_state->get_extra(3) == 50)
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
	state->reserve_extra(6);
	state->set_extra(0, fen_splited[1] == "w" ? 0 : 1);
	state->set_extra(1, (int(fen_splited[2].contains("K")) << 3) + (int(fen_splited[2].contains("Q")) << 2) + (int(fen_splited[2].contains("k")) << 1) + int(fen_splited[2].contains("q")));
	state->set_extra(2, Chess::to_position_int(fen_splited[3]));
	state->set_extra(3, fen_splited[4].to_int());
	state->set_extra(4, fen_splited[5].to_int());
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
	output.push_back(_state->get_extra(0) == 0 ? "w" : "b");
	output.push_back("");
	output[2] += (_state->get_extra(1) & 8) ? "K" : "";
	output[2] += (_state->get_extra(1) & 4) ? "Q" : "";
	output[2] += (_state->get_extra(1) & 2) ? "k" : "";
	output[2] += (_state->get_extra(1) & 1) ? "q" : "";
	if (!output[2])
	{
		output[2] = "-";
	}
	output.push_back(_state->get_extra(2) ? Chess::to_position_name(_state->get_extra(2)) : "-");
	output.push_back(godot::String::num(_state->get_extra(3), 0));
	output.push_back(godot::String::num(_state->get_extra(4), 0));
	// king_passant是为了判定是否违规走子，临时记录的，这里不做转换
	return godot::String(" ").join(output);
}

godot::Node3D *RuleStandard::get_piece_instance(int _piece)
{
	godot::Ref<godot::PackedScene> packed_scene = godot::ResourceLoader::get_singleton()->load(piece_mapping_instance[_piece]);
	godot::Node3D *instance = godot::Object::cast_to<godot::Node3D>(packed_scene->instantiate());
	//instance->group = piece_mapping_group[_piece]
	return instance;
}

bool RuleStandard::is_same_camp(int a, int b)
{
	return (a >= 'A' && a <= 'Z') == (b >= 'A' && b <= 'Z');
}

int RuleStandard::get_piece_score(int _by, int _piece)
{
	godot::Vector2i piece_position = godot::Vector2i(_by % 16, _by / 16);
	if (piece_value.count(_piece))
	{
		return position_value[_piece][piece_position.x + piece_position.y * 8] + piece_value[_piece];
	}
	return 0;
}

bool RuleStandard::is_move_valid(godot::Ref<State>_state, int _group, int _move)
{
	int from = Chess::from(_move);
	int from_piece = _state->get_piece(from);
	if (!from_piece || (_group == 0) != (from_piece >= 65 && from_piece <= 90))
	{
		return false;
	}
	godot::Ref<State>test_state = _state->duplicate();
	apply_move(test_state, _move);
	godot::PackedInt32Array move_list = generate_good_capture_move(test_state, 1 - _group);
	for (int i = 0; i < move_list.size(); i++)
	{
		int valid_check = evaluate(test_state, move_list[i]);
		if (abs(valid_check) >= THRESHOLD)
		{
			return false;
		}
	}
	return true;
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
			if ((_group == 0) != (from_piece >= 'A' && from_piece <= 'Z'))
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
	if (_group == 0 && _state->get_extra(1) & 8 && !_state->has_piece(Chess::g1()) && !_state->has_piece(Chess::f1()))
	{
		output.push_back(Chess::create(Chess::e1(), Chess::g1(), 75));
	}
	if (_group == 0 && _state->get_extra(1) & 4 && !_state->has_piece(Chess::c1()) && !_state->has_piece(Chess::d1()))
	{
		output.push_back(Chess::create(Chess::e1(), Chess::c1(), 81));
	}
	if (_group == 1 && _state->get_extra(1) & 2 && !_state->has_piece(Chess::g8()) && !_state->has_piece(Chess::f8()))
	{
		output.push_back(Chess::create(Chess::e8(), Chess::g8(), 75));
	}
	if (_group == 1 && _state->get_extra(1) & 1 && !_state->has_piece(Chess::c8()) && !_state->has_piece(Chess::d8()))
	{
		output.push_back(Chess::create(Chess::e8(), Chess::c8(), 81));
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
			if ((_group == 0) != (from_piece >= 'A' && from_piece <= 'Z'))
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
				if (_state->has_piece(_from + front + 1) && !is_same_camp(from_piece, _state->get_piece(_from + front + 1)) || ((_from >> 4) == 2 || (_from >> 4) == 5) && _state->get_extra(2) == _from + front + 1)
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
				if (_state->has_piece(_from + front - 1) && !is_same_camp(from_piece, _state->get_piece(_from + front - 1)) || ((_from >> 4) == 2 || (_from >> 4) == 5) && _state->get_extra(2) == _from + front - 1)
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
				while (!(to & 0x88) && (!to_piece || !is_same_camp(from_piece, to_piece)))
				{
					output.push_back(Chess::create(_from, to, 0));
					if (!(to & 0x88) && to_piece && !is_same_camp(from_piece, to_piece))
					{
						break;
					}
					if ((from_piece & 95) == 'K' || (from_piece & 95) == 'N')
					{
						break;
					}
					to += directions[i];
					to_piece = _state->get_piece(to);
					if (!(from_piece == 82 && to_piece == 'K' || from_piece == 114 && to_piece == 107))
					{
						continue;
					}
					if (_from & 15 >= 4 && (from_piece == 82 && _state->get_extra(1) & 8 || from_piece == 114 && _state->get_extra(1) & 2))
					{
						output.push_back(Chess::create(to, from_piece == 'R' ? Chess::g1() : Chess::g8(), 'K'));
					}
					else if (_from & 15 <= 3 && (from_piece == 82 && _state->get_extra(1) & 4 || from_piece == 114 && _state->get_extra(1) & 2))
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

godot::PackedInt32Array RuleStandard::generate_good_capture_move(godot::Ref<State>_state, int _group)
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
			if ((_group == 0) != (from_piece >= 'A' && from_piece <= 'Z'))
			{
				continue;
			}
			godot::PackedInt32Array directions;
			if ((from_piece & 95) == 'P')
			{
				int front = from_piece == 'P' ? -16 : 16;
				bool on_start = (_from >> 4) == (from_piece == 'P' ? 6 : 1);
				bool on_end = (_from >> 4) == (from_piece == 'P' ? 1 : 6);
				if (_state->has_piece(_from + front + 1) && !is_same_camp(from_piece, _state->get_piece(_from + front + 1))
				|| ((_from >> 4) == 2 || (_from >> 4) == 5) && _state->get_extra(2) == _from + front + 1
				|| !((_from + front + 1) & 0x88) && on_end && _state->get_extra(5) != -1 && abs(_state->get_extra(5) - (_from + front + 1)) <= 1)
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
				if (_state->has_piece(_from + front - 1) && !is_same_camp(from_piece, _state->get_piece(_from + front - 1))
				|| ((_from >> 4) == 2 || (_from >> 4) == 5) && _state->get_extra(2) == _from + front - 1
				|| !((_from + front - 1) & 0x88) && on_end && _state->get_extra(5) != -1 && abs(_state->get_extra(5) - (_from + front - 1)) <= 1)
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
				while (!(to & 0x88) && (!to_piece || !is_same_camp(from_piece, to_piece)))
				{
					if (!(to & 0x88) && to_piece && !is_same_camp(from_piece, to_piece) || _state->get_extra(5) != -1 && abs(to - _state->get_extra(5)) <= 1)
					{
						output.push_back(Chess::create(_from, to, 0));
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
	return output;
}

void RuleStandard::apply_move(godot::Ref<State>_state, int _move)
{
	_state->push_history(_state->get_zobrist());	// 上一步的局面
	_state->change_score(evaluate(_state, _move));
	if (_state->get_extra(0) == 1)
	{
		_state->set_extra(4, _state->get_extra(4) + 1);
		_state->set_extra(0, 0);
	}
	else if (_state->get_extra(0) == 0)
	{
		_state->set_extra(0, 1);
	}
	_state->set_extra(3, _state->get_extra(3) + 1);
	int from_piece = _state->get_piece(Chess::from(_move));
	int from_group = from_piece >= 'A' && from_piece <= 'Z' ? 0 : 1;
	int to_piece = _state->get_piece(Chess::to(_move));
	bool dont_move = false;
	bool has_en_passant = false;
	bool has_king_passant = false;
	if (to_piece)
	{
		_state->capture_piece(Chess::to(_move));
		_state->set_extra(3, 0);	// 吃子时重置50步和棋
	}
	if (abs(_state->get_extra(5) - Chess::to(_move)) <= 1)
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
		if (Chess::from(_move) & 15 >= 4)
		{
			if (from_group == 0)
			{
				_state->set_extra(1, _state->get_extra(1) & 7);
			}
			else
			{
				_state->set_extra(1, _state->get_extra(1) & 13);
			}
		}
		else if (Chess::from(_move) & 15 <= 3)
		{
			if (from_group == 0)
			{
				_state->set_extra(1, _state->get_extra(1) & 11);
			}
			else
			{
				_state->set_extra(1, _state->get_extra(1) & 14);
			}
		}
	}
	if ((from_piece & 95) == 75)
	{
		if (from_group == 0)
		{
			_state->set_extra(1, _state->get_extra(1) & 3);
		}
		else
		{
			_state->set_extra(1, _state->get_extra(1) & 12);
		}
		if (Chess::extra(_move))
		{
			if (Chess::to(_move) == Chess::g1())
			{
				_state->move_piece(Chess::h1(), Chess::f1());
				_state->set_extra(5, Chess::f1());
			}
			if (Chess::to(_move) == Chess::c1())
			{
				_state->move_piece(Chess::a1(), Chess::d1());
				_state->set_extra(5, Chess::d1());
			}
			if (Chess::to(_move) == Chess::g8())
			{
				_state->move_piece(Chess::h8(), Chess::f8());
				_state->set_extra(5, Chess::f8());
			}
			if (Chess::to(_move) == Chess::c8())
			{
				_state->move_piece(Chess::a8(), Chess::d8());
				_state->set_extra(5, Chess::d8());
			}
			has_king_passant = true;
		}
	}
	if ((from_piece & 95) == 'P')
	{
		int front = from_piece == 'P' ? -16 : 16;
		_state->set_extra(3, 0);	// 移动兵时重置50步和棋
		if (Chess::to(_move) - Chess::from(_move) == front * 2)
		{
			has_en_passant = true;
			_state->set_extra(2, Chess::from(_move) + front);
		}
		if (((Chess::from(_move) >> 4) == 2 || (Chess::from(_move) >> 4) == 5) && Chess::to(_move) == _state->get_extra(2))
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
		_state->move_piece(Chess::from(_move), Chess::to(_move));

	if (!has_en_passant)
		_state->set_extra(2, -1);
	if (!has_king_passant)
		_state->set_extra(5, -1);
}

int RuleStandard::evaluate(godot::Ref<State>_state, int _move)
{
	int from = Chess::from(_move);
	int from_piece = _state->get_piece(from);
	int to = Chess::to(_move);
	int to_piece = _state->get_piece(to);
	int extra = Chess::extra(_move);
	int group = from >= 'A' && from <= 'Z' ? 0 : 1;
	int score = get_piece_score(to, from_piece) - get_piece_score(from, from_piece);
	if (to_piece && !is_same_camp(from_piece, to_piece))
	{
		score -= get_piece_score(to, to_piece);
	}
	if (_state->get_extra(5) != -1 && abs(_state->get_extra(5) - Chess::to(_move)) <= 1)
	{
		score -= piece_value[group == 0 ? 'k' : 'K'];
	}
	if (from_piece == 'K' && extra != 0)
	{
		score += get_piece_score((from + to) / 2, 'R');
		score -= get_piece_score(to < from ? Chess::a1() : Chess::h1(), 'R');
	}
	if (from_piece == 'k' && extra != 0)
	{
		score += get_piece_score((from + to) / 2, 'r');
		score -= get_piece_score(to < from ? Chess::a8() : Chess::h8(), 'r');
	}
	if ((from_piece & 95) == 'P')
	{
		int front = group == 0 ? -16 : 16;
		if (from / 16 == 0)
		{
			score += get_piece_score(to, extra);
			score -= get_piece_score(from, from_piece);
		}
		if (to == _state->get_extra(2))
		{
			score -= get_piece_score(to - front, group == 0 ? 'p' : 'P');
		}
	}
	return score;
}

int RuleStandard::compare_move(int a, int b, int best_move, std::array<int, 65536> *history_table)
{
	if (best_move == a)
		return true;
	if (best_move == b)
		return false;
	if (history_table)
		return (*history_table)[a & 0xFFFF] > (*history_table)[b & 0xFFFF];
	return true;
}

int RuleStandard::quies(godot::Ref<State>_state, int _alpha, int _beta, int _group)
{
	int value = _state->get_relative_score(_group);
	if (value >= _beta)
	{
		return _beta;
	}
	if (value > _alpha)
	{
		_alpha = value;
	}
	godot::PackedInt32Array move_list = generate_good_capture_move(_state, _group);
	for (int i = 0; i < move_list.size(); i++)
	{
		godot::Ref<State>test_state = _state->duplicate();
		apply_move(test_state, move_list[i]);
		value = -quies(_state, -_beta, -_alpha, 1 - _group);
		if (value >= _beta)
		{
			return _beta;
		}
		if (value > _alpha)
		{
			_alpha = value;
		}
	}
	return _alpha;
}

int RuleStandard::alphabeta(godot::Ref<State>_state, int _alpha, int _beta, int _depth, int _group, bool _can_null, std::array<int, 65536> *_history_table, TranspositionTable *_transposition_table, godot::Callable _is_timeup, godot::Callable _debug_output)
{
	if (_transposition_table)
	{
		int score = _transposition_table->probe_hash(_state->get_zobrist(), _depth, _alpha, _beta);
		if (score != 65535)
		{
			return score;
		}
	}
	if (_depth <= 0)
	{
		int score = quies(_state, _alpha, _beta, _group);
		if (_transposition_table)
		{
			_transposition_table->record_hash(_state->get_zobrist(), _depth, score, EXACT, 0);
		}
		return score;
	}
	if (_state->has_history(_state->get_zobrist()))
	{
		return 0;	// 视作平局，如果局面不太好，也不会选择负分的下法
	}

	if (_is_timeup.is_valid() && _is_timeup.call())
	{
		return quies(_state, _alpha, _beta, _group);
	}

	godot::PackedInt32Array move_list;
	unsigned char flag = ALPHA;
	int value = -WIN;
	int best_move = 0;
	if (_transposition_table)
	{
		best_move = _transposition_table->best_move(_state->get_zobrist());
	}
	if (_can_null)
	{
		int score = alphabeta(_state, -_beta, -_beta + 1, _depth - 3, 1 - _group, false);
		if (score >= _beta)
			return _beta;
	}
	move_list = generate_move(_state, _group);
	for (int i = 0; i < move_list.size() - 1; i++)
	{
		for (int j = move_list.size() - 2; j >= i; j--)
		{
			if (!compare_move(move_list[j], move_list[j + 1], best_move, _history_table))
			{
				std::swap(move_list[j], move_list[j + 1]);
			}
		}
		if (_debug_output.is_valid())
		{
			_debug_output.call(_state->get_zobrist(), _depth, i, move_list.size());
		}
		godot::Ref<State>test_state = _state->duplicate();
		apply_move(test_state, move_list[i]);
		value = -alphabeta(test_state, -_beta, -_alpha, _depth - 1, 1 - _group, false, _history_table, _transposition_table, _is_timeup, _debug_output);

		if (_beta <= value)
		{
			if (_transposition_table)
			{
				_transposition_table->record_hash(_state->get_zobrist(), _depth, _beta, BETA, move_list[i]);
			}
			return _beta;
		}
		if (_alpha < value)
		{
			best_move = move_list[i];
			_alpha = value;
			flag = EXACT;
			if (_history_table)
			{
				(*_history_table)[move_list[i] & 0xFFFF] += (1 << _depth);
			}
		}
	}
	if (_transposition_table)
	{
		_transposition_table->record_hash(_state->get_zobrist(), _depth, _alpha, flag, best_move);
	}
	return _alpha;
}

void RuleStandard::search(godot::Ref<State>_state, int _group, TranspositionTable *_transposition_table, godot::Callable _is_timeup, int _max_depth, godot::Callable _debug_output)
{
	std::array<int, 65536> history_table;
	for (int i = 1; i < _max_depth; i++)
	{
		alphabeta(_state, -WIN, WIN, i, _group, true, &history_table, _transposition_table, _is_timeup, _debug_output);
		if (_is_timeup.is_valid() && _is_timeup.call())
		{
			return;
		}
	}
}

void RuleStandard::_bind_methods()
{
	godot::ClassDB::bind_method(godot::D_METHOD("get_end_type"), &RuleStandard::get_end_type);
	godot::ClassDB::bind_method(godot::D_METHOD("parse"), &RuleStandard::parse);
	godot::ClassDB::bind_method(godot::D_METHOD("stringify"), &RuleStandard::stringify);
	godot::ClassDB::bind_method(godot::D_METHOD("get_piece_instance"), &RuleStandard::get_piece_instance);
	godot::ClassDB::bind_method(godot::D_METHOD("is_same_camp"), &RuleStandard::is_same_camp);
	godot::ClassDB::bind_method(godot::D_METHOD("get_piece_score"), &RuleStandard::get_piece_score);
	godot::ClassDB::bind_method(godot::D_METHOD("is_move_valid"), &RuleStandard::is_move_valid);
	godot::ClassDB::bind_method(godot::D_METHOD("generate_premove"), &RuleStandard::generate_premove);
	godot::ClassDB::bind_method(godot::D_METHOD("generate_move"), &RuleStandard::generate_move);
	godot::ClassDB::bind_method(godot::D_METHOD("generate_valid_move"), &RuleStandard::generate_valid_move);
	godot::ClassDB::bind_method(godot::D_METHOD("generate_good_capture_move"), &RuleStandard::generate_good_capture_move);
	godot::ClassDB::bind_method(godot::D_METHOD("apply_move"), &RuleStandard::apply_move);
	godot::ClassDB::bind_method(godot::D_METHOD("evaluate"), &RuleStandard::evaluate);
	//godot::ClassDB::bind_method(godot::D_METHOD("compare_move"), &RuleStandard::compare_move);
	//godot::ClassDB::bind_method(godot::D_METHOD("quies"), &RuleStandard::quies);
	//godot::ClassDB::bind_method(godot::D_METHOD("alphabeta"), &RuleStandard::alphabeta);
	godot::ClassDB::bind_method(godot::D_METHOD("search"), &RuleStandard::search);
}
