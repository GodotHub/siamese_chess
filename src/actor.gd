extends InspectableItem
class_name Actor

# SiameseChess中100%的人都会参与到战斗中。

# 由于棋子总量有限，SiameseChess中部分人会兼有其他定位
@export var piece_type:PackedInt32Array = []

func _ready() -> void:
	super._ready()

func idle() -> void:
	var tween:Tween = create_tween()
	if has_node("animation_tree"):
		tween.tween_callback($animation_tree.get("parameters/playback").travel.bind("idle"))

func capturing(_pos:Vector3) -> void:	# 攻击
	var tween:Tween = create_tween()
	tween.tween_property(self, "global_position", _pos, global_position.distance_to(_pos) / 5)

func captured() -> void:	# 被攻击
	pass

func move(_pos:Vector3) -> void:	# 单纯的移动
	var tween:Tween = create_tween()
	tween.tween_property(self, "global_position", _pos, global_position.distance_to(_pos) / 5)

func target() -> void:	# 作为轻子威胁重子，或牵制对手的棋子时将会面向目标准备攻击，包括将军
	pass

func defend() -> void:  # 被轻子威胁，或被牵制时采取防御姿态
	pass
