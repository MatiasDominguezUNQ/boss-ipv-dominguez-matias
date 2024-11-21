extends Node2D

var charge_color: Color = Color(0.497, 0.642, 0.698)
@onready var fx_anim: AnimationPlayer = $"../FXAnim"
@onready var ranger: Player = $"../../.."
@export var circle_radius: float = 65.0 
@export var max_radius: float = 0.0
var current_radius: float = circle_radius
var animation_duration: float = 0.6
var elapsed_time: float = 0.0

func _ready() -> void:
	set_process(true)

func _process(delta: float) -> void:
	if fx_anim.is_playing() and fx_anim.current_animation in ["fire_start"]:
		update_circle_radius(delta)
		show()
	else:
		elapsed_time = 0.0
		current_radius = circle_radius
		hide()
	queue_redraw()

func update_circle_radius(delta: float) -> void:
	elapsed_time += delta
	var duration_adjusted = animation_duration / ranger.attack_speed
	current_radius = circle_radius + (max_radius - circle_radius) * min(elapsed_time / duration_adjusted, 1.0)

func _draw() -> void:
	var local_position = global_transform.origin
	draw_arc(
		to_local(local_position),
		current_radius,
		0,
		2 * PI,
		32,
		charge_color,
		0.5 
	)
