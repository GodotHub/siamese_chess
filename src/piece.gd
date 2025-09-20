extends Actor

var position_name:String = ""
var sfx:AudioStreamPlayer3D = null
var group:int = 0
var show_on_backup:bool = false
var backup_position:Vector3 = Vector3(0, 0, 0)

func _ready() -> void:
	super._ready()
	visible = show_on_backup
	global_position = backup_position
	group = Chess.group(piece_type[0])
	var audio_stream_randomizer:AudioStreamRandomizer = AudioStreamRandomizer.new()
	audio_stream_randomizer.random_pitch = 1.3
	audio_stream_randomizer.random_volume_offset_db = 2.0
	audio_stream_randomizer.add_stream(-1, load("res://assets/audio/351518__mh2o__chess_move_on_alabaster.wav"))
	sfx = AudioStreamPlayer3D.new()
	sfx.stream = audio_stream_randomizer
	add_child(sfx)
	sfx.unit_size = 2
	sfx.volume_db = -20
	#if position_name:
	#	position = chessboard.convert_name_to_position(position_name)
	#else:
	#	position_name = chessboard.get_position_name(position)
	#	position = chessboard.convert_name_to_position(position_name)
		
	var material:ShaderMaterial = ShaderMaterial.new()
	material.shader = load("res://src/unmoving_plaid.gdshader")
	material.set_shader_parameter("texture_albedo", load("res://assets/texture/Texturelabs_Stone_131S.jpg"))
	material.set_shader_parameter("saturation_mult", 0.85)
	material.set_shader_parameter("value_mult", 0.728)
	material.set_shader_parameter("contrast_mult", 0.199)
	var next_pass_material:StandardMaterial3D = StandardMaterial3D.new()
	next_pass_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	next_pass_material.cull_mode = BaseMaterial3D.CULL_FRONT
	next_pass_material.grow = true
	next_pass_material.grow_amount = 0.005
	if group == 1:
		material.set_shader_parameter("brightness_add", 0.000)
		next_pass_material.albedo_color = Color(1, 1, 1, 1)
	else:
		material.set_shader_parameter("brightness_add", 0.676)
		next_pass_material.albedo_color = Color(0, 0, 0, 1)
	material.next_pass = next_pass_material
	$piece.set_surface_override_material(0, material)

func introduce(_pos:Vector3) -> void:	# 登场动画
	visible = true
	move(_pos)

func move(_pos:Vector3) -> void:
	var tween:Tween = create_tween()
	tween.tween_property(self, "global_position", _pos, 0.3).set_trans(Tween.TRANS_SINE)

func capturing(_pos:Vector3, _captured:Actor) -> void:	# 攻击
	var tween:Tween = create_tween()
	tween.tween_property(self, "global_position", _pos, 0.3).set_trans(Tween.TRANS_SINE)
	_captured.captured()

func captured() -> void:	# 被攻击
	if !show_on_backup:
		visible = false
		return
	var tween:Tween = create_tween()
	tween.tween_property(self, "global_position", backup_position, 0.3).set_trans(Tween.TRANS_SINE)

func set_warning(enabled:bool) -> void:
	if enabled:
		$piece.get_surface_override_material(0).next_pass.albedo_color = Color(1, 0, 0, 1)
	elif group == 1:
		$piece.get_surface_override_material(0).next_pass.albedo_color = Color(1, 1, 1, 1)
	else:
		$piece.get_surface_override_material(0).next_pass.albedo_color = Color(0, 0, 0, 1)

func set_show_on_backup(_show_on_backup:bool) -> Actor:
	show_on_backup = _show_on_backup
	return self

func set_backup_position(_backup_position:Vector3) -> Actor:
	backup_position = _backup_position
	return self
