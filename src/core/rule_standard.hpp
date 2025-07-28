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
		virtual bool is_same_camp(int a, int b);
		virtual int get_piece_score(int _by, int _piece);
		virtual bool is_move_valid(godot::Ref<State> _state, int _group, int _move);
		virtual bool is_check(godot::Ref<State> _state, int _group);
		virtual godot::PackedInt32Array generate_premove(godot::Ref<State> _state, int _group);
		virtual godot::PackedInt32Array generate_move(godot::Ref<State> _state, int _group);
		virtual godot::PackedInt32Array generate_valid_move(godot::Ref<State> _state, int _group);
		virtual godot::PackedInt32Array generate_good_capture_move(godot::Ref<State> _state, int _group);
		virtual godot::String get_move_name(godot::Ref<State> _state, int move);
		virtual void apply_move(godot::Ref<State> _state, int _move, godot::Callable _callback_add_piece = godot::Callable(), godot::Callable _callback_capture_piece = godot::Callable(), godot::Callable _callback_move_piece = godot::Callable(), godot::Callable _callback_set_extra = godot::Callable(), godot::Callable _callback_push_history = godot::Callable(), godot::Callable _callback_change_score = godot::Callable());
		virtual int evaluate(godot::Ref<State> _state, int _move);
		virtual int compare_move(int a, int b, int best_move, std::array<int, 65536> *history_table = nullptr);
		virtual int quies(godot::Ref<State> _state, int alpha, int beta, int _group = 0);
		static void _bind_methods();
		static RuleStandard *get_singleton();
	private:
		std::unordered_map<int, int> piece_value;
		godot::PackedInt32Array directions_diagonal;
		godot::PackedInt32Array directions_straight;
		godot::PackedInt32Array directions_eight_way;
		godot::PackedInt32Array directions_horse;
		std::unordered_map<int, godot::PackedInt32Array> position_value;
};


#endif