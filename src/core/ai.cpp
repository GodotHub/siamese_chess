#include "ai.hpp"
#include <thread>

void AI::start_search(const godot::Ref<State> &_state, int _group, const godot::Callable &_is_timeup, const godot::Callable &_debug_output)
{
	std::thread thread(&AI::search, this, _state, _group, _is_timeup, _debug_output);
	thread.detach();
}

void AI::_bind_methods()
{
	godot::ClassDB::bind_method(godot::D_METHOD("start_search", "state", "group", "is_timeup", "debug_output"), &AI::start_search);
	godot::ClassDB::bind_method(godot::D_METHOD("search", "state", "group", "is_timeup", "debug_output"), &AI::search);
	godot::ClassDB::bind_method(godot::D_METHOD("get_search_result"), &AI::get_search_result);
}
