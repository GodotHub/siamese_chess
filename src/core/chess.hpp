#ifndef _CHESS_HPP_
#define _CHESS_HPP_

#include <godot_cpp/godot.hpp>
#include <godot_cpp/classes/object.hpp>

class Chess : public godot::Object
{
	GDCLASS(Chess, godot::Object)
	public:
		Chess();
		static int64_t mask(int n);
		static int rotate_90(int n);
		static int rotate_45(int n);
		static int rotate_315(int n);
		static int rotate_45_length(int n);
		static int rotate_315_length(int n);
		static int rotate_0_shift(int n);
		static int rotate_90_shift(int n);
		static int rotate_45_shift(int n);
		static int rotate_315_shift(int n);
		static int to_64(int n);
		static int to_x88(int n);
		static int group(int piece);
		static bool is_same_group(int piece_1, int piece_2);
		static int to_position_int(godot::String _position_name);
		static godot::String to_position_name(int _position);
		static int create(int _from, int _to, int _extra);
		static int from(int _move);
		static int to(int _move);
		static int extra(int _move);
		static Chess *get_singleton();
		static void _bind_methods();
		inline static int a8() { return 0; }
		inline static int b8() { return 1; }
		inline static int c8() { return 2; }
		inline static int d8() { return 3; }
		inline static int e8() { return 4; }
		inline static int f8() { return 5; }
		inline static int g8() { return 6; }
		inline static int h8() { return 7; }
		inline static int a1() { return 16 * 7; }
		inline static int b1() { return 16 * 7 + 1; }
		inline static int c1() { return 16 * 7 + 2; }
		inline static int d1() { return 16 * 7 + 3; }
		inline static int e1() { return 16 * 7 + 4; }
		inline static int f1() { return 16 * 7 + 5; }
		inline static int g1() { return 16 * 7 + 6; }
		inline static int h1() { return 16 * 7 + 7; }
	private:
		static Chess *singleton;
};

#endif