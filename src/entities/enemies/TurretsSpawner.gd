@tool

extends Node2D
@onready var enemies: Node2D = $".."

@export var scenes: Array[PackedScene]
@export var amount: int
@export var extents: Vector2: set = _set_extents


func _ready() -> void:
	if Engine.is_editor_hint():
		queue_redraw()
	else:
		call_deferred("_initialize")


func _initialize() -> void:
	for i in range(amount):
		var instance: GroundEnemy = scenes.pick_random().instantiate()
		var pos: Vector2 = Vector2(randf_range(global_position.x, global_position.x + extents.x), randf_range(global_position.y, global_position.y + extents.y))
		enemies.add_child(instance)
		instance.global_position = pos


func _set_extents(value: Vector2) -> void:
	extents = value
	
	if Engine.is_editor_hint():
		queue_redraw()


func _draw() -> void:
	if Engine.is_editor_hint():
		draw_rect(Rect2(Vector2.ZERO, extents), Color.BLUE, false)
