extends InspectableItem

var channel:Dictionary = {
}

var freq:float = 87.5	# 广播频率，到时做成跨度0.1的滑条
var volume:float = 0	# 音量
var power:bool = false	# 开关
@onready var area_freq:Area3D = $interface/knob_freq/area_3d
@onready var area_volume:Area3D = $interface/knob_volume/area_3d
var freq_polar_position:Vector2 = Vector2(0, 0)
var freq_last_polar_position:Vector2 = Vector2(0, 0)
var volume_polar_position:Vector2 = Vector2(0, 0)
var volume_last_polar_position:Vector2 = Vector2(0, 0)

func _ready() -> void:
	super._ready()

func input(_from:Node3D, _to:Area3D, _event:InputEvent, _event_position:Vector3, _normal:Vector3) -> void:
	if _to == $interface/knob_volume/area_3d:
		if _event is InputEventMouseMotion && (_event.button_mask & MOUSE_BUTTON_MASK_LEFT):
			var collision_shape:CollisionShape3D = area_volume.get_node("collision_shape_3d")
			var event_position_3d:Vector3 = collision_shape.global_transform.affine_inverse() * _event_position
			var event_position_2d:Vector2 = Vector2(event_position_3d.x, event_position_3d.z)
			volume_polar_position = Vector2(event_position_2d.length(), event_position_2d.angle())
			volume = clamp(volume + (volume_polar_position.y - volume_last_polar_position.y) / 4 / PI, 0, 1)
	elif _to == $interface/knob_freq/area_3d:
		if _event is InputEventMouseMotion && (_event.button_mask & MOUSE_BUTTON_MASK_LEFT):
			var collision_shape:CollisionShape3D = area_freq.get_node("collision_shape_3d")
			var event_position_3d:Vector3 = collision_shape.global_transform.affine_inverse() * _event_position
			var event_position_2d:Vector2 = Vector2(event_position_3d.x, event_position_3d.z)
			freq_polar_position = Vector2(event_position_2d.length(), event_position_2d.angle())
			freq = clamp(freq + (freq_polar_position.y - freq_last_polar_position.y) / PI, 87.5, 108.0)
