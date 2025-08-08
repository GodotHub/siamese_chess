#include "pastor_ai.hpp"
#include "rule_standard.hpp"
#include "chess.hpp"
#include <godot_cpp/core/error_macros.hpp>
#include <godot_cpp/classes/file_access.hpp>
#include <random>

PastorAI::PastorAI()
{
	transposition_table.instantiate();
	opening_book.instantiate();
	if (godot::FileAccess::file_exists("user://standard_opening.fa"))
	{
		transposition_table->load_file("user://standard_opening.fa");
	}
	else
	{
		transposition_table->reserve(1 << 20);
	}
	if (godot::FileAccess::file_exists("user://standard_opening_document.fa"))
	{
		opening_book->load_file("user://standard_opening_document.fa");
	}
	max_depth = 100;
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
}


godot::PackedInt32Array PastorAI::generate_good_capture_move(godot::Ref<State>_state, int _group)
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
				if (_state->has_piece(_from + front + 1) && !Chess::is_same_group(from_piece, _state->get_piece(_from + front + 1))
				|| ((_from >> 4) == 3 || (_from >> 4) == 4) && _state->get_en_passant() == _from + front + 1
				|| !((_from + front + 1) & 0x88) && on_end && _state->get_king_passant() != -1 && abs(_state->get_king_passant() - (_from + front + 1)) <= 1)
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
				if (_state->has_piece(_from + front - 1) && !Chess::is_same_group(from_piece, _state->get_piece(_from + front - 1))
				|| ((_from >> 4) == 3 || (_from >> 4) == 4) && _state->get_en_passant() == _from + front - 1
				|| !((_from + front - 1) & 0x88) && on_end && _state->get_king_passant() != -1 && abs(_state->get_king_passant() - (_from + front - 1)) <= 1)
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
					if (!(to & 0x88) && to_piece && !Chess::is_same_group(from_piece, to_piece))
					{
						if (abs(piece_value[_from]) <= abs(piece_value[to]))
						{
							output.push_back(Chess::create(_from, to, 0));
						}
						break;
					}
					if (_state->get_king_passant() != -1 && abs(to - _state->get_king_passant()) <= 1)
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


int PastorAI::get_piece_score(int _by, int _piece)
{
	godot::Vector2i piece_position = godot::Vector2i(_by % 16, _by / 16);
	if (piece_value.count(_piece))
	{
		return position_value[_piece][piece_position.x + piece_position.y * 8] + piece_value[_piece];
	}
	return 0;
}


int PastorAI::evaluate(godot::Ref<State>_state, int _move)
{
	int from = Chess::from(_move);
	int from_piece = _state->get_piece(from);
	int to = Chess::to(_move);
	int to_piece = _state->get_piece(to);
	int extra = Chess::extra(_move);
	int group = Chess::group(from_piece);
	int score = get_piece_score(to, from_piece) - get_piece_score(from, from_piece);
	if (to_piece && !Chess::is_same_group(from_piece, to_piece))
	{
		score -= get_piece_score(to, to_piece);
	}
	if (_state->get_king_passant() != -1 && abs(_state->get_king_passant() - Chess::to(_move)) <= 1)
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
		if (extra)
		{
			score += get_piece_score(to, extra);
			score -= get_piece_score(from, from_piece);
		}
		if (to == _state->get_en_passant())
		{
			score -= get_piece_score(to - front, group == 0 ? 'p' : 'P');
		}
	}
	return score;
}

int PastorAI::compare_move(int a, int b, int best_move, std::array<int, 65536> *history_table)
{
	if (best_move == a)
		return true;
	if (best_move == b)
		return false;
	if (history_table)
		return (*history_table)[a & 0xFFFF] > (*history_table)[b & 0xFFFF];
	return true;
}

int PastorAI::quies(godot::Ref<State>_state, int _alpha, int _beta, int _group)
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
		godot::Ref<State> test_state = _state->duplicate();
		RuleStandard::get_singleton()->apply_move(test_state, move_list[i]);
		test_state->change_score(evaluate(_state, move_list[i]));
		value = -quies(test_state, -_beta, -_alpha, 1 - _group);
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

int PastorAI::alphabeta(const godot::Ref<State> &_state, int _alpha, int _beta, int _depth, int _group, int _ply, bool _can_null, std::array<int, 65536> *_history_table, int *killer_1, int *killer_2, const godot::Callable &_is_timeup, const godot::Callable &_debug_output)
{
	bool found_pv = false;
	if (!transposition_table.is_null())
	{
		int score = transposition_table->probe_hash(_state->get_zobrist(), _depth, _alpha, _beta);
		if (score != 65535)
		{
			return score;
		}
	}
	if (_depth <= 0)
	{
		int score = quies(_state, _alpha, _beta, _group);
		if (!transposition_table.is_null())
		{
			transposition_table->record_hash(_state->get_zobrist(), _depth, score, EXACT, 0);
		}
		return score;
	}
	if (_state->has_history(_state->get_zobrist()))
	{
		return 0; // 视作平局，如果局面不太好，也不会选择负分的下法
	}

	if (_is_timeup.is_valid() && _is_timeup.call())
	{
		return quies(_state, _alpha, _beta, _group);
	}

	godot::PackedInt32Array move_list;
	unsigned char flag = ALPHA;
	int value = -WIN;
	int best_move = 0;
	if (!transposition_table.is_null())
	{
		best_move = transposition_table->best_move(_state->get_zobrist());
		if (RuleStandard::get_singleton()->is_move_valid(_state, _group, best_move))
		{
			godot::Ref<State> test_state = _state->duplicate();
			RuleStandard::get_singleton()->apply_move(test_state, best_move);
			test_state->change_score(evaluate(_state, best_move));
			value = -alphabeta(test_state, -_beta, -_alpha, _depth - 1, 1 - _group, _ply + 1, false, _history_table, nullptr, nullptr, _is_timeup, _debug_output);
			if (_beta <= value)
			{
				return _beta;
			}
		}
		else
		{
			best_move = 0;
		}
	}
	if (killer_1 && RuleStandard::get_singleton()->is_move_valid(_state, _group, *killer_1))
	{
		godot::Ref<State> test_state = _state->duplicate();
		RuleStandard::get_singleton()->apply_move(test_state, *killer_1);
		test_state->change_score(evaluate(_state, *killer_1));
		value = -alphabeta(test_state, -_beta, -_alpha, _depth - 1, 1 - _group, _ply + 1, false, _history_table, nullptr, nullptr, _is_timeup, _debug_output);
		if (_beta <= value)
		{
			return _beta;
		}
	}
	if (killer_2 && RuleStandard::get_singleton()->is_move_valid(_state, _group, *killer_2))
	{
		godot::Ref<State> test_state = _state->duplicate();
		RuleStandard::get_singleton()->apply_move(test_state, *killer_2);
		test_state->change_score(evaluate(_state, *killer_2));
		value = -alphabeta(test_state, -_beta, -_alpha, _depth - 1, 1 - _group, _ply + 1, false, _history_table, nullptr, nullptr, _is_timeup, _debug_output);
		if (_beta <= value)
		{
			return _beta;
		}
	}
	if (_can_null)
	{
		int score = -alphabeta(_state, -_beta, -_beta + 1, _depth - 3, 1 - _group, false);
		if (score >= _beta)
		{
			return _beta;
		}
	}
	move_list = RuleStandard::get_singleton()->generate_valid_move(_state, _group);
	if (move_list.size() == 0)
	{
		if (RuleStandard::get_singleton()->is_check(_state, 1 - _group))
		{
			return -WIN + _ply;
		} else {
			return 0;
		}
	}
	int next_killer_1 = 0;
	int next_killer_2 = 0;
	for (int i = 0; i < move_list.size(); i++)
	{
		for (int j = move_list.size() - 2; j >= i; j--)
		{
			if (!compare_move(move_list[j], move_list[j + 1], best_move, _history_table))
			{
				std::swap(move_list[j], move_list[j + 1]);
			}
		}
		_debug_output.call(_state->get_zobrist(), _depth, i, move_list.size());
		godot::Ref<State> test_state = _state->duplicate();
		RuleStandard::get_singleton()->apply_move(test_state, move_list[i]);
		test_state->change_score(evaluate(_state, move_list[i]));

		if (found_pv)
		{
			value = -alphabeta(test_state, -_alpha - 1, -_alpha, _depth - 1, 1 - _group, _ply + 1, false, _history_table, &next_killer_1, &next_killer_2, _is_timeup, _debug_output);
		}
		if (!found_pv || value > _alpha && value < _beta)
		{
			value = -alphabeta(test_state, -_beta, -_alpha, _depth - 1, 1 - _group, _ply + 1, false, _history_table, &next_killer_1, &next_killer_2, _is_timeup, _debug_output);
		}

		if (_beta <= value)
		{
			if (!transposition_table.is_null())
			{
				transposition_table->record_hash(_state->get_zobrist(), _depth, _beta, BETA, move_list[i]);
			}
			if (killer_1 && killer_2)
			{
				*killer_2 = *killer_1;
				*killer_1 = move_list[i];
			}
			return _beta;
		}

		if (_alpha < value)
		{
			found_pv = true;
			best_move = move_list[i];
			_alpha = value;
			flag = EXACT;
			if (_history_table)
			{
				(*_history_table)[move_list[i] & 0xFFFF] += (1 << _depth);
			}
		}
	}
	if (!transposition_table.is_null())
	{
		transposition_table->record_hash(_state->get_zobrist(), _depth, _alpha, flag, best_move);
	}
	return _alpha;
}

void PastorAI::search(const godot::Ref<State> &_state, int _group, const godot::Callable &_is_timeup, const godot::Callable &_debug_output)
{
	if (opening_book->has_record(_state))
	{
		godot::PackedInt32Array suggest_move = opening_book->get_suggest_move(_state);
		if (suggest_move.size())
		{
			std::mt19937_64 rng(time(nullptr));
			best_move = suggest_move[rng() % suggest_move.size()];
			call_deferred("emit_signal", "search_finished");
			return;
		}
	}
	std::array<int, 65536> history_table;
	for (int i = 1; i < max_depth; i++)
	{
		alphabeta(_state, -THRESHOLD, THRESHOLD, i, _group, 0, true, &history_table, nullptr, nullptr, _is_timeup, _debug_output);
		if (_is_timeup.is_valid() && _is_timeup.call())
		{
			break;
		}
	}
	best_move = transposition_table->best_move(_state->get_zobrist());
	call_deferred("emit_signal", "search_finished");
}

int PastorAI::get_search_result()
{
	return best_move;
}

void PastorAI::set_max_depth(int max_depth)
{
	this->max_depth = max_depth;
}

int PastorAI::get_max_depth() const
{
	return this->max_depth;
}

void PastorAI::set_transposition_table(const godot::Ref<TranspositionTable> &transposition_table)
{
	this->transposition_table = transposition_table;
}

godot::Ref<TranspositionTable> PastorAI::get_transposition_table() const
{
	return this->transposition_table;
}

void PastorAI::_bind_methods()
{
	ADD_SIGNAL(godot::MethodInfo("search_finished"));
	godot::ClassDB::bind_method(godot::D_METHOD("search", "state", "group", "is_timeup", "debug_output"), &PastorAI::search);
	godot::ClassDB::bind_method(godot::D_METHOD("get_search_result"), &PastorAI::get_search_result);
	godot::ClassDB::bind_method(godot::D_METHOD("set_max_depth", "max_depth"), &PastorAI::set_max_depth);
	godot::ClassDB::bind_method(godot::D_METHOD("get_max_depth"), &PastorAI::get_max_depth);
	// godot::ClassDB::bind_method(godot::D_METHOD("set_transposition_table", "transposition_table"), &PastorAI::set_transposition_table);
	godot::ClassDB::bind_method(godot::D_METHOD("get_transposition_table"), &PastorAI::get_transposition_table);
	// ADD_PROPERTY(PropertyInfo(Variant::INT, "max_depth"), "set_max_depth", "get_max_depth");
	// ADD_PROPERTY(PropertyInfo(Variant::OBJECT, "transposition_table"), "set_transposition_table", "get_transposition_table");
}
