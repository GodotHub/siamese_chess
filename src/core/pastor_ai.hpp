#ifndef __CAT_AI_H__
#define __CAT_AI_H__

#include "./ai.hpp"

using namespace godot;

class PastorAI : public AI {
	GDCLASS(PastorAI, AI);

private:
	TranspositionTable *_transposition_table;
	int _max_depth;
	int WIN = 50000;
	int THRESHOLD = 60000;

public:
	PastorAI();

protected:
	static void _bind_methods();

private:
	int alphabeta(const Ref<State> &_state, int _alpha, int _beta, int _depth, int _group = 0, int _ply = 0, bool _can_null = true, std::array<int, 65536> *_history_table = nullptr, const Callable &_is_timeup = Callable(), const Callable &_debug_output = Callable());

public:
	int search(const Ref<State> &_state, int _group, const Callable &_is_timeup, const Callable &_debug_output) override;
	void set_max_depth(int max_depth);
	int get_max_depth() const;
	void set_transposition_table(const Ref<TranspositionTable> &transposition_table);
	TranspositionTable* get_transposition_table() const;
};

#endif // __CAT_AI_H__