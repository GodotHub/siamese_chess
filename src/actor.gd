extends InspectableItem
class_name Actor

# SiameseChess中100%的人都会参与到战斗中。

func _ready() -> void:
	super._ready()

func play_animation(anim:String) -> void:
	$AnimationPlayer.play(anim)

func capturing(_pos:Vector3) -> void:	# 攻击
	pass

func captured() -> void:	# 被攻击
	pass

func move(_pos:Vector3) -> void:	# 单纯的移动
	var tween:Tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "global_position", _pos, 0.4)
	if has_node("AnimationPlayer") && $AnimationPlayer.has_animation("move"):
		$AnimationPlayer.play("move")

func target() -> void:	# 作为轻子威胁重子，或牵制对手的棋子时将会面向目标准备攻击，包括将军
	pass

func defend() -> void:  # 被轻子威胁，或被牵制时采取防御姿态
	pass
