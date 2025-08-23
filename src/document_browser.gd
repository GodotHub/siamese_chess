extends Control
class_name DocumentBrowser

var document:Document = null
var zoom:float = 1
var pivot:Vector2 = Vector2()
var offset:Vector2 = Vector2()

func _ready() -> void:
	pass

func _unhandled_input(event:InputEvent) -> void:
	if !document || !visible:
		return
	if event is InputEventMultiScreenDrag:
		change_offset(event.relative)
		get_viewport().set_input_as_handled()
	if event is InputEventScreenPinch:
		change_zoom(event.relative / 100)
		get_viewport().set_input_as_handled()

func set_document(_document) -> void:
	if is_instance_valid(document):
		$sub_viewport_container/sub_viewport.remove_child(document)
	document = _document
	zoom = 1
	pivot = Vector2(0, 0)
	offset = Vector2(0, 0)
	$sub_viewport_container/sub_viewport.add_child(document)

func update_transform() -> void:
	if !is_instance_valid(document):
		return
	pivot = get_global_transform().basis_xform_inv(size * 0.5)
	var offset_result:Vector2 = offset - pivot
	offset_result *= zoom / document.scale.x
	offset = offset_result + pivot
	document.scale = Vector2(zoom, zoom)
	document.position = offset

func change_zoom(relative:float) -> void:
	zoom += relative
	zoom = clamp(zoom, 0.1, 2.0)
	update_transform()

func change_offset(relative:Vector2) -> void:
	offset += relative
	update_transform()
