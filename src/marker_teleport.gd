extends MarkerBit
class_name MarkerTeleport

@export var to:String = ""
@export var args:Dictionary = {}

func _init() -> void:
	piece = "Z".unicode_at(0)

func change_scene() -> void:
	var level:Level = get_parent()
	var from:int = Chess.to_position_int(level.chessboard.get_position_name(position))
	if level.chessboard.state.get_piece(from) == "k".unicode_at(0):
		Loading.change_scene(to, args)
