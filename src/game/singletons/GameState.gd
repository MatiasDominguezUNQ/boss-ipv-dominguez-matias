extends Node

signal current_player_changed(player)
signal give_experience(amount)
signal change_input_mode(gamepad)
signal level_won()

@onready var items_stash: Inventory = Inventory.new()
var level: int = 0
var player_scene: PackedScene
var current_player: Player
var current_class: String
var player_level: int = 1
var player_xp: int = 0
var player_next_xp: int = 2
var player_can_attack: bool = true
var using_gamepad:bool = false
var player_hp: int = 0
var player_max_hp: int = 0

func set_player_scene(player):
	player_scene = player

func set_current_player(player: Player, player_class: String) -> void:
	current_player = player
	current_class = player_class
	call_deferred("emit_signal", "current_player_changed", player)

func notify_level_won() -> void:
	emit_signal("level_won")

func save_stats():
	items_stash = current_player.inventory
	player_level = current_player.current_level
	player_xp = current_player.current_experience
	player_next_xp = current_player.next_level_experience
	player_hp = current_player.health
	player_max_hp = current_player.max_health

func clear():
	items_stash = Inventory.new()
	player_level = 1
	player_xp = 0
	player_next_xp = 2
	player_hp = 0
	player_max_hp = 0

func switch_input():
	emit_signal("change_input_mode", using_gamepad)
