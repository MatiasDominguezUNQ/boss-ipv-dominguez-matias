extends Area2D

@onready var portal: AnimatedSprite2D = $Portal

var won: bool = false


func _ready() -> void:
	portal.play("idle")
	connect("body_entered", Callable(self, "_on_body_entered"))


func _on_body_entered(body: Node) -> void:
	if body is Player:
		if !won:
			won = true
			portal.play("open")
			GameState.notify_level_won()


func _on_Portal_animation_finished() -> void:
	if portal.animation == "open":
		portal.play("idle_open")
