#include "state.hpp"
#include "zobrist_hash.hpp"
#include "rule_standard.hpp"
#include "chess.hpp"
#include <cstring>

void State::PieceIterator::begin()
{
	while (!parent->pieces[by] && by < 128)
	{
		by++;
		if (by & 0x88)
		{
			by += 8;
			by -= by & 15;
		}
	}
}

void State::PieceIterator::next()
{
	by++;
	while (!parent->pieces[by] && by < 128)
	{
		by++;
		if (by & 0x88)
		{
			by += 8;
			by -= by & 15;
		}
	}
}

int State::PieceIterator::piece()
{
	return parent->pieces[by];
}

int State::PieceIterator::pos()
{
	return by;
}

bool State::PieceIterator::end()
{
	return by & 0x88;
}

State::State()
{
	memset(pieces, 0, sizeof(pieces));
}

godot::Ref<State> State::duplicate()
{
	godot::Ref<State> new_state = memnew(State);
	memcpy(new_state->pieces, pieces, sizeof(pieces));
	memcpy(new_state->bit, bit, sizeof(bit));
	new_state->turn = turn;
	new_state->castle = castle;
	new_state->en_passant = en_passant;
	new_state->step_to_draw = step_to_draw;
	new_state->round = round;
	new_state->king_passant = king_passant;
	new_state->zobrist = zobrist;
	return new_state;
}

State::PieceIterator State::piece_iterator_begin()
{
	State::PieceIterator instance;
	instance.parent = this;
	instance.by = 0;
	instance.begin();
	return instance;
}

godot::PackedInt32Array State::get_all_pieces()
{
	godot::PackedInt32Array output;
	for (int from_1 = 0; from_1 < 8; from_1++)
	{
		for (int from_2 = 0; from_2 < 8; from_2++)
		{
			int from = (from_1 << 4) + from_2;
			if (get_piece(from))
			{
				output.push_back(from);
			}
		}
	}
	return output;
}

int State::get_piece(int _by)
{
	if (_by & 0x88)
	{
		return 0;
	}
	return pieces[_by];
}

int State::has_piece(int _by)
{
	return !(_by & 0x88) && pieces[_by];
}

void State::add_piece(int _by, int _piece)
{
	uint64_t by_mask = Chess::mask(Chess::x88_to_64(_by));
	pieces[_by] = _piece;
	bit[_piece] |= by_mask;
	bit[Chess::group(_piece) == 0 ? 'A' : 'a'] |= by_mask;
	zobrist ^= ZobristHash::get_singleton()->hash_piece(_piece, _by);
}

void State::capture_piece(int _by)
{
	if (has_piece(_by))
	{
		int piece = pieces[_by];
		uint64_t by_mask = Chess::mask(Chess::x88_to_64(_by));
		zobrist ^= ZobristHash::get_singleton()->hash_piece(piece, _by);
		bit[piece] &= ~by_mask;
		bit[Chess::group(piece) == 0 ? 'A' : 'a'] &= ~by_mask;
		piece = 0;
		// 虽然大多数情况是攻击者移到被攻击者上，但是吃过路兵是例外，后续可能会出现类似情况，所以还是得手多一下
	}
}

void State::move_piece(int _from, int _to)
{
	int piece = get_piece(_from);
	uint64_t from_mask = Chess::mask(Chess::x88_to_64(_from));
	uint64_t to_mask = Chess::mask(Chess::x88_to_64(_to));
	zobrist ^= ZobristHash::get_singleton()->hash_piece(piece, _from);
	zobrist ^= ZobristHash::get_singleton()->hash_piece(piece, _to);
	bit[pieces[_from]] &= ~from_mask;
	bit[Chess::group(piece) == 0 ? 'A' : 'a'] &= ~from_mask;
	bit[pieces[_to]] |= to_mask;
	bit[Chess::group(piece) == 0 ? 'A' : 'a'] |= to_mask;
	pieces[_to] = pieces[_from];
	pieces[_from] = 0;
}

int State::get_turn()
{
	return turn;
}

void State::set_turn(int _turn)
{
	turn = _turn;
}

int State::get_castle()
{
	return castle;
}

void State::set_castle(int _castle)
{
	castle = _castle;
}

int State::get_en_passant()
{
	return en_passant;
}

void State::set_en_passant(int _en_passant)
{
	en_passant = _en_passant;
}

int State::get_step_to_draw()
{
	return step_to_draw;
}

void State::set_step_to_draw(int _step_to_draw)
{
	step_to_draw = _step_to_draw;
}

int State::get_round()
{
	return round;
}

void State::set_round(int _round)
{
	round = _round;
}

int State::get_king_passant()
{
	return king_passant;
}

void State::set_king_passant(int _king_passant)
{
	king_passant = _king_passant;
}

int64_t State::get_zobrist()
{
	return zobrist;
}

void State::_bind_methods()
{
	godot::ClassDB::bind_method(godot::D_METHOD("duplicate"), &State::duplicate);
	godot::ClassDB::bind_method(godot::D_METHOD("get_all_pieces"), &State::get_all_pieces);
	godot::ClassDB::bind_method(godot::D_METHOD("get_piece"), &State::get_piece);
	godot::ClassDB::bind_method(godot::D_METHOD("has_piece"), &State::has_piece);
	godot::ClassDB::bind_method(godot::D_METHOD("add_piece"), &State::add_piece);
	godot::ClassDB::bind_method(godot::D_METHOD("capture_piece"), &State::capture_piece);
	godot::ClassDB::bind_method(godot::D_METHOD("move_piece"), &State::move_piece);
	godot::ClassDB::bind_method(godot::D_METHOD("get_turn"), &State::get_turn);
	godot::ClassDB::bind_method(godot::D_METHOD("set_turn"), &State::set_turn);
	godot::ClassDB::bind_method(godot::D_METHOD("get_castle"), &State::get_castle);
	godot::ClassDB::bind_method(godot::D_METHOD("set_castle"), &State::set_castle);
	godot::ClassDB::bind_method(godot::D_METHOD("get_en_passant"), &State::get_en_passant);
	godot::ClassDB::bind_method(godot::D_METHOD("set_en_passant"), &State::set_en_passant);
	godot::ClassDB::bind_method(godot::D_METHOD("get_step_to_draw"), &State::get_step_to_draw);
	godot::ClassDB::bind_method(godot::D_METHOD("set_step_to_draw"), &State::set_step_to_draw);
	godot::ClassDB::bind_method(godot::D_METHOD("get_round"), &State::get_round);
	godot::ClassDB::bind_method(godot::D_METHOD("set_round"), &State::set_round);
	godot::ClassDB::bind_method(godot::D_METHOD("get_king_passant"), &State::get_king_passant);
	godot::ClassDB::bind_method(godot::D_METHOD("set_king_passant"), &State::set_king_passant);
	godot::ClassDB::bind_method(godot::D_METHOD("get_zobrist"), &State::get_zobrist);
}
