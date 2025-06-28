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

class Item extends Object:
	var checksum:int = 0
	var depth:int = 0
	var flag:Flag = Flag.UNKNOWN
	var value:int = 0
	var best_move:int = 0

var transposition_table:Array[Item] = []

func reserve(_table_size:int) -> void:
	table_size = _table_size
	transposition_table.resize(table_size)
	for i:int in range(transposition_table.size()):
		transposition_table[i] = Item.new()

func save_file(path:String) -> void:
	var file:FileAccess = FileAccess.open_compressed(path, FileAccess.WRITE, FileAccess.COMPRESSION_FASTLZ)
	file.store_32(table_size)
	for iter:Item in transposition_table:
		file.store_64(iter.checksum)
		file.store_16(iter.depth)
		file.store_8(iter.flag)
		file.store_32(iter.value)
		file.store_32(iter.best_move)
	file.close()

func load_file(path:String) -> void:
	var file:FileAccess = FileAccess.open_compressed(path, FileAccess.READ, FileAccess.COMPRESSION_FASTLZ)
	table_size = file.get_32()
	table_size_mask = table_size - 1
	transposition_table.resize(table_size)
	for i:int in range(table_size):
		transposition_table[i] = Item.new()
		transposition_table[i].checksum = file.get_64()
		transposition_table[i].depth = file.get_16()
		transposition_table[i].flag = file.get_8()
		transposition_table[i].value = file.get_32()
		transposition_table[i].best_move = file.get_32()
	file.close()

func probe_hash(checksum:int, depth:int, alpha:int, beta:int) -> int:
	var index:int = checksum & table_size_mask
	var item:Item = transposition_table[index]
	if item.checksum == checksum:
		if item.depth >= depth:
			if item.flag == Flag.EXACT:
				return item.value
			if item.flag == Flag.ALPHA && item.value < alpha:
				return alpha
			if item.flag == Flag.BETA && item.value > beta:
				return beta
	return 65535

func get_best_move(checksum:int, depth:int, alpha:int, beta:int) -> int:
	var index:int = checksum & table_size_mask
	var item:Item = transposition_table[index]
	if item.checksum == checksum:
		if item.depth >= depth:
			if item.flag == Flag.EXACT || item.flag == Flag.ALPHA && item.value < alpha || item.flag == Flag.BETA && item.value > beta:
				return item.best_move
	return 0

func record_hash(checksum:int, depth:int, value:int, flag:Flag)-> void:
	var index:int = checksum & table_size_mask
	var item:Item = transposition_table[index]
	if read_only && item.flag != Flag.UNKNOWN || depth < item.depth:
		return	# 最好不要丢掉开局库内容，这是容不得覆盖的
	item.checksum = checksum
	item.depth = depth
	item.value = value
	item.flag = flag
