extends InspectableItem

var region:Rect2 = Rect2(0, 0, 552, 780)
var lines:Array[Line2D] = []	# 直接暴力搜解决问题
var uv_mapping:UVMapping = null
var last_event_position_2d:Vector2 = Vector2(-1, -1)
var use_eraser:bool = false

var document:Document = null

func _ready() -> void:
	if is_instance_valid(document):
		$sub_viewport.add_child(document)
		document.position = $sub_viewport.size / 2
	var array_mesh:ArrayMesh = ArrayMesh.new()
	array_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, $mesh_instance_3d.mesh.get_mesh_arrays())
	$mesh_instance_3d.mesh = array_mesh
	uv_mapping = UVMapping.new()
	uv_mapping.set_mesh($mesh_instance_3d)
	super._ready()

func set_document(_document:Document) -> void:
	if is_instance_valid(document):
		$sub_viewport.remove_child(document)
	document = _document
	$sub_viewport.add_child(document)
	document.position = $sub_viewport.size / 2


func input(_from:Node3D, _to:Area3D, _event:InputEvent, _event_position:Vector3, _normal:Vector3) -> void:
	var event_position_3d:Vector3 = $mesh_instance_3d.global_transform.affine_inverse() * _event_position
	var event_normal_3d:Vector3 = $mesh_instance_3d.global_transform.orthonormalized().basis.inverse() * _normal
	var event_position_2d:Vector2 = Vector2()
	event_position_2d = uv_mapping.get_uv_coords(event_position_3d, event_normal_3d)
	if event_position_2d == Vector2(-1, -1):
		if last_event_position_2d != Vector2(-1, -1):
			event_position_2d = last_event_position_2d
	else:
		event_position_2d.x *= region.size.x
		event_position_2d.y *= region.size.y
	last_event_position_2d = event_position_2d
	var actual_position:Vector2 = event_position_2d - document.get_global_position()
	if _event is InputEventMouseButton:
		if !use_eraser:
			if _event.pressed && _event.button_index == MOUSE_BUTTON_LEFT:
				document.start_drawing(actual_position)
			else:
				document.end_drawing()
	elif _event is InputEventMouseMotion:
		if _event.button_mask & MOUSE_BUTTON_MASK_LEFT:
			if use_eraser || _event.pen_inverted:
				document.cancel_drawing()
				document.erase_line(actual_position)
			else:
				document.drawing_curve(actual_position)
		elif _event.button_mask & MOUSE_BUTTON_MASK_RIGHT:
			document.cancel_drawing()
			document.erase_line(actual_position)
