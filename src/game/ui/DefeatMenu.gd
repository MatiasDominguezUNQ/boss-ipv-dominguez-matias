extends Control

## Menú de derrota genérico. Solo se presenta si detecta que
## el Player llegó a 0 de HP.

signal retry_selected()
signal return_selected()
signal death_music()
@export var focus_sfx: AudioStream
@export var click_sfx: AudioStream
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer


func _ready() -> void:
	hide()
	GameState.connect("current_player_changed", Callable(self, "_on_current_player_changed"))


func _on_current_player_changed(player: Player) -> void:
	player.connect("hp_changed", Callable(self, "_on_hp_changed"))
	_on_hp_changed(player.health, player.max_health)


func _on_hp_changed(hp: int, hp_max: int) -> void:
	if hp == 0:
		show()
		emit_signal("death_music")


func _on_RetryButton_pressed() -> void:
	emit_signal("retry_selected")


func _on_ReturnButton_pressed() -> void:
	emit_signal("return_selected")


func on_focus():
	audio_stream_player.stream = focus_sfx
	audio_stream_player.play()

func on_click():
	audio_stream_player.stream = click_sfx
	audio_stream_player.play()
