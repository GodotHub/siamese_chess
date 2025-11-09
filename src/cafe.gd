extends Node3D

func _ready() -> void:
	$player.move_camera($level/camera)
	$level/chessboard/pieces/pastor.play_animation("thinking")

func on_clicked_interact() -> void:
	pass
