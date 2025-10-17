#ifndef _PASTOR_ENGINE_H_
#define _PASTOR_ENGINE_H_

#include "engine.hpp"
#include "transposition_table.hpp"
#include "opening_book.hpp"
#include <unordered_map>

class PastorEngine : public ChessEngine
{
	GDCLASS(PastorEngine, ChessEngine)
	public:
		PastorEngine();
		int get_piece_score(int _by, int _piece);
		int evaluate_all(godot::Ref<State> _state);
		int evaluate(godot::Ref<State> _state, int _move);
		int compare_move(int a, int b, int best_move, int killer_1, int killer_2, const godot::Ref<State> &state, std::array<int, 65536> *history_table = nullptr);
		int quies(godot::Ref<State> _state, int score, int alpha, int beta, int _group = 0);
		godot::PackedInt32Array generate_good_capture_move(godot::Ref<State> _state, int _group);
		int alphabeta(const godot::Ref<State> &_state, int score, int _alpha, int _beta, int _depth, int _group = 0, int _ply = 0, bool _can_null = true, std::unordered_map<int, int> *_history_state = nullptr, std::array<int, 65536> *_history_table = nullptr, int *killer_1 = nullptr, int *killer_2 = nullptr, const godot::Callable &_debug_output = godot::Callable());
		void search(const godot::Ref<State> &_state, int _group, const godot::PackedInt32Array &history_state, const godot::Callable &_debug_output) override;
		int get_search_result() override;
		godot::PackedInt32Array get_principal_variation();
		int get_score();
		void set_max_depth(int _max_depth);
		void set_despise_factor(int _despise_factor);
		void set_think_time(double _think_time);
		void set_transposition_table(const godot::Ref<TranspositionTable> &transposition_table);
		godot::Ref<TranspositionTable> get_transposition_table() const;
		static void _bind_methods();
	private:
		godot::Ref<TranspositionTable> transposition_table;
		godot::Ref<OpeningBook> opening_book;
		int max_depth;
		int WIN = 50000;
		int THRESHOLD = 60000;
		int MAX_PLY = 50;
		int despise_factor = -100;
		double think_time;
		int best_move;
		int best_score;
		godot::PackedInt32Array principal_variation;
		std::unordered_map<int, int> piece_value;
		godot::PackedInt32Array directions_diagonal;
		godot::PackedInt32Array directions_straight;
		godot::PackedInt32Array directions_eight_way;
		godot::PackedInt32Array directions_horse;
		std::unordered_map<int, godot::PackedInt32Array> position_value;
};

#endif