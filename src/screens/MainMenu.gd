extends Node

## La escena principal pasa a ser el MainMenu, y lo que era la escena
## Main se refactorizó a Level01 y se lo integró como Nivel dentro
## de LevelManager (Leer más ahí).

## El fondo de la interfaz puede personalizarse a gusto. Puede ser
## una imagen estática, con movimiento, o como se quiera.
## Los nodos de Control que manejan el flujo de la aplicación están
## en CanvasLayer/Container. Si no estuvieran dentro del CanvasLayer,
## se verían afectados por el movimiento de la cámara.

## PISTA: El input del mouse podría no se capturado por default por los
## elementos interactivos. Eso puede ser porque algun otro nodo de Control
## que se dibuja encima está consumiendo ese Input primero.
## Se puede revisar la propiedad Control.mouse_filter en el inspector y en
## la documentación para experimentar

@export var level_manager_scene: PackedScene
@onready var character_select: Control = $CanvasLayer/CharacterSelect
@export var focus_sfx: AudioStream
@export var click_sfx: AudioStream
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

@export var mouse_cursor: Texture


func _ready() -> void:
	Input.set_custom_mouse_cursor(mouse_cursor)


func _on_StartButton_pressed() -> void:
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
