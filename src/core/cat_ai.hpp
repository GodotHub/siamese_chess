#ifndef __CAT_AI_H__
#define __CAT_AI_H__

#include "./ai.hpp"

using namespace godot;

class CatAI : public AI {
private:
  TranspositionTable *_transposition_table;
  int max_depth = 100;

protected:
  static void _bind_methods();

private:
  int alphabeta(const godot::Ref<State> &_state, int _alpha, int _beta,
                int _depth, int _group = 0, int _ply = 0, bool _can_null = true,
                std::array<int, 65536> *_history_table = nullptr,
                const Ref<TranspositionTable> _transposition_table = nullptr,
                const godot::Callable &_is_timeup = godot::Callable(),
                const godot::Callable &_debug_output = godot::Callable());

public:
  void init(const Ref<TranspositionTable> &_transposition_table, int max_depth);
  int search(const godot::Ref<State> &_state, int _group,
             const godot::Callable &_is_timeup,
             const godot::Callable &_debug_output);
};

#endif // __CAT_AI_H__