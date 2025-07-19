extends CanvasLayer
class_name Dialog

signal on_next()

const packed_scene:PackedScene = preload("res://scene/dialog.tscn")
var selected:String = ""
var click_anywhere:bool = false
var force_selection:bool = false

func _ready() -> void:
	$texture_rect_bottom/label.connect("meta_clicked", clicked_selection)
	
func test() -> void:
	push_dialog("这是一段测试对话", true, true)
	await on_next
	push_dialog("这次使用全局对话框，可能会占用一部分的画面", true, true)
	await on_next
	push_dialog("不过，我们会在操作时穿插对话、注解以及选项", true, true)
	await on_next
	push_dialog("现在进行3秒间隔测试，该对话不可跳过", true, false)
	await get_tree().create_timer(3).timeout
	push_dialog("接下来是选项", false, true)
	await on_next
	push_selection(["选项1", "选项2", "选项3"], false, false)
	await on_next
	push_selection(["选项4", "选项5", "选项6"], true, true)


func _unhandled_input(event:InputEvent) -> void:
	if click_anywhere:
		if event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_LEFT && event.pressed:
			next()
	if click_anywhere || force_selection:
		get_viewport().set_input_as_handled()

func push_dialog(text:String, blackscreen:bool = false, _click_anywhere:bool = false) -> void:
	var tween:Tween = create_tween()
	force_selection = false
	click_anywhere = _click_anywhere
	$texture_rect_bottom/label.text = ""
	if blackscreen:
		tween.tween_property($texture_rect_full, "visible", true, 0)
	tween.tween_interval(0.3)
	tween.tween_property($texture_rect_bottom/label, "text", tr(text), 0)
	tween.tween_property($texture_rect_full, "visible", false, 0)

func push_selection(selection:PackedStringArray, _force_selection:bool = true, blackscreen:bool = false) -> void:
	var text = ""
	click_anywhere = false
	force_selection = _force_selection
	for iter:String in selection:
		text += "[url link=\"" + iter + "\"]" + tr(iter) + "[/url]  "
	var tween:Tween = create_tween()
	if blackscreen:
		tween.tween_property($texture_rect_full, "visible", true, 0)
	tween.tween_interval(0.3)
	tween.tween_property($texture_rect_bottom/label, "text", text, 0)
	tween.tween_property($texture_rect_full, "visible", false, 0)

func next() -> void:
	$texture_rect_bottom/label.text = ""
	click_anywhere = false
	force_selection = false
	on_next.emit()

func clicked_selection(_selected:String) -> void:
	selected = _selected
	next()
