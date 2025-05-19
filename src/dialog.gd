extends CanvasLayer
class_name Dialog

signal on_next(index:int)
signal on_exit()

var text_list:PackedStringArray = [
	"现在你看到的是测试对话。",
	"你我之间对话通常不止一句，",
	"在对话同时，还涉及到视角的转换、角色神情的变化，",
	"甚至需要展示特定的图像。",
	"Dialog对象只处理对话的内容，",
	"在你点击时，除了跳到下一条语句外，它会发送信号，通知给其他演出相关的对象。",
]
var pointer:int = 0

const packed_scene:PackedScene = preload("res://scene/dialog.tscn")

static func create_dialog_instance(_text_list:PackedStringArray) -> Dialog:
	var instance:Dialog = packed_scene.instantiate()
	instance.text_list = _text_list
	return instance

func _ready() -> void:
	var tween:Tween = create_tween()
	tween.tween_property($texture_rect_full, "visible", true, 0)
	tween.tween_callback(on_next.emit.bind(pointer))
	tween.tween_interval(0.3)
	tween.tween_property($texture_rect_bottom/label, "text", text_list[pointer], 0)
	tween.tween_property($texture_rect_full, "visible", false, 0)

func _input(event:InputEvent) -> void:
	if event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_LEFT && event.pressed:
		next()
		get_viewport().set_input_as_handled()

func next() -> void:
	pointer += 1
	if pointer < text_list.size():
		var tween:Tween = create_tween()
		tween.tween_property($texture_rect_full, "visible", true, 0)
		tween.tween_callback(on_next.emit.bind(pointer))
		tween.tween_interval(0.3)
		tween.tween_property($texture_rect_bottom/label, "text", text_list[pointer], 0)
		tween.tween_property($texture_rect_full, "visible", false, 0)
	else:
		var tween:Tween = create_tween()
		tween.tween_property($texture_rect_bottom/label, "visible", true, 0)
		tween.tween_callback(on_exit.emit)
		tween.tween_interval(0.3)
		tween.tween_callback(queue_free)
	
