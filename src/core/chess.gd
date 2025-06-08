extends Node

const a8:int = 0
const c8:int = 2
const d8:int = 3
const f8:int = 5
const g8:int = 6
const h8:int = 7
const a1:int = 16 * 7
const c1:int = 16 * 7 + 2
const d1:int = 16 * 7 + 3
const f1:int = 16 * 7 + 5
const g1:int = 16 * 7 + 6
const h1:int = 16 * 7 + 7

@onready var test_state:ChessState = ChessState.new()

func to_piece_position(position_name:String) -> Vector2i:
	if !position_name:
		return Vector2i(-1, -1)
	return Vector2i(position_name.unicode_at(0) - 97, position_name.unicode_at(1) - 49)

func to_int(position_name:String) -> int:
	if !position_name:
		return -1
	return position_name.unicode_at(0) - 97 + (7 - position_name.unicode_at(1) + 49) * 16

func to_position_name(position_int:int) -> String:
	if position_int & 0x88:
		return ""
	return "%c%c" % [position_int % 16 + 97, (7 - position_int / 16) + 49]
