extends AbstractEnemyState

func enter():
	print("I'm turret and imma die")
	character._play_animation("dead")
	character.body_sfx.stream = character.die_sfx
	character.body_sfx.play()
	character.dead = true
	character.collision_layer = 0
	character.collision_mask = 0
	if character.target != null:
		character._play_animation("die_alert")
	else:
		character._play_animation("die")

func _on_animation_finished(animation):
	if animation in ["die_alert", "die"]:
		character._remove()
