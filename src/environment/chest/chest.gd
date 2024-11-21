extends Area2D
class_name Chest

@export var item: PackedScene
@export var is_random: bool = false
@onready var animation_player: AnimationPlayer = $AnimationPlayer
var can_open: bool = false
var already_open: bool = false

func _ready() -> void:
	set_process(false)

func set_item(item):
	self.item = item

func open():
	if not already_open:
		already_open = true
		animation_player.play("open_chest")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "open_chest":
		drop_item()

func drop_item():
	var spawned_item = item.instantiate()
	add_child(spawned_item)
	spawned_item.global_position = global_position

func _on_area_entered(area):
	if area is Player and not already_open:
		set_process(true)
		can_open = true

func _on_area_exited(area):
	if area is Player:
		set_process(false)
		can_open = false

func _process(delta):
	if not already_open and can_open and Input.is_action_just_pressed("interact"):
		open()
