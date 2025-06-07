extends Node

var table_size:int = 1048576
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
	var value:float = 0

var transposition_table:Array[Item] = []

func _init() -> void:
	transposition_table.resize(table_size)

func probe_hash(checksum:int, depth:int, alpha:float, beta:float) -> float:
	var index:int = checksum & table_size_mask
	var item:Item = transposition_table[index]
	if is_instance_valid(item) && item.checksum == checksum:
		if item.depth >= depth:
			if item.flag == Flag.EXACT:
				return item.value
			if item.flag == Flag.ALPHA && item.value < alpha:
				return alpha
			if item.flag == Flag.BETA && item.value > beta:
				return beta
	return NAN

func record_hash(checksum:int, depth:int, value:float, flag:Flag)-> void:
	var index:int = checksum & table_size_mask
	if !is_instance_valid(transposition_table[index]):
		transposition_table[index] = Item.new()
	var item:Item = transposition_table[index]
	item.checksum = checksum
	item.depth = depth
	item.value = value
	item.flag = flag
