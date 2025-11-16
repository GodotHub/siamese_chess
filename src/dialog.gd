extends CanvasLayer

signal on_next()

const packed_scene:PackedScene = preload("res://scene/dialog.tscn")
var selection:PackedStringArray = []
var selected:String = ""
var waiting:bool = false
var click_anywhere:bool = false
var force_selection:bool = false
var click_cooldown:float = 0

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

func _input(event:InputEvent) -> void:
	if click_anywhere && !waiting:
		if event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_LEFT && event.pressed && Time.get_unix_time_from_system() - click_cooldown >= 0.3:
			next()
			click_cooldown = Time.get_unix_time_from_system()
	if click_anywhere || force_selection || Time.get_unix_time_from_system() - click_cooldown < 0.3:
		get_viewport().set_input_as_handled()

func push_dialog(text:String, blackscreen:bool = false, _click_anywhere:bool = false, _waiting:bool = false) -> void:
	var tween:Tween = create_tween()
	force_selection = false
	waiting = _waiting
	click_anywhere = _click_anywhere
	$texture_rect_bottom/label.text = ""
	if blackscreen:
		tween.tween_property($texture_rect_full, "visible", true, 0)
	tween.tween_interval(0.3)
	tween.tween_property($texture_rect_bottom/label, "text", tr(text), 0)
	tween.tween_property($texture_rect_full, "visible", false, 0)

func push_selection(_selection:PackedStringArray, _force_selection:bool = true, blackscreen:bool = false) -> void:
	var text = ""
	click_anywhere = false
	force_selection = _force_selection
	selection = _selection
	for iter:String in selection:
		text += "[url=\"" + iter + "\"]" + tr(iter) + "[/url]  "
	var tween:Tween = create_tween()
	if blackscreen:
		tween.tween_property($texture_rect_full, "visible", true, 0)
	tween.tween_interval(0.3)
	tween.tween_property($texture_rect_bottom/label, "text", text, 0)
	tween.tween_property($texture_rect_full, "visible", false, 0)

func set_title(text:String) -> void:
	var tween:Tween = create_tween()
	tween.tween_interval(0.3)
	tween.tween_property($texture_rect_top/label, "text", text, 0)

func clear() -> void:
	$texture_rect_bottom/label.text = ""
	$texture_rect_top/label.text = ""
	click_anywhere = false
	force_selection = false

func next() -> void:
	$texture_rect_bottom/label.text = ""
	$texture_rect_top/label.text = ""
	click_anywhere = false
	waiting = false
	force_selection = false
	on_next.emit.call_deferred()

func clicked_selection(_selected:String) -> void:
	selected = _selected
	next()
