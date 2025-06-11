extends Node

var table_size:int = 1024
var table_size_mask:int = table_size - 1

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

var transposition_table:Array[Item] = []

func _init() -> void:
	transposition_table.resize(table_size)
	for i:int in range(transposition_table.size()):
		transposition_table[i] = Item.new()

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

func record_hash(checksum:int, depth:int, value:int, flag:Flag)-> void:
	var index:int = checksum & table_size_mask
	var item:Item = transposition_table[index]
	item.checksum = checksum
	item.depth = depth
	item.value = value
	item.flag = flag
