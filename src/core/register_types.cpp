#include "register_types.hpp"

#include <gdextension_interface.h>
#include <godot_cpp/core/defs.hpp>
#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/classes/engine.hpp>
#include <godot_cpp/godot.hpp>

#include "chess.hpp"
#include "rule_standard.hpp"
#include "state.hpp"
#include "opening_book.hpp"
#include "transposition_table.hpp"
#include "zobrist_hash.hpp"
#include "ai.hpp"
#include "pastor_ai.hpp"
#include "violet_ai.hpp"

void initialize_siamese_module(godot::ModuleInitializationLevel p_level)
{
	if (p_level != godot::MODULE_INITIALIZATION_LEVEL_SCENE)
	{
		return;
	}

	godot::ClassDB::register_class<Chess>();
	godot::ClassDB::register_class<RuleStandard>();
	godot::ClassDB::register_class<State>();
	godot::ClassDB::register_class<OpeningBook>();
	godot::ClassDB::register_class<TranspositionTable>();
	godot::ClassDB::register_class<ZobristHash>();
	godot::ClassDB::register_abstract_class<AI>();
	godot::ClassDB::register_class<PastorAI>();
	godot::ClassDB::register_class<NNUE>();
	godot::ClassDB::register_class<VioletAI>();
	
	godot::Engine::get_singleton()->register_singleton("Chess", Chess::get_singleton());
	godot::Engine::get_singleton()->register_singleton("ZobristHash", ZobristHash::get_singleton());
	godot::Engine::get_singleton()->register_singleton("RuleStandard", RuleStandard::get_singleton());
}

void uninitialize_siamese_module(godot::ModuleInitializationLevel p_level) {
	if (p_level != godot::MODULE_INITIALIZATION_LEVEL_SCENE)
	{
		return;
	}
}

// Initialization.
extern "C"
{
	GDExtensionBool GDE_EXPORT siamese_library_init(GDExtensionInterfaceGetProcAddress p_get_proc_address, GDExtensionClassLibraryPtr p_library, GDExtensionInitialization *r_initialization)
	{
		godot::GDExtensionBinding::InitObject init_obj(p_get_proc_address, p_library, r_initialization);
		init_obj.register_initializer(initialize_siamese_module);
		init_obj.register_terminator(uninitialize_siamese_module);
		init_obj.set_minimum_library_initialization_level(godot::MODULE_INITIALIZATION_LEVEL_SCENE);
		return init_obj.init();
	}
}