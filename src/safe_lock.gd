extends InspectableItem

@export var password:String = "0123456789"
var current:String = ""
@onready var area_0:Area3D = $"door/0"
@onready var area_1:Area3D = $"door/1"
@onready var area_2:Area3D = $"door/2"
@onready var area_3:Area3D = $"door/3"
@onready var area_4:Area3D = $"door/4"
@onready var area_5:Area3D = $"door/5"
@onready var area_6:Area3D = $"door/6"
@onready var area_7:Area3D = $"door/7"
@onready var area_8:Area3D = $"door/8"
@onready var area_9:Area3D = $"door/9"
@onready var area_a:Area3D = $"door/a"
@onready var area_b:Area3D = $"door/b"
@onready var area_c:Area3D = $"door/c"
@onready var area_d:Area3D = $"door/d"
@onready var area_e:Area3D = $"door/e"
@onready var area_f:Area3D = $"door/f"
@onready var area_handle:Area3D = $"door/handle/area_handle"

func _ready() -> void:
	super._ready()

func update_text() -> void:
	$sub_viewport/label.text = current

func input(_from:Node3D, _to:Area3D, _event:InputEvent, _event_position:Vector3, _normal:Vector3) -> void:	# 按按钮，以及门把手
	if _event is InputEventMouseButton && _event.pressed && _event.button_index == MOUSE_BUTTON_LEFT:
		if _to == area_0:
			current += "0"
		elif _to == area_1:
			current += "1"
		elif _to == area_2:
			current += "2"
		elif _to == area_3:
			current += "3"
		elif _to == area_4:
			current += "4"
		elif _to == area_5:
			current += "5"
		elif _to == area_6:
			current += "6"
		elif _to == area_7:
			current += "7"
		elif _to == area_8:
			current += "8"
		elif _to == area_9:
			current += "9"
		elif _to == area_a:
			current += "a"
		elif _to == area_b:
			current += "b"
		elif _to == area_c:
			current += "c"
		elif _to == area_d:
			current += "d"
		elif _to == area_e:
			current += "e"
		elif _to == area_f:
			current += "f"
		update_text()
