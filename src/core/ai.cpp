#include "ai.hpp"

void AI::_bind_methods() {
	godot::ClassDB::bind_method(godot::D_METHOD("search", "state", "group", "is_timeup", "debug_output"), &AI::search);
}
