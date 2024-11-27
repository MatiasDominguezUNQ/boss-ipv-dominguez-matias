extends Control

@export var focus_sfx: AudioStream
@export var click_sfx: AudioStream
@export var player: Player
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var stored: Array = $MainPanel/Stored.get_children()
@onready var itemStackClass = preload("res://src/game/ui/inventory/item_stack.tscn")
@onready var stats: Array = $MainPanel/Stats.get_children()
@onready var xp_bar: ProgressBar = $MainPanel/HealthBar
@onready var level: Label = %Level
@onready var left_equipment: Array = $MainPanel/LeftEquipment.get_children()
@onready var right_equipment: Array = $MainPanel/RightEquipment.get_children()
@onready var main_panel: Panel = $MainPanel
@onready var default_position: Vector2 = $MainPanel.global_position

var equipped: Array = []
var itemInHand: ItemStack

func _ready() -> void:
	equipped.append_array(left_equipment)
	equipped.append_array(right_equipment)
	connectSlots()
	hide()
	player.inventory.connect("updated", Callable(self, "update"))
	player.connect("statsUpdated", Callable(self, "updateStats"))
	player.connect("xp_changed", Callable(xp_bar, "update"))
	player.connect("level_up", Callable(self, "update_level"))
	update()

func updateStats(player_stats):
	var all_stats = player_stats.keys()
	player_stats = player_stats.values()
	var i = 0
	for stat: Label in stats:
		stat.text = str(all_stats[i],": ",player_stats[i])
		i += 1

func update_level(new_level: int):
	level.text = str("Lvl: ", new_level)

func connectSlots():
	for i in range(stored.size()):
		var slot = stored[i]
		slot.index = i
		slot.connect("pressed", Callable(self, "onSlotClicked").bind(slot))
	for i in range(equipped.size()):
		var slot = equipped[i]
		slot.index = i
		slot.item_type = i
		slot.connect("pressed", Callable(self, "onEquipmentSlotClicked").bind(slot))

func onEquipmentSlotClicked(slot):
	if itemInHand and slot.isEmpty() and itemInHand.item.item_type == slot.item_type:
		equipItemInSlot(slot)
		return
	if !itemInHand and !slot.isEmpty():
		add_to_stored(slot)

func unequipItemFromSlot(slot):
	itemInHand = slot.take_equipped_item()
	add_child(itemInHand)
	updateItemInHand()

func equipItemInSlot(slot):
	var item = itemInHand
	remove_child(itemInHand)
	itemInHand = null
	slot.equip_item(item)

func equipItemInSlotDirect(slot, item):
	slot.equip_item(item)

func onSlotClicked(slot):
	if slot.isEmpty() and itemInHand:
		insertItemInSlot(slot)
		return
	if slot.itemStackGui and equipped[slot.itemStackGui.item.item_type].isEmpty() and !itemInHand:
		equipItemInSlotDirect(equipped[slot.itemStackGui.item.item_type], slot.takeItem())
		return
	if !itemInHand :
		takeItemFromSlot(slot)

func takeItemFromSlot(slot):
	itemInHand = slot.takeItem()
	if itemInHand:
		add_child(itemInHand)
		updateItemInHand()

func insertItemInSlot(slot):
	var item = itemInHand
	remove_child(itemInHand)
	itemInHand = null
	slot.insert(item)

func _on_return_button_pressed() -> void:
	hide()

func _input(event: InputEvent) -> void:
	if visible and event is InputEventKey and event.physical_keycode == KEY_SPACE:
		get_viewport().set_input_as_handled()
		return
	updateItemInHand()
	if event.is_action_pressed("toggle_inventory"):
		if visible:
			hide()
			GameState.player_can_attack = true
		else:
			main_panel.global_position = default_position
			show()

func add_to_stored(slot):
	for i in range(min(player.inventory.slots.size(), stored.size())):
		var i_slot: InventorySlot = player.inventory.slots[i]
		if i_slot.item: continue
		var i_stack: ItemStack = stored[i].itemStackGui
		if !i_stack:
			i_stack = itemStackClass.instantiate()
			stored[i].insert(slot.take_equipped_item())
		i_stack.inventorySlot = i_slot
		i_stack.update()
		break

func update():
	for i in range(min(player.inventory.slots.size(), stored.size())):
		var i_slot: InventorySlot = player.inventory.slots[i]
		if !i_slot.item: continue
		var i_stack: ItemStack = stored[i].itemStackGui
		if !i_stack:
			i_stack = itemStackClass.instantiate()
			stored[i].insert(i_stack)
		i_stack.inventorySlot = i_slot
		i_stack.update()
		stored[i].update()
	for i in range(min(player.inventory.equipment_slots.size(), equipped.size())):
		var i_slot: InventorySlot = player.inventory.equipment_slots[i]
		if !i_slot.item: continue
		var i_stack: ItemStack = equipped[i].itemStackGui
		if !i_stack:
			i_stack = itemStackClass.instantiate()
			equipped[i].equip_item(i_stack)
		i_stack.inventorySlot = i_slot
		i_stack.update()
		equipped[i].update()

func updateItemInHand():
	if !itemInHand: return
	itemInHand.global_position = get_global_mouse_position() - itemInHand.size / 2

func on_focus():
	audio_stream_player.stream = focus_sfx
	audio_stream_player.play()

func on_click():
	audio_stream_player.stream = click_sfx
	audio_stream_player.play()

func _on_stored_mouse_entered() -> void:
	print("stored")
