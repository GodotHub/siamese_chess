extends Node3D
class_name PieceInstance

var chessboard:Chessboard = null
var chessboard_name:String = ""
var position_name:String = ""
var group:int = 0

func _ready() -> void:
	chessboard = Chess.get_current_chessboard()
	if !chessboard:
		return
	if position_name:
		position = chessboard.convert_name_to_position(position_name)
	else:
		position_name = chessboard.get_position_name(position)
		position = chessboard.convert_name_to_position(position_name)
		
	var material:StandardMaterial3D = StandardMaterial3D.new()
	var next_pass_material:StandardMaterial3D = StandardMaterial3D.new()
	next_pass_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	next_pass_material.cull_mode = BaseMaterial3D.CULL_FRONT
	next_pass_material.grow = true
	next_pass_material.grow_amount = 0.001
	if group == 1:
		material.albedo_color = Color(0.3, 0.3, 0.3, 1)
		next_pass_material.albedo_color = Color(1, 1, 1, 1)
	else:
		material.albedo_color = Color(0.7, 0.7, 0.7, 1)
		next_pass_material.albedo_color = Color(0, 0, 0, 1)
	material.next_pass = next_pass_material
	$piece.set_surface_override_material(0, material)

func move(_position_name:String) -> void:
	position_name = _position_name
	var tween:Tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "position", chessboard.convert_name_to_position(position_name), 0.4)
