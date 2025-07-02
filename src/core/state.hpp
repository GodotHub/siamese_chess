#ifndef _STATE_HPP_
#define _STATE_HPP_

#include <godot_cpp/classes/ref_counted.hpp>
#include <godot_cpp/variant/packed_int32_array.hpp>
#include <godot_cpp/templates/hash_set.hpp>

class Rule;

class State : public godot::RefCounted
{
	GDCLASS(State, RefCounted)
	public:
		State();
		State *duplicate();
		int get_piece(int _by);
		int has_piece(int _by);
		void add_piece(int _by, int _piece);
		void capture_piece(int _by);
		void move_piece(int _from, int _to);
		int get_extra(int _index);
		void set_extra(int _index, int _value);
		void reserve_extra(int _size);
		long long get_zobrist();
		int has_history(long long _zobrist);
		void push_history(long long _zobrist);
		int get_relative_score(int _group);
		static void _bind_methods();
	private:
		int pieces[128];
		godot::PackedInt32Array extra;
		godot::HashMap<long long, int> history;
		long long zobrist = 0;
		int score = 0;
};

#endif