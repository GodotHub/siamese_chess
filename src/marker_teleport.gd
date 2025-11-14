extends MarkerBit
class_name MarkerTeleport

@export var to:String = ""
@export var args:Dictionary = {}

func _init() -> void:
	piece = "z".unicode_at(0)

func change_scene() -> void:
	var level:Level = get_parent()
	var by:int = Chess.to_position_int(level.chessboard.get_position_name(position))
	var from:int = level.chessboard.state.bit_index("k".unicode_at(0))[0]
	from = Chess.to_x88(from)
	level.chessboard.execute_move(Chess.create(from, by, 0))
	await level.chessboard.animation_finished
	Loading.change_scene(to, args)
