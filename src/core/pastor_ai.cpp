#include "pastor_ai.hpp"
#include "rule_standard.hpp"
#include <godot_cpp/core/error_macros.hpp>
#include <godot_cpp/classes/file_access.hpp>

PastorAI::PastorAI() {
	_transposition_table.instantiate();
	_max_depth = 100;
}

int PastorAI::alphabeta(const godot::Ref<State> &_state, int _alpha, int _beta, int _depth, int _group, int _ply, bool _can_null, std::array<int, 65536> *_history_table, const godot::Callable &_is_timeup, const godot::Callable &_debug_output) {
	if (!_transposition_table.is_null()) {
		int score = _transposition_table->probe_hash(_state->get_zobrist(), _depth, _alpha, _beta);
		if (score != 65535) {
			return score;
		}
	}
	if (_depth <= 0) {
		int score = RuleStandard::get_singleton()->quies(_state, _alpha, _beta, _group);
		if (!_transposition_table.is_null()) {
			_transposition_table->record_hash(_state->get_zobrist(), _depth, score, EXACT, 0);
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
	if (!_transposition_table.is_null()) {
		best_move = _transposition_table->best_move(_state->get_zobrist());
	}
	if (_can_null) {
		int score = -alphabeta(_state, -_beta, -_beta + 1, _depth - 3, 1 - _group, false);
		if (score >= _beta)
			return _beta;
	}
	move_list = RuleStandard::get_singleton()->generate_valid_move(_state, _group);
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
		RuleStandard::get_singleton()->apply_move(test_state, move_list[i], godot::Callable(*test_state, "add_piece"), godot::Callable(*test_state, "capture_piece"), godot::Callable(*test_state, "move_piece"), godot::Callable(*test_state, "set_extra"), godot::Callable(*test_state, "push_history"), godot::Callable(*test_state, "change_score"));
		value = -alphabeta(test_state, -_beta, -_alpha, _depth - 1, 1 - _group, _ply + 1, false, _history_table, _is_timeup, _debug_output);

		if (_beta <= value) {
			if (!_transposition_table.is_null()) {
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
	if (!_transposition_table.is_null()) {
		_transposition_table->record_hash(_state->get_zobrist(), _depth, _alpha, flag, best_move);
	}
	return _alpha;
}

int PastorAI::search(const godot::Ref<State> &_state, int _group, const godot::Callable &_is_timeup, const godot::Callable &_debug_output) {
	std::array<int, 65536> history_table;
	for (int i = 1; i < _max_depth; i++) {
		alphabeta(_state, -THRESHOLD, THRESHOLD, i, _group, 0, true, &history_table, _is_timeup, _debug_output);
		if (_is_timeup.is_valid() && _is_timeup.call()) {
			return _transposition_table->best_move(_state->get_zobrist());
		}
	}
	return _transposition_table->best_move(_state->get_zobrist());
}
// FIXME: r4rk1/pQ3pbp/3p1np1/4p3/2P5/1PN5/2qB1PPP/n2K2NR w - - 0 1

void PastorAI::set_max_depth(int max_depth) {
	this->_max_depth = max_depth;
}

int PastorAI::get_max_depth() const {
	return this->_max_depth;
}

void PastorAI::set_transposition_table(const Ref<TranspositionTable> &transposition_table) {
	this->_transposition_table = transposition_table;
}

Ref<TranspositionTable> PastorAI::get_transposition_table() const {
	return this->_transposition_table;
}

void PastorAI::_bind_methods() {
	ClassDB::bind_method(D_METHOD("search", "state", "group", "is_timeup", "debug_output"), &PastorAI::search);
	ClassDB::bind_method(D_METHOD("set_max_depth", "max_depth"), &PastorAI::set_max_depth);
	ClassDB::bind_method(D_METHOD("get_max_depth"), &PastorAI::get_max_depth);
	// ClassDB::bind_method(D_METHOD("set_transposition_table", "transposition_table"), &PastorAI::set_transposition_table);
	ClassDB::bind_method(D_METHOD("get_transposition_table"), &PastorAI::get_transposition_table);
	ADD_PROPERTY(PropertyInfo(Variant::INT, "max_depth"), "set_max_depth", "get_max_depth");
	// ADD_PROPERTY(PropertyInfo(Variant::OBJECT, "transposition_table"), "set_transposition_table", "get_transposition_table");
}