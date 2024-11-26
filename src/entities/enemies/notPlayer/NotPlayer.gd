extends CharacterBody2D
class_name PlayerBoss

signal hp_changed(health, max_health)
signal hit(amount)
signal dead()

const FLOOR_NORMAL: Vector2 = Vector2.UP  # Igual a Vector2(0, -1)
const SNAP_DIRECTION: Vector2 = Vector2.DOWN
const SNAP_LENGTH: float = 32.0
const SLOPE_THRESHOLD: float = deg_to_rad(46)

@onready var weapon: Node = $"%Weapon"
@onready var weapon_container: Node2D = $WeaponContainer
@onready var body_animations: AnimationPlayer = $BodyAnimations
@onready var body_pivot: Node2D = $BodyPivot
@onready var weapon_pivot: Node2D = $BodyPivot/WeaponPivot
@onready var raycast: RayCast2D = $Eyes
@onready var fx_anim: AnimationPlayer = $WeaponContainer/Weapon/FXAnim
@onready var attack_cooldown: Timer = $AttackCooldown
@onready var sword_area: Area2D = $WeaponContainer/Weapon/SwordArea
@onready var right_floor_cast: RayCast2D = $FloorRaycasts/RightFloorCast
@onready var left_floor_cast: RayCast2D = $FloorRaycasts/LeftFloorCast
@onready var body: Sprite2D = $BodyPivot/Body
@onready var body_sfx: AudioStreamPlayer2D = $BodySFX
@onready var damage_spawn: Marker2D = %DamageSpawn

@export var ACCELERATION: float = 350.0
@export var AIR_ACCELERATION: float = 100.0
@export var V_SPEED_LIMIT: float = 500.0
@export var jump_speed: int = 400
@export var FRICTION_WEIGHT: float = 0.1
@export var gravity: int = 15
@export var max_health: int = 20
@export var health: int 
@export var push_force: float = 80.0
@export var experience_reward: int = 10
@export var damage: int = 4
var is_flipped: bool = false
var can_attack:bool = true
var ground_attacks = ["attack_1","attack_2"]
var ground_attacks_flipped = ["attack_1_flipped", "attack_2_flipped"]
var air_attacks = ["attack_3"]
var air_attacks_flipped  = ["attack_3_flipped"]
var move_direction: int = 0
var attack: String = ""
var snap_vector: Vector2 = SNAP_DIRECTION * SNAP_LENGTH
var is_dead: bool = false
var stop_on_slope: bool = true
var target = null
var spike_walk_skill = false
var is_attacking = false
@export var jump_sfx: AudioStream
@export var land_sfx: AudioStream
@export var hit_sfx: AudioStream

func _ready() -> void:
	health = max_health
	emit_signal("hp_changed",health, max_health)
	body.material.set_shader_parameter("enable_damage", false)

func _handle_move() -> void:
	if target != null && !fx_anim.is_playing() and !is_attacking:
		move_direction = 1 - 2 * float(to_local(target.global_position).x < 0)
		velocity.x = lerp(velocity.x, move_direction * ACCELERATION, FRICTION_WEIGHT)
		if move_direction == 1 and is_flipped:
			weapon_container.scale.x = -1
			is_flipped = false
		if move_direction == -1 and !is_flipped:
			weapon_container.scale.x = -1
			is_flipped = true
	elif !is_on_floor():
		velocity.x = lerp(velocity.x, move_direction * AIR_ACCELERATION, FRICTION_WEIGHT)
	else:
		_handle_deacceleration()

func _handle_air_move() -> void:
	move_direction = 1 - 2 * float(to_local(target.global_position).x < 0)
	body_pivot.scale.x = move_direction
	move_and_slide()

func _handle_deacceleration() -> void:
	velocity.x = lerp(velocity.x, 0.0, FRICTION_WEIGHT) if abs(velocity.x) > 1 else 0

func _apply_movement() -> void:
	velocity.y += gravity
	velocity.y = clamp(velocity.y, -jump_speed * 3, V_SPEED_LIMIT)
	set_floor_stop_on_slope_enabled(stop_on_slope)
	set_max_slides(4)
	set_floor_max_angle(SLOPE_THRESHOLD)
	move_and_slide()
	for i in get_slide_collision_count():
		var c = get_slide_collision(i)
		if c.get_collider() is RigidBody2D:
			c.get_collider().apply_impulse(-c.get_normal() * push_force)
	if is_on_floor() && snap_vector == Vector2.ZERO:
		snap_vector = SNAP_DIRECTION * SNAP_LENGTH

func _physics_process(delta: float) -> void:
	if is_flipped:
		body_pivot.scale.x = -1
	else:
		body_pivot.scale.x = 1
	if target != null && !fx_anim.is_playing() and !is_attacking:
		raycast.target_position = to_local(target.global_position)
		raycast.force_raycast_update()
		body_pivot.scale.x = 1 - 2 * float(raycast.target_position.x < 0)

func _can_move_to_target():
	var has_floor: bool
	if target == null:
		return false
	if move_direction == 1:
		right_floor_cast.force_raycast_update()
		has_floor = right_floor_cast.is_colliding()
	else:
		left_floor_cast.force_raycast_update()
		has_floor = left_floor_cast.is_colliding()
	raycast.target_position = to_local(target.global_position)
	raycast.force_raycast_update()
	return has_floor && (raycast.is_colliding() && raycast.get_collider() == target) && ((abs(raycast.target_position.x) > 100 && (abs(raycast.target_position.y) < 60)) || (abs(raycast.target_position.x) > 0 && (abs(raycast.target_position.y) > 60)))

func _can_attack_target():
	if target == null:
		return false
	return (_can_attack_target_ground() || _can_attack_target_air()) && can_attack

func _can_attack_target_ground():
	if target == null:
		return false
	return abs(raycast.target_position.x) < 115 && abs(raycast.target_position.y) < 60 

func _can_attack_target_air():
	if target == null:
		return false
	return abs(raycast.target_position.x) < 15

func _handle_ground_attack():
	attack = ground_attacks.pick_random()
	if fx_anim.has_animation(attack):
		fx_anim.play(attack)

func _handle_air_attack():
	attack = air_attacks.pick_random()
	if fx_anim.has_animation(attack):
		fx_anim.play(attack)

func _handle_jump():
	velocity.y = -jump_speed
	body_sfx.stream = jump_sfx
	body_sfx.play()

func notify_hit(amount: int = 1, isCrit = false) -> void:
	emit_signal("hit", amount, isCrit)

func _handle_hit(amount: int, isCrit) -> void:
	if !is_dead:
		receive_damage(amount, isCrit)
		emit_signal("hp_changed",health, max_health)
		if !body_sfx.playing:
			body_sfx.stream = hit_sfx
			body_sfx.play()
		body.material.set_shader_parameter("enable_damage", true)
		await get_tree().create_timer(0.1).timeout
		body.material.set_shader_parameter("enable_damage", false)

func receive_damage(amount, isCrit):
	health -= amount
	GameEnviroment.show_damage(damage_spawn.global_position, amount, isCrit)
	if (health <= 0):
		health = 0
		handle_death()

func handle_death():
		is_dead = true
		GameState.give_experience.emit(experience_reward)
		emit_signal("dead")

func _play_animation(animation: String) -> void:
	if body_animations.has_animation(animation):
		body_animations.play(animation)

func _remove_custom() -> void:
	set_physics_process(false)
	collision_layer = 0

func _on_sword_area_body_entered(body: Node2D) -> void:
	GameEnviroment.enemy_attack(body, damage, sword_area, self)
	if body.has_method("knockback"):
		body.knockback()

func _on_attack_cooldown_timeout() -> void:
	can_attack = true
