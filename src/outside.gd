extends Node3D

var engine:ChessEngine = null
var history_state:PackedInt32Array = []

func _ready() -> void:
	var cheshire_by:int = get_meta("by")
	var cheshire_instance:Actor = load("res://scene/cheshire.tscn").instantiate()
	cheshire_instance.position = $level/chessboard.convert_name_to_position(Chess.to_position_name(cheshire_by))
	$level/chessboard.state.add_piece(cheshire_by, "k".unicode_at(0))
	$level/chessboard.add_piece_instance(cheshire_instance, cheshire_by)
	$player.force_set_camera($level/camera)
	for node:Node in $level.get_children():
		if node is MarkerTeleport:
			var by:int = Chess.to_position_int($level/chessboard.get_position_name(node.global_position))
			$level.interact_list[by] = {"": node.change_scene}
