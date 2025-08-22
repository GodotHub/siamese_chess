extends Control
class_name DocumentBrowser

var document:Document = null
var zoom:float = 1
var pivot:Vector2 = Vector2()
var offset:Vector2 = Vector2()

func _ready() -> void:
	document = load("res://scene/history.tscn").instantiate()
	$sub_viewport_container/sub_viewport.add_child(document)

func _input(event:InputEvent) -> void:
	if event is InputEventMultiScreenDrag:
		change_offset(event.relative)
	if event is InputEventScreenPinch:
		change_zoom(event.relative / 100)

func update_transform() -> void:
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
