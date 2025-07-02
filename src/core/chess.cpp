#include "chess.hpp"
#include <godot_cpp/core/class_db.hpp>

Chess *Chess::singleton = nullptr;

Chess::Chess()
{

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
