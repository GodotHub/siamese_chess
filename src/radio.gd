extends InspectableItem

var channel:Dictionary = {
}

var freq:float = 0	# 广播频率，到时做成跨度0.1的滑条
var volume:float = 0	# 音量
var power:bool = false	# 开关

func _ready() -> void:
	super._ready()

func input(_from:Node3D, _to:Area3D, _event:InputEvent, _event_position:Vector3, _normal:Vector3) -> void:
	if _to == $interface/knob_volume/area_3d:
		pass
	elif _to == $interface/knob_freq/area_3d:
		pass
