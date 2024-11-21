extends AnimatedSprite2D

func _ready() -> void:
	# Genera un número aleatorio entre 0 y el último frame de la animación actual
	var random_frame = int(randf() * sprite_frames.get_frame_count("default") - 1)
	frame = random_frame
	# Inicia la animación normalmente
	play()
