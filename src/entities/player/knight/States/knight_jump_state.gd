extends AbstractState

@export var jumps_limit: int = 1

func enter() -> void:
	jumps_limit = character.jumps_limit
	if character.is_sliding:
		character.jumps += 1
		character.player_sfx.stream = character.jump_sfx
		character.player_sfx.play()
		character.V_SPEED_LIMIT = character.jump_speed
		character.velocity.y = -character.jump_speed
		if character.body_pivot.scale.x == character.wall_direction():
			character.velocity.x = 1000 * -character.body_pivot.scale.x
		else:
			character.velocity.x = 1000 * character.body_pivot.scale.x
		character.is_sliding = false
	if character.is_on_floor() || character.is_grabbing_rope:
		character.player_sfx.stream = character.jump_sfx
		character.player_sfx.play()
		character.is_grabbing_rope = false
		character.jumps += 1
		character.velocity.y -= character.jump_speed 
		character._play_animation("jump")
	else:
		if character.velocity.y > 0:
			character._play_animation("fall")
		else:
			character._play_animation("jump")

func _on_rope_cast_collided(collider):
	if Input.is_action_pressed("move_up"):
		if collider is RigidBody2D and !character.is_grabbing_rope:
			character.rope = collider
			emit_signal("finished", "rope_swing")

func handle_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("jump") && character.jumps < jumps_limit:
		character.jumps += 1
		character.player_sfx.stream = character.jump_sfx
		character.player_sfx.play()
		character.velocity.y = -character.jump_speed
		character._play_animation("jump")
	if Input.is_action_just_pressed("utility_skill") and !character.fx_anim.is_playing():
		emit_signal("finished", "block")

func update(delta: float) -> void:
	character._handle_weapon_actions()
	character._handle_move_input()
	if character.move_direction == 0:
		character._handle_deacceleration()
	character._apply_movement()
	if character.is_on_floor():
		character.player_sfx.stream = character.land_sfx
		character.player_sfx.play()
		if character.move_direction == 0:
			emit_signal("finished", "idle")
		else:
			emit_signal("finished", "walk")
	else:
		if character.slide_skill && character.can_slide && character.wall_direction() != 0:
			emit_signal("finished", "wall_jump")
		if character.velocity.y > 0:
			character._play_animation("fall")
		else:
			character._play_animation("jump")

# En este callback manejamos, por el momento, solo los impactos
func handle_event(event: String, value = null, isCrit = null) -> void:
	match event:
		"hit":
			character._handle_hit(value, isCrit)
			if character.is_dead:
				emit_signal("finished", "dead")
		"spike_hit":
			character._handle_spike_hit()
			if character.is_dead:
				emit_signal("finished", "dead")
