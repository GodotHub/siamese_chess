#ifndef _RULE_STANDARD_HPP_
#define _RULE_STANDARD_HPP_

#include <unordered_map>
#include <array>
#include <godot_cpp/classes/object.hpp>
#include <godot_cpp/classes/ref.hpp>
#include <state.hpp>

class RuleStandard : public godot::Object
{
	GDCLASS(RuleStandard, Object)
	public:
		RuleStandard();
		godot::String get_end_type(godot::Ref<State> _state);
		godot::Ref<State> parse(godot::String _str);
		godot::Ref<State> create_initial_state();
		godot::Ref<State> create_random_state(int piece_count);
		godot::String stringify(godot::Ref<State> _state);
		bool is_move_valid(godot::Ref<State> _state, int _group, int _move);
		bool is_check(godot::Ref<State> _state, int _group);
		godot::PackedInt32Array generate_premove(godot::Ref<State> _state, int _group);
		godot::PackedInt32Array generate_move(godot::Ref<State> _state, int _group);
		godot::PackedInt32Array generate_valid_move(godot::Ref<State> _state, int _group);
		godot::String get_move_name(godot::Ref<State> _state, int move);
		int name_to_move(godot::Ref<State> _state, godot::String name);
		void apply_move(godot::Ref<State> _state, int _move);
		void apply_move_custom(godot::Ref<State> _state, int _move, godot::Callable _callback_event = godot::Callable());
		uint64_t perft(godot::Ref<State> _state, int _depth, int group);
		static void _bind_methods();
		static RuleStandard *get_singleton();
	private:
		godot::PackedInt32Array directions_diagonal;
		godot::PackedInt32Array directions_straight;
		godot::PackedInt32Array directions_eight_way;
		godot::PackedInt32Array directions_horse;
};

#endif