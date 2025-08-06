#ifndef _PASTOR_AI_H_
#define _PASTOR_AI_H_

#include "ai.hpp"
#include "transposition_table.hpp"
#include "opening_book.hpp"
#include <unordered_map>

class PastorAI : public AI {
	GDCLASS(PastorAI, AI)

private:
	godot::Ref<TranspositionTable> transposition_table;
	godot::Ref<OpeningBook> opening_book;
	int max_depth;
	int WIN = 50000;
	int THRESHOLD = 60000;
	int best_move;
	std::unordered_map<int, int> piece_value;
	godot::PackedInt32Array directions_diagonal;
	godot::PackedInt32Array directions_straight;
	godot::PackedInt32Array directions_eight_way;
	godot::PackedInt32Array directions_horse;
	std::unordered_map<int, godot::PackedInt32Array> position_value;
	int best_move;
public:
	PastorAI();

protected:
	static void _bind_methods();

protected:
	int get_piece_score(int _by, int _piece);
	int evaluate(godot::Ref<State> _state, int _move);
	int compare_move(int a, int b, int best_move, std::array<int, 65536> *history_table = nullptr);
	godot::PackedInt32Array generate_good_capture_move(godot::Ref<State> _state, int _group);
	int alphabeta(const godot::Ref<State> &_state, int _alpha, int _beta, int _depth, int _group = 0, int _ply = 0, bool _can_null = true, std::array<int, 65536> *_history_table = nullptr, int *killer_1 = nullptr, int *killer_2 = nullptr, const godot::Callable &_is_timeup = godot::Callable(), const godot::Callable &_debug_output = godot::Callable());
public:
	void search(const godot::Ref<State> &_state, int _group, const godot::Callable &_is_timeup, const godot::Callable &_debug_output) override;
	int get_search_result() override;
	void set_max_depth(int max_depth);
	int get_max_depth() const;
	void set_transposition_table(const godot::Ref<TranspositionTable> &transposition_table);
	godot::Ref<TranspositionTable> get_transposition_table() const;
};

#endif // _PASTOR_AI_H_