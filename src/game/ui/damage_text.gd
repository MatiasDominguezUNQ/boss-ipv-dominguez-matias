extends Label

func display_text(text: String, color = Color(1,1,1)) -> void:
	self.text = text
	modulate = color
	start_animation()

func start_animation() -> void:
	var tween = create_tween()
	tween.set_parallel(false) 
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)

	var start_position = global_position
	tween.tween_property(self, "global_position", start_position - Vector2(0, 20), 1.0).from(start_position)
	tween.tween_property(self, "modulate:a", 0.0, 1.0).from(1.0)

	tween.connect("finished", Callable(self, "_on_animation_finished"))

func _on_animation_finished() -> void:
	queue_free()
