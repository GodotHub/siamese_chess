#include "chess.hpp"
#include <godot_cpp/core/class_db.hpp>

Chess *Chess::singleton = nullptr;

Chess::Chess()
{

}

uint64_t Chess::mask(int n)
{
	return 1 << n;
}

int Chess::x88_to_64(int n)
{
	return (n >> 4 << 3) | (n & 0xF);
}

int Chess::group(int piece)
{
	if (piece >= 'A' && piece <= 'Z')
	{
		return 0;
	}
	else if (piece >= 'a' && piece <= 'z')
	{
		return 1;
	}
	return 2;
}

bool Chess::is_same_group(int piece_1, int piece_2)
{
	return (piece_1 >= 'A' && piece_1 <= 'Z') == (piece_2 >= 'A' && piece_2 <= 'Z');
}

int Chess::to_position_int(godot::String _position_name)
{
	return ((7 - (_position_name[1] - '1')) << 4) + _position_name[0] - 'a';
}

godot::String Chess::to_position_name(int _position)
{
	return godot::String::chr((_position & 15) + 'a') + godot::String::chr((7 - (_position >> 4)) + '1');
}

int Chess::create(int _from, int _to, int _extra)
{
	return _from + (_to << 8) + (_extra << 16);
}

int Chess::from(int _move)
{
	return _move & 0xFF;
}

int Chess::to(int _move)
{
	return (_move >> 8) & 0xFF;
}

int Chess::extra(int _move)
{
	return (_move >> 16) & 0xFF;
}

Chess *Chess::get_singleton()
{
	if (!singleton)
	{
		singleton = memnew(Chess);
	}
	return singleton;
}

void Chess::_bind_methods()
{
	godot::ClassDB::bind_static_method(get_class_static(), godot::D_METHOD("to_position_int"), &Chess::to_position_int);
	godot::ClassDB::bind_static_method(get_class_static(), godot::D_METHOD("to_position_name"), &Chess::to_position_name);
	godot::ClassDB::bind_static_method(get_class_static(), godot::D_METHOD("create"), &Chess::create);
	godot::ClassDB::bind_static_method(get_class_static(), godot::D_METHOD("from"), &Chess::from);
	godot::ClassDB::bind_static_method(get_class_static(), godot::D_METHOD("to"), &Chess::to);
	godot::ClassDB::bind_static_method(get_class_static(), godot::D_METHOD("extra"), &Chess::extra);
}
