extends AbstractState


func enter() -> void:
	character.emit_signal("dead")
	character._play_animation("die")
	character.fx_anim.stop()
	character.weapon_sfx.stop()
	if character.special_sfx:
		character.special_sfx.stop()
	character._remove_custom()

func update(delta) -> void:
	character._handle_deacceleration()
	character._apply_movement()
