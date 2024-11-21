extends AbstractState

func enter() -> void:
	character._play_animation("die")
	character._remove_custom()

func update(delta) -> void:
	character._handle_deacceleration()
	character._apply_movement()
