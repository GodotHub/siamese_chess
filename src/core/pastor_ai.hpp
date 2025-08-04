#ifndef _PASTOR_AI_H_
#define _PASTOR_AI_H_

#include "ai.hpp"
#include <unordered_map>

using namespace godot;

class PastorAI : public AI {
	GDCLASS(PastorAI, AI);

private:
	Ref<TranspositionTable> transposition_table;
	int max_depth;
	int WIN = 50000;
	int THRESHOLD = 60000;
	std::unordered_map<int, int> piece_value;
	godot::PackedInt32Array directions_diagonal;
	godot::PackedInt32Array directions_straight;
	godot::PackedInt32Array directions_eight_way;
	godot::PackedInt32Array directions_horse;
	std::unordered_map<int, godot::PackedInt32Array> position_value;
public:
	PastorAI();

protected:
	static void _bind_methods();

protected:
	int get_piece_score(int _by, int _piece);
	int evaluate(godot::Ref<State> _state, int _move);
	int compare_move(int a, int b, int best_move, std::array<int, 65536> *history_table = nullptr);
	int quies(godot::Ref<State> _state, int alpha, int beta, int _group = 0);
	godot::PackedInt32Array generate_good_capture_move(godot::Ref<State> _state, int _group);
	int alphabeta(const Ref<State> &_state, int _alpha, int _beta, int _depth, int _group = 0, int _ply = 0, bool _can_null = true, std::array<int, 65536> *_history_table = nullptr, const Callable &_is_timeup = Callable(), const Callable &_debug_output = Callable());
public:
	int search(const Ref<State> &_state, int _group, const Callable &_is_timeup, const Callable &_debug_output) override;
	void set_max_depth(int max_depth);
	int get_max_depth() const;
	void set_transposition_table(const Ref<TranspositionTable> &transposition_table);
	Ref<TranspositionTable> get_transposition_table() const;
};

#endif // _PASTOR_AI_H_