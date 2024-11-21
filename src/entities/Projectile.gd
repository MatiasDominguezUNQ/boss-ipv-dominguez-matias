extends Node2D

@onready var lifetime_timer: Timer = $LifetimeTimer
@onready var hitbox: Area2D = $Hitbox
@onready var projectile_animations: AnimationPlayer = $ProjectileAnimations

@export var VELOCITY: float = 800.0
@export var gravity: float = 0.7
@export var vfx_hit: PackedScene
var spawner
var direction: Vector2
var damage: int

func initialize(container: Node, spawn_position: Vector2, direction: Vector2, spawner, damage: int = 1) -> void:
	container.add_child(self)
	self.spawner = spawner
	self.direction = direction
	global_position = spawn_position
	rotation = direction.angle()
	lifetime_timer.connect("timeout", Callable(self, "_on_lifetime_timer_timeout"))
	lifetime_timer.start()
	projectile_animations.play("fire_start")
	projectile_animations.queue("fire_loop")
	self.damage = damage


func _physics_process(delta: float) -> void:
	if spawner is not Player:
		position += direction * VELOCITY * delta
	else:
		direction.y += gravity * delta
		position += direction * VELOCITY * delta
		rotation = direction.angle()

func _on_lifetime_timer_timeout() -> void:
	remove()


func remove() -> void:
	hitbox.collision_mask = 0
	set_physics_process(false)
	projectile_animations.play("hit")


## Esta función se llamaría desde "hit" al terminar la animación
func _remove() -> void:
	print(damage)
	get_parent().remove_child(self)
	queue_free()


func _on_Hitbox_body_entered(body: Node) -> void:
	if body.has_method("notify_hit"):
		body.notify_hit(damage)
	remove()

func _on_hitbox_area_entered(area: Area2D) -> void:
	hitbox.collision_mask = 0
	set_physics_process(false)
	await get_tree().create_timer(2).timeout
	remove()


func _on_arrow_sfx_finished() -> void:
	_remove()
