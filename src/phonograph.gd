extends InspectableItem

@export var audio_stream:AudioStream = null
var source_frequency:int = 44100
var wav:PackedVector2Array = []
var generator_playback:AudioStreamGeneratorPlayback = null
@onready var audio_stream_player:AudioStreamPlayer3D = $audio_stream_player_3d
@onready var area_stylus:Area3D = $stylus/area_stylus	# 点击唱针播放
@onready var area_vinyl:Area3D = $area_vinyl	# 点击唱片切换？或者搓碟也不是不行？
var polar_position:Vector2 = Vector2()
var last_event_polar_position:Vector2 = Vector2()
var velocity:float = 0
var play_frame:int = 0	# 下标位置
var frame_delta:int = 0	# 这一帧跳转到这里
var playing:bool = false
var is_pressed:bool = false

func _ready() -> void:
	super._ready()
	var audio_stream_playback:AudioStreamPlayback = audio_stream.instantiate_playback()	
	audio_stream_playback.start(0)
	var data:PackedVector2Array = audio_stream_playback.mix_audio(1, 44100)
	while data.size():
		wav.append_array(data)
		data = audio_stream_playback.mix_audio(1, 44100)
	source_frequency = wav.size() / audio_stream.get_length()
	generator_playback = audio_stream_player.get_stream_playback()

func _physics_process(delta: float) -> void:
	if playing:
		velocity = lerp(velocity, 1.0, 0.2)
	else:
		velocity = lerp(velocity, 0.0, 0.2)
	if is_pressed:
		var angle_delta:float = angle_difference(last_event_polar_position.y, polar_position.y)
		var angle_velocity = (angle_delta / ((TAU * 100.0 / 3.0) / 60.0)) / delta
		velocity = lerp(velocity, angle_velocity, 0.05)
	$vinyl.rotation.y -= velocity * (TAU * 100.0 / 3.0 / 60.0) * delta
	frame_delta += source_frequency * velocity * delta
	last_event_polar_position = polar_position
	fill_buffer(delta)

func input(_from:Node3D, _to:Area3D, _event:InputEvent, _event_position:Vector3, _normal:Vector3) -> void:
	if _to == area_stylus:
		if _event is InputEventMouseButton:
			if _event.pressed && _event.button_index == MOUSE_BUTTON_LEFT:
				playing = !playing
				if playing:
					create_tween().tween_property($stylus, "rotation_degrees:y", -16.6, 0.2).set_trans(Tween.TRANS_SINE)
				else:
					create_tween().tween_property($stylus, "rotation_degrees:y", 0, 0.2).set_trans(Tween.TRANS_SINE)
	elif _to == area_vinyl:
		if _event is InputEventMouseMotion && (_event.button_mask & MOUSE_BUTTON_MASK_LEFT):
			is_pressed = true
			var collision_shape:CollisionShape3D = area_vinyl.get_node("collision_shape_3d")
			var event_position_3d:Vector3 = collision_shape.global_transform.affine_inverse() * _event_position
			var event_position_2d:Vector2 = Vector2(event_position_3d.x, event_position_3d.z)
			polar_position = Vector2(event_position_2d.length(), event_position_2d.angle())
		else:
			is_pressed = false

func fill_buffer(delta:float) -> void:
	var frame_count:int = 44100 * delta
	for i:int in frame_count:
		var frame:int = play_frame + float(frame_delta) * float(i) / float(frame_count)
		frame = clamp(frame, 0, wav.size() - 1)
		if frame >= 0 && frame < wav.size():
			generator_playback.push_frame(wav[frame])
		else:
			generator_playback.push_frame(Vector2(0, 0))
	play_frame = clamp(play_frame + frame_delta, 0, wav.size() - 1)
	frame_delta = 0
