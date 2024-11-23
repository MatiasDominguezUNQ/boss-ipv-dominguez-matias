extends Node

signal brightness_changed(value)

@onready var floating_text_scene = preload("res://src/game/ui/damage_text.tscn")
@onready var viewport_size = get_viewport().size
var color: Color
var global_brightness: float = 1

func show_damage(position: Vector2, damage: int, isCrit: bool = false, default: bool = false) -> void:
	if floating_text_scene:
		if isCrit:
			color = Color(0.941, 0.655, 0)
		else:
			color = Color(1, 0.125, 0.125)
		if default:
			color = Color(1,1,1)
		var instance = floating_text_scene.instantiate()
		add_child(instance)
		instance.global_position = position + Vector2(randf_range(-10, 10), randf_range(-10, 10))
		instance.display_text(str(damage), color)
