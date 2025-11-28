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

int Chess::rotate_90_reverse(int n)
{
	static const int table[64] = {
		56, 48, 40, 32, 24, 16,  8,  0,
		57, 49, 41, 33, 25, 17,  9,  1,
		58, 50, 42, 34, 26, 18, 10,  2,
		59, 51, 43, 35, 27, 19, 11,  3,
		60, 52, 44, 36, 28, 20, 12,  4,
		61, 53, 45, 37, 29, 21, 13,  5,
		62, 54, 46, 38, 30, 22, 14,  6,
		63, 55, 47, 39, 31, 23, 15,  7
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
int Chess::rotate_45_reverse(int n)
{
	static const int table[64] = {
		               0, 
		             8,  1,
		          16,  9,  2,
		        24, 17, 10,  3,
		      32, 25, 18, 11,  4,
		    40, 33, 26, 19, 12,  5,
		  48, 41, 34, 27, 20, 13,  6,
		56, 49, 42, 35, 28, 21, 14,  7,
		  57, 50, 43, 36, 29, 22, 15,
		    58, 51, 44, 37, 30, 23,
		      59, 52, 45, 38, 31,
		        60, 53, 46, 39,
		          61, 54, 47,
		            62, 55,
		              63,
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

int Chess::rotate_315_reverse(int n)
{
	static const int table[64] = {
		               7, 
		             6, 15,
		           5, 14, 23,
		         4, 13, 22, 31,
		       3, 12, 21, 30, 39,
		     2, 11, 20, 29, 38, 47,
		   1, 10, 19, 28, 37, 46, 55,
		 0,  9, 18, 27, 36, 45, 54, 63,
		   8, 17, 26, 35, 44, 53, 62,
		    16, 25, 34, 43, 52, 61,
		      24, 33, 42, 51, 60,
		        32, 41, 50, 59,
		          40, 49, 58,
		            48, 57,
		              56,
	};
	return table[n];
}
int Chess::rotate_45_length(int n)
{
	static const int table[64] = {
		1, 2, 3, 4, 5, 6, 7, 8,
		2, 3, 4, 5, 6, 7, 8, 7,
		3, 4, 5, 6, 7, 8, 7, 6,
		4, 5, 6, 7, 8, 7, 6, 5,
		5, 6, 7, 8, 7, 6, 5, 4,
		6, 7, 8, 7, 6, 5, 4, 3,
		7, 8, 7, 6, 5, 4, 3, 2,
		8, 7, 6, 5, 4, 3, 2, 1,
	};
	return table[n];
}

int Chess::rotate_315_length(int n)
{
	static const int table[64] = {
		8, 7, 6, 5, 4, 3, 2, 1,
		7, 8, 7, 6, 5, 4, 3, 2,
		6, 7, 8, 7, 6, 5, 4, 3,
		5, 6, 7, 8, 7, 6, 5, 4,
		4, 5, 6, 7, 8, 7, 6, 5,
		3, 4, 5, 6, 7, 8, 7, 6,
		2, 3, 4, 5, 6, 7, 8, 7,
		1, 2, 3, 4, 5, 6, 7, 8,
	};
	return table[n];
}

int Chess::rotate_45_length_mask(int n)
{
	static const int table[64] = {
		(1 << 1) - 1, (1 << 2) - 1, (1 << 3) - 1, (1 << 4) - 1, (1 << 5) - 1, (1 << 6) - 1, (1 << 7) - 1, (1 << 8) - 1,
		(1 << 2) - 1, (1 << 3) - 1, (1 << 4) - 1, (1 << 5) - 1, (1 << 6) - 1, (1 << 7) - 1, (1 << 8) - 1, (1 << 7) - 1,
		(1 << 3) - 1, (1 << 4) - 1, (1 << 5) - 1, (1 << 6) - 1, (1 << 7) - 1, (1 << 8) - 1, (1 << 7) - 1, (1 << 6) - 1,
		(1 << 4) - 1, (1 << 5) - 1, (1 << 6) - 1, (1 << 7) - 1, (1 << 8) - 1, (1 << 7) - 1, (1 << 6) - 1, (1 << 5) - 1,
		(1 << 5) - 1, (1 << 6) - 1, (1 << 7) - 1, (1 << 8) - 1, (1 << 7) - 1, (1 << 6) - 1, (1 << 5) - 1, (1 << 4) - 1,
		(1 << 6) - 1, (1 << 7) - 1, (1 << 8) - 1, (1 << 7) - 1, (1 << 6) - 1, (1 << 5) - 1, (1 << 4) - 1, (1 << 3) - 1,
		(1 << 7) - 1, (1 << 8) - 1, (1 << 7) - 1, (1 << 6) - 1, (1 << 5) - 1, (1 << 4) - 1, (1 << 3) - 1, (1 << 2) - 1,
		(1 << 8) - 1, (1 << 7) - 1, (1 << 6) - 1, (1 << 5) - 1, (1 << 4) - 1, (1 << 3) - 1, (1 << 2) - 1, (1 << 1) - 1,
	};
	return table[n];
}

int Chess::rotate_315_length_mask(int n)
{
	static const int table[64] = {
		(1 << 8) - 1, (1 << 7) - 1, (1 << 6) - 1, (1 << 5) - 1, (1 << 4) - 1, (1 << 3) - 1, (1 << 2) - 1, (1 << 1) - 1,
		(1 << 7) - 1, (1 << 8) - 1, (1 << 7) - 1, (1 << 6) - 1, (1 << 5) - 1, (1 << 4) - 1, (1 << 3) - 1, (1 << 2) - 1,
		(1 << 6) - 1, (1 << 7) - 1, (1 << 8) - 1, (1 << 7) - 1, (1 << 6) - 1, (1 << 5) - 1, (1 << 4) - 1, (1 << 3) - 1,
		(1 << 5) - 1, (1 << 6) - 1, (1 << 7) - 1, (1 << 8) - 1, (1 << 7) - 1, (1 << 6) - 1, (1 << 5) - 1, (1 << 4) - 1,
		(1 << 4) - 1, (1 << 5) - 1, (1 << 6) - 1, (1 << 7) - 1, (1 << 8) - 1, (1 << 7) - 1, (1 << 6) - 1, (1 << 5) - 1,
		(1 << 3) - 1, (1 << 4) - 1, (1 << 5) - 1, (1 << 6) - 1, (1 << 7) - 1, (1 << 8) - 1, (1 << 7) - 1, (1 << 6) - 1,
		(1 << 2) - 1, (1 << 3) - 1, (1 << 4) - 1, (1 << 5) - 1, (1 << 6) - 1, (1 << 7) - 1, (1 << 8) - 1, (1 << 7) - 1,
		(1 << 1) - 1, (1 << 2) - 1, (1 << 3) - 1, (1 << 4) - 1, (1 << 5) - 1, (1 << 6) - 1, (1 << 7) - 1, (1 << 8) - 1,
	};
	return table[n];
}

int Chess::rotate_0_shift(int n)
{
	return (n >> 3) << 3;
}

int Chess::rotate_90_shift(int n)
{
	return (n & 7) << 3;
}

int Chess::rotate_45_shift(int n)
{
	static const int table[64] = {
		 0,  1,  3,  6, 10, 15, 21, 28,
		 1,  3,  6, 10, 15, 21, 28, 36,
		 3,  6, 10, 15, 21, 28, 36, 43,
		 6, 10, 15, 21, 28, 36, 43, 49,
		10, 15, 21, 28, 36, 43, 49, 54,
		15, 21, 28, 36, 43, 49, 54, 58,
		21, 28, 36, 43, 49, 54, 58, 61,
		28, 36, 43, 49, 54, 58, 61, 63,
	};
	return table[n];
}

int Chess::rotate_315_shift(int n)
{
	static const int table[64] = {
		28, 21, 15, 10,  6,  3,  1,  0,
		36, 28, 21, 15, 10,  6,  3,  1,
		43, 36, 28, 21, 15, 10,  6,  3,
		49, 43, 36, 28, 21, 15, 10,  6,
		54, 49, 43, 36, 28, 21, 15, 10,
		58, 54, 49, 43, 36, 28, 21, 15,
		61, 58, 54, 49, 43, 36, 28, 21,
		63, 61, 58, 54, 49, 43, 36, 28
	};
	return table[n];
}

godot::String Chess::print_bit_square(int64_t bit)
{
	godot::String output;
	uint64_t current_bit = bit;
	for (int i = 0; i < 8; i++)
	{
		for (int j = 0; j < 8; j++)
		{
			output += (current_bit & 1) ? '#' : '.';
			output += ' ';
			current_bit >>= 1;
		}
		output += '\n';
	}
	return output;
}

godot::String Chess::print_bit_diamond(int64_t bit)
{
	godot::String output;
	uint64_t current_bit = bit;
	for (int i = 0; i < 8; i++)
	{
		for (int j = 0; j < 8 - i; j++)
		{
			output += ' ';
		}
		for (int j = 0; j < i + 1; j++)
		{
			output += (current_bit & 1) ? '#' : '.';
			output += ' ';
			current_bit >>= 1;
		}
		output += '\n';
	}
	for (int i = 6; i >= 0; i--)
	{
		for (int j = 0; j < 8 - i; j++)
		{
			output += ' ';
		}
		for (int j = 0; j < i + 1; j++)
		{
			output += (current_bit & 1) ? '#' : '.';
			output += ' ';
			current_bit >>= 1;
		}
		output += '\n';
	}
	return output;
}

int64_t Chess::mask(int n)
{
	return 1LL << n;
}

int Chess::population(uint64_t bit)
{
	const uint64_t k1 = 0x5555555555555555;
	const uint64_t k2 = 0x3333333333333333;
	const uint64_t k4 = 0x0f0f0f0f0f0f0f0f;
	const uint64_t kf = 0x0101010101010101;
	bit = bit - ((bit >> 1) & k1);
	bit = (bit & k2) + ((bit >> 2) & k2);
	bit = (bit + (bit >> 4)) & k4;
	bit = (bit * kf) >> 56;
	return (int)bit;
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
	godot::ClassDB::bind_static_method(get_class_static(), godot::D_METHOD("rotate_45_length"), &Chess::rotate_45_length);
	godot::ClassDB::bind_static_method(get_class_static(), godot::D_METHOD("rotate_315_length"), &Chess::rotate_315_length);
	godot::ClassDB::bind_static_method(get_class_static(), godot::D_METHOD("rotate_45_length_mask"), &Chess::rotate_45_length_mask);
	godot::ClassDB::bind_static_method(get_class_static(), godot::D_METHOD("rotate_315_length_mask"), &Chess::rotate_315_length_mask);
	godot::ClassDB::bind_static_method(get_class_static(), godot::D_METHOD("rotate_0_shift"), &Chess::rotate_0_shift);
	godot::ClassDB::bind_static_method(get_class_static(), godot::D_METHOD("rotate_90_shift"), &Chess::rotate_90_shift);
	godot::ClassDB::bind_static_method(get_class_static(), godot::D_METHOD("rotate_45_shift"), &Chess::rotate_45_shift);
	godot::ClassDB::bind_static_method(get_class_static(), godot::D_METHOD("rotate_315_shift"), &Chess::rotate_315_shift);
	godot::ClassDB::bind_static_method(get_class_static(), godot::D_METHOD("to_64"), &Chess::to_64);
	godot::ClassDB::bind_static_method(get_class_static(), godot::D_METHOD("to_x88"), &Chess::to_x88);
	godot::ClassDB::bind_static_method(get_class_static(), godot::D_METHOD("mask"), &Chess::mask);
	godot::ClassDB::bind_static_method(get_class_static(), godot::D_METHOD("population"), &Chess::population);
	godot::ClassDB::bind_static_method(get_class_static(), godot::D_METHOD("group"), &Chess::group);
	godot::ClassDB::bind_static_method(get_class_static(), godot::D_METHOD("is_same_group"), &Chess::is_same_group);
	godot::ClassDB::bind_static_method(get_class_static(), godot::D_METHOD("to_position_int"), &Chess::to_position_int);
	godot::ClassDB::bind_static_method(get_class_static(), godot::D_METHOD("to_position_name"), &Chess::to_position_name);
	godot::ClassDB::bind_static_method(get_class_static(), godot::D_METHOD("create"), &Chess::create);
	godot::ClassDB::bind_static_method(get_class_static(), godot::D_METHOD("from"), &Chess::from);
	godot::ClassDB::bind_static_method(get_class_static(), godot::D_METHOD("to"), &Chess::to);
	godot::ClassDB::bind_static_method(get_class_static(), godot::D_METHOD("extra"), &Chess::extra);
}
