extends InspectableItem
class_name Actor

# SiameseChess中100%的人都会参与到战斗中。

# 由于棋子总量有限，SiameseChess中部分人会兼有其他定位
@export var piece_type:PackedInt32Array = []

func _ready() -> void:
	super._ready()

func introduce(_pos:Vector3) -> void:	# 登场动画
	visible = true
	global_position = _pos

func capturing(_pos:Vector3, _captured:Actor) -> void:	# 攻击
	var tween:Tween = create_tween()
	tween.tween_property(self, "global_position", _pos, 0.3).set_trans(Tween.TRANS_SINE)
	_captured.captured(self)

func captured(_capturing:Actor) -> void:	# 被攻击
	visible = false

func promote() -> void:	# 升变
	visible = false

func move(_pos:Vector3) -> void:	# 单纯的移动
	var tween:Tween = create_tween()
	tween.tween_property(self, "global_position", _pos, 0.3).set_trans(Tween.TRANS_SINE)

func target() -> void:	# 作为轻子威胁重子，或牵制对手的棋子时将会面向目标准备攻击，包括将军
	pass

func defend() -> void:  # 被轻子威胁，或被牵制时采取防御姿态
	pass
