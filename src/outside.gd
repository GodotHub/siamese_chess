extends Level

func _ready() -> void:
	super._ready()
	var cheshire_by:int = get_meta("by")
	var cheshire_instance:Actor = load("res://scene/cheshire.tscn").instantiate()
	cheshire_instance.position = $chessboard.convert_name_to_position(Chess.to_position_name(cheshire_by))
	$chessboard.state.add_piece(cheshire_by, "k".unicode_at(0))
	$chessboard.add_piece_instance(cheshire_instance, cheshire_by)
	$player.force_set_camera($camera)
	for node:Node in get_children():
		if node is MarkerTeleport:
			var by:int = Chess.to_position_int($chessboard.get_position_name(node.global_position))
			interact_list[by] = {"": node.change_scene}
