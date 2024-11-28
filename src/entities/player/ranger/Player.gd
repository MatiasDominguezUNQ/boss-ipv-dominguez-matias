extends CharacterBody2D
class_name Player

signal hit(amount)
signal healed(amount)
signal hp_changed(health, max_health)
signal xp_changed(current, max)
signal statsUpdated(stats)
signal level_up(level)
signal dead()

@onready var player_sfx: AudioStreamPlayer = $PlayerSfx
@onready var weapon: Node = $"%Weapon"
@onready var body_animations: AnimationPlayer = $BodyAnimations
@onready var body_pivot: Node2D = $BodyPivot
@onready var rope_raycast: Array = $RopeRaycast.get_children()
@onready var fx_anim: AnimationPlayer = $WeaponContainer/Weapon/FXAnim
@onready var weapon_sfx: AudioStreamPlayer = $WeaponContainer/Weapon/WeaponSFX
@onready var attack_cooldown: Timer = $AttackCooldown
@onready var camera_2d: Camera2D = $Camera2D
@onready var damage_spawn: Marker2D = %DamageSpawn
@onready var weapon_container: Node2D = $WeaponContainer
@onready var stamina_bar: Control = $StaminaBar
@onready var special_sfx: AudioStreamPlayer = $WeaponContainer/Weapon/SpecialSFX

@export var base_acceleration: float = 200.0
@export var roll_speed: float = 300.0 
@export var V_SPEED_LIMIT: float = 650.0
@export var jump_speed: int = 500
@export var FRICTION_WEIGHT: float = 0.1
@export var gravity: int = 10
@export var base_damage: int = 1
@export var max_health: int = 25
@export var health: int
@export var push_force: float = 80.0
var inventory: Inventory
@export var jump_sfx: AudioStream
@export var land_sfx: AudioStream
@export var hit_sfx: AudioStream

@export var base_attributes: Dictionary = {
	"Str": 2,
	"Dex": 5,
	"Def": 2,
	"Spd": 4,
}

var current_attributes: Dictionary
var current_experience: int = 0
var next_level_experience: int = 2
var current_level: int = 1
var skill_points: int = 0

var projectile_container: Node
var can_slide: bool = true
var move_direction: int = 0
var rope: RigidBody2D = null
var is_grabbing_rope: bool = false
var current_joint: PinJoint2D = null
var current_item: Item = null
var is_dead: bool = false
var is_sliding: bool = false
var jumps: int = 0
var attack_speed: float
var damage: int 
var critical_damage: int
var acceleration: float
var move_speed: float

var crit_skill:bool = true
var slide_skill: bool = true
var spike_walk_skill: bool = false
var jumps_limit: int = 2
var can_special_attack: = true

func _ready() -> void:
	health = max_health
	GameState.give_experience.connect(self.handle_give_experience)
	inventory.item_equipped.connect(self.updateStats)
	base_attributes = {
		"Str": 2,
		"Dex": 3,
		"Def": 1,
		"Spd": 2,
	}
	current_attributes = inventory.get_total_attributes(base_attributes)
	emit_signal("statsUpdated",current_attributes)
	camera_2d.make_current()
	calculate_attack_speed()
	calculate_damage()
	calculate_speed()
	initialize()
	GameState.set_current_player(self, "Ranger")
	emit_signal("level_up", current_level)

func _physics_process(delta: float) -> void:
	if current_item != null and current_item.can_grab and Input.is_action_just_pressed("interact"):
		_handle_item_pickup()
	if !fx_anim.is_playing() or fx_anim.current_animation != "fire_release":
		var mouse_position = get_global_mouse_position()
		weapon.look_at(mouse_position)
		if mouse_position.x > global_position.x:
			body_pivot.scale.x = 1 
		else:
			body_pivot.scale.x = -1  

func initialize(projectile_container: Node = get_parent()) -> void:
	self.projectile_container = projectile_container
	weapon.projectile_container = projectile_container

func _handle_weapon_actions() -> void:
	weapon.process_input()
	if GameState.player_can_attack and Input.is_action_pressed("primary_attack") && !fx_anim.is_playing():
		can_slide = false
		if projectile_container == null:
			projectile_container = get_parent()
		if weapon.projectile_container == null:
			weapon.projectile_container = projectile_container
		weapon.fire()
	elif can_special_attack and GameState.player_can_attack and Input.is_action_pressed("secondary_attack") && !fx_anim.is_playing():
		can_slide = false
		if projectile_container == null:
			projectile_container = get_parent()
		if weapon.projectile_container == null:
			weapon.projectile_container = projectile_container
		weapon.fire_special()

func _handle_move_input() -> void:
	move_direction = int(Input.is_action_pressed("move_right")) - int(Input.is_action_pressed("move_left"))
	if move_direction != 0:
		velocity.x = lerp(velocity.x, move_direction * acceleration, FRICTION_WEIGHT)

func _handle_deacceleration() -> void:
	velocity.x = lerp(velocity.x, 0.0, FRICTION_WEIGHT) if abs(velocity.x) > 1 else 0

func _apply_movement() -> void:
	if !is_grabbing_rope:
		velocity.y += gravity
		velocity.y = clamp(velocity.y, -jump_speed * 3, V_SPEED_LIMIT)
		move_and_slide()
		manage_collision()

func manage_collision():
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
		elif body is RigidBody2D:
			body.apply_impulse(-c.get_normal() * push_force)

func _handle_item_pickup():
	if !inventory.is_full():
		inventory.add_item(current_item)
		current_item.pickup(self)

func updateStats():
	current_attributes = inventory.get_total_attributes(base_attributes)
	print(current_attributes)
	emit_signal("statsUpdated",current_attributes)
	calculate_attack_speed()
	calculate_damage()

func notify_hit(amount: int = 1, isCrit = false) -> void:
	emit_signal("hit", amount, isCrit)
	

func _handle_hit(amount: int, isCrit) -> void:
	receive_damage(amount, isCrit)
	player_sfx.stream = hit_sfx
	player_sfx.play()
	emit_signal("hp_changed",health, max_health)

func knockback(force: float, direction: Vector2) -> void:
	direction = direction.normalized()
	var knockback_force = direction * force 
	if is_on_floor() and knockback_force.y > -100:
		knockback_force.y = -80
	velocity = knockback_force

func heal(amount: int):
	health += amount
	emit_signal("hp_changed",health, max_health)
	GameEnviroment.show_heal(damage_spawn.global_position, amount)

func receive_damage(amount, isCrit):
	if !is_dead:
		var defense = current_attributes.get("Def")
		var reduced_damage = amount * (1 - defense / (defense + 10))
		health -= reduced_damage
		GameEnviroment.show_damage(damage_spawn.global_position, amount, isCrit)
		if (health <= 0):
			is_dead = true
			health = 0

func _remove_custom() -> void:
	set_physics_process(false)
	collision_layer = 0

func _play_animation(animation: String, custom_blend: float = -1, custom_speed: float = 1.0) -> void:
	if body_animations.has_animation(animation):
		body_animations.play(animation, custom_blend, custom_speed)
#
#func _on_rope_area_body_entered(body: Node2D) -> void:
	#if !is_grabbing_rope:
		#rope = body
#
#func _on_rope_area_body_exited(body: Node2D) -> void:
	#if body == rope && !is_grabbing_rope:
		#rope = null

func _handle_rope_swing_input():
	global_rotation = rope.global_rotation
	global_position = rope.global_position
	if Input.is_action_pressed("move_right"):
		rope.apply_impulse(Vector2(35, 0))
	elif Input.is_action_pressed("move_left"):
		rope.apply_impulse(Vector2(-35, 0))
	velocity = rope.linear_velocity
	move_and_slide()

func can_move_up_rope():
	var parent = rope.get_parent().get_parent()
	for joint in parent.get_children():
		if joint is PinJoint2D && joint.node_b.get_name(2) == rope.name  && joint.node_a.get_name(2) != "Segment":
			rope = joint.get_node(joint.node_a)
			return true
	return false

func can_move_down_rope():
	var parent = rope.get_parent().get_parent()
	for joint in parent.get_children():
		if joint is PinJoint2D and joint.node_a.get_name_count() > 2 and joint.node_a.get_name(2) == rope.name:
			rope = joint.get_node(joint.node_b)
			return true
	return false

#func can_grab_rope():
	#rope = null
	#for raycast in rope_raycast:
		#if raycast.is_colliding():
			#rope = raycast.get_collider()
			#break
	#return rope != null

func wall_direction():
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collision_normal = collision.get_normal()
		if collision_normal == Vector2(1, 0):
			return -1
		elif collision_normal == Vector2(-1, 0):
			return 1
	return 0

func item_in_area(item: Item):
	current_item = item

func leave_item(item: Item) -> void:
	if current_item == item:
		current_item = null

func handle_give_experience(value):
	current_experience += value
	print("Experiencia: ", current_experience)
	emit_signal("xp_changed", current_experience, next_level_experience)
	if current_experience >= next_level_experience:
		print("Level up")
		handle_level_up()
		
func handle_level_up():
	current_experience -= next_level_experience
	next_level_experience = next_level_experience*2
	max_health += 5
	emit_signal("hp_changed",health,max_health)
	emit_signal("xp_changed", current_experience, next_level_experience)
	current_level += 1
	emit_signal("level_up", current_level)
	skill_points += 1
	print("skill points:", skill_points)

func _on_fx_anim_animation_finished(anim_name: StringName) -> void:
	if anim_name == "fire_release" or anim_name == "fire_release_special":
		can_slide = true
		
func _on_attack_cooldown_timeout() -> void:
	pass

func calculate_attack_speed():
	attack_speed = lerp(0.5, 2.0, float(current_attributes.get("Dex") - 1) / (20 - 1))
	print("Attack speed:", attack_speed)

func calculate_damage():
	var scaling_factor = 1.5
	damage = base_damage + scaling_factor * sqrt(current_attributes.get("Str"))
	critical_damage = damage * 0.60
	print("damage: ", damage, "| crit: ", critical_damage)

func calculate_speed():
	var scaling_factor = 30
	acceleration = base_acceleration + scaling_factor * sqrt(current_attributes.get("Spd"))
	move_speed = lerp(0.5, 4.0, float(current_attributes.get("Spd") - 1) / (20 - 1))

func move_slow():
	if is_on_floor():
		acceleration = 100

func _on_stamina_bar_cooldown_timeout() -> void:
	can_special_attack = true
