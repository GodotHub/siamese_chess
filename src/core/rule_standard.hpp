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
		godot::String get_end_type(const godot::Ref<State> &_state);
		godot::Ref<State> parse(const godot::String &_str);
		godot::Ref<State> create_initial_state();
		godot::Ref<State> create_random_state(int piece_count);
		godot::Ref<State> mirror_state(const godot::Ref<State> &_state);
		godot::Ref<State> rotate_state(const godot::Ref<State> &_state);
		godot::Ref<State> swap_group(const godot::Ref<State> &_state);
		godot::String stringify(const godot::Ref<State> &_state);
		bool is_move_valid(const godot::Ref<State> &_state, int _group, int _move);
		bool is_check(const godot::Ref<State> &_state, int _group);
		bool is_blocked(const godot::Ref<State> &_state, int _from, int _to);
		bool is_enemy(const godot::Ref<State> &_state, int _from, int _to);
		bool is_en_passant(const godot::Ref<State> &_state, int _from, int _to);
		godot::PackedInt32Array generate_premove(const godot::Ref<State> &_state, int _group);
		godot::PackedInt32Array generate_move(const godot::Ref<State> &_state, int _group);
		void _internal_generate_move(godot::PackedInt32Array &output, const godot::Ref<State> &_state, int _group);
		godot::PackedInt32Array generate_valid_move(const godot::Ref<State> &_state, int _group);
		void _internal_generate_valid_move(godot::PackedInt32Array &output, const godot::Ref<State> &_state, int _group);
		godot::PackedInt32Array generate_explore_move(const godot::Ref<State> &_state, int _group);
		godot::PackedInt32Array generate_king_path(const godot::Ref<State> &_state, int _from, int _to);
		godot::String get_move_name(const godot::Ref<State> &_state, int move);
		int name_to_move(const godot::Ref<State> &_state, const godot::String &name);
		void apply_move(const godot::Ref<State> &_state, int _move);
		godot::Dictionary apply_move_custom(const godot::Ref<State> &_state, int _move);
		uint64_t perft(const godot::Ref<State> &_state, int _depth, int group);
		static void _bind_methods();
		static RuleStandard *get_singleton();
	private:
		godot::PackedInt32Array directions_diagonal;
		godot::PackedInt32Array directions_straight;
		godot::PackedInt32Array directions_eight_way;
		godot::PackedInt32Array directions_horse;
		int64_t rank_attacks[64][256];
		int64_t file_attacks[64][256];	//将棋盘转置后使用
		int64_t diag_a1h8_attacks[64][256];
		int64_t diag_a8h1_attacks[64][256];
		int64_t horse_attacks[64];
		int64_t king_attacks[64];
		int64_t pawn_attacks[64][4];	//游戏特殊原因，兵会被设定为四种方向
};

#endif