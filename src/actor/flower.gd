extends Actor

func move(_pos:Vector3) -> void:
	$gpu_particles_died.restart()
	$flower.visible = false
	await get_tree().create_timer(0.3).timeout
	global_position = _pos
	$flower.visible = true
	$gpu_particles_died.restart()
