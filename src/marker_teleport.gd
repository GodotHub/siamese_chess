extends MarkerSelection
class_name MarkerTeleport

@export var to:String = ""
@export var args:Dictionary = {}

func _init() -> void:
	selection = "前往"

func event() -> void:
	var from:int = Chess.to_position_int(level.chessboard.get_position_name(position))
	if level.chessboard.state.get_piece(from) == "k".unicode_at(0):
		HoldCard.reset()
		Loading.change_scene(to, args)
