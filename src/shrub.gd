extends Actor

func captured(_capturing:Actor) -> void:
	$root.visible = false
	$leaves.visible = false
	$leaves_001.visible = false
	$gpu_particles_died.restart()
