extends Control

signal start_game(character_scene)
@export var focus_sfx: AudioStream
@export var click_sfx: AudioStream
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

func _ready() -> void:
	hide()

func _on_return_button_pressed() -> void:
	hide()


func _on_character_select_character_ready(character_scene: Variant) -> void:
	emit_signal("start_game", character_scene)

func on_focus():
	audio_stream_player.stream = focus_sfx
	audio_stream_player.play()

func on_click():
	audio_stream_player.stream = click_sfx
	audio_stream_player.play()
