extends Node3D

@onready var resolution:float = 512

var select_position:Array[Node2D] = []
var attack_position:Array[Node2D] = []
var move_position:Array[Node2D] = []
var pointer_position:Node2D = null

class ChessboardSelectPosition extends Node2D:
	var resolution:float = 512
	func _draw() -> void:
		draw_rect(Rect2(-resolution / 16, -resolution / 16, resolution / 8, resolution / 8), Color(0.1, 0.6, 0.1, 0.4))
		draw_rect(Rect2(-resolution / 16, -resolution / 16, resolution / 8, resolution / 8), Color(0.3, 0.6, 0.3), false, 10)

class ChessboardPointerPosition extends Node2D:
	var resolution:float = 512
	func _draw() -> void:
		draw_rect(Rect2(-resolution / 16, -resolution / 16, resolution / 8, resolution / 8), Color(0.1, 0.6, 0.1, 0.4))
		draw_rect(Rect2(-resolution / 16, -resolution / 16, resolution / 8, resolution / 8), Color(0.3, 0.6, 0.3), false, 10)

class ChessboardMovePosition extends Node2D:
	var resolution:float = 512
	func _draw() -> void:
		draw_rect(Rect2(-resolution / 16, -resolution / 16, resolution / 8, resolution / 8), Color(0.69411, 0.933333, 0.82745, 0.4))
		draw_rect(Rect2(-resolution / 16, -resolution / 16, resolution / 8, resolution / 8), Color(0.69411, 0.933333, 0.82745), false, 5)

class ChessboardAttackPosition extends Node2D:
	var resolution:float = 512
	var count:int = 0
	func _draw() -> void:
		var white:int = count & 0x3F
		var black:int = (count >> 6) & 0x3F
		draw_rect(Rect2(-resolution / 16, -resolution / 16, resolution / 8, resolution / 8), Color(0.6, 0.1, 0.1, white * 0.3))
		draw_rect(Rect2(-resolution / 16, -resolution / 16, resolution / 8, resolution / 8), Color(0.1, 0.1, 0.6, black * 0.3))

func _ready() -> void:
	$sub_viewport.size = Vector2(resolution, resolution)

func draw_pointer_position(drawing_position:Vector2) -> void:
	if !is_instance_valid(pointer_position):
		pointer_position = ChessboardPointerPosition.new()
		pointer_position.resolution = resolution
	if !pointer_position.is_inside_tree():
		$sub_viewport.add_child(pointer_position)
	pointer_position.position = drawing_position

func clear_pointer_position() -> void:
	if is_instance_valid(pointer_position) && pointer_position.is_inside_tree():
		$sub_viewport.remove_child(pointer_position)

func draw_select_position(drawing_position:Vector2) -> void:
	var new_point:ChessboardSelectPosition = ChessboardSelectPosition.new()
	new_point.position = drawing_position
	new_point.resolution = resolution
	$sub_viewport.add_child(new_point)
	select_position.push_back(new_point)

func clear_select_position() -> void:
	for iter:Node2D in select_position:
		iter.queue_free()
	select_position.clear()

func draw_attack_position(drawing_position:Vector2, count:int) -> void:
	var new_point:ChessboardAttackPosition = ChessboardAttackPosition.new()
	new_point.position = drawing_position
	new_point.resolution = resolution
	new_point.count = count
	$sub_viewport.add_child(new_point)
	attack_position.push_back(new_point)

func clear_attack_position() -> void:
	for iter:Node2D in attack_position:
		iter.queue_free()
	attack_position.clear()

func draw_move_position(drawing_position:Vector2) -> void:
	var new_point:ChessboardMovePosition = ChessboardMovePosition.new()
	new_point.position = drawing_position
	new_point.resolution = resolution
	$sub_viewport.add_child(new_point)
	move_position.push_back(new_point)

func clear_move_position() -> void:
	for iter:Node2D in move_position:
		iter.queue_free()
	move_position.clear()

func convert_name_to_position(_name:String) -> Vector2:
	var ascii:PackedByteArray = _name.to_ascii_buffer()
	var converted:Vector2 = Vector2(ascii[0] - 97, 7 - (ascii[1] - 49))
	return converted * resolution / 8 + Vector2(resolution / 16, resolution / 16)
