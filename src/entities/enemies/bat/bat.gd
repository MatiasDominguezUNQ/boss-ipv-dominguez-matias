extends GroundEnemy

@export var dash_speed: float = 400.0
@export var return_offset: Vector2 = Vector2(50, 0) 

var dash_target_position: Vector2
var dash_direction: Vector2
var start_position: Vector2
var is_dashing: bool = false
var has_collided:bool = false

func _handle_move() -> void:
	if target != null and not acting() and not is_dashing and can_attack:
		var on_wall = is_on_wall()
		var on_floor = is_on_floor()
		var move_direction = 1 - 2 * float(to_local(target.global_position).x < 0)
		var target_y = to_local(target.global_position).y
		if on_wall:
			velocity.y = lerp(velocity.y, sign(target_y) * ACCELERATION, FRICTION_WEIGHT)
			velocity.x = 0
		elif on_floor:
			velocity.x = lerp(velocity.x, move_direction * ACCELERATION, FRICTION_WEIGHT)
			velocity.y = 0
		else:
			velocity.x = lerp(velocity.x, move_direction * ACCELERATION, FRICTION_WEIGHT)
			velocity.y = lerp(velocity.y, sign(target_y) * ACCELERATION, FRICTION_WEIGHT)
		body_pivot.scale.x = move_direction
	elif not is_on_ceiling():
		velocity.y = lerp(velocity.y, -AIR_ACCELERATION, FRICTION_WEIGHT)
	else:
		_handle_deacceleration()

func _apply_movement() -> void:
	if is_dead:
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
				velocity.y -= ACCELERATION
			if body.velocity.x == 0:
				body.velocity.x = push_force * 0.5
				velocity.y -= ACCELERATION
			break

func _physics_process(delta: float) -> void:
	if target != null && !acting():
		raycast.target_position = to_local(target.global_position)
		raycast.force_raycast_update()
		body_pivot.scale.x = 1 - 2 * float(raycast.target_position.x < 0)

func acting():
	return body_animations.current_animation == "hit"

func _can_move_to_target():
	var has_floor: bool
	var has_spikes: bool
	if target == null:
		return false
	raycast.target_position = to_local(target.global_position)
	raycast.force_raycast_update()
	return (abs(raycast.target_position.x) > 150 || (abs(raycast.target_position.y) > 150)) and can_attack

func _can_attack_target():
	if target == null:
		return false
	return _can_attack_target_air() && can_attack

func _can_attack_target_air():
	if target == null:
		return false
	raycast.target_position = to_local(target.global_position)
	raycast.force_raycast_update()
	return raycast.is_colliding() and raycast.get_collider() == target and abs(raycast.target_position.x) < 150 and abs(raycast.target_position.y) < 150

func can_see_body(body):
	raycast.target_position = to_local(body.global_position)
	raycast.force_raycast_update()
	return raycast.is_colliding() and raycast.get_collider() == body

func _on_sword_area_body_entered(body: Node2D) -> void:
	has_collided = true
	GameEnviroment.enemy_attack(body, damage, attack_area, self)

func _on_attack_cooldown_timeout() -> void:
	can_attack = true

func dash_attack() -> void:
	if target == null:
		return
	print("dashing")
	dash_direction = global_position.direction_to(target.global_position)
	print(dash_direction)
	is_dashing = true
	velocity = dash_direction * dash_speed
	_play_animation("attack")
