#include "ai.hpp"

void AI::_bind_methods() {
	ClassDB::bind_method(
			D_METHOD("search", "state", "group", "is_timeup", "debug_output"),
			&AI::search);
	ClassDB::bind_method(D_METHOD("init", "args"), (&AI::init));
}
