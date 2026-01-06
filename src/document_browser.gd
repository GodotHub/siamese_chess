extends Control
class_name DocumentBrowser

var document:Document = null
var zoom:float = 1
var pivot:Vector2 = Vector2()
var offset:Vector2 = Vector2()
var use_eraser:bool = false
@export var zoom_curve:Curve
var zoom_mapped:float = 1

func _ready() -> void:
	pass

func _unhandled_input(event:InputEvent) -> void:
	if !document || !visible:
		return
	if event is InputEventMultiScreenDrag && get_global_rect().has_point(event.position):
		change_offset(event.relative)
		get_viewport().set_input_as_handled()
	if event is InputEventScreenPinch && event.position && get_global_rect().has_point(event.position):
		change_zoom(event.relative / 1000)
		get_viewport().set_input_as_handled()
	var actual_position:Vector2
	if event is InputEventMouseButton || event is InputEventMouseMotion || event is InputEventSingleScreenTouch || event is InputEventSingleScreenDrag || event is InputEventMultiScreenDrag || event is InputEventScreenPinch:
		actual_position = event.position - $sub_viewport_container.global_position - document.get_global_position()
		actual_position /= zoom_mapped
	if event is InputEventMouseButton:
		if !use_eraser:
			if event.pressed && event.button_index == MOUSE_BUTTON_LEFT:
				document.start_drawing(actual_position)
			else:
				document.end_drawing()
		get_viewport().set_input_as_handled()
	elif event is InputEventMouseMotion:
		if event.button_mask & MOUSE_BUTTON_MASK_LEFT:
			if use_eraser || event.pen_inverted:
				document.cancel_drawing()
				document.erase_line(actual_position)
			else:
				document.drawing_curve(actual_position)
		elif event.button_mask & MOUSE_BUTTON_MASK_RIGHT:
			document.cancel_drawing()
			document.erase_line(actual_position)
		get_viewport().set_input_as_handled()


func set_document(_document) -> void:
	if is_instance_valid(document):
		$sub_viewport_container/sub_viewport.remove_child(document)
	document = _document
	zoom = 1
	zoom_mapped = zoom_curve.sample(zoom)
	pivot = Vector2(0, 0)
	offset = $sub_viewport_container/sub_viewport.size / 2
	$sub_viewport_container/sub_viewport.add_child(document)
	document.position = $sub_viewport_container/sub_viewport.size / 2

func update_transform() -> void:
	if !is_instance_valid(document):
		return
	pivot = get_global_transform().basis_xform_inv(size * 0.5)
	var offset_result:Vector2 = offset - pivot
	offset_result *= zoom_mapped / document.scale.x
	offset = offset_result + pivot
	document.scale = Vector2(zoom_mapped, zoom_mapped)
	document.position = offset

func change_zoom(relative:float) -> void:
	zoom += relative
	zoom = clamp(zoom, 0.1, 2.0)
	zoom_mapped = zoom_curve.sample(zoom)
	update_transform()

func change_offset(relative:Vector2) -> void:
	offset += relative
	update_transform()
