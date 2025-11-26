#include "chess.hpp"
#include <godot_cpp/core/class_db.hpp>

Chess *Chess::singleton = nullptr;

Chess::Chess()
{

}

int Chess::rotate_90(int n)
{
	static const int table[64] = {
		 7, 15, 23, 31, 39, 47, 55, 63,
		 6, 14, 22, 30, 38, 46, 54, 62,
		 5, 13, 21, 29, 37, 45, 53, 61,
		 4, 12, 20, 28, 36, 44, 52, 60,
		 3, 11, 19, 27, 35, 43, 51, 59,
		 2, 10, 18, 26, 34, 42, 50, 58,
		 1,  9, 17, 25, 33, 41, 49, 57,
		 0,  8, 16, 24, 32, 40, 48, 56
	};
	return table[n];
}

int Chess::rotate_45(int n)
{
	static const int table[64] = {
		 0,  2,  5,  9, 14, 20, 27, 35,
		 1,  4,  8, 13, 19, 26, 34, 42,
		 3,  7, 12, 18, 25, 33, 41, 48,
		 6, 11, 17, 24, 32, 40, 47, 53,
		10, 16, 23, 31, 39, 46, 52, 57,
		15, 22, 30, 38, 45, 51, 56, 60,
		21, 29, 37, 44, 50, 55, 59, 62,
		28, 36, 43, 49, 54, 58, 61, 63
	};
	return table[n];
}

int Chess::rotate_315(int n)
{
	static const int table[64] = {
		28, 21, 15, 10,  6,  3,  1,  0,
		36, 29, 22, 16, 11,  7,  4,  2,
		43, 37, 30, 23, 17, 12,  8,  5,
		49, 44, 38, 31, 24, 18, 13,  9,
		54, 50, 45, 39, 32, 25, 19, 14,
		58, 55, 51, 46, 40, 33, 26, 20,
		61, 59, 56, 52, 47, 41, 34, 27,
		63, 62, 60, 57, 53, 48, 42, 35
	};
	return table[n];
}

int64_t Chess::mask(int n)
{
	return 1LL << n;
}

int Chess::to_64(int n)
{
	return (n >> 4 << 3) | (n & 0xF);
}

int Chess::to_x88(int n)
{
	return (n >> 3 << 4) | (n & 7);
}

int Chess::group(int piece)
{
	return piece >= 'a' && piece <= 'z';
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
	godot::ClassDB::bind_static_method(get_class_static(), godot::D_METHOD("rotate_90"), &Chess::rotate_90);
	godot::ClassDB::bind_static_method(get_class_static(), godot::D_METHOD("rotate_45"), &Chess::rotate_45);
	godot::ClassDB::bind_static_method(get_class_static(), godot::D_METHOD("rotate_315"), &Chess::rotate_315);
	godot::ClassDB::bind_static_method(get_class_static(), godot::D_METHOD("to_64"), &Chess::to_64);
	godot::ClassDB::bind_static_method(get_class_static(), godot::D_METHOD("to_x88"), &Chess::to_x88);
	godot::ClassDB::bind_static_method(get_class_static(), godot::D_METHOD("mask"), &Chess::mask);
	godot::ClassDB::bind_static_method(get_class_static(), godot::D_METHOD("group"), &Chess::group);
	godot::ClassDB::bind_static_method(get_class_static(), godot::D_METHOD("is_same_group"), &Chess::is_same_group);
	godot::ClassDB::bind_static_method(get_class_static(), godot::D_METHOD("to_position_int"), &Chess::to_position_int);
	godot::ClassDB::bind_static_method(get_class_static(), godot::D_METHOD("to_position_name"), &Chess::to_position_name);
	godot::ClassDB::bind_static_method(get_class_static(), godot::D_METHOD("create"), &Chess::create);
	godot::ClassDB::bind_static_method(get_class_static(), godot::D_METHOD("from"), &Chess::from);
	godot::ClassDB::bind_static_method(get_class_static(), godot::D_METHOD("to"), &Chess::to);
	godot::ClassDB::bind_static_method(get_class_static(), godot::D_METHOD("extra"), &Chess::extra);
}
