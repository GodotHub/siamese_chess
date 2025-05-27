extends Node3D

signal timeout(group:int)

@onready var timer_0:Timer = $timer_0	# 左侧为0，右侧为1
@onready var timer_1:Timer = $timer_1
@onready var button:MeshInstance3D = $button
@onready var label:Label = $sub_viewport/panel/label

var in_game:bool = false
var turn:int = 0
var time_0:int = 0
var time_1:int = 0
var extra:int = 0

func _ready() -> void:
	# 按钮的旋转角度是1.5度，向左倾斜为正数，轮到1。向右则轮到0
	button.rotation_degrees.z = 1.5
	label.text = ""
	timer_0.connect("timeout", end_game.bind(0))
	timer_1.connect("timeout", end_game.bind(1))
	set_physics_process(false)

func set_time(_time:int, _first:int, _extra:int) -> void:
	timer_0.wait_time = _time
	timer_1.wait_time = _time
	time_0 = _time
	time_1 = _time
	extra = _extra
	turn = _first
	timer_0.start()
	timer_1.start()
	timer_0.paused = true
	timer_1.paused = true
	in_game = true
	label.text = "%02d:%02d   %02d:%02d" % [time_0 / 60, time_0 % 60, time_1 / 60, time_1 % 60]
	#set_physics_process(true)

func start() -> void:
	if turn == 0:
		timer_0.paused = false
		timer_1.paused = true
	else:
		timer_0.paused = true
		timer_1.paused = false
	set_physics_process(true)

func _physics_process(_delta:float) -> void:
	time_0 = timer_0.time_left
	time_1 = timer_1.time_left
	label.text = "%02d:%02d   %02d:%02d" % [time_0 / 60, time_0 % 60, time_1 / 60, time_1 % 60]

func pause() -> void:
	timer_0.stop()
	timer_1.stop()
	set_physics_process(false)

func resume() -> void:
	if turn == 0:
		timer_0.start()
	else:
		timer_1.start()

func next() -> void:
	turn = (turn + 1) % 2
	var tween:Tween = create_tween()
	tween.tween_property(button, "rotation_degrees:z", 1.5 * (1 if turn == 1 else -1), 0.2).set_trans(Tween.TRANS_SPRING)
	if turn == 0:
		timer_1.wait_time = time_1 + extra
		timer_1.start()
		timer_0.paused = false
		timer_1.paused = true
	else:
		timer_0.wait_time = time_0 + extra
		timer_0.start()
		timer_0.paused = true
		timer_1.paused = false

func stop() -> void:
	timer_0.stop()
	timer_1.stop()
	label.text = ""
	set_physics_process(false)

func end_game(group:int) -> void:
	if group == 0:
		time_0 = timer_0.time_left
	else:
		time_1 = timer_1.time_left
	label.text = "%02d:%02d   %02d:%02d" % [time_0 / 60, time_0 % 60, time_1 / 60, time_1 % 60]
	if group == 0:
		timer_1.stop()
	else:
		timer_0.stop()
	set_physics_process(false)
	timeout.emit(group)
