extends AbstractState


func enter() -> void:
	character.fx_anim.play("parry_hold")

func handle_input(event:InputEvent) -> void:
	if !Input.is_action_pressed("utility_skill")and character.fx_anim.current_animation != "parry_attack":
		emit_signal("finished", "idle")
	elif Input.is_action_just_released("utility_skill") and character.fx_anim.current_animation != "parry_attack":
		emit_signal("finished", "idle")
	elif Input.is_action_just_pressed("jump"):
		emit_signal("finished", "jump")

func update(delta: float) -> void:
	character._handle_move_input_without_flip()
	character._apply_movement()
	if character.move_direction == 0:
		character._play_animation("idle")
		character._handle_deacceleration()
	else:
		if character.is_on_floor():
			character._play_animation("walk")
		else:
			if character.velocity.y > 0:
				character._play_animation("fall")
			else:
				character._play_animation("jump")

func exit() -> void:
	character._on_attack_cooldown_timeout()
	character.sword_block.collision_layer = 0
	character.fx_anim.play("RESET")

func handle_event(event: String, value = null, isCrit = false) -> void:
	match event:
		"hit":
			character._handle_hit(value, isCrit)
			if character.is_dead:
				emit_signal("finished", "dead")

func _on_animation_finished(anim_name:String) -> void:
	if anim_name == "parry_hold":
		print("switch to block")
		character.fx_anim.play("block")
	if anim_name == "parry_attack":
		emit_signal("finished", "idle")
