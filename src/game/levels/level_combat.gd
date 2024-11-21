extends GameLevel

func _ready() -> void:
	randomize()

func get_chests():
	return chests_node.get_children()
# Funciones que hacen de interfaz para las señales
func _on_level_won() -> void:
	emit_signal("next_level_requested")

func _on_return_requested() -> void:
	emit_signal("return_requested")

func _on_restart_requested() -> void:
	emit_signal("restart_requested")
	
func set_tutorials():
	set_attack_tutorial()
	set_movement_tutorial()
	set_jump_tutorial()
	set_rope_tutorial()
	set_interact_tutorial()

func set_attack_tutorial():
	var attack_key = get_key("primary_attack")
	var utility_key = get_key("utility_skill")
	var tutorial: String = ""
	var tutorial2: String = ""
	var player = GameState.current_class
	match player:
		"Ranger":
			tutorial = tr("TUTO_03_RANGER")
			tutorial2 = tr("TUTO_04_RANGER")
		"Knight":
			tutorial = tr("TUTO_03_KNIGHT")
			tutorial2 = tr("TUTO_04_KNIGHT")
	tutorial = tutorial.replace("#", attack_key)
	tutorial2 = tutorial2.replace("#", utility_key)
	attack_tutorial.text = tutorial
	utility_tutorial.text = tutorial2

func set_movement_tutorial():
	var move_up_key = get_key("move_up")
	var move_left_key = get_key("move_left")
	var move_down_key = get_key("move_down")
	var move_right_key = get_key("move_right")
	var text = tr("TUTO_01")
	var tuto = move_up_key+"/"+move_left_key+"/"+move_down_key+"/"+move_right_key
	text = text.replace("#", tuto)
	movement.text = text

func set_jump_tutorial():
	var jump_key = get_key("jump")
	var text = tr("TUTO_02")
	text = text.replace("#", jump_key)
	jump.text = text

func set_rope_tutorial():
	var move_up_key = get_key("move_up")
	var jump_key = get_key("jump")
	var text = tr("TUTO_07")
	var text2 = tr("TUTO_08")
	text = text.replace("#", move_up_key)
	text2 = text2.replace("#", jump_key)

func set_interact_tutorial():
	var key = get_key("interact")
	var text = tr("TUTO_09")
	text = text.replace("#", key)
	interact.text = text

func get_key(action_id) -> String:
	var events = InputMap.action_get_events(action_id)[0]
	if events is InputEventKey:
		return OS.get_keycode_string(events.keycode)
	else:
		return events.as_text()

func _on_victory_menu_victory_music() -> void:
	background_music.stream = victory_music
	background_music.play()


func _on_death_music() -> void:
	background_music.stream = death_music
	background_music.play()


func _on_boss_area_entered(area) -> void:
	print("boss entered")
	background_music.stream = boss_music
	background_music.volume_db = -16
	background_music.play()

func _on_boss_area_exited(area) -> void:
	print("boss exited")
	background_music.stream = default_music
	background_music.volume_db = 0
	background_music.play()

func _on_boss_dead() -> void:
	background_music.stream = victory_music
	background_music.volume_db = 0
	background_music.play()
	await get_tree().create_timer(5).timeout
	emit_signal("next_level_requested")
