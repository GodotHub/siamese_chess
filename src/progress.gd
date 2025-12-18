extends Node

# 全局存档系统
# 由于Archive名称已占用，故命名Progress，也就是游玩进展
# 这里的存档区分于Archive，Archive是允许跨越多个存档的文件机制

var table:Dictionary = {}

func _ready() -> void:
	pass

func load_file() -> void:
	var file:FileAccess = FileAccess.open("user://progress/prototype_2.json", FileAccess.READ)
	if !is_instance_valid(file):
		return

func save_file() -> void:
	var dir:DirAccess = DirAccess.open("user://progress/prototype_2.json")
	if !dir:
		DirAccess.make_dir_absolute("user://progress/prototype_2.json")
		dir = DirAccess.open("user://progress/prototype_2.json")

func has_key(key:String) -> bool:
	return table.has(key)

func get_value(key:String) -> Variant:
	if table.has(key):
		return table[key]
	return null

func set_value(key:String, data:Variant) -> void:
	table[key] = data
