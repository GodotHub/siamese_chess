#include "state.hpp"
#include "zobrist_hash.hpp"
#include "rule_standard.hpp"
#include <cstring>

State::State()
{
	memset(pieces, 0, sizeof(pieces));
}

godot::Ref<State> State::duplicate()
{
	godot::Ref<State> new_state = memnew(State);
	memcpy(new_state->pieces, pieces, sizeof(pieces));
	new_state->turn = turn;
	new_state->castle = castle;
	new_state->en_passant = en_passant;
	new_state->step_to_draw = step_to_draw;
	new_state->round = round;
	new_state->king_passant = king_passant;
	new_state->score = score;
	new_state->zobrist = zobrist;
	return new_state;
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

godot::Array State::get_pieces_info() {
	godot::Array output;
	for (int from_1 = 0; from_1 < 8; from_1++)
	{
		for (int from_2 = 0; from_2 < 8; from_2++)
		{
			int from = (from_1 << 4) + from_2;
			int piece_type = get_piece(from);
			if (piece_type)
			{
				godot::Dictionary dict;
				godot::Vector2i position(from & 0XF, from >> 4);
				dict["square"] = position;
				dict["side"] = get_turn();
				switch (piece_type)
				{
					case 'k':
					case 'K':{
						dict["piece_type"] = 0;
					} break;
					case 'q':
					case 'Q':{
						dict["piece_type"] = 1;
					} break;
					case 'r':
					case 'R':{
						dict["piece_type"] = 2;
					} break;
					case 'n':
					case 'N':{
						dict["piece_type"] = 3;
					} break;
					case 'b':
					case 'B':{
						dict["piece_type"] = 4;
					} break;
					case 'p':
					case 'P':{
						dict["piece_type"] = 5;
					} break;
					default:
						break;
				}
				output.append(dict);
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
	pieces[_by] = _piece;
	zobrist ^= ZobristHash::get_singleton()->hash_piece(_piece, _by);
}

void State::capture_piece(int _by)
{
	if (has_piece(_by))
	{
		zobrist ^= ZobristHash::get_singleton()->hash_piece(pieces[_by], _by);
		pieces[_by] = 0;
		// 虽然大多数情况是攻击者移到被攻击者上，但是吃过路兵是例外，后续可能会出现类似情况，所以还是得手多一下
	}
}

void State::move_piece(int _from, int _to)
{
	int piece = get_piece(_from);
	zobrist ^= ZobristHash::get_singleton()->hash_piece(piece, _from);
	zobrist ^= ZobristHash::get_singleton()->hash_piece(piece, _to);
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

void State::change_score(int delta)
{
	score += delta;
}

int64_t State::get_zobrist()
{
	return zobrist;
}

int State::has_history(int64_t _zobrist)
{
	return history.count(_zobrist) ? history[_zobrist] : 0;
}

void State::push_history(int64_t _zobrist)
{
	if (history.count(_zobrist))
	{
		history[_zobrist]++;
	}
	else
	{
		history[_zobrist] = 1;
	}
}

int State::get_relative_score(int _group)
{
	return _group == 0 ? score : -score;
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
	godot::ClassDB::bind_method(godot::D_METHOD("change_score"), &State::change_score);
	godot::ClassDB::bind_method(godot::D_METHOD("get_relative_score"), &State::get_relative_score);
	godot::ClassDB::bind_method(godot::D_METHOD("get_zobrist"), &State::get_zobrist);
	godot::ClassDB::bind_method(godot::D_METHOD("has_history"), &State::has_history);
	godot::ClassDB::bind_method(godot::D_METHOD("push_history"), &State::push_history);
	godot::ClassDB::bind_method(godot::D_METHOD("get_pieces_info"), &State::get_pieces_info);
}
