#ifndef _STATE_HPP_
#define _STATE_HPP_

#include <godot_cpp/classes/ref_counted.hpp>
#include <godot_cpp/variant/packed_int32_array.hpp>
#include <unordered_map>

class Rule;

class State : public godot::RefCounted
{
	GDCLASS(State, RefCounted)
	public:
		State();
		godot::Ref<State>duplicate();
		int get_piece(int _by);
		int has_piece(int _by);
		void add_piece(int _by, int _piece);
		void capture_piece(int _by);
		void move_piece(int _from, int _to);
		int get_extra(int _index);
		void set_extra(int _index, int _value);
		void reserve_extra(int _size);
		void change_score(int delta);
		int64_t get_zobrist();
		int has_history(int64_t _zobrist);
		void push_history(int64_t _zobrist);
		int get_relative_score(int _group);
		static void _bind_methods();
	private:
		int pieces[128];
		godot::PackedInt32Array extra;
		std::unordered_map<int64_t, int> history;
		int64_t zobrist = 0;
		int score = 0;
};

#endif