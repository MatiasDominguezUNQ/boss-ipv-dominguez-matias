extends Control

## Menú de victoria genérico. Solo se presenta si se levanta la signal
## de "level_won" en GameState.

signal next_selected()
signal return_selected()
signal victory_music()
@export var focus_sfx: AudioStream
@export var click_sfx: AudioStream
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer


func _ready() -> void:
	hide()
	GameState.connect("level_won", Callable(self, "_on_level_won"))


func _on_level_won() -> void:
	show()
	get_tree().paused = true
	emit_signal("victory_music")

func _on_NextButton_pressed() -> void:
	emit_signal("next_selected")


func _on_ReturnButton_pressed() -> void:
	emit_signal("return_selected")


func on_focus():
	audio_stream_player.stream = focus_sfx
	audio_stream_player.play()

func on_click():
	audio_stream_player.stream = click_sfx
	audio_stream_player.play()
