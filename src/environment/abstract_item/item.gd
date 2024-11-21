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
	"Int": 0
}
@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var item_info: Label = %Info
@onready var sprite_2d: Sprite2D = $Sprite2D


var item_showing: bool = false

var players_in_area: Array[Player] = []
var can_grab: bool = true

func _ready() -> void:
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
	print("pickup item")
	show_item_info()
	equip_bonus(player)

func show_item_info() -> void:
	can_grab = false
	sprite_2d.hide()
	#item_info.show()
	item_showing = true
	await get_tree().create_timer(5).timeout
	queue_free()

func equip_bonus(player):
	pass
