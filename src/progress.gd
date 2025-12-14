extends Node

# 全局存档系统
# 由于Archive名称已占用，故命名Progress，也就是游玩进展
# 这里的存档区分于Archive，Archive是允许跨越多个存档的文件机制

var table:Dictionary = {}

func _ready() -> void:
	pass

func load_file() -> void:
	pass

func save_file() -> void:
	pass

func get_table(key:String) -> Dictionary:
	return table[key]

func set_table(key:String, data:Dictionary) -> void:
	table[key] = data
