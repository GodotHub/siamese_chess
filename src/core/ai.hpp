#ifndef __CHESS_AI_H__
#define __CHESS_AI_H__

#include "./state.hpp"
#include "./transposition_table.hpp"
#include <godot_cpp/classes/ref_counted.hpp>
#include <godot_cpp/core/gdvirtual.gen.inc>
#include <godot_cpp/variant/dictionary.hpp>

using namespace godot;

class AI : public RefCounted {
	GDCLASS(AI, RefCounted);

protected:
	static void _bind_methods();

public:
	virtual int search(const godot::Ref<State> &_state, int _group, const godot::Callable &_is_timeup, const godot::Callable &_debug_output) = 0;
};
#endif // __CHESS_AI_H__