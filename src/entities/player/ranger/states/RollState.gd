extends AbstractState


var dash_timer: float = 0.0

func enter() -> void:
	character.collision_layer = (1 << 9)
	character.collision_mask = 1
	match character.move_direction:
		1:
			character.velocity.x = character.roll_speed
			character._play_animation("front_roll")
		-1:
			character.velocity.x = -character.roll_speed
			character._play_animation("back_roll")

func update(_delta: float) -> void:
	character._apply_movement()

func exit() -> void:
	character.collision_layer = (1 << 1) | (1 << 9)
	character.collision_mask = (1 << 0) | (1 << 1) | (1 << 2) | (1 << 5) 

func _on_animation_finished(anim_name:String) -> void:
	if anim_name == "back_roll" || anim_name == "front_roll":
		emit_signal("finished", "idle")
