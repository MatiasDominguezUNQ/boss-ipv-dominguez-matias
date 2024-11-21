extends Player

var combo_skill: int = 2
var current_attack: String = ""
var can_attack = true
var is_flipped = false
var combo_window = 0.2
var combo_timer: Timer = null
@onready var sword_attack: Area2D = $WeaponContainer/Weapon/SwordAttack
@onready var sword_block: PlayerShield = $WeaponContainer/Weapon/SwordBlock

const ARROW_DEFLECT = preload("res://assets/sound/sfx/attacks/bow/arrow_deflect.mp3")

func _ready() -> void:
	GameState.give_experience.connect(self.handle_give_experience)
	inventory.item_equipped.connect(self.updateStats)
	base_attributes = {
		"Str": 5,
		"Dex": 2,
		"Def": 3,
		"Spd": 3,
		"Int": 1
	}
	current_attributes = base_attributes.duplicate()
	emit_signal("statsUpdated",current_attributes)
	camera_2d.make_current()
	calculate_attack_speed()
	calculate_damage()
	calculate_speed()
	GameState.set_current_player(self, "Soldier")
	emit_signal("level_up", current_level)
	spike_walk_skill = true
	crit_skill = false
	slide_skill = false
	jumps_limit = 1

func _handle_move_input() -> void:
	move_direction = int(Input.is_action_pressed("move_right")) - int(Input.is_action_pressed("move_left"))
	if move_direction != 0:
		velocity.x = lerp(velocity.x, move_direction * acceleration, FRICTION_WEIGHT)
		body_pivot.scale.x = move_direction
		if move_direction == 1 and is_flipped:
			weapon_container.scale.x = -1
			is_flipped = false
		if move_direction == -1 and !is_flipped:
			weapon_container.scale.x = -1
			is_flipped = true

func _handle_move_input_without_flip():
	move_direction = int(Input.is_action_pressed("move_right")) - int(Input.is_action_pressed("move_left"))
	if move_direction != 0:
		velocity.x = lerp(velocity.x, move_direction * acceleration, FRICTION_WEIGHT)

func _physics_process(delta: float) -> void:
	if current_item != null and current_item.can_grab and Input.is_action_just_pressed("interact"):
		_handle_item_pickup()

func _handle_weapon_actions() -> void:
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

func _on_fx_anim_animation_finished(anim_name: StringName) -> void:
	match anim_name:
		"attack_1":
			start_combo_timer()
		"attack_2":
			start_combo_timer()
		"attack_3":
			end_attack()

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

func _handle_deal_damage(area: Node2D) -> void:
	if area is Shield:
		sword_attack.collision_mask = 0
		weapon_sfx.stream = ARROW_DEFLECT
		weapon_sfx.play()
	elif area.has_method("notify_hit"):
		area.notify_hit(damage)
		sword_attack.collision_mask = 0
