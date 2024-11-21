extends CharacterBody2D
class_name GroundEnemy

signal hp_changed(health, max_health)
signal hit(amount)
signal dead()

@onready var body_animations: AnimationPlayer = $BodyAnimations
@onready var body_pivot: Node2D = $BodyPivot
@onready var right_floor_cast: RayCast2D = $FloorRaycasts/RightFloorCast
@onready var left_floor_cast: RayCast2D = $FloorRaycasts/LeftFloorCast
@onready var raycast: RayCast2D = $Eyes
@onready var attack_area: Area2D = $BodyPivot/AttackArea
@onready var right_floor_cast_2: RayCast2D = $FloorRaycasts/RightFloorCast2
@onready var left_floor_cast_2: RayCast2D = $FloorRaycasts/LeftFloorCast2
@onready var damage_spawn: Marker2D = %DamageSpawn
@onready var attack_cooldown: Timer = $AttackCooldown

@export var ACCELERATION: float = 60.0
@export var AIR_ACCELERATION: float = 100.0
@export var V_SPEED_LIMIT: float = 500.0
@export var jump_speed: int = 200
@export var FRICTION_WEIGHT: float = 0.3
@export var gravity: int = 15
@export var max_health: int = 9
@export var health: int = max_health
@export var push_force: float = 80.0
@export var experience_reward: int = 2
@export var knockback_resistance: float = 1.0
var can_attack:bool = true
var move_direction: int = 0
var attack: String = ""
var is_dead: bool = false
var stop_on_slope: bool = true
var target = null
var spike_walk_skill = false
@export var hit_sfx: AudioStream
@onready var body_sfx: AudioStreamPlayer2D = $BodySfx

func _ready() -> void:
	health = max_health

func _handle_move() -> void:
	if target != null && !acting():
		move_direction = 1 - 2 * float(to_local(target.global_position).x < 0)
		velocity.x = lerp(velocity.x, move_direction * ACCELERATION, FRICTION_WEIGHT)
		body_pivot.scale.x = move_direction
	elif !is_on_floor():
		velocity.x = lerp(velocity.x, move_direction * AIR_ACCELERATION, FRICTION_WEIGHT)
	else:
		_handle_deacceleration()

func _handle_deacceleration() -> void:
	velocity.x = lerp(velocity.x, 0.0, FRICTION_WEIGHT) if abs(velocity.x) > 1 else 0

func _apply_movement() -> void:
	velocity.y += gravity
	velocity.y = clamp(velocity.y, -jump_speed * 3, V_SPEED_LIMIT)
	move_and_slide()
	for i in get_slide_collision_count():
		var c = get_slide_collision(i)
		var body = c.get_collider()
		if body is GroundEnemy:
			var relative_velocity = velocity.x - body.velocity.x
			if abs(relative_velocity) > 0:
				var push_force_total = relative_velocity * 0.5
				body.velocity.x += push_force_total
				velocity.x -= push_force_total
			if body.velocity.x == 0:
				body.velocity.x = push_force * 0.5
			break

func _physics_process(delta: float) -> void:
	if target != null && !acting():
		raycast.target_position = to_local(target.global_position)
		raycast.force_raycast_update()
		body_pivot.scale.x = 1 - 2 * float(raycast.target_position.x < 0)

func knockback(force: float, direction: Vector2) -> void:
	direction = direction.normalized()
	var knockback_force = direction * force / knockback_resistance
	if is_on_floor() and knockback_force.y > -100:
		knockback_force.y = -80
	velocity += knockback_force

func acting():
	return body_animations.current_animation == "hit" || body_animations.current_animation == "attack"

func _can_move_to_target():
	var has_floor: bool
	var has_spikes: bool
	if target == null:
		return false
	if move_direction == 1:
		right_floor_cast.force_raycast_update()
		right_floor_cast_2.force_raycast_update()
		has_floor = right_floor_cast.is_colliding()
		has_spikes = right_floor_cast_2.is_colliding()
	else:
		left_floor_cast.force_raycast_update()
		left_floor_cast_2.force_raycast_update()
		has_floor = left_floor_cast.is_colliding()
		has_spikes = left_floor_cast_2.is_colliding()
	raycast.target_position = to_local(target.global_position)
	raycast.force_raycast_update()
	#(raycast.is_colliding() && raycast.get_collider() == target)
	return not has_spikes && has_floor && ((abs(raycast.target_position.x) > 55 && (abs(raycast.target_position.y) < 60)) || (abs(raycast.target_position.x) > 0 && (abs(raycast.target_position.y) > 60)))

func _can_attack_target():
	if target == null:
		return false
	return _can_attack_target_ground() && can_attack

func _can_attack_target_ground():
	if target == null:
		return false
	return abs(raycast.target_position.x) < 55 && abs(raycast.target_position.y) < 60 

func _handle_jump():
	velocity.y = -jump_speed

func notify_hit(amount: int = 1, isCrit = false) -> void:
	emit_signal("hit", amount, isCrit)

func _handle_hit(amount: int, isCrit) -> void:
	if !is_dead:
		if body_animations.current_animation != "attack":
			body_animations.play("hit")
			body_sfx.stream = hit_sfx
			body_sfx.play()
		receive_damage(amount, isCrit)
		emit_signal("hp_changed",health, max_health)

func receive_damage(amount, isCrit):
	health -= amount
	GameEnviroment.show_damage(damage_spawn.global_position, amount, isCrit)
	if (health <= 0):
		health = 0
		handle_death()

func handle_death():
		is_dead = true
		GameState.give_experience.emit(experience_reward)

func _play_animation(animation: String) -> void:
	if body_animations.has_animation(animation):
		body_animations.play(animation)

func _remove_custom() -> void:
	set_physics_process(false)
	collision_layer = 0

func _on_sword_area_body_entered(body: Node2D) -> void:
	if body is PlayerShield and body.has_method("notify_hit"):
		attack_area.collision_mask = 0
		body.notify_hit(2, self)
	elif body is Player and body.has_method("notify_hit"):
		attack_area.collision_mask = 0
		body.notify_hit(2)

func _on_attack_cooldown_timeout() -> void:
	can_attack = true
