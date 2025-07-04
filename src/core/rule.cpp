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

void Rule::apply_move(godot::Ref<State>_state, int _move)
{

}

int Rule::evaluate(godot::Ref<State>_state, int _move)
{
	return 0;
}

void Rule::search(godot::Ref<State>_state, int _group, TranspositionTable *_transposition_table, godot::Callable _is_timeup, int _max_depth, godot::Callable _debug_output)
{
	
}

void Rule::_bind_methods()
{
	godot::ClassDB::bind_method(godot::D_METHOD("get_end_type"), &Rule::get_end_type);
	godot::ClassDB::bind_method(godot::D_METHOD("parse"), &Rule::parse);
	godot::ClassDB::bind_method(godot::D_METHOD("stringify"), &Rule::stringify);
	godot::ClassDB::bind_method(godot::D_METHOD("generate_premove"), &Rule::generate_premove);
	godot::ClassDB::bind_method(godot::D_METHOD("generate_move"), &Rule::generate_move);
	godot::ClassDB::bind_method(godot::D_METHOD("generate_valid_move"), &Rule::generate_valid_move);
	godot::ClassDB::bind_method(godot::D_METHOD("apply_move"), &Rule::apply_move);
	godot::ClassDB::bind_method(godot::D_METHOD("evaluate"), &Rule::evaluate);
	godot::ClassDB::bind_method(godot::D_METHOD("search"), &Rule::search);
}