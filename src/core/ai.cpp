#include "ai.hpp"
#include <godot_cpp/classes/time.hpp>
#include <thread>

void AI::start_search(const godot::Ref<State> &_state, int _group, double _time_left, const godot::Callable &_debug_output)
{
	searching = true;
	interrupted = false;
	start_thinking = godot::Time::get_singleton()->get_unix_time_from_system();
	time_left = _time_left;
	std::thread thread(&AI::search_thread, this, _state->duplicate(), _group, _debug_output);
	thread.detach();
}

void AI::search_thread(const godot::Ref<State> &_state, int _group, const godot::Callable &_debug_output)
{
	search(_state, _group, _debug_output);
	call_deferred("emit_signal", "search_finished");
	searching = false;
}

void AI::stop_search()
{
	interrupted = true;
}

bool AI::is_searching()
{
	return searching;
}

double AI::time_passed()
{
	return godot::Time::get_singleton()->get_unix_time_from_system() - start_thinking;
}

void AI::_bind_methods()
{
	godot::ClassDB::bind_method(godot::D_METHOD("start_search", "state", "group", "time_left", "debug_output"), &AI::start_search);
	godot::ClassDB::bind_method(godot::D_METHOD("stop_search"), &AI::stop_search);
	godot::ClassDB::bind_method(godot::D_METHOD("is_searching"), &AI::is_searching);
	godot::ClassDB::bind_method(godot::D_METHOD("search", "state", "group", "debug_output"), &AI::search);
	godot::ClassDB::bind_method(godot::D_METHOD("get_search_result"), &AI::get_search_result);
}
