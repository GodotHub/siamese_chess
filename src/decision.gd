extends CanvasLayer
class_name Decision

signal decided(index:int)	# -1表示取消

var decision_list:PackedStringArray = []

const packed_scene:PackedScene = preload("res://scene/decision.tscn")

static func create_decision_instance(_decision_list:PackedStringArray) -> Decision:
	var instance:Decision = packed_scene.instantiate()
	instance.decision_list = _decision_list
	return instance

func _ready() -> void:
	for i:int in range(decision_list.size()):
		var button = Button.new()
		button.text = decision_list[i]
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
		button.connect("button_up", button_pressed.bind(i))
		$texture_rect/v_box_container.add_child(button)
	var cancel_button = Button.new()
	cancel_button.text = "Cancel"
	cancel_button.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9, 1))
	cancel_button.add_theme_color_override("font_focus_color", Color(1, 1, 1, 1))
	cancel_button.add_theme_color_override("font_hover_color", Color(1, 1, 1, 1))
	cancel_button.add_theme_color_override("font_pressed_color", Color(0.6, 0.6, 0.6, 1))
	cancel_button.add_theme_font_size_override("font_size", 30)
	cancel_button.add_theme_stylebox_override("normal", StyleBoxEmpty.new())
	cancel_button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	cancel_button.add_theme_stylebox_override("hover", StyleBoxEmpty.new())
	cancel_button.add_theme_stylebox_override("pressed", StyleBoxEmpty.new())
	cancel_button.connect("button_up", button_pressed.bind(-1))
	$texture_rect/v_box_container.add_child(cancel_button)
	
	$texture_rect/v_box_container.hide()
	var tween:Tween = create_tween()
	tween.tween_interval(0.3)
	tween.tween_property($texture_rect/v_box_container, "visible", true, 0)

func button_pressed(index:int) -> void:
	decided.emit(index)
	var tween:Tween = create_tween()
	tween.tween_property($texture_rect/v_box_container, "visible", false, 0)
	tween.tween_interval(0.3)
	tween.tween_callback(queue_free)
