extends Actor

var position_name:String = ""
var sfx:AudioStreamPlayer3D = null
var show_on_backup:bool = true
var backup_position:Vector3 = Vector3(0, 0, 0)

func _ready() -> void:
	super._ready()
	top_level = true
	visible = show_on_backup
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

func introduce(_pos:Vector3) -> void:	# 登场动画
	visible = true
	move(_pos)

func move(_pos:Vector3) -> void:
	var tween:Tween = create_tween()
	tween.tween_property(self, "global_position", _pos, 0.3).set_trans(Tween.TRANS_SINE)
	tween.tween_callback(animation_finished.emit)

func capturing(_pos:Vector3, _captured:Actor) -> void:	# 攻击
	var tween:Tween = create_tween()
	tween.tween_property(self, "global_position", _pos, 0.3).set_trans(Tween.TRANS_SINE)
	tween.tween_callback(animation_finished.emit)
	_captured.captured(self)

func captured(_capturing:Actor = null) -> void:	# 被攻击
	if !show_on_backup:
		visible = false
		return
	var tween:Tween = create_tween()
	tween.tween_property(self, "global_position", backup_position, 0.3).set_trans(Tween.TRANS_SINE)

func promote(_pos:Vector3, _piece:int) -> void:
	var tween:Tween = create_tween()
	tween.tween_property(self, "global_position", _pos, 0.3).set_trans(Tween.TRANS_SINE)
	tween.tween_callback(animation_finished.emit)
	$piece.visible = false
	var instance:Actor = null
	match _piece:
		81:
			instance = load("res://scene/piece_queen_black.tscn").instantiate()
		82:
			instance = load("res://scene/piece_rook_black.tscn").instantiate()
		66:
			instance = load("res://scene/piece_bishop_black.tscn").instantiate()
		78:
			instance = load("res://scene/piece_knight_black.tscn").instantiate()
		113:
			instance = load("res://scene/piece_queen_black.tscn").instantiate()
		114:
			instance = load("res://scene/piece_rook_black.tscn").instantiate()
		98:
			instance = load("res://scene/piece_bishop_black.tscn").instantiate()
		110:
			instance = load("res://scene/piece_knight_black.tscn").instantiate()
	add_child(instance)

func set_show_on_backup(_show_on_backup:bool) -> Actor:
	show_on_backup = _show_on_backup
	return self

func set_backup_position(_backup_position:Vector3) -> Actor:
	backup_position = _backup_position
	return self

func set_larger_scale() -> Actor:
	scale = Vector3(8, 8, 8)
	return self
