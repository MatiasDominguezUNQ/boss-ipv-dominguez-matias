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

func enemy_attack(body, damage, weapon_area, enemy):
	var hit_bodies = []
	for overlapping_body in weapon_area.get_overlapping_bodies():
		hit_bodies.append(overlapping_body)
	for overlapping_body in weapon_area.get_overlapping_areas():
		hit_bodies.append(overlapping_body)
	var shield_hit = false
	for hit_body in hit_bodies:
		if hit_body is PlayerShield and hit_body.has_method("notify_hit"):
			shield_hit = true
			weapon_area.collision_mask = 0
			hit_body.notify_hit(damage, enemy)
			return
	if not shield_hit:
		for hit_body in hit_bodies:
			if hit_body is Player and hit_body.has_method("notify_hit"):
				weapon_area.collision_mask = 0
				hit_body.notify_hit(damage)
				break 
	weapon_area.collision_mask = 0
