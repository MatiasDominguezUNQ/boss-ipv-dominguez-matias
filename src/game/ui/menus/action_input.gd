@tool
extends Node

@onready var input: Button = %Input
@onready var action: Label = %Action
@export var focus_sfx: AudioStream
@export var click_sfx: AudioStream
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

@export var action_id: String
@export var action_name: String:
	set(input):
		action_name = input
		if Engine.is_editor_hint() && has_node("%Action"):
			%Action.text = input

func _ready() -> void:
	var key_string;
	set_process_input(false)
	input.text = action_id
	action.text = action_name
	if !Engine.is_editor_hint() && InputMap.has_action(action_id):
		var events = InputMap.action_get_events(action_id)[0]
		if events is InputEventKey:
			key_string = OS.get_keycode_string(events.keycode)
		else:
			key_string = events.as_text()
		_set_event(key_string)

func _set_event(event):
	input.text = event

func _on_input_pressed() -> void:
	set_process_input(true)
	input.text = "..."
	input.release_focus()
	input.disabled = true

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.physical_keycode == KEY_ESCAPE:
		get_viewport().set_input_as_handled()
		set_process_input(false)
		await get_tree().create_timer(0.1).timeout
		input.grab_focus()
		input.disabled = false
		_set_event(InputMap.action_get_events(action_id)[0].as_text())
		return
	if event is not InputEventMouseMotion and (not event is InputEventMouseButton or not event.double_click):
		InputMap.action_erase_events(action_id)
		InputMap.action_add_event(action_id, event)
		var key = event.as_text().trim_suffix(" (Physical)")
		_set_event(key)
		set_process_input(false)
		await get_tree().create_timer(0.1).timeout
		input.grab_focus()
		input.disabled = false


func on_focus():
	audio_stream_player.stream = focus_sfx
	audio_stream_player.play()

func on_click():
	audio_stream_player.stream = click_sfx
	audio_stream_player.play()
