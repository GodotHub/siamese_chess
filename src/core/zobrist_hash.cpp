#include "zobrist_hash.hpp"
#include <godot_cpp/classes/random_number_generator.hpp>
#include <random>

ZobristHash *ZobristHash::singleton = nullptr;

ZobristHash::ZobristHash()
{
	std::mt19937_64 rng(0);
	for (int i = 0; i < 65536; i++)
	{
		randomized[i] = rng();
	}
}

ZobristHash *ZobristHash::get_singleton()
{
	if (!singleton)
	{
		singleton = memnew(ZobristHash);
	}
	return singleton;
}

int64_t ZobristHash::hash_piece(int _piece, int _by)
{
	return randomized[((_piece & 0xFF) + (_by << 8)) & 0xFFFF];
}

void ZobristHash::_bind_methods()
{
	godot::ClassDB::bind_method(godot::D_METHOD("hash_piece"), &ZobristHash::hash_piece);
}