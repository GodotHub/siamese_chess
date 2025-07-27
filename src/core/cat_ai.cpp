#include "cat_ai.hpp"

void CatAI::_bind_methods() {

}

int CatAI::alphabeta(const godot::Ref<State> &_state, int _alpha, int _beta, int _depth, int _group, int _ply, bool _can_null, std::array<int, 65536> *_history_table, const Ref<TranspositionTable> _transposition_table, const godot::Callable &_is_timeup, const godot::Callable &_debug_output)
{
  return 0;
}

void CatAI::init(const Ref<TranspositionTable> &_transposition_table, int max_depth)
{
  this->_transposition_table = _transposition_table.ptr();
  this->max_depth = max_depth;
}

int CatAI::search(const godot::Ref<State> &_state, int _group, const godot::Callable &_is_timeup, const godot::Callable &_debug_output)
{
  return 0;
}
