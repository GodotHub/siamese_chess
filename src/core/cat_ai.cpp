#include "cat_ai.hpp"
#include "rule_standard.hpp"

void CatAI::init(const Ref<TranspositionTable> &transposition_table,
                 int max_depth) {
  this->_transposition_table = transposition_table.ptr();
  this->_max_depth = max_depth;
}

void CatAI::init(const Dictionary &args) {
  init(args["transposition_table"], args["max_depth"]);
}

int CatAI::alphabeta(const godot::Ref<State> &_state, int _alpha, int _beta,
                     int _depth, int _group, int _ply, bool _can_null,
                     std::array<int, 65536> *_history_table,
                     const godot::Callable &_is_timeup,
                     const godot::Callable &_debug_output) {
  if (_transposition_table) {
    int score = _transposition_table->probe_hash(_state->get_zobrist(), _depth,
                                                 _alpha, _beta);
    if (score != 65535) {
      return score;
    }
  }
  if (_depth <= 0) {
    int score =
        RuleStandard::get_singleton()->quies(_state, _alpha, _beta, _group);
    if (_transposition_table) {
      _transposition_table->record_hash(_state->get_zobrist(), _depth, score,
                                        EXACT, 0);
    }
    return score;
  }
  if (_state->has_history(_state->get_zobrist())) {
    return 0; // 视作平局，如果局面不太好，也不会选择负分的下法
  }

  if (_is_timeup.is_valid() && _is_timeup.call()) {
    return RuleStandard::get_singleton()->quies(_state, _alpha, _beta, _group);
  }

  godot::PackedInt32Array move_list;
  unsigned char flag = ALPHA;
  int value = -WIN;
  int best_move = 0;
  if (_transposition_table) {
    best_move = _transposition_table->best_move(_state->get_zobrist());
  }
  if (_can_null) {
    int score =
        -alphabeta(_state, -_beta, -_beta + 1, _depth - 3, 1 - _group, false);
    if (score >= _beta)
      return _beta;
  }
  move_list =
      RuleStandard::get_singleton()->generate_valid_move(_state, _group);
  if (move_list.size() == 0) {
    if (RuleStandard::get_singleton()->is_check(_state, 1 - _group)) {
      return -WIN + _ply;
    } else {
      return 0;
    }
  }
  for (int i = 0; i < move_list.size(); i++) {
    for (int j = move_list.size() - 2; j >= i; j--) {
      if (!RuleStandard::get_singleton()->compare_move(
              move_list[j], move_list[j + 1], best_move, _history_table)) {
        std::swap(move_list[j], move_list[j + 1]);
      }
    }
    _debug_output.call(_state->get_zobrist(), _depth, i, move_list.size());
    godot::Ref<State> test_state = _state->duplicate();
    RuleStandard::get_singleton()->apply_move(
        test_state, move_list[i], godot::Callable(*test_state, "add_piece"),
        godot::Callable(*test_state, "capture_piece"),
        godot::Callable(*test_state, "move_piece"),
        godot::Callable(*test_state, "set_extra"),
        godot::Callable(*test_state, "push_history"),
        godot::Callable(*test_state, "change_score"));
    value =
        -alphabeta(test_state, -_beta, -_alpha, _depth - 1, 1 - _group,
                   _ply + 1, false, _history_table, _is_timeup, _debug_output);

    if (_beta <= value) {
      if (_transposition_table) {
        _transposition_table->record_hash(_state->get_zobrist(), _depth, _beta,
                                          BETA, move_list[i]);
      }
      return _beta;
    }
    if (_alpha < value) {
      best_move = move_list[i];
      _alpha = value;
      flag = EXACT;
      if (_history_table) {
        (*_history_table)[move_list[i] & 0xFFFF] += (1 << _depth);
      }
    }
  }
  if (_transposition_table) {
    _transposition_table->record_hash(_state->get_zobrist(), _depth, _alpha,
                                      flag, best_move);
  }
  return _alpha;
}

int CatAI::search(const godot::Ref<State> &_state, int _group,
                  const godot::Callable &_is_timeup,
                  const godot::Callable &_debug_output) {
  std::array<int, 65536> history_table;
  for (int i = 1; i < _max_depth; i++) {
    alphabeta(_state, -THRESHOLD, THRESHOLD, i, _group, 0, true, &history_table,
              _is_timeup, _debug_output);
    if (_is_timeup.is_valid() && _is_timeup.call()) {
      return 0;
    }
  }
  return _transposition_table->best_move(_state->get_zobrist());
}

void CatAI::_bind_methods() {
  ClassDB::bind_method(
      D_METHOD("search", "state", "group", "is_timeup", "debug_output"),
      &CatAI::search);
  ClassDB::bind_method(
      D_METHOD("init", "args"),
      static_cast<void (CatAI::*)(const Dictionary &)>(&CatAI::init));
}