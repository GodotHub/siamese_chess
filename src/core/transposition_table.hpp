#ifndef _TRANSPOSITION_TABLE_HPP_
#define _TRANSPOSITION_TABLE_HPP_

#include <godot_cpp/godot.hpp>
#include <godot_cpp/classes/ref_counted.hpp>
#include <godot_cpp/templates/vector.hpp>

enum TranspositionTableFlag	{
	UNKNOWN = 0,
	EXACT = 1,
	ALPHA = 2,
	BETA = 3
};

struct TranspositionTableItem
{
	long long checksum;
	unsigned char depth;
	unsigned char flag;
	int value;
	int best_move;
};

class TranspositionTable : public godot::RefCounted
{
	GDCLASS(TranspositionTable, RefCounted)
	public:
		void reserve(int _table_size);
		void save_file(godot::String path);
		void load_file(godot::String path);
		int probe_hash(long long checksum, unsigned char depth, int alpha, int beta);
		int best_move(long long checksum);
		void record_hash(long long checksum, unsigned char depth, int value, unsigned char flag, int best_move);
		static void _bind_methods();
	private:
		bool read_only = false;
		int table_size;
		int table_size_mask;
		godot::Vector<TranspositionTableItem> table;
};

#endif