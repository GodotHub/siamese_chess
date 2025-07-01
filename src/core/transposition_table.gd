extends RefCounted
class_name TranspositionTable

var table_size:int = 1024
var table_size_mask:int = table_size - 1
var read_only:int = false	# 如果遇到现有信息的话就停止覆盖

enum Flag	{
	UNKNOWN = 0,
	EXACT = 1,
	ALPHA = 2,
	BETA = 3
}

var transposition_table:PackedByteArray = []

func get_checksum(index:int) -> int:
	return transposition_table.decode_s64(index * 14)

func get_depth(index:int) -> int:
	return transposition_table.decode_u8(index * 14 + 8)

func get_flag(index:int) -> int:
	return transposition_table.decode_s8(index * 14 + 9)

func get_value(index:int) -> int:
	return transposition_table.decode_s32(index * 14 + 10)

func set_checksum(index:int, checksum:int) -> void:
	transposition_table.encode_s64(index * 14, checksum)

func set_depth(index:int, depth:int) -> void:
	transposition_table.encode_u8(index * 14 + 8, depth)

func set_flag(index:int, flag:int) -> void:
	transposition_table.encode_s8(index * 14 + 9, flag)

func set_value(index:int, value:int) -> void:
	transposition_table.encode_s32(index * 14 + 10, value)

func reserve(_table_size:int) -> void:
	table_size = _table_size
	table_size_mask = table_size - 1
	transposition_table.resize(table_size * 14)

func save_file(path:String) -> void:
	var file:FileAccess = FileAccess.open(path, FileAccess.WRITE)
	file.store_buffer(transposition_table)
	file.close()

func load_file(path:String) -> void:
	transposition_table = FileAccess.get_file_as_bytes(path)
	table_size = transposition_table.size() / 14
	table_size_mask = table_size - 1

func probe_hash(checksum:int, depth:int, alpha:int, beta:int) -> int:
	var index:int = checksum & table_size_mask
	if get_checksum(index) == checksum:
		if get_depth(index) >= depth:
			if get_flag(index) == Flag.EXACT:
				return get_value(index)
			if get_flag(index) == Flag.ALPHA && get_value(index) < alpha:
				return alpha
			if get_flag(index) == Flag.BETA && get_value(index) > beta:
				return beta
	return 65535

func record_hash(checksum:int, depth:int, value:int, flag:Flag)-> void:
	var index:int = checksum & table_size_mask
	if read_only && get_flag(index) != Flag.UNKNOWN || depth < get_depth(index):
		return	# 最好不要丢掉开局库内容，这是容不得覆盖的
	set_checksum(index, checksum)
	set_depth(index, depth)
	set_value(index, value)
	set_flag(index, flag)
