extends Actor

func captured(_capturing:Actor = null) -> void:
	$root.visible = false
	$leaves.visible = false
	$leaves_001.visible = false
	$gpu_particles_died.restart()
	$audio_stream_player_3d.play()
