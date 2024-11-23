extends Button

@export var slot_icon: Texture2D
@onready var container: CenterContainer = $CenterContainer
var itemStackGui: ItemStack
var index: int
var player_inventory: Inventory
var item_type: int

func _ready() -> void:
	show()
	call_deferred("set_player_inventory")
	if slot_icon:
		icon = slot_icon

func set_player_inventory():
	player_inventory = GameState.current_player.inventory

func insert(itemStack: ItemStack):
	itemStackGui = itemStack
	container.add_child(itemStackGui)
	if !itemStackGui.inventorySlot or player_inventory.slots[index] == itemStackGui.inventorySlot:
		return
	player_inventory.insert_item_at_index(index, itemStack.inventorySlot)

func equip_item(itemStack: ItemStack):
	icon = null
	itemStackGui = itemStack
	container.add_child(itemStackGui)
	if !itemStackGui.inventorySlot or player_inventory.equipment_slots[index] == itemStackGui.inventorySlot:
		return
	player_inventory.equip_item_at_index(index, itemStack.inventorySlot)
	
func take_equipped_item():
	if itemStackGui:
		var item = itemStackGui
		container.remove_child(itemStackGui)
		itemStackGui = null
		if slot_icon:
			icon = slot_icon
		player_inventory.unequip_item_at_index(item_type)
		return item
	
func takeItem():
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
