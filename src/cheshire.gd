extends Actor

func _ready() -> void:
	$animation_tree.get("parameters/playback").start("battle_idle")
	super._ready()

func play_animation(anim:String) -> void:
	$animation_tree.get("parameters/playback").travel(anim)

func capturing(_pos:Vector3) -> void:	# 攻击
	var current_position_2d:Vector2 = Vector2(global_position.x, global_position.z)
	var target_position_2d:Vector2 = Vector2(_pos.x, _pos.z)
	var target_angle:float = -current_position_2d.angle_to_point(target_position_2d) + PI / 2
	target_angle = global_rotation.y + angle_difference(global_rotation.y, target_angle)
	var tween:Tween = create_tween()
	if has_node("animation_tree"):
		tween.tween_callback($animation_tree.get("parameters/playback").travel.bind("battle_attack"))
	tween.tween_property(self, "global_rotation:y", target_angle, 0.1).set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "global_position", _pos, global_position.distance_to(_pos) / 5)

func captured() -> void:	# 被攻击
	var tween:Tween = create_tween()
	if has_node("animation_tree"):
		tween.tween_callback($animation_tree.get("parameters/playback").travel.bind("battle_dead"))

func move(_pos:Vector3) -> void:	# 单纯的移动
	var current_position_2d:Vector2 = Vector2(global_position.x, global_position.z)
	var target_position_2d:Vector2 = Vector2(_pos.x, _pos.z)
	var target_angle:float = -current_position_2d.angle_to_point(target_position_2d) + PI / 2
	target_angle = global_rotation.y + angle_difference(global_rotation.y, target_angle)
	var tween:Tween = create_tween()
	if has_node("animation_tree"):
		tween.tween_callback($animation_tree.get("parameters/playback").travel.bind("battle_move"))
	tween.tween_property(self, "global_rotation:y", target_angle, 0.1).set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "global_position", _pos, global_position.distance_to(_pos) / 5)
	if has_node("animation_tree"):
		tween.tween_callback($animation_tree.get("parameters/playback").travel.bind("battle_idle"))

func target() -> void:	# 作为轻子威胁重子，或牵制对手的棋子时将会面向目标准备攻击，包括将军
	var tween:Tween = create_tween()
	if has_node("animation_tree"):
		tween.tween_callback($animation_tree.get("parameters/playback").travel.bind("battle_target"))

func defend() -> void:  # 被轻子威胁，或被牵制时采取防御姿态
	var tween:Tween = create_tween()
	if has_node("animation_tree"):
		tween.tween_callback($animation_tree.get("parameters/playback").travel.bind("battle_defend"))
