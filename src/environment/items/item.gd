extends Node2D
class_name Item

@export var item_name: String
@export var item_desc: String
enum ItemType { HEAD, CHEST, HANDS, FEET, ACCESORY, CONSUMABLE }
@export var item_type: ItemType
@export var item_amount: int = 1
@export var effects := {
	"Str": 0,
	"Dex": 0,
	"Def": 0,
	"Spd": 0,
}
@export var random_stats: bool = false
@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var item_info: Label = %Info
@onready var sprite_2d: Sprite2D = $Sprite2D


var item_showing: bool = false

var players_in_area: Array[Player] = []
var can_grab: bool = true

func _ready() -> void:
	if random_stats:
		randomize_stats()
	anim_player.play("idle")
	set_process(false)
	item_name = tr(item_name)
	item_desc = tr(item_desc)
	item_info.text = item_name + ": " + item_desc
	item_info.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	item_info.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

func _on_area_entered(area):
	if area is Player:
		print("area entered item")
		set_process(true)
		area.item_in_area(self)
		players_in_area.push_back(area)

func _on_area_exited(area):
	if area is Player:
		players_in_area.erase(area)
		area.leave_item(self)
		if players_in_area.is_empty() and not item_showing:
			set_process(false)

func _process(delta):
	if item_showing:
		item_info.position.y -= 5*delta

func pickup(player) -> void:
	show_item_info()
	equip_bonus(player)

func show_item_info() -> void:
	can_grab = false
	sprite_2d.hide()
	#item_info.show()
	item_showing = true
	await get_tree().create_timer(5).timeout
	queue_free()

func stats_to_string():
	var result = ""
	for stat in effects.keys():
		var value = effects[stat]
		if value > 0:
			result += stat + " +" + str(value) + "\n"
	return result.strip_edges()

func equip_bonus(player):
	pass
	
func randomize_stats():
	var possible_stats = []
	match item_type:
		ItemType.HEAD:
			possible_stats = ["Def", "Dex", "Str"]
		ItemType.CHEST:
			possible_stats = ["Def", "Str", "Spd"]
		ItemType.HANDS:
			possible_stats = ["Dex", "Str", "Def"]
		ItemType.FEET:
			possible_stats = ["Spd", "Dex", "Def"]
		ItemType.ACCESORY:
			possible_stats = ["Str", "Dex", "Spd"]
	if possible_stats.is_empty(): return
	var stats_to_apply = 2
	if randi_range(1, 100) <= 10: 
		stats_to_apply = 3
	var chosen_stats = []
	while chosen_stats.size() < stats_to_apply:
		var stat = possible_stats.pick_random()
		if stat not in chosen_stats:
			chosen_stats.append(stat)
	for stat in effects.keys():
		if stat in chosen_stats:
			effects[stat] = int(randf_range(1, 5))
		else:
			effects[stat] = 0
