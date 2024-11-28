extends AbstractState

func enter() -> void:
	character.emit_signal("dead")
	character._play_animation("die")
	character._remove_custom()
	character.attack_area.collision_mask = 0

func update(delta) -> void:
	character._handle_deacceleration()
	character._apply_movement()

func _on_animation_finished(anim_name):
	match anim_name:
		"die":
			await get_tree().create_timer(20).timeout
			character.queue_free()
