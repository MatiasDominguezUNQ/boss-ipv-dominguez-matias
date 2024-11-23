extends Node

## Escena manager de niveles que administra y carga el nivel actual,
## y se encarga de reiniciar el nivel, regresar al menu principal o
## cargar el siguiente nivel.

@export var levels: Array[PackedScene]
@export var items_global: Array[PackedScene]
@export var main_menu_path: String
@export var mouse_cursor: Texture

@onready var current_level_container: Node = $CurrentLevelContainer
var current_level: GameLevel
var level: int = 0

func _ready() -> void:
	GameState.connect("current_player_changed", Callable(self, "assign_items_to_chests"))
	Input.set_custom_mouse_cursor(mouse_cursor, Input.CURSOR_ARROW, mouse_cursor.get_size() / 2)
	call_deferred("_setup_level", level)

func _setup_level(id: int) -> void:
	var player: Player = GameState.player_scene.instantiate()
	player.inventory = GameState.items_stash
	player.current_level = GameState.player_level
	player.current_experience = GameState.player_xp
	player.next_level_experience = GameState.player_next_xp
	if id >= 0 && id < levels.size():
		
		# Remueve el nivel activo, si existiese
		if current_level_container.get_child_count() > 0:
			for child in current_level_container.get_children():
				current_level_container.remove_child(child)
				child.queue_free()
		
		# Inicializa el nivel nuevo y lo agrega al árbol
		current_level = levels[id].instantiate()
		current_level_container.add_child(current_level)
		current_level.connect("return_requested", Callable(self, "_return_called"))
		current_level.connect("restart_requested", Callable(self, "_restart_called"))
		current_level.connect("next_level_requested", Callable(self, "_next_called"))
		current_level.get_node("Environment").get_node("Entities").add_child(player)
		player.global_position = current_level.spawn_point
		get_tree().paused = false
		current_level.set_tutorials()

# Callback de regreso al MainMenu.
func _return_called() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file(main_menu_path)

func _restart_called() -> void:
	_setup_level(level)

func _next_called() -> void:
	level = min(level + 1, levels.size() - 1)
	_setup_level(level)

func assign_items_to_chests(player) -> void:
	print("assign_items")
	var items
	var chests = current_level.get_chests()
	var player_class = GameState.current_class
	items = items_global.duplicate()
	for chest in chests:
		if chest.is_random:
			if items.size() > 0:
				var item = items.pop_at(randi_range(0, items.size()-1))
				chest.set_item(item)
