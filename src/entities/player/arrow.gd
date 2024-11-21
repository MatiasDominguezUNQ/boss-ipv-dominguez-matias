extends CharacterBody2D

@onready var lifetime_timer: Timer = $LifetimeTimer
@onready var projectile_animations: AnimationPlayer = $ProjectileAnimations
@onready var arrow_sfx: AudioStreamPlayer2D = $ArrowSfx
@onready var hit_box: Area2D = $HitBox
@onready var gpu_particles_2d: GPUParticles2D = $GPUParticles2D

@export var VELOCITY: float = 800.0
@export var gravity: float = 6
@export var vfx_hit: PackedScene
@export var hit_sfx: AudioStream
@export var bounce_sfx: AudioStream
var spawner
var direction: Vector2
var damage: int
var isCrit: bool

func initialize(container: Node, spawn_position: Vector2, direction: Vector2, spawner, damage: int = 1, isCrit = false) -> void:
	container.add_child(self)
	self.spawner = spawner
	self.direction = direction
	self.isCrit = isCrit
	gpu_particles_2d.emitting = isCrit
	if isCrit:
		arrow_sfx.pitch_scale = 0.74
		arrow_sfx.bus = "CritBowSFX"
	else:
		arrow_sfx.pitch_scale = 1
		arrow_sfx.bus = "BowSFX"
	global_position = spawn_position
	rotation = direction.angle()
	velocity = direction*VELOCITY
	lifetime_timer.connect("timeout", Callable(self, "_on_lifetime_timer_timeout"))
	lifetime_timer.start()
	projectile_animations.play("fire_start")
	projectile_animations.queue("fire_loop")
	self.damage = damage

func _physics_process(delta):
	velocity.y += gravity
	rotation = velocity.angle()
	var collision = move_and_collide(velocity * delta) 
	if collision:
		handle_collision(collision)

func handle_collision(collision: KinematicCollision2D):
	var collider = collision.get_collider()
	if collider is Shield:
		print("arrow handle collision")
		arrow_sfx.stream = bounce_sfx
		arrow_sfx.play()
		velocity = velocity.bounce(collision.get_normal())
	else:
		arrow_sfx.stream = hit_sfx
		arrow_sfx.play()
		if collider.has_method("notify_hit"):
			collider.notify_hit(damage, isCrit)
			if isCrit and collider.has_method("knockback"):
				var knockback_direction = Vector2(cos(rotation), sin(rotation)).normalized()
				collider.knockback(800, knockback_direction) 
			_remove()
		else:
			gpu_particles_2d.emitting = false
			spawn_effect(vfx_hit)
			set_physics_process(false)
			await get_tree().create_timer(2).timeout
			_remove()

func _on_lifetime_timer_timeout() -> void:
	_remove()

func _remove() -> void:
	set_physics_process(false)
	collision_mask = 0
	print(damage)
	get_parent().remove_child(self)
	queue_free()

func _on_hitbox_area_entered(area: Area2D) -> void:
	print("arrow area bounce")
	arrow_sfx.stream = bounce_sfx
	arrow_sfx.play()
	collision_mask = (1 << 0) | (1 << 1) | (1 << 2) | (1 << 5) | (1 << 6)
	var normal = area.global_position.direction_to(global_position).normalized()
	velocity = -velocity.bounce(normal)
	print("Arrow hit shield and bounced")

func spawn_effect(EFFECT: PackedScene, effect_position: Vector2 = global_position):
	if EFFECT:
		var effect = EFFECT.instantiate()
		get_tree().current_scene.add_child(effect)
		effect.global_position = effect_position
		effect.rotation = rotation
		return effect
