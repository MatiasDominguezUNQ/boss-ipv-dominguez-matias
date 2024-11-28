extends Control

@onready var hp_progress_1: TextureProgressBar = $"%HpProgress1"
@onready var hp_text: Label = %HpText


func _ready() -> void:
	GameState.connect("current_player_changed", Callable(self, "_on_current_player_changed"))

func _on_current_player_changed(player: Player) -> void:
	player.connect("hp_changed", Callable(self, "_on_hp_changed"))
	_on_hp_changed(player.health, player.max_health)

func _on_hp_changed(hp: int, hp_max: int) -> void:
	hp_progress_1.max_value = hp_max
	hp_progress_1.value = hp
	hp_text.text = str(hp,"/",hp_max)
