extends AbstractStateMachine


func notify_hit(amount: int, isCrit) -> void:
	current_state.handle_event("hit", amount, isCrit)


func _on_body_animations_animation_finished(anim_name: StringName) -> void:
	current_state._on_animation_finished(anim_name)

func _on_detection_area_body_entered(body: Node2D) -> void:
	if character.target == null && !character.is_dead and !character.acting() and !character.is_attacking:
		character._play_animation("react")
		character.target = body

func _on_detection_area_body_exited(body: Node2D) -> void:
	if body == character.target && !character.is_dead:
		pass#character.target = null

func _on_fx_anim_animation_finished(anim_name: StringName) -> void:
	current_state._on_animation_finished(anim_name)
