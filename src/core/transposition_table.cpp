#include "transposition_table.hpp"
#include <godot_cpp/classes/file_access.hpp>

void TranspositionTable::reserve(int _table_size)
{
	table_size = _table_size;
	table_size_mask = table_size - 1;
	table.resize(table_size);
}

void TranspositionTable::save_file(godot::String path)
{
	godot::Ref<godot::FileAccess> file = godot::FileAccess::open(path, godot::FileAccess::ModeFlags::WRITE);
	file->store_32(table_size);
	for (int i = 0; i < table.size(); i++)
	{
		file->store_64(table[i].checksum);
		file->store_8(table[i].depth);
		file->store_8(table[i].flag);
		file->store_32(table[i].value);
		file->store_32(table[i].best_move);
	}
	file->close();
}

void TranspositionTable::load_file(godot::String path)
{
	godot::Ref<godot::FileAccess> file = godot::FileAccess::open(path, godot::FileAccess::READ);
	table_size = file->get_32();
	table_size_mask = table_size - 1;
	table.resize(table_size);
	for (int i = 0; i < table.size(); i++)
	{
		table[i].checksum = file->get_64();
		table[i].depth = file->get_8();
		table[i].flag = file->get_8();
		table[i].value = file->get_32();
		table[i].best_move = file->get_32();
	}
	file->close();
}

int TranspositionTable::probe_hash(int64_t checksum, unsigned char depth, int alpha, int beta)
{
	int index = checksum & table_size_mask;
	if (table[index].checksum == checksum)
	{
		if (table[index].depth >= depth)
		{
			if (table[index].flag == EXACT)
			{
				return table[index].value;
			}
			if (table[index].flag == ALPHA && table[index].value < alpha)
			{
				return alpha;
			}
			if (table[index].flag == BETA && table[index].value > beta)
			{
				return beta;
			}
		}
	}
	return 65535;
}

int TranspositionTable::best_move(int64_t checksum)
{
	int index = checksum & table_size_mask;
	return table[index].best_move;
}

void TranspositionTable::record_hash(int64_t checksum, unsigned char depth, int value, unsigned char flag, int best_move)
{
	int index = checksum & table_size_mask;
	if ((read_only && table[index].flag != UNKNOWN || depth < table[index].depth))
	{
		return;	// 最好不要丢掉开局库内容，这是容不得覆盖的
	}
	table[index].checksum = checksum;
	table[index].depth = depth;
	table[index].flag = flag;
	table[index].value = value;
	table[index].best_move = best_move;
}

void TranspositionTable::_bind_methods()
{
	godot::ClassDB::bind_method(godot::D_METHOD("reserve"), &TranspositionTable::reserve);
	godot::ClassDB::bind_method(godot::D_METHOD("save_file"), &TranspositionTable::save_file);
	godot::ClassDB::bind_method(godot::D_METHOD("load_file"), &TranspositionTable::load_file);
	godot::ClassDB::bind_method(godot::D_METHOD("probe_hash"), &TranspositionTable::probe_hash);
	godot::ClassDB::bind_method(godot::D_METHOD("best_move"), &TranspositionTable::best_move);
	godot::ClassDB::bind_method(godot::D_METHOD("record_hash"), &TranspositionTable::record_hash);
}
