extends Button

@export var slot_icon: Texture2D
@onready var container: CenterContainer = $CenterContainer
@onready var item_info: Label = $ItemInfo

var itemStackGui: ItemStack
var index: int
var player_inventory: Inventory
var item_type: int

func _ready() -> void:
	item_info.visible = false
	show()
	call_deferred("set_player_inventory")
	if slot_icon:
		icon = slot_icon

func set_player_inventory():
	player_inventory = GameState.current_player.inventory

func insert(itemStack: ItemStack):
	itemStackGui = itemStack
	container.add_child(itemStackGui)
	if itemStackGui.item:
		item_info.text = itemStackGui.item.stats_to_string()
	if !itemStackGui.inventorySlot or player_inventory.slots[index] == itemStackGui.inventorySlot:
		return
	player_inventory.insert_item_at_index(index, itemStack.inventorySlot)

func equip_item(itemStack: ItemStack):
	icon = null
	itemStackGui = itemStack
	container.add_child(itemStackGui)
	if itemStackGui.item:
		item_info.text = itemStackGui.item.stats_to_string()
	if !itemStackGui.inventorySlot or player_inventory.equipment_slots[itemStackGui.item.item_type] == itemStackGui.inventorySlot:
		return
	player_inventory.equip_item_at_index(index, itemStack.inventorySlot)


func take_equipped_item():
	if itemStackGui:
		item_info.text = ""
		item_info.visible = false
		var item = itemStackGui
		container.remove_child(itemStackGui)
		itemStackGui = null
		if slot_icon:
			icon = slot_icon
		player_inventory.unequip_item_at_index(item_type)
		return item
	
func takeItem():
	item_info.text = ""
	item_info.visible = false
	var item = itemStackGui
	container.remove_child(itemStackGui)
	itemStackGui = null
	if slot_icon:
		icon = slot_icon
	return item

func isEmpty():
	return !itemStackGui

func _on_pressed() -> void:
	GameState.player_can_attack = false

func _on_mouse_entered() -> void:
	GameState.player_can_attack = false
	if item_info.text != "":
		item_info.visible = true
		var local_position = get_local_mouse_position()
		item_info.position = local_position + Vector2(10, 10)

func _on_mouse_exited() -> void:
	GameState.player_can_attack = true
	item_info.visible = false

func _on_focus_entered() -> void:
	var button_center = global_position + (size / 2)
	var camera = get_viewport().get_camera_2d()
	var local_position = camera.global_transform.affine_inverse().basis_xform(button_center)
	var final_position = ((local_position - camera.global_position) * camera.zoom) + (get_viewport_rect().size / 2)
	get_viewport().warp_mouse(final_position)

func update():
	if itemStackGui.item:
		item_info.text = itemStackGui.item.stats_to_string()
