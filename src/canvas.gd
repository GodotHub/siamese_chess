extends Node3D

@onready var resolution:float = 512

var pointer:Dictionary[Color, Array] = {}

class ChessboardPointer extends Node2D:
	var resolution:float = 512
	var color:Color = Color(0, 0, 0, 1)
	func _draw() -> void:
		draw_rect(Rect2(-resolution / 16, -resolution / 16, resolution / 8, resolution / 8), color.lightened(0.1))
		draw_rect(Rect2(-resolution / 16, -resolution / 16, resolution / 8, resolution / 8), color, false, 10)

func _ready() -> void:
	$sub_viewport.size = Vector2(resolution, resolution)

func draw_pointer(color:Color, drawing_position:Vector2) -> void:
	if !pointer.has(color):
		pointer[color] = []
	var new_point:ChessboardPointer = ChessboardPointer.new()
	new_point.position = drawing_position
	new_point.color = color
	new_point.resolution = resolution
	$sub_viewport.add_child(new_point)
	pointer[color].push_back(new_point)

func clear_pointer(color:Color) -> void:
	if !pointer.has(color):
		return
	for iter:Node2D in pointer[color]:
		iter.queue_free()
	pointer.erase(color)

func convert_name_to_position(_name:String) -> Vector2:
	var ascii:PackedByteArray = _name.to_ascii_buffer()
	var converted:Vector2 = Vector2(ascii[0] - 97, 7 - (ascii[1] - 49))
	return converted * resolution / 8 + Vector2(resolution / 16, resolution / 16)
