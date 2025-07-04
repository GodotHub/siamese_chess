#ifndef _RULE_HPP_
#define _RULE_HPP_

#include <godot_cpp/godot.hpp>
#include <godot_cpp/classes/ref_counted.hpp>
#include <godot_cpp/classes/node3d.hpp>
#include "state.hpp"
#include "transposition_table.hpp"

class Rule : public godot::Object
{
	GDCLASS(Rule, Object)
	public:
		virtual godot::String get_end_type(State *_state);
		virtual State *parse(godot::String _str);
		virtual godot::String stringify(State *_state);
		virtual godot::PackedInt32Array generate_premove(State *_state, int _group);
		virtual godot::PackedInt32Array generate_move(State *_state, int _group);
		virtual godot::PackedInt32Array generate_valid_move(State *_state, int _group);
		virtual void apply_move(State *_state, int _move);
		virtual int evaluate(State *_state, int _move);
		virtual void search(State *_state, int _group, TranspositionTable *_transposition_table, godot::Callable _is_timeup, int _max_depth, godot::Callable _debug_output);
		static void _bind_methods();
	private:
};

#endif