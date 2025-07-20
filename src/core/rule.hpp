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
		virtual godot::String get_end_type(godot::Ref<State> _state);
		virtual godot::Ref<State> parse(godot::String _str);
		virtual godot::String stringify(godot::Ref<State> _state);
		virtual bool is_check(godot::Ref<State> _state, int _group);
		virtual godot::PackedInt32Array generate_premove(godot::Ref<State> _state, int _group);
		virtual godot::PackedInt32Array generate_move(godot::Ref<State> _state, int _group);
		virtual godot::PackedInt32Array generate_valid_move(godot::Ref<State> _state, int _group);
		virtual godot::String get_move_name(godot::Ref<State> _state, int move);
		virtual void apply_move(godot::Ref<State> _state, int _move, godot::Callable _callback_add_piece = godot::Callable(), godot::Callable _callback_capture_piece = godot::Callable(), godot::Callable _callback_move_piece = godot::Callable(), godot::Callable _callback_set_extra = godot::Callable(), godot::Callable _callback_push_history = godot::Callable(), godot::Callable _callback_change_score = godot::Callable());
		virtual int evaluate(godot::Ref<State> _state, int _move);
		virtual void search(godot::Ref<State> _state, int _group, TranspositionTable *_transposition_table, godot::Callable _is_timeup, int _max_depth, godot::Callable _debug_output);
		virtual unsigned long long perft(godot::Ref<State> _state, int _depth, int group);
		static void _bind_methods();
	private:
};

#endif