extends RefCounted
class_name Move

var position_name_from:String
var position_name_to:String
var extra:String
var comment:String

func stringify() -> String:
	return position_name_from + "|" + position_name_to + "|" + extra + "|" + comment

static func parse(move_str:String) -> Move:
	var str_list:PackedStringArray = move_str.split("|")
	if !move_str || str_list.size() != 4:
		return null
	return Move.create(str_list[0], str_list[1], str_list[2], str_list[3])

static func create(_position_name_from:String, _position_name_to:String, _extra:String, _comment:String) -> Move:
	var new_move:Move = Move.new()
	new_move.position_name_from = _position_name_from
	new_move.position_name_to = _position_name_to
	new_move.extra = _extra
	new_move.comment = _comment
	return new_move
