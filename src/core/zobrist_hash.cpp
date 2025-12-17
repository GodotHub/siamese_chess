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

void ZobristHash::print_randomized()
{
	for (int i = 0; i < 64; i += 4)
	{
		godot::print_line(i, ": ");
		std::vector<int> cnt(16);
		for (int j = 0; j < 65536; j++)
		{
			int index = (uint64_t(randomized[j]) >> i) & 0xF;
			cnt[index]++;
		}
		for (int j = 0; j < 16; j++)
		{
			godot::print_line("\t", j, ": ", cnt[j]);
		}
	}
}

void ZobristHash::_bind_methods()
{
	godot::ClassDB::bind_method(godot::D_METHOD("hash_piece"), &ZobristHash::hash_piece);
	godot::ClassDB::bind_method(godot::D_METHOD("print_randomized"), &ZobristHash::print_randomized);
}