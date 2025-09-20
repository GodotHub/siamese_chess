extends Node2D

@export var audio_stream:AudioStream = null
var source_frequency:int = 44100
var wav:PackedVector2Array = []
var fourier:PackedVector2Array = []

func _ready() -> void:
	var audio_stream_playback:AudioStreamPlayback = audio_stream.instantiate_playback()	
	audio_stream_playback.start(0)
	var data:PackedVector2Array = audio_stream_playback.mix_audio(1, 44100)
	while data.size():
		wav.append_array(data)
		data = audio_stream_playback.mix_audio(1, 44100)
	source_frequency = wav.size() / audio_stream.get_length()
	fourier = fourier_transform(wav)

func _draw() -> void:
	var time:float = 0.34
	var start_index:int = time * source_frequency
	for i in 1000:
		draw_circle(Vector2(i + 10, wav[start_index + i].x * 600 + 300), 5, Color(1, 0, 0, 0.5))
		draw_circle(Vector2(i + 10, wav[start_index + i].y * 600 + 300), 5, Color(0, 0, 1, 0.5))
		var sample:Vector2 = fourier_transform_sample(fourier, time + float(i) / source_frequency)
		draw_circle(Vector2(i + 10, sample.x * 600 + 300), 5, Color(0, 1, 0, 0.5))
		draw_circle(Vector2(i + 10, sample.y * 600 + 300), 5, Color(0, 1, 0, 0.5))

func fourier_transform(data:PackedVector2Array) -> PackedVector2Array:
	var a:PackedVector2Array
	a.resize(80002)	# 系数，音频采样点和单位正弦波采样点点乘
	for i:int in data.size():
		var time:float = float(i) / source_frequency
		for j:int in range(-20000, 20001):	# 频率0-100
			a[j + 20000] += data[i] * sin(time * j) / data.size()
			a[j + 60001] += data[i] * cos(time * j) / data.size()
	return a

func fourier_transform_sample(data:PackedVector2Array, time:float) -> Vector2:
	var output:Vector2
	for i:int in range(-20000, 20001):
		output += data[i + 20000] * sin(i * time)
	for i:int in range(-20000, 20001):
		output += data[i + 60001] * cos(i * time)
	return output

func fft(data:PackedVector2Array) -> PackedVector2Array:
	return []
