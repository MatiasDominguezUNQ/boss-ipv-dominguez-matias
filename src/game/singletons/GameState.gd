extends Node

signal current_player_changed(player)
signal give_experience(amount)
signal level_won()

var weapons_stash: Array = []
var items_stash: Array = []
var weapons_available: Array = []
var player_scene: PackedScene
var current_player: Player
var current_class: String
var player_can_attack: bool = true

func notify_weapon_picked(weapon_scene: PackedScene) -> void:
	if !weapons_available.has(weapon_scene):
		weapons_available.push_back(weapon_scene)

func set_player_scene(player):
	player_scene = player

func set_current_player(player: Player, player_class: String) -> void:
	current_player = player
	current_class = player_class
	call_deferred("emit_signal", "current_player_changed", player)

func notify_level_won() -> void:
	weapons_stash.append_array(weapons_available)
	weapons_available = []
	emit_signal("level_won")
