#ifndef _RULE_STANDARD_HPP_
#define _RULE_STANDARD_HPP_

#include "rule.hpp"
#include <unordered_map>

class RuleStandard : public Rule
{
	GDCLASS(RuleStandard, Rule)
	public:
		virtual godot::String get_end_type(State *_state);
		virtual State *parse(godot::String _str);
		virtual godot::String stringify(State *_state);
		virtual godot::Node3D *get_piece_instance(int _piece);
		virtual bool is_same_camp(int a, int b);
		virtual int get_piece_score(int _by, int _piece);
		virtual bool is_move_valid(State *_state, int _group, int _move);
		virtual godot::PackedInt32Array generate_premove(State *_state, int _group);
		virtual godot::PackedInt32Array generate_move(State *_state, int _group);
		virtual godot::PackedInt32Array generate_valid_move(State *_state, int _group);
		virtual godot::PackedInt32Array generate_good_capture_move(State *_state, int _group);
		virtual void apply_move(State *_state, int _move);
		virtual int evaluate(State *_state, int _move);
		virtual int compare_move(int a, int b, int best_move, godot::Dictionary history_table);
		virtual int quies(State *_state, int alpha, int beta, int _group = 0);
		virtual int alphabeta(State *_state, int _alpha, int _beta, int _depth, int _group = 0, bool _can_null = true, godot::Dictionary _history_table = {}, godot::PackedInt32Array _main_variation = {}, TranspositionTable *_transposition_table = nullptr, godot::Callable _is_timeup = godot::Callable(), godot::Callable _debug_output = godot::Callable());
		virtual void search(State *_state, int _group, godot::PackedInt32Array _main_variation = {}, TranspositionTable *_transposition_table = nullptr, godot::Callable _is_timeup = godot::Callable(), int _max_depth = 1000, godot::Callable _debug_output = godot::Callable());
		static void _bind_methods();
	private:
		static int WIN;
		static int THRESHOLD;
		static std::unordered_map<int, int> piece_value;
		static godot::PackedInt32Array directions_diagonal;
		static godot::PackedInt32Array directions_straight;
		static godot::PackedInt32Array directions_eight_way;
		static godot::PackedInt32Array directions_horse;
		static std::unordered_map<int, godot::PackedInt32Array> position_value;
		static std::unordered_map<int, godot::String> piece_mapping_instance;
		static std::unordered_map<int, int> piece_mapping_group;
		
};


#endif