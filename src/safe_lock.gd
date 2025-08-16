extends InspectableItem

@export var password:String = "0123456789"
var current:String = ""
var unlocked:bool = false
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
@onready var area_close:Area3D = $"door/area_close"

func _ready() -> void:
	super._ready()
	update_text()

func update_text() -> void:
	if unlocked:
		$sub_viewport/label.text = "OK"
	else:
		$sub_viewport/label.text = current

func input(_from:Node3D, _to:Area3D, _event:InputEvent, _event_position:Vector3, _normal:Vector3) -> void:	# 按按钮，以及门把手
	if _event is InputEventMouseButton && _event.pressed && _event.button_index == MOUSE_BUTTON_LEFT:
		if _to == area_0:
			current += "#"
		elif _to == area_1:
			current += "7"
		elif _to == area_2:
			current += "8"
		elif _to == area_3:
			current += "9"
		elif _to == area_4:
			current += "4"
		elif _to == area_5:
			current += "5"
		elif _to == area_6:
			current += "6"
		elif _to == area_7:
			current += "1"
		elif _to == area_8:
			current += "2"
		elif _to == area_9:
			current += "3"
		elif _to == area_a:	# 删除单字
			if current.length():
				current = current.left(current.length() - 1)
		elif _to == area_b:	# 全部清空
			current = ""
		elif _to == area_c:	# 上锁
			current = ""
			unlocked = false
			$sub_viewport/label.text = "LOCKED"
			await get_tree().create_timer(2.0).timeout
		elif _to == area_d:	# 提交
			if current == password:
				unlocked = true
			else:
				$sub_viewport/label.text = "ERROR"
				current = ""
				await get_tree().create_timer(2.0).timeout
		elif _to == area_e:
			current += "*"
		elif _to == area_f:
			current += "0"
		elif _to == area_handle && unlocked:
			create_tween().tween_property($door, "rotation_degrees:y", 90, 2).set_trans(Tween.TRANS_SINE)
		elif _to == area_close:
			create_tween().tween_property($door, "rotation_degrees:y", 0, 2).set_trans(Tween.TRANS_SINE)
		update_text()
