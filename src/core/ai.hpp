#ifndef __CHESS_AI_H__
#define __CHESS_AI_H__

#include "./state.hpp"
#include "./transposition_table.hpp"
#include <godot_cpp/classes/ref_counted.hpp>
#include <godot_cpp/core/gdvirtual.gen.inc>
#include <godot_cpp/variant/dictionary.hpp>
#include <thread>

class AI : public godot::RefCounted {
	GDCLASS(AI, godot::RefCounted)
protected:
	static void _bind_methods();
	double start_thinking;
	double time_left;
	bool interrupted;
	bool searching;
public:
	void start_search(const godot::Ref<State> &_state, int _group, double _time_left, const godot::Callable &_debug_output);
	void search_thread(const godot::Ref<State> &_state, int _group, const godot::Callable &_debug_output);
	void stop_search();
	bool is_searching();
	double time_passed();
	virtual void search(const godot::Ref<State> &_state, int _group, const godot::Callable &_debug_output) = 0;
	virtual int get_search_result() = 0;
};
#endif // __CHESS_AI_H__