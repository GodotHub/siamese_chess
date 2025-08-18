extends InspectableItem

# 打电话，当然里面肯定会藏线索

var address:Array = [
	"2025"
]

signal call_number(number:String)

@onready var area_1:Area3D = $"1"
@onready var area_2:Area3D = $"2"
@onready var area_3:Area3D = $"3"
@onready var area_4:Area3D = $"4"
@onready var area_5:Area3D = $"5"
@onready var area_6:Area3D = $"6"
@onready var area_7:Area3D = $"7"
@onready var area_8:Area3D = $"8"
@onready var area_9:Area3D = $"9"
@onready var area_0:Area3D = $"0"
@onready var area_phone:Area3D = $"phone/area_phone"
@onready var dial_mask:MeshInstance3D = $dial_base/dial_mask

var number:String = ""
var hanging:bool = false

func _ready() -> void:
	super._ready()

func check_number() -> void:
	if address.has(number):
		# 播放完音效后交给环境场景进行演出
		call_number.emit(number)

func input(_from:Node3D, _to:Area3D, _event:InputEvent, _event_position:Vector3, _normal:Vector3) -> void:
	if _event is InputEventMouseButton && _event.pressed && _event.button_index == MOUSE_BUTTON_LEFT:
		if _to == area_0:
			number += "0"
			create_tween().tween_property(dial_mask, "rotation:y", 30 * 10, 0.3).set_trans(Tween.TRANS_SINE)
			create_tween().tween_property(dial_mask, "rotation:y", 0, 0.3).set_trans(Tween.TRANS_SINE)
		elif _to == area_1:
			number += "1"
			create_tween().tween_property(dial_mask, "rotation:y", 30 * 1, 0.3).set_trans(Tween.TRANS_SINE)
			create_tween().tween_property(dial_mask, "rotation:y", 0, 0.3).set_trans(Tween.TRANS_SINE)
		elif _to == area_2:
			number += "2"
			create_tween().tween_property(dial_mask, "rotation:y", 30 * 2, 0.3).set_trans(Tween.TRANS_SINE)
			create_tween().tween_property(dial_mask, "rotation:y", 0, 0.3).set_trans(Tween.TRANS_SINE)
		elif _to == area_3:
			number += "3"
			create_tween().tween_property(dial_mask, "rotation:y", 30 * 3, 0.3).set_trans(Tween.TRANS_SINE)
			create_tween().tween_property(dial_mask, "rotation:y", 0, 0.3).set_trans(Tween.TRANS_SINE)
		elif _to == area_4:
			number += "4"
			create_tween().tween_property(dial_mask, "rotation:y", 30 * 4, 0.3).set_trans(Tween.TRANS_SINE)
			create_tween().tween_property(dial_mask, "rotation:y", 0, 0.3).set_trans(Tween.TRANS_SINE)
		elif _to == area_5:
			number += "5"
			create_tween().tween_property(dial_mask, "rotation:y", 30 * 5, 0.3).set_trans(Tween.TRANS_SINE)
			create_tween().tween_property(dial_mask, "rotation:y", 0, 0.3).set_trans(Tween.TRANS_SINE)
		elif _to == area_6:
			number += "6"
			create_tween().tween_property(dial_mask, "rotation:y", 30 * 6, 0.3).set_trans(Tween.TRANS_SINE)
			create_tween().tween_property(dial_mask, "rotation:y", 0, 0.3).set_trans(Tween.TRANS_SINE)
		elif _to == area_7:
			number += "7"
			create_tween().tween_property(dial_mask, "rotation:y", 30 * 7, 0.3).set_trans(Tween.TRANS_SINE)
			create_tween().tween_property(dial_mask, "rotation:y", 0, 0.3).set_trans(Tween.TRANS_SINE)
		elif _to == area_8:
			number += "8"
			create_tween().tween_property(dial_mask, "rotation:y", 30 * 8, 0.3).set_trans(Tween.TRANS_SINE)
			create_tween().tween_property(dial_mask, "rotation:y", 0, 0.3).set_trans(Tween.TRANS_SINE)
		elif _to == area_9:
			number += "9"
			create_tween().tween_property(dial_mask, "rotation:y", 30 * 9, 0.3).set_trans(Tween.TRANS_SINE)
			create_tween().tween_property(dial_mask, "rotation:y", 0, 0.3).set_trans(Tween.TRANS_SINE)
		elif _to == area_phone:
			number = ""
			hanging = !hanging
			if hanging:
				pass	# 提起话筒
			else:
				pass	# 放下话筒
