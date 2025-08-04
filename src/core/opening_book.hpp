#ifndef _OPENING_BOOK_HPP_
#define _OPENING_BOOK_HPP_


#include <godot_cpp/godot.hpp>
#include <godot_cpp/classes/object.hpp>
#include "state.hpp"
#include <map>

struct Opening
{
	godot::String name;
	godot::String description;
	godot::PackedInt32Array move;
};

class OpeningBook : public godot::Object
{
	GDCLASS(OpeningBook, Object)
	public:
		void load_file(godot::String _path);
		void save_file(godot::String _path);
		bool has_record(godot::Ref<State> _state);
		godot::String get_opening_name(godot::Ref<State> _state);
		godot::String get_opening_description(godot::Ref<State> _state);
		godot::PackedInt32Array get_suggest_move(godot::Ref<State> _state);
		void set_opening(godot::Ref<State> _state, const godot::String &name, const godot::String &description, const godot::PackedInt32Array &move);
		static void _bind_methods();
	private:
		std::map<int64_t, Opening> opening_book;
};


#endif