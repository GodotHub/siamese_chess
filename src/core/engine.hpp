#ifndef _ENGINE_H_
#define _ENGINE_H_

#include "./state.hpp"
#include "./transposition_table.hpp"
#include <godot_cpp/classes/ref_counted.hpp>
#include <godot_cpp/core/gdvirtual.gen.inc>
#include <godot_cpp/variant/dictionary.hpp>
#include <thread>

class Engine : public godot::RefCounted
{
	GDCLASS(Engine, godot::RefCounted)
	public:
		void start_search(const godot::Ref<State> &_state, int _group, const godot::PackedInt32Array &history_state, const godot::Callable &_debug_output);
		void search_thread(const godot::Ref<State> &_state, int _group, const godot::PackedInt32Array &history_state, const godot::Callable &_debug_output);
		void stop_search();
		bool is_searching();
		double time_passed();
		virtual void search(const godot::Ref<State> &_state, int _group, const godot::PackedInt32Array &history_state, const godot::Callable &_debug_output) = 0;
		virtual int get_search_result() = 0;
	protected:
		static void _bind_methods();
		double start_thinking;
		bool interrupted;
		bool searching;
};
#endif