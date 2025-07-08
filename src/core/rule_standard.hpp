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
		virtual godot::String get_end_type(godot::Ref<State>_state);
		virtual godot::Ref<State>parse(godot::String _str);
		virtual godot::String stringify(godot::Ref<State>_state);
		virtual godot::Node3D *get_piece_instance(int _piece);
		virtual bool is_same_camp(int a, int b);
		virtual int get_piece_score(int _by, int _piece);
		virtual bool is_move_valid(godot::Ref<State>_state, int _group, int _move);
		virtual godot::PackedInt32Array generate_premove(godot::Ref<State>_state, int _group);
		virtual godot::PackedInt32Array generate_move(godot::Ref<State>_state, int _group);
		virtual godot::PackedInt32Array generate_valid_move(godot::Ref<State>_state, int _group);
		virtual godot::PackedInt32Array generate_good_capture_move(godot::Ref<State>_state, int _group);
		virtual void apply_move(godot::Ref<State>_state, int _move, godot::Callable _callback_add_piece = godot::Callable(), godot::Callable _callback_capture_piece = godot::Callable(), godot::Callable _callback_move_piece = godot::Callable(), godot::Callable _callback_set_extra = godot::Callable(), godot::Callable _callback_push_history = godot::Callable(), godot::Callable _callback_change_score = godot::Callable());
		virtual int evaluate(godot::Ref<State>_state, int _move);
		virtual int compare_move(int a, int b, int best_move, std::array<int, 65536> *history_table = nullptr);
		virtual int quies(godot::Ref<State>_state, int alpha, int beta, int _group = 0);
		virtual int alphabeta(godot::Ref<State>_state, int _alpha, int _beta, int _depth, int _group = 0, bool _can_null = true, std::array<int, 65536> *_history_table = nullptr, TranspositionTable *_transposition_table = nullptr, godot::Callable _is_timeup = godot::Callable(), godot::Callable _debug_output = godot::Callable());
		virtual void search(godot::Ref<State>_state, int _group, TranspositionTable *_transposition_table = nullptr, godot::Callable _is_timeup = godot::Callable(), int _max_depth = 1000, godot::Callable _debug_output = godot::Callable());
		virtual unsigned long long perft(godot::Ref<State> _state, int _depth, int group);
		static void _bind_methods();
	private:
		int WIN;
		int THRESHOLD;
		std::unordered_map<int, int> piece_value;
		godot::PackedInt32Array directions_diagonal;
		godot::PackedInt32Array directions_straight;
		godot::PackedInt32Array directions_eight_way;
		godot::PackedInt32Array directions_horse;
		std::unordered_map<int, godot::PackedInt32Array> position_value;
		std::unordered_map<int, godot::String> piece_mapping_instance;
		std::unordered_map<int, int> piece_mapping_group;
		
};


#endif