extends Control

## Menú de pausa genérico, abierto utilizando la acción "pause_menu"
## (por default la tecla Esc).

signal return_selected()
signal restart_selected()
@onready var options_menu: Control = $OptionsMenu
@export var focus_sfx: AudioStream
@export var click_sfx: AudioStream
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

func _ready() -> void:
	hide()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause_menu"):
		if visible:
			options_menu.hide()
		visible = !visible
		get_tree().paused = visible


func _on_ResumeButton_pressed() -> void:
	hide()
	get_tree().paused = false


func _on_ReturnButton_pressed() -> void:
	emit_signal("return_selected")


func _on_restart_button_pressed() -> void:
	emit_signal("restart_selected")
