extends Node

@export var level_manager_scene: PackedScene
@export var tutorial_level: PackedScene
@onready var character_select: Control = $CanvasLayer/CharacterSelect
@export var focus_sfx: AudioStream
@export var click_sfx: AudioStream
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

@export var mouse_cursor: Texture


func _ready() -> void:
	Input.set_custom_mouse_cursor(mouse_cursor)


func _on_StartButton_pressed() -> void:
	GameState.level = 1
	character_select.show()
	#get_tree().change_scene_to_packed(level_manager_scene)


func _on_ExitButton_pressed() -> void:
	get_tree().quit()


func _on_character_select_start_game(character_scene: Variant) -> void:
	print("third button signal")
	GameState.set_player_scene(character_scene)
	call_deferred("start_game")

func start_game():
	get_tree().change_scene_to_packed(level_manager_scene)
	

func on_focus():
	audio_stream_player.stream = focus_sfx
	audio_stream_player.play()

func on_click():
	audio_stream_player.stream = click_sfx
	audio_stream_player.play()


func _on_start_tutorial_button_pressed() -> void:
	GameState.level = 0
	character_select.show()
	
