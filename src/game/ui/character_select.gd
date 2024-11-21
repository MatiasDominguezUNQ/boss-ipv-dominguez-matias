@tool
extends Node

signal character_ready(character_scene)

@onready var character_button: Button = %CharacterButton
@export var focus_sfx: AudioStream
@export var click_sfx: AudioStream
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

@export var disabled: bool
@export var character_scene: PackedScene
@export var character_image: Texture
@export var character_name: String:
	set(input):
		character_name = input
		if Engine.is_editor_hint() && has_node("%CharacterName"):
			%CharacterName.text = input

func _ready() -> void:
	%CharacterName.text = character_name
	character_button.icon = character_image
	character_button.disabled = disabled


func _on_input_pressed() -> void:
	print("first button signal")
	emit_signal("character_ready", character_scene)


func on_focus():
	audio_stream_player.stream = focus_sfx
	audio_stream_player.play()

func on_click():
	audio_stream_player.stream = click_sfx
	audio_stream_player.play()
