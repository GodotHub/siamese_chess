#include "engine.hpp"
#include <godot_cpp/classes/time.hpp>
#include <thread>

void Engine::start_search(const godot::Ref<State> &_state, int _group, const godot::PackedInt32Array &history_state, const godot::Callable &_debug_output)
{
	searching = true;
	interrupted = false;
	start_thinking = godot::Time::get_singleton()->get_unix_time_from_system();
	std::thread thread(&Engine::search_thread, this, _state->duplicate(), _group, history_state, _debug_output);
	thread.detach();
}

void Engine::search_thread(const godot::Ref<State> &_state, int _group, const godot::PackedInt32Array &history_state, const godot::Callable &_debug_output)
{
	search(_state, _group, history_state, _debug_output);
	call_deferred("emit_signal", "search_finished");
	searching = false;
}

void Engine::stop_search()
{
	interrupted = true;
}

bool Engine::is_searching()
{
	return searching;
}

double Engine::time_passed()
{
	return godot::Time::get_singleton()->get_unix_time_from_system() - start_thinking;
}

void Engine::_bind_methods()
{
	godot::ClassDB::bind_method(godot::D_METHOD("start_search"), &Engine::start_search);
	godot::ClassDB::bind_method(godot::D_METHOD("stop_search"), &Engine::stop_search);
	godot::ClassDB::bind_method(godot::D_METHOD("is_searching"), &Engine::is_searching);
	godot::ClassDB::bind_method(godot::D_METHOD("search"), &Engine::search);
	godot::ClassDB::bind_method(godot::D_METHOD("get_search_result"), &Engine::get_search_result);
}
