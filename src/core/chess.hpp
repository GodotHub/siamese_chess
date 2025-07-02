#ifndef _CHESS_HPP_
#define _CHESS_HPP_

#include <godot_cpp/godot.hpp>
#include <godot_cpp/classes/object.hpp>

class Chess : public godot::Object
{
	GDCLASS(Chess, godot::Object)
	public:
		Chess();
		static int to_position_int(godot::String _position_name);
		static godot::String to_position_name(int _position);
		static int create(int _from, int _to, int _extra);
		static int from(int _move);
		static int to(int _move);
		static int extra(int _move);
		static Chess *get_singleton();
		static void _bind_methods();
		const static int a8 = 0;
		const static int b8 = 1;
		const static int c8 = 2;
		const static int d8 = 3;
		const static int e8 = 4;
		const static int f8 = 5;
		const static int g8 = 6;
		const static int h8 = 7;
		const static int a1 = 16 * 7;
		const static int b1 = 16 * 7;
		const static int c1 = 16 * 7 + 2;
		const static int d1 = 16 * 7 + 3;
		const static int e1 = 4;
		const static int f1 = 16 * 7 + 5;
		const static int g1 = 16 * 7 + 6;
		const static int h1 = 16 * 7 + 7;
	private:
		static Chess *singleton;
};

#endif