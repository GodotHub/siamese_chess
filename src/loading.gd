extends CanvasLayer

var current:Node = null

func _ready() -> void:
	current = get_tree().current_scene

func change_scene(path:String, meta:Dictionary) -> void:
	var instance:Node = load(path).instantiate()
	for key:String in meta:
		instance.set_meta(key, meta[key])
	if is_instance_valid(current):
		current.queue_free()
	get_tree().root.add_child(instance)
	current = instance
