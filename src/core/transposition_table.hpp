#ifndef _TRANSPOSITION_TABLE_HPP_
#define _TRANSPOSITION_TABLE_HPP_

#include <godot_cpp/godot.hpp>
#include <godot_cpp/classes/ref_counted.hpp>
#include <vector>

enum TranspositionTableFlag	{
	UNKNOWN = 0,
	EXACT = 1,
	ALPHA = 2,
	BETA = 3
};

struct TranspositionTableItem
{
	int64_t checksum;
	int8_t depth;
	int8_t flag;
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
		int probe_hash(int64_t checksum, int8_t depth, int alpha, int beta);
		int best_move(int64_t checksum);
		void record_hash(int64_t checksum, int8_t depth, int value, int8_t flag, int best_move);
		static void _bind_methods();
	private:
		bool read_only = false;
		int table_size;
		int table_size_mask;
		std::vector<TranspositionTableItem> table;
};

#endif