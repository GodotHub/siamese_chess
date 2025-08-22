extends CanvasLayer

var template_list:Dictionary = {
	"menu": "res://scene/menu.tscn",
	"history": "res://scene/history.tscn",
}

var document_list:Dictionary = {}

func _ready() -> void:
	var dir:DirAccess = DirAccess.open("user://archive/")
	if !dir:
		DirAccess.make_dir_absolute("user://archive/")
		dir = DirAccess.open("user://archive/")
	dir.list_dir_begin()
	var file_name:String = dir.get_next()
	while file_name != "":
		if !dir.current_is_dir():
			document_list[file_name] = "user://archive/" + file_name
		file_name = dir.get_next()
	

	for iter:String in document_list:
		var button = Button.new()
		button.text = iter
		button.flat = true
		button.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9, 1))
		button.add_theme_color_override("font_focus_color", Color(1, 1, 1, 1))
		button.add_theme_color_override("font_hover_color", Color(1, 1, 1, 1))
		button.add_theme_color_override("font_pressed_color", Color(0.6, 0.6, 0.6, 1))
		button.add_theme_font_size_override("font_size", 30)
		button.add_theme_stylebox_override("normal", StyleBoxEmpty.new())
		button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
		button.add_theme_stylebox_override("hover", StyleBoxEmpty.new())
		button.add_theme_stylebox_override("pressed", StyleBoxEmpty.new())
		button.add_theme_font_override("font", preload("res://assets/fonts/FangZhengShuSongJianTi-1.ttf"))
		button.connect("button_up", button_pressed.bind(iter))
		$texture_rect/v_box_container.add_child(button)
	
func button_pressed(key:String) -> void:
	var filename_splited = key.split(".")	# 模板.名称.json
	var new_document:Document = load(template_list[filename_splited[0]]).instantiate()
	var data:String = FileAccess.get_file_as_string(document_list[key])
	new_document.parse(data)
	$texture_rect/document_browser.set_document(new_document)
