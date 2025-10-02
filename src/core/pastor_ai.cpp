#include "pastor_ai.hpp"
#include "rule_standard.hpp"
#include "chess.hpp"
#include <godot_cpp/core/error_macros.hpp>
#include <godot_cpp/classes/file_access.hpp>
#include <random>
#include <algorithm>
#include <functional>

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
		{0, 0},
		{'K', 60000},
		{'Q', 929},
		{'R', 479},
		{'B', 320},
		{'N', 280},
		{'P', 100},
		{'W', 0},
		{'X', 0},
		{'Y', 0},
		{'Z', 0},
		{'k', -60000},
		{'q', -929},
		{'r', -479},
		{'b', -320},
		{'n', -280},
		{'p', -100},
		{'w', 0},
		{'x', 0},
		{'y', 0},
		{'z', 0},
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
		{'W', {
		0,   0,   0,   0,   0,   0,   0,   0,
		0,   0,   0,   0,   0,   0,   0,   0,
		0,   0,   0,   0,   0,   0,   0,   0,
		0,   0,   0,   0,   0,   0,   0,   0,
		0,   0,   0,   0,   0,   0,   0,   0,
		0,   0,   0,   0,   0,   0,   0,   0,
		0,   0,   0,   0,   0,   0,   0,   0,
		0,   0,   0,   0,   0,   0,   0,   0,
		}},
		{'X', {
		0,   0,   0,   0,   0,   0,   0,   0,
		0,   0,   0,   0,   0,   0,   0,   0,
		0,   0,   0,   0,   0,   0,   0,   0,
		0,   0,   0,   0,   0,   0,   0,   0,
		0,   0,   0,   0,   0,   0,   0,   0,
		0,   0,   0,   0,   0,   0,   0,   0,
		0,   0,   0,   0,   0,   0,   0,   0,
		0,   0,   0,   0,   0,   0,   0,   0,
		}},
		{'Y', {
		0,   0,   0,   0,   0,   0,   0,   0,
		0,   0,   0,   0,   0,   0,   0,   0,
		0,   0,   0,   0,   0,   0,   0,   0,
		0,   0,   0,   0,   0,   0,   0,   0,
		0,   0,   0,   0,   0,   0,   0,   0,
		0,   0,   0,   0,   0,   0,   0,   0,
		0,   0,   0,   0,   0,   0,   0,   0,
		0,   0,   0,   0,   0,   0,   0,   0,
		}},
		{'Z', {
		0,   0,   0,   0,   0,   0,   0,   0,
		0,   0,   0,   0,   0,   0,   0,   0,
		0,   0,   0,   0,   0,   0,   0,   0,
		0,   0,   0,   0,   0,   0,   0,   0,
		0,   0,   0,   0,   0,   0,   0,   0,
		0,   0,   0,   0,   0,   0,   0,   0,
		0,   0,   0,   0,   0,   0,   0,   0,
		0,   0,   0,   0,   0,   0,   0,   0,
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
		}},
		{'w', {
		0,   0,   0,   0,   0,   0,   0,   0,
		0,   0,   0,   0,   0,   0,   0,   0,
		0,   0,   0,   0,   0,   0,   0,   0,
		0,   0,   0,   0,   0,   0,   0,   0,
		0,   0,   0,   0,   0,   0,   0,   0,
		0,   0,   0,   0,   0,   0,   0,   0,
		0,   0,   0,   0,   0,   0,   0,   0,
		0,   0,   0,   0,   0,   0,   0,   0,
		}},
		{'x', {
		0,   0,   0,   0,   0,   0,   0,   0,
		0,   0,   0,   0,   0,   0,   0,   0,
		0,   0,   0,   0,   0,   0,   0,   0,
		0,   0,   0,   0,   0,   0,   0,   0,
		0,   0,   0,   0,   0,   0,   0,   0,
		0,   0,   0,   0,   0,   0,   0,   0,
		0,   0,   0,   0,   0,   0,   0,   0,
		0,   0,   0,   0,   0,   0,   0,   0,
		}},
		{'y', {
		0,   0,   0,   0,   0,   0,   0,   0,
		0,   0,   0,   0,   0,   0,   0,   0,
		0,   0,   0,   0,   0,   0,   0,   0,
		0,   0,   0,   0,   0,   0,   0,   0,
		0,   0,   0,   0,   0,   0,   0,   0,
		0,   0,   0,   0,   0,   0,   0,   0,
		0,   0,   0,   0,   0,   0,   0,   0,
		0,   0,   0,   0,   0,   0,   0,   0,
		}},
		{'z', {
		0,   0,   0,   0,   0,   0,   0,   0,
		0,   0,   0,   0,   0,   0,   0,   0,
		0,   0,   0,   0,   0,   0,   0,   0,
		0,   0,   0,   0,   0,   0,   0,   0,
		0,   0,   0,   0,   0,   0,   0,   0,
		0,   0,   0,   0,   0,   0,   0,   0,
		0,   0,   0,   0,   0,   0,   0,   0,
		0,   0,   0,   0,   0,   0,   0,   0,
		}}
	};
}

double PastorAI::plan_time_cost(godot::Ref<State> _state)
{
	return pow(time_left * (_state->get_round()), 0.2);
}

godot::PackedInt32Array PastorAI::generate_good_capture_move(godot::Ref<State>_state, int _group)
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
				if ((to & 0x88))
				{
					break;
				}
				to_piece = _state->get_piece(to);
				if (to_piece && Chess::is_same_group(from_piece, to_piece) && (to_piece & 95) != 'W' && (to_piece & 95) != 'X')
				{
					break;
				}
				if (to_piece)
				{
					output.push_back(Chess::create(_from, to, 0));
					break;
				}
				if ((from_piece & 95) == 'K' || (from_piece & 95) == 'N')
				{
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

int PastorAI::evaluate_all(godot::Ref<State> _state)
{
	int score = 0;
	for (State::PieceIterator iter = _state->piece_iterator_begin(); !iter.end(); iter.next())
	{
		int by = iter.pos();
		int piece = iter.piece();
		score += get_piece_score(by, piece);
	}
	return score;
}

int PastorAI::evaluate(godot::Ref<State> _state, int _move)
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

int PastorAI::compare_move(int a, int b, int best_move, int killer_1, int killer_2, const godot::Ref<State> &state, std::array<int, 65536> *history_table)
{
	if (best_move == a)
		return true;
	if (best_move == b)
		return false;
	if (killer_1 == a)
		return true;
	if (killer_1 == b)
		return false;
	if (killer_2 == a)
		return true;
	if (killer_2 == b)
		return false;
	if (history_table && (*history_table)[a & 0xFFFF] != (*history_table)[b & 0xFFFF])
		return (*history_table)[a & 0xFFFF] > (*history_table)[b & 0xFFFF];
	int mvv_a = abs(piece_value[state->get_piece(Chess::to(a))]);
	int mvv_b = abs(piece_value[state->get_piece(Chess::to(b))]);
	if (mvv_a != mvv_b)
	{
		return mvv_a > mvv_b;
	}
	int lva_a = abs(piece_value[state->get_piece(Chess::from(a))]);
	int lva_b = abs(piece_value[state->get_piece(Chess::from(b))]);
	if (mvv_a != 0 && lva_a != lva_b)
	{
		return lva_a < lva_b;
	}
	return a > b;
}

int PastorAI::quies(godot::Ref<State> _state, int score, int _alpha, int _beta, int _group)
{
	int score_relative = _group == 0 ? score : -score;
	if (score_relative >= _beta)
	{
		return _beta;
	}
	if (score_relative > _alpha)
	{
		_alpha = score_relative;
	}
	godot::PackedInt32Array move_list = generate_good_capture_move(_state, _group);
	std::sort(move_list.ptrw(), move_list.ptrw() + move_list.size(), std::bind(compare_move, this, std::placeholders::_1, std::placeholders::_2, 0, 0, 0, _state, nullptr));
	for (int i = 0; i < move_list.size(); i++)
	{
		godot::Ref<State> test_state = _state->duplicate();
		RuleStandard::get_singleton()->apply_move(test_state, move_list[i]);
		int test_score = -quies(test_state, score + evaluate(_state, move_list[i]), -_beta, -_alpha, 1 - _group);
		if (test_score >= _beta)
		{
			return _beta;
		}
		if (test_score > _alpha)
		{
			_alpha = test_score;
		}
	}
	return _alpha;
}

int PastorAI::alphabeta(const godot::Ref<State> &_state, int score, int _alpha, int _beta, int _depth, int _group, int _ply, bool _can_null, std::unordered_map<int, int> *_history_state, std::array<int, 65536> *_history_table, int *killer_1, int *killer_2, const godot::Callable &_debug_output)
{
	bool found_pv = false;
	int transposition_table_score = transposition_table->probe_hash(_state->get_zobrist(), _depth, _alpha, _beta);
	if (transposition_table_score != 65535)
	{
		return transposition_table_score;
	}
	if (_depth <= 0)
	{
		int next_score = quies(_state, score, _alpha, _beta, _group);
		if (!transposition_table.is_null())
		{
			transposition_table->record_hash(_state->get_zobrist(), _depth, next_score, EXACT, 0);
		}
		return next_score;
	}
	if (_history_state && _history_state->count(_state->get_zobrist()))
	{
		return 0; // 视作平局，如果局面不太好，也不会选择负分的下法
	}

	if (time_passed() >= plan_time_cost(_state) || interrupted)
	{
		return quies(_state, score, _alpha, _beta, _group);
	}

	unsigned char flag = ALPHA;
	int best_move = 0;
	bool has_transposition_table_move = false;
	if (!transposition_table.is_null())
	{
		best_move = transposition_table->best_move(_state->get_zobrist());
		if (RuleStandard::get_singleton()->is_move_valid(_state, _group, best_move))
		{
			godot::Ref<State> test_state = _state->duplicate();
			RuleStandard::get_singleton()->apply_move(test_state, best_move);
			int next_score = -alphabeta(test_state, score + evaluate(_state, best_move), -_beta, -_alpha, _depth - 1, 1 - _group, _ply + 1, true, _history_state, _history_table, nullptr, nullptr, _debug_output);
			has_transposition_table_move = true;
			if (_beta <= next_score)
			{
				return _beta;
			}
		}
		else
		{
			best_move = 0;
		}
	}
	bool has_killer_1 = false;
	if (killer_1 && RuleStandard::get_singleton()->is_move_valid(_state, _group, *killer_1))
	{
		godot::Ref<State> test_state = _state->duplicate();
		RuleStandard::get_singleton()->apply_move(test_state, *killer_1);
		int next_score = -alphabeta(test_state, score + evaluate(_state, *killer_1), -_beta, -_alpha, _depth - 1, 1 - _group, _ply + 1, true, _history_state, _history_table, nullptr, nullptr, _debug_output);
		has_killer_1 = true;
		if (_beta <= next_score)
		{
			return _beta;
		}
	}
	bool has_killer_2 = false;
	if (killer_2 && RuleStandard::get_singleton()->is_move_valid(_state, _group, *killer_2))
	{
		godot::Ref<State> test_state = _state->duplicate();
		RuleStandard::get_singleton()->apply_move(test_state, *killer_2);
		int next_score = -alphabeta(test_state, score + evaluate(_state, *killer_2), -_beta, -_alpha, _depth - 1, 1 - _group, _ply + 1, true, _history_state, _history_table, nullptr, nullptr, _debug_output);
		has_killer_2 = true;
		if (_beta <= next_score)
		{
			return _beta;
		}
	}
	if (_can_null)
	{
		int next_score = -alphabeta(_state, score, -_beta, -_beta + 1, _depth - 3, 1 - _group, _ply + 1, false);
		if (next_score >= _beta)
		{
			return _beta;
		}
	}
	godot::PackedInt32Array move_list = RuleStandard::get_singleton()->generate_valid_move(_state, _group);
	if (move_list.size() == 0)
	{
		if (RuleStandard::get_singleton()->is_check(_state, 1 - _group))
		{
			return -WIN + _ply;
		} else {
			return 0;
		}
	}
	std::sort(move_list.ptrw(), move_list.ptrw() + move_list.size(), std::bind(compare_move, this, std::placeholders::_1, std::placeholders::_2, best_move, killer_1 ? *killer_1 : 0, killer_2 ? *killer_2 : 0, _state, _history_table));
	int move_count = move_list.size();
	if (_depth > 2)
	{
		move_count -= 0.57 + (pow(_depth, 0.10) * pow(move_count, 0.16)) / 2.49;
		move_count = move_count <= 0 ? 1 : move_count;
	}
	int next_killer_1 = 0;
	int next_killer_2 = 0;
	for (int i = 0; i < move_count; i++)
	{
		if (i == 0 && has_transposition_table_move || i == 1 && has_killer_1 || i == 2 && has_killer_2)
		{
			continue;
		}
		if (_debug_output.is_valid())
		{
			_debug_output.call(_state->get_zobrist(), _depth, i, move_list.size());
		}
		godot::Ref<State> test_state = _state->duplicate();
		RuleStandard::get_singleton()->apply_move(test_state, move_list[i]);
		int next_score = 0;
		if (found_pv)
		{
			next_score = -alphabeta(test_state, score + evaluate(_state, move_list[i]), -_alpha - 1, -_alpha, _depth - 1, 1 - _group, _ply + 1, true, _history_state, _history_table, &next_killer_1, &next_killer_2, _debug_output);
		}
		if (!found_pv || next_score > _alpha && next_score < _beta)
		{
			next_score = -alphabeta(test_state, score + evaluate(_state, move_list[i]), -_beta, -_alpha, _depth - 1, 1 - _group, _ply + 1, true, _history_state, _history_table, &next_killer_1, &next_killer_2, _debug_output);
		}

		if (_beta <= next_score)
		{
			transposition_table->record_hash(_state->get_zobrist(), _depth, _beta, BETA, move_list[i]);
			if (killer_1 && killer_2)
			{
				*killer_2 = *killer_1;
				*killer_1 = move_list[i];
			}
			return _beta;
		}
		if (_alpha < next_score)
		{
			found_pv = true;
			best_move = move_list[i];
			_alpha = next_score;
			flag = EXACT;
			if (_history_table)
			{
				(*_history_table)[move_list[i] & 0xFFFF] += (1 << _depth);
			}
		}
	}
	transposition_table->record_hash(_state->get_zobrist(), _depth, _alpha, flag, best_move);
	return _alpha;
}

void PastorAI::search(const godot::Ref<State> &_state, int _group, const godot::PackedInt32Array &history_state, const godot::Callable &_debug_output)
{
	if (opening_book->has_record(_state))
	{
		godot::PackedInt32Array suggest_move = opening_book->get_suggest_move(_state);
		if (suggest_move.size())
		{
			std::mt19937_64 rng(time(nullptr));
			best_move = suggest_move[rng() % suggest_move.size()];
			return;
		}
	}
	std::array<int, 65536> history_table;
	std::unordered_map<int, int> map_history_state;
	for (int i = 0; i < history_state.size(); i++)
	{
		map_history_state[history_state[i]]++;
	}
	for (int i = 0; i <= max_depth; i += 2)
	{
		alphabeta(_state, evaluate_all(_state), -THRESHOLD, THRESHOLD, i, _group, 0, true, &map_history_state, &history_table, nullptr, nullptr, _debug_output);
		if (time_passed() >= plan_time_cost(_state) || interrupted)
		{
			break;
		}
	}
	best_move = transposition_table->best_move(_state->get_zobrist());
	principal_variation.clear();
	godot::Ref<State> test_state = _state->duplicate();
	while (transposition_table->probe_hash(test_state->get_zobrist(), 1, -THRESHOLD, THRESHOLD) != 65535)
	{
		int move = transposition_table->best_move(test_state->get_zobrist());
		principal_variation.push_back(move);
		RuleStandard::get_singleton()->apply_move(test_state, move);
	}
}

int PastorAI::get_search_result()
{
	return best_move;
}

godot::PackedInt32Array PastorAI::get_principal_variation()
{
	return principal_variation;
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
	godot::ClassDB::bind_method(godot::D_METHOD("search", "state", "group", "history_state", "debug_output"), &PastorAI::search);
	godot::ClassDB::bind_method(godot::D_METHOD("get_search_result"), &PastorAI::get_search_result);
	godot::ClassDB::bind_method(godot::D_METHOD("get_principal_variation"), &PastorAI::get_principal_variation);
	godot::ClassDB::bind_method(godot::D_METHOD("set_max_depth", "max_depth"), &PastorAI::set_max_depth);
	godot::ClassDB::bind_method(godot::D_METHOD("get_max_depth"), &PastorAI::get_max_depth);
	// godot::ClassDB::bind_method(godot::D_METHOD("set_transposition_table", "transposition_table"), &PastorAI::set_transposition_table);
	godot::ClassDB::bind_method(godot::D_METHOD("get_transposition_table"), &PastorAI::get_transposition_table);
	// ADD_PROPERTY(PropertyInfo(Variant::INT, "max_depth"), "set_max_depth", "get_max_depth");
	// ADD_PROPERTY(PropertyInfo(Variant::OBJECT, "transposition_table"), "set_transposition_table", "get_transposition_table");
}
