extends InspectableItem

# 打电话，当然里面肯定会藏线索

var address:Array = [
	"2025"
]

signal call_number(number:String)

@onready var area_1:Area3D = $"area_1"
@onready var area_2:Area3D = $"area_2"
@onready var area_3:Area3D = $"area_3"
@onready var area_4:Area3D = $"area_4"
@onready var area_5:Area3D = $"area_5"
@onready var area_6:Area3D = $"area_6"
@onready var area_7:Area3D = $"area_7"
@onready var area_8:Area3D = $"area_8"
@onready var area_9:Area3D = $"area_9"
@onready var area_0:Area3D = $"area_0"
@onready var area_phone:Area3D = $"microphone/area_3d"
@onready var dial_mask:MeshInstance3D = $dial_base/dial
var number:String = ""
var hanging:bool = false

func _ready() -> void:
	super._ready()

func check_number() -> void:
	if address.has(number):
		# 播放完音效后交给环境场景进行演出
		var tween:Tween = create_tween()
		tween.tween_callback($microphone/audio_stream_player_phone.stop)
		tween.tween_interval(2)
		tween.tween_callback($microphone/audio_stream_player_phone.play)
		tween.tween_interval(1)
		tween.tween_callback($microphone/audio_stream_player_phone.stop)
		tween.tween_interval(2)
		tween.tween_callback($microphone/audio_stream_player_phone.play)
		tween.tween_interval(1)
		tween.tween_callback($microphone/audio_stream_player_phone.stop)
		tween.tween_interval(2)
		tween.tween_callback(call_number.emit.bind(number))

func input(_from:Node3D, _to:Area3D, _event:InputEvent, _event_position:Vector3, _normal:Vector3) -> void:
	if _event is InputEventMouseButton && _event.pressed && _event.button_index == MOUSE_BUTTON_LEFT:
		if _to == area_0:
			number += "0"
			var tween:Tween = create_tween()
			tween.tween_callback($audio_stream_player_dial_up.play)
			tween.tween_property(dial_mask, "rotation_degrees:y", -320, 0.6).set_trans(Tween.TRANS_SINE)
			tween.tween_callback($audio_stream_player_dial_down.play)
			tween.tween_property(dial_mask, "rotation_degrees:y", 0, 0.6).set_trans(Tween.TRANS_SINE)
			tween.tween_callback(check_number)
		elif _to == area_1:
			number += "1"
			var tween:Tween = create_tween()
			tween.tween_callback($audio_stream_player_dial_up.play)
			tween.tween_property(dial_mask, "rotation_degrees:y", -67, 0.4).set_trans(Tween.TRANS_SINE)
			tween.tween_callback($audio_stream_player_dial_down.play)
			tween.tween_property(dial_mask, "rotation_degrees:y", 0, 0.4).set_trans(Tween.TRANS_SINE)
			tween.tween_callback(check_number)
		elif _to == area_2:
			number += "2"
			var tween:Tween = create_tween()
			tween.tween_callback($audio_stream_player_dial_up.play)
			tween.tween_property(dial_mask, "rotation_degrees:y", -96, 0.45).set_trans(Tween.TRANS_SINE)
			tween.tween_callback($audio_stream_player_dial_down.play)
			tween.tween_property(dial_mask, "rotation_degrees:y", 0, 0.45).set_trans(Tween.TRANS_SINE)
			tween.tween_callback(check_number)
		elif _to == area_3:
			number += "3"
			var tween:Tween = create_tween()
			tween.tween_callback($audio_stream_player_dial_up.play)
			tween.tween_property(dial_mask, "rotation_degrees:y", -124, 0.5).set_trans(Tween.TRANS_SINE)
			tween.tween_callback($audio_stream_player_dial_down.play)
			tween.tween_property(dial_mask, "rotation_degrees:y", 0, 0.5).set_trans(Tween.TRANS_SINE)
			tween.tween_callback(check_number)
		elif _to == area_4:
			number += "4"
			var tween:Tween = create_tween()
			tween.tween_callback($audio_stream_player_dial_up.play)
			tween.tween_property(dial_mask, "rotation_degrees:y", -150, 0.55).set_trans(Tween.TRANS_SINE)
			tween.tween_callback($audio_stream_player_dial_down.play)
			tween.tween_property(dial_mask, "rotation_degrees:y", 0, 0.55).set_trans(Tween.TRANS_SINE)
			tween.tween_callback(check_number)
		elif _to == area_5:
			number += "5"
			var tween:Tween = create_tween()
			tween.tween_callback($audio_stream_player_dial_up.play)
			tween.tween_property(dial_mask, "rotation_degrees:y", -177, 0.6).set_trans(Tween.TRANS_SINE)
			tween.tween_callback($audio_stream_player_dial_down.play)
			tween.tween_property(dial_mask, "rotation_degrees:y", 0, 0.6).set_trans(Tween.TRANS_SINE)
			tween.tween_callback(check_number)
		elif _to == area_6:
			number += "6"
			var tween:Tween = create_tween()
			tween.tween_callback($audio_stream_player_dial_up.play)
			tween.tween_property(dial_mask, "rotation_degrees:y", -206, 0.6).set_trans(Tween.TRANS_SINE)
			tween.tween_callback($audio_stream_player_dial_down.play)
			tween.tween_property(dial_mask, "rotation_degrees:y", 0, 0.6).set_trans(Tween.TRANS_SINE)
			tween.tween_callback(check_number)
		elif _to == area_7:
			number += "7"
			var tween:Tween = create_tween()
			tween.tween_callback($audio_stream_player_dial_up.play)
			tween.tween_property(dial_mask, "rotation_degrees:y", -231, 0.6).set_trans(Tween.TRANS_SINE)
			tween.tween_callback($audio_stream_player_dial_down.play)
			tween.tween_property(dial_mask, "rotation_degrees:y", 0, 0.6).set_trans(Tween.TRANS_SINE)
			tween.tween_callback(check_number)
		elif _to == area_8:
			number += "8"
			var tween:Tween = create_tween()
			tween.tween_callback($audio_stream_player_dial_up.play)
			tween.tween_property(dial_mask, "rotation_degrees:y", -258, 0.6).set_trans(Tween.TRANS_SINE)
			tween.tween_callback($audio_stream_player_dial_down.play)
			tween.tween_property(dial_mask, "rotation_degrees:y", 0, 0.6).set_trans(Tween.TRANS_SINE)
			tween.tween_callback(check_number)
		elif _to == area_9:
			number += "9"
			var tween:Tween = create_tween()
			tween.tween_callback($audio_stream_player_dial_up.play)
			tween.tween_property(dial_mask, "rotation_degrees:y", -290, 0.6).set_trans(Tween.TRANS_SINE)
			tween.tween_callback($audio_stream_player_dial_down.play)
			tween.tween_property(dial_mask, "rotation_degrees:y", 0, 0.6).set_trans(Tween.TRANS_SINE)
			tween.tween_callback(check_number)
		elif _to == area_phone:
			number = ""
			hanging = !hanging
			if hanging:
				$audio_stream_player_hang_off.play()
				var tween:Tween = create_tween()
				tween.tween_property($microphone, "transform", Transform3D(Vector3(0.924, -0.382, 0), Vector3(0.382, 0.924, 0), Vector3(0, 0, 1), Vector3(0, 0.128, -0.027)), 0.5).set_trans(Tween.TRANS_SINE)
				tween.tween_callback($microphone/audio_stream_player_phone.play)
			else:
				var tween:Tween = create_tween()
				tween.tween_property($microphone, "transform", Transform3D(Vector3(1, 0, 0), Vector3(0, 1, 0), Vector3(0, 0, 1), Vector3(0, 0.001, -0.027)), 0.5).set_trans(Tween.TRANS_SINE)
				tween.tween_callback($microphone/audio_stream_player_phone.stop)
				tween.tween_callback($audio_stream_player_hung_up.play)
