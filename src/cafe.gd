extends Node3D

func _ready() -> void:
	$player.move_camera($level/camera)
	$level/chessboard/pieces/pastor.play_animation("thinking")
	$level.interact_list[0x65] = interact_pastor

func interact_pastor() -> void:
	$player.force_set_camera($level/camera_3d)
	await get_tree().create_timer(3).timeout
	$player.force_set_camera($level/camera)
