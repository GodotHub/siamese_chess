#ifndef _RULE_STANDARD_HPP_
#define _RULE_STANDARD_HPP_

#include "rule.hpp"
#include <unordered_map>
#include <array>

class RuleStandard : public Rule
{
	GDCLASS(RuleStandard, Rule)
	public:
		RuleStandard();
		virtual godot::String get_end_type(godot::Ref<State> _state);
		virtual godot::Ref<State> parse(godot::String _str);
		virtual godot::String stringify(godot::Ref<State> _state);
		virtual bool is_move_valid(godot::Ref<State> _state, int _group, int _move);
		virtual bool is_check(godot::Ref<State> _state, int _group);
		virtual godot::PackedInt32Array generate_premove(godot::Ref<State> _state, int _group);
		virtual godot::PackedInt32Array generate_move(godot::Ref<State> _state, int _group);
		virtual godot::PackedInt32Array generate_valid_move(godot::Ref<State> _state, int _group);
		virtual godot::String get_move_name(godot::Ref<State> _state, int move);
		virtual int name_to_move(godot::Ref<State> _state, godot::String name);
		virtual void apply_move(godot::Ref<State> _state, int _move);
		virtual void apply_move_custom(godot::Ref<State> _state, int _move, godot::Callable _callback_add_piece = godot::Callable(), godot::Callable _callback_capture_piece = godot::Callable(), godot::Callable _callback_move_piece = godot::Callable());
		static void _bind_methods();
		static RuleStandard *get_singleton();
	private:
		godot::PackedInt32Array directions_diagonal;
		godot::PackedInt32Array directions_straight;
		godot::PackedInt32Array directions_eight_way;
		godot::PackedInt32Array directions_horse;
};


#endif