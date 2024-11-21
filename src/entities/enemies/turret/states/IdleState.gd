extends AbstractEnemyState

@onready var idle_timer: Timer = $IdleTimer

func enter():
	character.velocity = Vector2.ZERO
	if character.target != null:
		character._play_animation("idle_alert")
	else:
		character._play_animation("idle")
	idle_timer.start()

func exit():
	idle_timer.stop()

func update(delta):
	character._apply_movement()
	if character._can_see_target():
		emit_signal("finished", "alert")

func _on_idle_timer_timeout() -> void:
	emit_signal("finished", "walk")

func _handle_body_entered(body):
	super(body)
	character.target = body
	character._play_animation("idle_alert")
	
func _handle_body_exited(body):
	super(body)
	character.target = null
	character._play_animation("idle")
	
