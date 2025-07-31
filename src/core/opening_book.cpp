#include "opening_book.hpp"
#include <godot_cpp/classes/file_access.hpp>
#include <godot_cpp/classes/json.hpp>

void OpeningBook::load_file(godot::String _path)
{
	godot::Ref<godot::FileAccess> file = godot::FileAccess::open(_path, godot::FileAccess::ModeFlags::READ);
	opening_book = godot::JSON::parse_string(file->get_as_text());
	file->close();
}

void OpeningBook::save_file(godot::String _path)
{
	godot::Ref<godot::FileAccess> file = godot::FileAccess::open(_path, godot::FileAccess::ModeFlags::WRITE);
	file->store_string(godot::JSON::stringify(opening_book, "\t"));
	file->close();
}

bool OpeningBook::has_record(godot::Ref<State> _state)
{
	return opening_book.has(godot::String::num_int64(_state->get_zobrist()));
}

godot::String OpeningBook::get_opening_name(godot::Ref<State> _state)
{
	return godot::Dictionary(opening_book.get(godot::String::num_int64(_state->get_zobrist()), godot::Dictionary())).get("name", "");
}

godot::String OpeningBook::get_opening_description(godot::Ref<State> _state)
{
	return godot::Dictionary(opening_book.get(godot::String::num_int64(_state->get_zobrist()), godot::Dictionary())).get("description", "");
}

godot::PackedInt32Array OpeningBook::get_suggest_move(godot::Ref<State> _state)
{

}

void OpeningBook::set_opening(godot::Ref<State> _state, godot::String name, godot::String description)
{
	godot::Dictionary dict;
	dict["name"] = name;
	dict["description"] = description;
	opening_book[godot::String::num_int64(_state->get_zobrist())] = dict;
}

void OpeningBook::_bind_methods()
{
	godot::ClassDB::bind_method(godot::D_METHOD("load_file"), &OpeningBook::load_file);
	godot::ClassDB::bind_method(godot::D_METHOD("save_file"), &OpeningBook::save_file);
	godot::ClassDB::bind_method(godot::D_METHOD("has_record"), &OpeningBook::has_record);
	godot::ClassDB::bind_method(godot::D_METHOD("get_opening_name"), &OpeningBook::get_opening_name);
	godot::ClassDB::bind_method(godot::D_METHOD("get_opening_description"), &OpeningBook::get_opening_description);
	godot::ClassDB::bind_method(godot::D_METHOD("get_suggest_move"), &OpeningBook::get_suggest_move);
	godot::ClassDB::bind_method(godot::D_METHOD("set_opening"), &OpeningBook::set_opening);
}
