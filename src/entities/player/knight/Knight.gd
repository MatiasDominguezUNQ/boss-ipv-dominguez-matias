extends Player

@export var dash_speed: int = 400
@onready var sword_attack: Area2D = $WeaponContainer/Weapon/SwordAttack
@onready var sword_block: PlayerShield = $WeaponContainer/Weapon/SwordBlock
@onready var attack_particles: GPUParticles2D = $WeaponContainer/Weapon/SwordAttack/AttackParticles

var combo_skill: int = 2
var current_attack: String = ""
var can_attack = true
var is_flipped = false
var fully_charged = false
var combo_window = 0.2
var combo_timer: Timer = null
var is_charging: bool = false

const ARROW_DEFLECT = preload("res://assets/sound/sfx/attacks/bow/arrow_deflect.mp3")

func _ready() -> void:
	GameState.give_experience.connect(self.handle_give_experience)
	inventory.item_equipped.connect(self.updateStats)
	base_attributes = {
		"Str": 4,
		"Dex": 3,
		"Def": 3,
		"Spd": 2,
	}
	current_attributes = inventory.get_total_attributes(base_attributes)
	emit_signal("statsUpdated",current_attributes)
	camera_2d.make_current()
	calculate_attack_speed()
	calculate_damage()
	calculate_speed()
	GameState.set_current_player(self, "Soldier")
	emit_signal("level_up", current_level)
	spike_walk_skill = false
	crit_skill = false
	slide_skill = false
	jumps_limit = 1

func _handle_move_input() -> void:
	move_direction = int(Input.is_action_pressed("move_right")) - int(Input.is_action_pressed("move_left"))
	if move_direction != 0 and !is_charging:
		velocity.x = lerp(velocity.x, move_direction * acceleration, FRICTION_WEIGHT)
		if !fx_anim.is_playing():
			body_pivot.scale.x = move_direction
			if move_direction == 1 and is_flipped:
				weapon_container.scale.x = -1
				is_flipped = false
			if move_direction == -1 and !is_flipped:
				weapon_container.scale.x = -1
				is_flipped = true

func _handle_deacceleration() -> void:
	if !is_charging:
		velocity.x = lerp(velocity.x, 0.0, FRICTION_WEIGHT) if abs(velocity.x) > 1 else 0

func _handle_move_input_without_flip():
	move_direction = int(Input.is_action_pressed("move_right")) - int(Input.is_action_pressed("move_left"))
	if move_direction != 0:
		velocity.x = lerp(velocity.x, move_direction * acceleration, FRICTION_WEIGHT)

func _physics_process(delta: float) -> void:
	if current_item != null and current_item.can_grab and Input.is_action_just_pressed("interact"):
		_handle_item_pickup()

func _handle_weapon_actions() -> void:
	if fx_anim.is_playing() && fx_anim.current_animation == "charge_start" && !Input.is_action_pressed("secondary_attack"):
		fx_anim.play("RESET")
		weapon_sfx.stop()
		fully_charged = false
	elif fully_charged and !Input.is_action_pressed("secondary_attack"):
		dash_attack()
		fully_charged = false
	if GameState.player_can_attack and !fx_anim.is_playing() and can_attack and current_attack == "" and Input.is_action_just_pressed("primary_attack"):
		can_attack = false 
		current_attack = "attack_1"
		fx_anim.play("attack_1", -1, attack_speed)
		reset_combo_timer()
	elif GameState.player_can_attack and current_attack == "attack_1" and Input.is_action_just_pressed("primary_attack"):
		if combo_timer and !combo_timer.is_stopped(): 
			current_attack = "attack_2"
			fx_anim.play("attack_2", -1, attack_speed)
			reset_combo_timer()
	elif GameState.player_can_attack and current_attack == "attack_2" and Input.is_action_just_pressed("primary_attack"):
		if combo_timer and combo_timer.is_stopped() == false:
			fx_anim.play("attack_3", -1, attack_speed)
			reset_combo_timer()
	elif can_special_attack and GameState.player_can_attack  and !fx_anim.is_playing() and can_attack and Input.is_action_just_pressed("secondary_attack"):
		if combo_timer and combo_timer.is_stopped() == false:
				reset_combo_timer()
		fx_anim.play("charge_start")

func _on_fx_anim_animation_finished(anim_name: StringName) -> void:
	match anim_name:
		"attack_1":
			start_combo_timer()
		"attack_2":
			start_combo_timer()
		"attack_3":
			end_attack()
		"charge_start":
			fully_charged = true
			fx_anim.play("charge_hold")
		"charge_attack":
			fx_anim.play("RESET")

func start_combo_timer() -> void:
	if combo_timer == null:
		combo_timer = Timer.new()
		combo_timer.wait_time = combo_window
		combo_timer.one_shot = true
		combo_timer.timeout.connect(self.end_attack)
		add_child(combo_timer)
	combo_timer.start() 

func reset_combo_timer() -> void:
	if combo_timer and !combo_timer.is_stopped():
		combo_timer.stop()

func end_attack() -> void:
	can_attack = false
	fx_anim.play("RESET")
	if combo_timer:
		combo_timer.queue_free()
		combo_timer = null
	attack_cooldown.start()

func _on_attack_cooldown_timeout() -> void:
	current_attack = ""
	can_attack = true

func dash_attack() -> void:
	collision_mask = (1 << 0) | (1 << 1)
	var dash_direction = Vector2(1 if !is_flipped else -1, 0) 
	velocity = dash_direction * dash_speed 
	if fx_anim:
		is_charging = true
		fx_anim.play("charge_attack")
	can_attack = false
	await get_tree().create_timer(0.5).timeout
	#velocity = Vector2.ZERO
	is_charging = false
	can_attack = true
	can_special_attack = false
	stamina_bar.start_timer()

func _handle_deal_damage(area: Node2D) -> void:
	var hit_areas = []
	for overlapping_area in sword_attack.get_overlapping_areas():
		hit_areas.append(overlapping_area)
	for overlapping_body in sword_attack.get_overlapping_bodies():
		hit_areas.append(overlapping_body)
	var shield_hit = false
	for hit_area in hit_areas:
		if hit_area is Shield:
			shield_hit = true
			sword_attack.collision_mask = 0
			weapon_sfx.stream = ARROW_DEFLECT
			weapon_sfx.play()
			return 
	if not shield_hit:
		for hit_area in hit_areas:
			if hit_area.has_method("notify_hit"):
				if is_charging:
					hit_area.notify_hit(damage, true)
					emit_charge_particles()
					if hit_area is PlayerBoss:
						hit_area.notify_hit(damage, true)
						emit_charge_particles()
				else:
					hit_area.notify_hit(damage)
				break 
	if !is_charging:
		sword_attack.collision_mask = 0

func emit_charge_particles():
	attack_particles.emitting = true
