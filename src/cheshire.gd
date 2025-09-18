extends Actor

func _ready() -> void:
	$animation_tree.connect("animation_finished", play_particle)
	super._ready()

func play_particle(anim_name:String) -> void:
	if anim_name == "battle_attack":
		$gpu_particles_attack.restart()
