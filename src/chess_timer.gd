extends Node3D

signal timeup(group:int)
@onready var timer_0:Timer = $timer_0	# 左侧为0，右侧为1
@onready var timer_1:Timer = $timer_1
@onready var button:MeshInstance3D = $button

var turn:int = 0
var time_0:int = 0
var time_1:int = 0

func _ready() -> void:
	# 按钮的旋转角度是1.5度，向左倾斜为正数，轮到1。向右则轮到0
	button.rotation_degrees.z = 1.5
	set_physics_process(false)
	start_game(1800, 1)

func start_game(time:int, first:int) -> void:
	timer_0.wait_time = time
	timer_1.wait_time = time
	time_0 = time
	time_1 = time
	turn = first
	if first == 0:
		timer_0.start()
	else:
		timer_1.start()
	set_physics_process(true)

func _physics_process(_delta:float) -> void:
	if turn == 0:
		time_0 = timer_0.time_left
	else:
		time_1 = timer_1.time_left
	$sub_viewport/panel/label.text = "%02d:%02d      %02d:%02d" % [time_0 / 60, time_0 % 60, time_1 / 60, time_1 % 60]

func set_time() -> void:
	pass
