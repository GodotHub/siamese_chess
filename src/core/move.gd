extends Object
class_name Move
# 大致格式是：（前面一堆0补位）（extra 8位）（to 8位）（from 8位）

static func create(_from:int, _to:int, _extra:int) -> int:
	return _from + (_to << 8) + (_extra << 16)

static func from(move:int) -> int:
	return move & 0xFF

static func to(move:int) -> int:
	return (move >> 8) & 0xFF

static func extra(move:int) -> int:
	return (move >> 16) & 0xFF
