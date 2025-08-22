extends Node2D
class_name Document
# 文档分为模板和实例
# 实例包含了文件名称和变量

var filename:String = ""	# 文档名称，唯一
var template:String = ""	# 模板路径

func _ready() -> void:
	pass

func parse(_data:String) -> void:
	pass

func stringify() -> String:
	return ""

func set_filename(_filename:String) -> void:
	filename = _filename
