extends CanvasLayer

signal next_level_requested()
signal return_requested()
signal restart_requested()
signal player_death()
signal player_victory()

func _on_level_won() -> void:
	emit_signal("next_level_requested")

func _on_return_requested() -> void:
	emit_signal("return_requested")

func _on_restart_requested() -> void:
	emit_signal("restart_requested")

func _on_defeat_menu_death_music() -> void:
	emit_signal("player_death")

func _on_victory_menu_victory_music() -> void:
	emit_signal("player_victory")
