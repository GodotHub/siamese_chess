#include <rule.hpp>

godot::String Rule::get_end_type(State *_state)
{
	return "";
}

State *Rule::parse(godot::String _str)
{
	return nullptr;
}

godot::String Rule::stringify(State *_state)
{
	return "";
}

godot::Node3D *Rule::get_piece_instance(int _piece)
{
	return nullptr;
}

godot::PackedInt32Array Rule::generate_premove(State *_state, int _group)
{
	return {};
}

godot::PackedInt32Array Rule::generate_move(State *_state, int _group)
{
	return {};
}

godot::PackedInt32Array Rule::generate_valid_move(State *_state, int _group)
{
	return {};
}

void Rule::apply_move(State *_state, int _move)
{

}

int Rule::evaluate(State *_state, int _move)
{
	return 0;
}

void Rule::search(State *_state, int _group, godot::PackedInt32Array _main_variation, TranspositionTable *_transposition_table, godot::Callable _is_timeup, int _max_depth, godot::Callable _debug_output)
{

}

void Rule::_bind_methods()
{
	godot::ClassDB::bind_method(godot::D_METHOD("get_end_type"), &Rule::get_end_type);
	godot::ClassDB::bind_method(godot::D_METHOD("parse"), &Rule::parse);
	godot::ClassDB::bind_method(godot::D_METHOD("stringify"), &Rule::stringify);
	godot::ClassDB::bind_method(godot::D_METHOD("get_piece_instance"), &Rule::get_piece_instance);
	godot::ClassDB::bind_method(godot::D_METHOD("generate_premove"), &Rule::generate_premove);
	godot::ClassDB::bind_method(godot::D_METHOD("generate_move"), &Rule::generate_move);
	godot::ClassDB::bind_method(godot::D_METHOD("generate_valid_move"), &Rule::generate_valid_move);
	godot::ClassDB::bind_method(godot::D_METHOD("apply_move"), &Rule::apply_move);
	godot::ClassDB::bind_method(godot::D_METHOD("evaluate"), &Rule::evaluate);
	godot::ClassDB::bind_method(godot::D_METHOD("search"), &Rule::search);
}