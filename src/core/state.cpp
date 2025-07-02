#include "state.hpp"
#include "zobrist_hash.hpp"
#include <cstring>

State::State()
{
	memset(pieces, 0, sizeof(pieces));
}

State *State::duplicate()
{
	State *new_state = memnew(State);
	memcpy(new_state->pieces, pieces, sizeof(pieces));
	new_state->extra = extra.duplicate();
	new_state->score = score;
	new_state->zobrist = zobrist;
	return new_state;
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
	//emit_signal("piece_added", _by);	//存疑，很像性能瓶颈
}

void State::capture_piece(int _by)
{
	if (has_piece(_by))
	{
		zobrist ^= ZobristHash::get_singleton()->hash_piece(pieces[_by], _by);
		pieces[_by] = 0;
		// 虽然大多数情况是攻击者移到被攻击者上，但是吃过路兵是例外，后续可能会出现类似情况，所以还是得手多一下
		//emit_signal("piece_captured", _by);
	}
}

void State::move_piece(int _from, int _to)
{
	int piece = get_piece(_from);
	zobrist ^= ZobristHash::get_singleton()->hash_piece(piece, _from);
	zobrist ^= ZobristHash::get_singleton()->hash_piece(piece, _to);
	pieces[_to] = pieces[_from];
	pieces[_from] = 0;
	//emit_signal("piece_moved", _from, _to);
}

int State::get_extra(int _index)
{
	if (_index < extra.size())
	{
		return extra[_index];
	}
	return -1;
}

void State::set_extra(int _index, int _value)
{
	if (_index < extra.size())
	{
		extra[_index] = _value;
	}
}

void State::reserve_extra(int _size)
{
	while (extra.size() < _size)
	{
		extra.push_back(-1);
	}
}

long long State::get_zobrist()
{
	return zobrist;
}

int State::has_history(long long _zobrist)
{
	return history.has(_zobrist) ? history[_zobrist] : 0;
}

void State::push_history(long long _zobrist)
{
	if (history.has(_zobrist))
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
	godot::ClassDB::bind_method(godot::D_METHOD("get_piece"), &State::get_piece);
	godot::ClassDB::bind_method(godot::D_METHOD("has_piece"), &State::has_piece);
	godot::ClassDB::bind_method(godot::D_METHOD("add_piece"), &State::add_piece);
	godot::ClassDB::bind_method(godot::D_METHOD("capture_piece"), &State::capture_piece);
	godot::ClassDB::bind_method(godot::D_METHOD("move_piece"), &State::move_piece);
	godot::ClassDB::bind_method(godot::D_METHOD("get_extra"), &State::get_extra);
	godot::ClassDB::bind_method(godot::D_METHOD("set_extra"), &State::set_extra);
	godot::ClassDB::bind_method(godot::D_METHOD("reserve_extra"), &State::reserve_extra);
	godot::ClassDB::bind_method(godot::D_METHOD("get_relative_score"), &State::get_relative_score);
	godot::ClassDB::add_signal(get_class_static(), godot::MethodInfo("piece_added", godot::PropertyInfo(godot::Variant::Type::INT, "by")));
	godot::ClassDB::add_signal(get_class_static(), godot::MethodInfo("piece_captured", godot::PropertyInfo(godot::Variant::Type::INT, "by")));
	godot::ClassDB::add_signal(get_class_static(), godot::MethodInfo("piece_moved", godot::PropertyInfo(godot::Variant::Type::INT, "from"), godot::PropertyInfo(godot::Variant::Type::INT, "to")));
}
