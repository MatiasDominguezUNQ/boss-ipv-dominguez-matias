extends Control

@export var focus_sfx: AudioStream
@export var click_sfx: AudioStream
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var brightness: HSlider = %Brightness
@onready var check_button: CheckButton = $MainPanel/ScrollContainer/VBoxContainer/Label2/CheckButton

func _ready() -> void:
	var fullscreen = DisplayServer.window_get_mode()
	if fullscreen == DisplayServer.WINDOW_MODE_FULLSCREEN:
		check_button.button_pressed = true
	else: 
		check_button.button_pressed = false
	brightness.value = GameEnviroment.global_brightness
	WorldEnviroment.environment.adjustment_brightness = GameEnviroment.global_brightness
	hide()

func _on_brightness_value_changed(value: float) -> void:
	print(value)
	WorldEnviroment.environment.adjustment_brightness = value
	GameEnviroment.global_brightness = value
	GameEnviroment.emit_signal("brightness_changed", value)

func _on_return_button_pressed() -> void:
	hide()

func on_focus():
	audio_stream_player.stream = focus_sfx
	audio_stream_player.play()

func on_click():
	audio_stream_player.stream = click_sfx
	audio_stream_player.play()


func _on_check_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
