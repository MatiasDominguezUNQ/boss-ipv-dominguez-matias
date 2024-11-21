extends Control
@onready var inventory_display: Control = $".."

var dragging: bool = false
var offset: Vector2

func _process(delta: float) -> void:
	if dragging:
		position = get_viewport().get_mouse_position() - offset

func _on_gui_input(event: InputEvent) -> void:
	if !dragging and event.is_action_pressed("drag"):
		var mouse_pos = get_viewport().get_mouse_position()
		offset = mouse_pos - position
		dragging = true
		get_viewport().set_input_as_handled()
		move_to_front()
	if dragging and event.is_action_released("drag"):
		dragging = false
		get_viewport().set_input_as_handled()

func _on_mouse_entered() -> void:
	GameState.player_can_attack = false

func _on_mouse_exited() -> void:
	GameState.player_can_attack = true
