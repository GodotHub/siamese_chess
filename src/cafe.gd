extends Node3D

func _ready() -> void:
	$player.move_camera($level/camera)
	$level/table_0/chessboard_standard.set_enabled(false)
	$level/chessboard/pieces/pastor.play_animation("thinking")
	$level.interact_list[0x65] = interact_pastor

func interact_pastor() -> void:
	$player.force_set_camera($level/camera_3d)
	$level/chessboard.set_enabled(false)
	$level/table_0/chessboard_standard.set_enabled(true)
	$level/chessboard/pieces/cheshire.set_position($level/chessboard.convert_name_to_position("e2"))
	$level/chessboard/pieces/cheshire.play_animation("thinking")
	await get_tree().create_timer(3).timeout
	$player.force_set_camera($level/camera)
	$level/chessboard/pieces/cheshire.play_animation("battle_idle")
	$level/chessboard.set_enabled(true)
	$level/table_0/chessboard_standard.set_enabled(false)
