extends AbstractState


func enter() -> void:
	character.jumps = 0
	character._play_animation("idle")

func handle_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("jump"):
		emit_signal("finished", "jump")
	elif Input.is_action_just_pressed("utility_skill") and !character.fx_anim.is_playing():
		emit_signal("finished", "block")

func _on_rope_cast_collided(collider):
	if Input.is_action_pressed("move_up"):
		if collider is RigidBody2D and !character.is_grabbing_rope:
			character.rope = collider
			emit_signal("finished", "rope_swing")

func update(_delta: float) -> void:
	character._handle_weapon_actions()
	character._handle_move_input()
	if character.move_direction != 0:
		emit_signal("finished", "walk")
	else:
		character._handle_deacceleration()
		character._apply_movement()
		if character.is_on_floor():
			character._play_animation("idle")
		else:
			emit_signal("finished", "jump")

func handle_event(event: String, value = null, isCrit = false) -> void:
	match event:
		"hit":
			character._handle_hit(value, isCrit)
			if character.is_dead:
				emit_signal("finished", "dead")
