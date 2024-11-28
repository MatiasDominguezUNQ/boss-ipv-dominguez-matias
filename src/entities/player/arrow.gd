extends CharacterBody2D

@onready var lifetime_timer: Timer = $LifetimeTimer
@onready var projectile_animations: AnimationPlayer = $ProjectileAnimations
@onready var arrow_sfx: AudioStreamPlayer2D = $ArrowSfx
@onready var hit_box: Area2D = $HitBox
@onready var crit_particles: GPUParticles2D = $CritParticles
@onready var timer: Timer = $Timer
@onready var special_particles: GPUParticles2D = $SpecialParticles
@onready var attack_particles: GPUParticles2D = $AttackParticles

@export var VELOCITY: float = 800.0
@export var gravity: float = 6
@export var vfx_hit: PackedScene
@export var hit_sfx: AudioStream
@export var bounce_sfx: AudioStream
var spawner
var direction: Vector2
var damage: int
var isCrit: bool
var bounces: int = 0
var bounces_limit: int = 0
var pierces: int = 0
var pierces_limit: int = 0
var hit_targets: Array = []

func initialize(container: Node, spawn_position: Vector2, direction: Vector2, spawner, damage: int = 1, isCrit = false, special = false) -> void:
	container.add_child(self)
	self.spawner = spawner
	self.direction = direction
	self.isCrit = isCrit
	crit_particles.emitting = isCrit and not special
	special_particles.emitting = special
	if isCrit:
		arrow_sfx.pitch_scale = 0.74
		arrow_sfx.bus = "CritBowSFX"
	else:
		arrow_sfx.pitch_scale = 1
		arrow_sfx.bus = "BowSFX"
	global_position = spawn_position
	rotation = direction.angle()
	lifetime_timer.connect("timeout", Callable(self, "_on_lifetime_timer_timeout"))
	lifetime_timer.start()
	projectile_animations.play("fire_start")
	projectile_animations.queue("fire_loop")
	self.damage = damage
	if special:
		collision_mask = (1 << 0) | (1 << 2) | (1 << 5)
		hit_box.collision_mask = 0
		bounces_limit = 3
		pierces_limit = 3
		gravity = 0
		VELOCITY = VELOCITY * 1
	velocity = direction*VELOCITY

func _physics_process(delta):
	velocity.y += gravity
	rotation = velocity.angle()
	var collision = move_and_collide(velocity * delta) 
	if collision:
		handle_collision(collision)

func handle_collision(collision: KinematicCollision2D):
	var collider = collision.get_collider()
	arrow_sfx.stream = hit_sfx
	arrow_sfx.play()
	if collider.has_method("notify_hit"):
		collision_mask = (1 << 0)
		timer.start()
		if collider in hit_targets:
			return
		hit_targets.append(collider)
		collider.notify_hit(damage, isCrit)
		if isCrit and collider.has_method("knockback"):
			var knockback_direction = Vector2(cos(rotation), sin(rotation)).normalized()
			collider.knockback(800, knockback_direction) 
		if pierces >= pierces_limit:
			_remove()
		else:
			attack_particles.emitting = true
		pierces += 1
	else:
		if bounces >= bounces_limit:
			crit_particles.emitting = false
			spawn_effect(vfx_hit)
			set_physics_process(false)
			hit_box.collision_mask = 0
			await get_tree().create_timer(2).timeout
			_remove()
		else:
			hit_targets = []
			var normal = collision.get_normal()
			var incoming_velocity = velocity.normalized()
			var reflected_velocity = incoming_velocity.bounce(normal)
			velocity = reflected_velocity * velocity.length()
			rotation = velocity.angle()
		bounces += 1

func _on_lifetime_timer_timeout() -> void:
	_remove()

func _remove() -> void:
	set_physics_process(false)
	collision_mask = 0
	get_parent().remove_child(self)
	queue_free()

func _on_hitbox_area_entered(area: Area2D) -> void:
	if area is Shield and bounces_limit == 0:
		arrow_sfx.stream = bounce_sfx
		arrow_sfx.play()
		collision_mask = (1 << 0) | (1 << 1) | (1 << 2) | (1 << 5) | (1 << 6)
		var normal = Vector2(cos(rotation), sin(rotation)).normalized()
		velocity = velocity.bounce(normal) * 1.5

func spawn_effect(EFFECT: PackedScene, effect_position: Vector2 = global_position):
	if EFFECT:
		var effect = EFFECT.instantiate()
		get_tree().current_scene.add_child(effect)
		effect.global_position = effect_position
		effect.rotation = rotation
		return effect

func _on_area_exited(area: Area2D) -> void:
	if area in hit_targets:
		hit_targets.erase(area)


func _on_timer_timeout() -> void:
	collision_mask = (1 << 0) | (1 << 2) | (1 << 5)
