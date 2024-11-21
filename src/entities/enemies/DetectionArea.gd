extends Area2D

@onready var green_circle: Node2D = $green_circle


func _ready() -> void:
	green_circle.modulate = Color("#ffffff4d")
	green_circle.visible = false
	
