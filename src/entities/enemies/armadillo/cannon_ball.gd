extends GroundEnemy

@onready var time_attacking: Timer = $TimeAttacking
@export var roll_speed: float = 150.0
var is_attacking:bool = false
var roll_direction: int

func _handle_move() -> void:
	if target != null && !acting():
		move_direction = 1 - 2 * float(to_local(target.global_position).x < 0)
		velocity.x = lerp(velocity.x, move_direction * ACCELERATION, FRICTION_WEIGHT)
		body_pivot.scale.x = move_direction
	elif !is_on_floor():
		velocity.x = lerp(velocity.x, move_direction * AIR_ACCELERATION, FRICTION_WEIGHT)
	else:
		_handle_deacceleration()

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
	if is_attacking:
		velocity.x = roll_direction * roll_speed
		move_and_slide()
		if !has_safe_floor(roll_direction):
			roll_direction = -roll_direction
			switch_roll()
			velocity.x = roll_direction * roll_speed
		else:
			for i in get_slide_collision_count():
				var collision = get_slide_collision(i)
				if collision.get_normal().x == 1 or collision.get_normal().x == -1:
					roll_direction = -roll_direction
					switch_roll()
					velocity.x = roll_direction * roll_speed
					break

func switch_roll():
	if roll_direction == 1:
		_play_animation("attack")
	else:
		_play_animation("attack_counterclock")

func knockback(force: float, direction: Vector2) -> void:
	direction = direction.normalized()
	var knockback_force = direction * force / knockback_resistance
	if is_on_floor() and knockback_force.y > -100:
		knockback_force.y = -80
	velocity = knockback_force

func acting():
	return body_animations.current_animation == "start_attack" or body_animations.current_animation == "stop_attack"

func _can_move_to_target():
	if target == null:
		return false
	raycast.target_position = to_local(target.global_position)
	raycast.force_raycast_update()
	#(raycast.is_colliding() && raycast.get_collider() == target)
	return has_safe_floor(move_direction) && ((abs(raycast.target_position.x) > 450 && (abs(raycast.target_position.y) < 40)) || (abs(raycast.target_position.x) > 5 && (abs(raycast.target_position.y) > 60)))

func has_safe_floor(direction:int) -> bool:
	var has_floor: bool
	var has_spikes: bool
	if target == null:
		return false
	if direction == 1:
		right_floor_cast.force_raycast_update()
		right_floor_cast_2.force_raycast_update()
		has_floor = right_floor_cast.is_colliding()
		has_spikes = right_floor_cast_2.is_colliding()
	else:
		left_floor_cast.force_raycast_update()
		left_floor_cast_2.force_raycast_update()
		has_floor = left_floor_cast.is_colliding()
		has_spikes = left_floor_cast_2.is_colliding()
	return has_floor and not has_spikes

func _can_attack_target():
	if target == null:
		return false
	return _can_attack_target_ground() && can_attack

func _can_attack_target_ground():
	if target == null:
		return false
	return abs(raycast.target_position.x) < 450 && abs(raycast.target_position.y) < 40

func receive_damage(amount, isCrit):
	if is_attacking: 
		GameEnviroment.show_damage(damage_spawn.global_position, 0, false, true)
	else:
		health -= amount
		GameEnviroment.show_damage(damage_spawn.global_position, amount, isCrit)
		if (health <= 0):
			health = 0
			handle_death()

func _handle_hit(amount: int, isCrit) -> void:
	if !is_dead:
		if body_animations.current_animation != "attack":
			body_sfx.stream = hit_sfx
			body_sfx.play()
		receive_damage(amount, isCrit)
		emit_signal("hp_changed",health, max_health)

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
	GameEnviroment.enemy_attack(body, damage, attack_area, self)

func _on_attack_cooldown_timeout() -> void:
	print("can attack")
	can_attack = true

func roll_attack() -> void:
	if target == null:
		return
	switch_roll()
	roll_direction = sign(to_local(target.global_position).x)
	is_attacking = true
	time_attacking.start()

func _on_time_attacking_timeout() -> void:
	print("stopping")
	is_attacking = false
	can_attack = false
