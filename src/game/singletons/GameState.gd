extends Node

signal current_player_changed(player)
signal give_experience(amount)
signal level_won()

@onready var items_stash: Inventory = preload("res://src/entities/player/player_inventory.tres")
var player_scene: PackedScene
var current_player: Player
var current_class: String
var player_level: int = 1
var player_xp: int = 0
var player_next_xp: int = 2
var player_can_attack: bool = true

func set_player_scene(player):
	player_scene = player

func set_current_player(player: Player, player_class: String) -> void:
	current_player = player
	current_class = player_class
	call_deferred("emit_signal", "current_player_changed", player)

func notify_level_won() -> void:
	items_stash = current_player.inventory
	player_level = current_player.current_level
	player_xp = current_player.current_experience
	player_next_xp = current_player.next_level_experience
	emit_signal("level_won")
