extends AbstractState

var joint: PinJoint2D

func enter() -> void:
	character.is_grabbing_rope = true
	character.jumps = 0
	character._play_animation("jump")
	grab_rope()

func grab_rope():
	joint = PinJoint2D.new()
	joint.position = character.position 
	joint.node_a = get_path() 
	joint.node_b = character.rope.get_path() 
	add_child(joint)
	character.rope.linear_velocity = character.velocity / 10
	character.velocity = Vector2.ZERO

func clear_current_joint():
	remove_child(joint)
	joint.queue_free()
	joint = null

func exit():
	character.rope = null
	character.global_rotation = 0
	clear_current_joint()

func handle_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("move_up") && character.can_move_up_rope():
		clear_current_joint()
		grab_rope()
	elif Input.is_action_just_pressed("move_down") && character.can_move_down_rope():
		clear_current_joint()
		grab_rope()
	elif Input.is_action_just_pressed("jump"):
		emit_signal("finished", "jump")

func update(_delta: float) -> void:
	character._handle_rope_swing_input()

func handle_event(event: String, value = null, isCrit = false) -> void:
	match event:
		"hit":
			character._handle_hit(value, isCrit)
			if character.is_dead:
				emit_signal("finished", "dead")
