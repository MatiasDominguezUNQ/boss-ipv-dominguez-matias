extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		if body.velocity.x != 0:
			if body.has_method("notify_hit") and !body.spike_walk_skill:
				body.notify_hit(999)
				body.velocity = Vector2.ZERO
