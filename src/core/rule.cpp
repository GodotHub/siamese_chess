#include <rule.hpp>

godot::String Rule::get_end_type(godot::Ref<State>_state)
{
	return "";
}

godot::Ref<State>Rule::parse(godot::String _str)
{
	return nullptr;
}

godot::String Rule::stringify(godot::Ref<State>_state)
{
	return "";
}

bool Rule::is_check(godot::Ref<State> _state, int _group)
{
	return false;
}

godot::PackedInt32Array Rule::generate_premove(godot::Ref<State>_state, int _group)
{
	return {};
}

godot::PackedInt32Array Rule::generate_move(godot::Ref<State>_state, int _group)
{
	return {};
}

godot::PackedInt32Array Rule::generate_valid_move(godot::Ref<State>_state, int _group)
{
	return {};
}

godot::String Rule::get_move_name(godot::Ref<State> _state, int move)
{
	return "";
}

void Rule::apply_move(godot::Ref<State>_state, int _move, godot::Callable _callback_add_piece, godot::Callable _callback_capture_piece, godot::Callable _callback_move_piece, godot::Callable _callback_set_extra, godot::Callable _callback_push_history, godot::Callable _callback_change_score)
{

}

int Rule::evaluate(godot::Ref<State>_state, int _move)
{
	return 0;
}

void Rule::search(godot::Ref<State>_state, int _group, TranspositionTable *_transposition_table, godot::Callable _is_timeup, int _max_depth, godot::Callable _debug_output)
{
	
}

unsigned long long Rule::perft(godot::Ref<State> _state, int _depth, int group)
{
	if (_depth == 0)
	{
		return 1ULL;
	}
	godot::PackedInt32Array move_list = generate_valid_move(_state, group);
	unsigned long long cnt = 0;
	if (_depth == 1)
	{
		return move_list.size();
	}
	for (int i = 0; i < move_list.size(); i++)
	{
		godot::Ref<State> test_state = _state->duplicate();
		apply_move(test_state, move_list[i], godot::Callable(*test_state, "add_piece"), godot::Callable(*test_state, "capture_piece"), godot::Callable(*test_state, "move_piece"), godot::Callable(*test_state, "set_extra"), godot::Callable(*test_state, "push_history"), godot::Callable(*test_state, "change_score"));
		cnt += perft(test_state, _depth - 1, 1 - group);
	}
	return cnt;
}

void Rule::_bind_methods()
{
	godot::ClassDB::bind_method(godot::D_METHOD("get_end_type"), &Rule::get_end_type);
	godot::ClassDB::bind_method(godot::D_METHOD("parse"), &Rule::parse);
	godot::ClassDB::bind_method(godot::D_METHOD("stringify"), &Rule::stringify);
	godot::ClassDB::bind_method(godot::D_METHOD("is_check"), &Rule::is_check);
	godot::ClassDB::bind_method(godot::D_METHOD("generate_premove"), &Rule::generate_premove);
	godot::ClassDB::bind_method(godot::D_METHOD("generate_move"), &Rule::generate_move);
	godot::ClassDB::bind_method(godot::D_METHOD("generate_valid_move"), &Rule::generate_valid_move);
	godot::ClassDB::bind_method(godot::D_METHOD("get_move_name"), &Rule::get_move_name);
	godot::ClassDB::bind_method(godot::D_METHOD("apply_move"), &Rule::apply_move);
	godot::ClassDB::bind_method(godot::D_METHOD("evaluate"), &Rule::evaluate);
	godot::ClassDB::bind_method(godot::D_METHOD("search"), &Rule::search);
	godot::ClassDB::bind_method(godot::D_METHOD("perft"), &Rule::perft);
}