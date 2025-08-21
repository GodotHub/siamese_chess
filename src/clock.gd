extends InspectableItem

signal timeout(group:int)

@onready var button:MeshInstance3D = $button
@onready var label:Label = $sub_viewport/panel/label

var in_game:bool = false
var turn:int = 0
var time_0:float = 0
var start_thinking_0:float = 0
var time_1:float = 0
var start_thinking_1:float = 0
var extra:int = 0

func _ready() -> void:
	# 按钮的旋转角度是1.5度，向左倾斜为正数，轮到1。向右则轮到0
	button.rotation_degrees.z = 1.5
	label.text = ""
	set_physics_process(false)

func set_time(_time:float, _first:int, _extra:int) -> void:
	time_0 = _time
	time_1 = _time
	extra = _extra
	turn = _first
	in_game = true
	label.text = "%02d:%02d   %02d:%02d" % [time_0 / 60, fmod(time_0, 60), time_1 / 60, fmod(time_1, 60)]
	#set_physics_process(true)

func start() -> void:
	if turn == 0:
		start_thinking_0 = Time.get_unix_time_from_system()
	else:
		start_thinking_1 = Time.get_unix_time_from_system()
	set_physics_process(true)

func _physics_process(_delta:float) -> void:
	var time_left_0:float = max(0, get_time_left(0))
	var time_left_1:float = max(0, get_time_left(1))
	label.text = "%02d:%02d:%02d   %02d:%02d:%02d" % [time_left_0 / 60, fmod(time_left_0, 60), fmod(time_left_0 * 100, 100.0), time_left_1 / 60, fmod(time_left_1, 60), fmod(time_left_1 * 100, 100.0)]
	if time_left_0 == 0:
		end_game(0)
	elif time_left_1 == 0:
		end_game(1)

func get_time_left(group:int) -> float:
	if turn == group:
		return time_0 - (Time.get_unix_time_from_system() - start_thinking_0) if group == 0 else time_1 - (Time.get_unix_time_from_system() - start_thinking_1)
	else:
		return time_0 if group == 0 else time_1

func pause() -> void:
	if turn == 0:
		time_0 -= Time.get_unix_time_from_system() - start_thinking_0
	else:
		time_1 -= Time.get_unix_time_from_system() - start_thinking_1
	set_physics_process(false)

func resume() -> void:
	if turn == 0:
		start_thinking_0 = Time.get_unix_time_from_system()
	else:
		start_thinking_1 = Time.get_unix_time_from_system()

func next() -> void:
	var tween:Tween = create_tween()
	tween.tween_property(button, "rotation_degrees:z", 1.5 * (1 if turn == 1 else -1), 0.2).set_trans(Tween.TRANS_SPRING)
	if turn == 0:
		time_0 -= Time.get_unix_time_from_system() - start_thinking_0
		start_thinking_1 = Time.get_unix_time_from_system()
	else:
		time_1 -= Time.get_unix_time_from_system() - start_thinking_1
		start_thinking_0 = Time.get_unix_time_from_system()
	turn = (turn + 1) % 2

func stop() -> void:
	label.text = ""
	set_physics_process(false)

func end_game(group:int) -> void:
	var time_left_0:float = max(0, get_time_left(0))
	var time_left_1:float = max(0, get_time_left(1))
	label.text = "%02d:%02d   %02d:%02d" % [time_left_0 / 60, fmod(time_left_0, 60), time_left_1 / 60, fmod(time_left_1, 60)]
	set_physics_process(false)
	timeout.emit(group)
