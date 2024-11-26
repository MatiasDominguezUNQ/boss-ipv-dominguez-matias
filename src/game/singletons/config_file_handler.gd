extends Node

var config: ConfigFile = ConfigFile.new()
const settings_file_path = "user://settings.ini"

func _ready() -> void:
	if !FileAccess.file_exists(settings_file_path):
		config.set_value("keybinding","move_left", "A")
		config.set_value("keybinding","move_right", "D")
		config.set_value("keybinding","move_up", "W")
		config.set_value("keybinding","move_down", "S")
		config.set_value("keybinding","primary_attack", "mouse_1")
		config.set_value("keybinding","utility_skill", "shift")
		config.set_value("keybinding","pause_menu", "escape")
		config.set_value("keybinding","interact", "E")
		config.set_value("keybinding","toggle_inventory", "C")
		config.set_value("video","brightness", 1.0)
		config.set_value("audio","master_volume", 1.0)
		config.set_value("audio","music_volume", 1.0)
		config.set_value("audio","sfx_volume", 1.0)
		
