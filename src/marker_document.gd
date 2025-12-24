extends MarkerEvent
class_name MarkerDocument

@export var file_path:String = "usr://archive/"
@export var file_content:Dictionary = {"line": []}
@export var comment:String = ""

func event() -> void:
	if !FileAccess.file_exists(file_path):
		var path:String = file_path
		var file:FileAccess = FileAccess.open(path, FileAccess.WRITE)
		file.store_string(JSON.stringify(file_content))
		file.close()
