extends Node

var table_size:int = 524288
var table_size_mask:int = table_size - 1

enum Flag	{
	UNKNOWN = 0,
	EXACT = 1,
	ALPHA = 2,
	BETA = 3
}

class Item:
	var checksum:int = 0
	var depth:int = 0
	var flag:Flag = Flag.UNKNOWN
	var value:float = 0

var table:Dictionary[int, Item] = {}

func probe_hash(checksum:int, depth:int, alpha:float, beta:float) -> float:
	if !table.has(checksum):
		return NAN
	var item:Item = table[checksum]
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
	if !table.has(checksum):
		table[checksum] = Item.new()
	var item:Item = table[checksum]
	item.checksum = checksum
	item.depth = depth
	item.value = value
	item.flag = flag
