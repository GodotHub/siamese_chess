extends InspectableItem

@export password:String = "0123456789"
var current:String = ""

func _ready() -> void:
	super._ready()

func input(_from:Node3D, _to:Area3D, _event:InputEvent, _event_position:Vector3, _normal:Vector3) -> void:	# 按按钮，以及门把手
	pass
