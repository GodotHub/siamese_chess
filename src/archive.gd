extends CanvasLayer

var template_list:Dictionary = {
	"menu": "res://scene/menu.tscn",
	"history": "res://scene/history.tscn",
}

var document:Document = null
var document_list:Array = []
var button_list:Array[Button] = []

func open() -> void:
	for iter:Button in button_list:
		iter.queue_free()
	button_list.clear()
	document_list.clear()

	visible = true
	$texture_rect/document_browser.visible = false
	var dir:DirAccess = DirAccess.open("user://archive/")
	if !dir:
		DirAccess.make_dir_absolute("user://archive/")
		dir = DirAccess.open("user://archive/")
	dir.list_dir_begin()
	var file_name:String = dir.get_next()
	while file_name != "":
		if !dir.current_is_dir():
			document_list.push_back(file_name)
		file_name = dir.get_next()

	for iter:String in document_list:
		var button = Button.new()
		button.text = iter
		button.flat = true
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
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
		$texture_rect/scroll_container/v_box_container.add_child(button)
		button_list.push_back(button)
	$texture_rect/button_close.connect("button_up", close)

func button_pressed(filename:String) -> void:
	if is_instance_valid(document):
		document.save_file()
	
	var filename_splited = filename.split(".")	# 模板.名称.json
	document = load(template_list[filename_splited[0]]).instantiate()
	document.set_filename(filename)
	document.load_file()
	$texture_rect/document_browser.set_document(document)
	$texture_rect/document_browser.visible = true

func close() -> void:
	$texture_rect/document_browser.visible = false
	visible = false
