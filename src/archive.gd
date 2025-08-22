extends CanvasLayer

var document_list:Dictionary = {
	"Notation": "res://scene/history.tscn",
	"Menu": "res://scene/menu.tscn"
}

func _ready() -> void:
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
	$texture_rect/document_browser.set_document(load(document_list[key]).instantiate())
