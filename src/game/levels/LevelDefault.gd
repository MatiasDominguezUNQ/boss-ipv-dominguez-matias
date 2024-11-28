extends Node
class_name GameLevel

@onready var chests_node: Node2D = $Environment/Objects/Chests
@onready var attack_tutorial: Label = %AttackTutorial
@onready var utility_tutorial: Label = %UtilityTutorial
@onready var background_music: AudioStreamPlayer = $BackgroundMusic
@onready var movement: Label = %Movement
@onready var jump: Label = %Jump
@onready var interact: Label = %Interact
@onready var rope: Label = %Rope
@onready var boss_area: Area2D = $Environment/BossArea
@onready var boss_camera: Camera2D = %BossCamera
@onready var spawn_point: Vector2 = %SpawnPoint.global_position
@onready var rope_jump: Label = %"Rope Jump"
@onready var inventory: Label = %Inventory

@export var victory_music: AudioStream
@export var death_music: AudioStream
@export var default_music: AudioStream
@export var boss_music: AudioStream

var camera: Camera2D
# Regresa al menu principal
signal return_requested()
# Reinicia el nivel
signal restart_requested()
# Inicia el siguiente nivel
signal next_level_requested()


func _ready() -> void: 
	WorldEnviroment.environment.glow_enabled = true
	randomize()
	if boss_area:
		boss_area.collision_mask = (1 << 9)
	call_deferred("set_tutorials")


func get_chests():
	return chests_node.get_children()
# Funciones que hacen de interfaz para las señales
func _on_level_won() -> void:
	emit_signal("next_level_requested")

func _on_return_requested() -> void:
	emit_signal("return_requested")

func _on_restart_requested() -> void:
	emit_signal("restart_requested")

func set_tutorials():
	set_attack_tutorial()
	set_movement_tutorial()
	set_jump_tutorial()
	set_rope_tutorial()
	set_interact_tutorial()

func set_attack_tutorial():
	var attack_key = get_key("primary_attack")
	var utility_key = get_key("utility_skill")
	var tutorial: String = ""
	var tutorial2: String = ""
	var player = GameState.current_class
	match player:
		"Ranger":
			tutorial = tr("TUTO_03_RANGER")
			tutorial2 = tr("TUTO_04_RANGER")
		"Knight":
			tutorial = tr("TUTO_03_KNIGHT")
			tutorial2 = tr("TUTO_04_KNIGHT")
	tutorial = tutorial.replace("#", attack_key)
	tutorial2 = tutorial2.replace("#", utility_key)
	attack_tutorial.text = tutorial
	utility_tutorial.text = tutorial2

func set_movement_tutorial():
	var move_up_key = get_key("move_up")
	var move_left_key = get_key("move_left")
	var move_down_key = get_key("move_down")
	var move_right_key = get_key("move_right")
	var text = tr("TUTO_01")
	var tuto = move_up_key+"/"+move_left_key+"/"+move_down_key+"/"+move_right_key
	text = text.replace("#", tuto)
	movement.text = text

func set_jump_tutorial():
	var jump_key = get_key("jump")
	var text = tr("TUTO_02")
	text = text.replace("#", jump_key)
	jump.text = text

func set_rope_tutorial():
	var move_up_key = get_key("move_up")
	var jump_key = get_key("jump")
	var text = tr("TUTO_07")
	var text2 = tr("TUTO_08")
	text = text.replace("#", move_up_key)
	text2 = text2.replace("#", jump_key)
	rope.text = text
	rope_jump.text = text2

func set_interact_tutorial():
	var inv_key = get_key("toggle_inventory")
	var inv_text = tr("TUTO_10").replace("#", inv_key)
	var key = get_key("interact")
	var text = tr("TUTO_09")
	text = text.replace("#", key)
	interact.text = text
	inventory.text = inv_text

func get_key(action_id) -> String:
	var events = InputMap.action_get_events(action_id)[0]
	if events is InputEventKey:
		return OS.get_keycode_string(events.keycode)
	else:
		return events.as_text()

func _on_player_victory() -> void:
	background_music.stream = victory_music
	background_music.play()

func _on_player_death() -> void:
	background_music.stream = death_music
	background_music.play()

func _on_boss_area_entered(area) -> void:
	print("boss entered")
	background_music.stream = boss_music
	background_music.volume_db = -16
	background_music.play()
	focus_camera_on_boss()

func _on_boss_area_exited(area) -> void:
	print("boss exited")
	background_music.stream = default_music
	background_music.volume_db = 0
	background_music.play()
	reset_camera()

func _on_boss_dead() -> void:
	background_music.stream = default_music
	background_music.volume_db = 0
	background_music.play()
	boss_area.collision_mask = 0
	await get_tree().create_timer(3).timeout
	GameState.emit_signal("level_won")

func focus_camera_on_boss() -> void:
	get_tree().root.content_scale_aspect = 4
	CameraTransition.transition_camera2D(GameState.current_player.camera_2d, boss_camera)

func reset_camera() -> void:
	get_tree().root.content_scale_aspect = 1
	CameraTransition.transition_camera2D(boss_camera, GameState.current_player.camera_2d)
