#include "zobrist_hash.hpp"
#include <godot_cpp/classes/random_number_generator.hpp>

ZobristHash *ZobristHash::singleton = nullptr;

ZobristHash::ZobristHash()
{
	godot::RandomNumberGenerator *generator = memnew(godot::RandomNumberGenerator);
	generator->set_seed(0);  //固定值
	for (int i = 0; i < 65536; i++)
	{
		randomized[i] = generator->randi() << 32 + generator->randi();
	}
	memfree(generator);
}

ZobristHash *ZobristHash::get_singleton()
{
	if (!singleton)
	{
		singleton = memnew(ZobristHash);
	}
	return singleton;
}

long long ZobristHash::hash_piece(int _piece, int _by)
{
	return (_piece & 0xFF) + (_by << 8);
}

void ZobristHash::_bind_methods()
{
	godot::ClassDB::bind_method(godot::D_METHOD("hash_piece"), &ZobristHash::hash_piece);
}