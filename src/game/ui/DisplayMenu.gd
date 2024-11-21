extends Control

@export var focus_sfx: AudioStream
@export var click_sfx: AudioStream
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var brightness: HSlider = %Brightness

func _ready() -> void:
	WorldEnviroment.environment.adjustment_brightness = brightness.value
	hide()

func _on_return_button_pressed() -> void:
	hide()

func on_focus():
	audio_stream_player.stream = focus_sfx
	audio_stream_player.play()

func on_click():
	audio_stream_player.stream = click_sfx
	audio_stream_player.play()

func _on_brightness_value_changed(value: float) -> void:
	print(value)
	WorldEnviroment.environment.adjustment_brightness = value
