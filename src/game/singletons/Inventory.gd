extends Resource

class_name Inventory

signal updated()
signal item_equipped()

var slots: Array[InventorySlot] = []
var equipment_slots: Array[InventorySlot] = []
var itemsq: int = 0
var attribute_modifiers := {
	"Str": 0,
	"Dex": 0,
	"Def": 0,
	"Spd": 0,
	"Int": 0
}

func _ready():
	print("inv ready")
	emit_signal("updated")

func _init():
	slots.resize(20)
	equipment_slots.resize(5)
	for i in range(slots.size()):
		slots[i] = InventorySlot.new()
	for i in range(equipment_slots.size()):
		equipment_slots[i] = InventorySlot.new()

func add_item(item: Item) -> void:
	print("adding item")
	for slot in slots:
		if slot.item and slot.item.item_name == item.item_name and slot.item.item_type == Item.ItemType.CONSUMABLE:
			slot.amount += 1
			emit_signal("updated")
			return
	for i in range(slots.size()):
		print("slot: ", i)
		if slots[i].item is not Item:
			print(i)
			slots[i].item = item.duplicate()
			slots[i].amount = 1
			slots[i].texture = item.sprite_2d.texture.duplicate()
			itemsq += 1
			emit_signal("updated")
			return

func is_full():
	return itemsq >= 20

func remove_item_at_index(index: int):
	slots[index] = InventorySlot.new()

func insert_item_at_index(index: int, item: InventorySlot):
	var old_index = slots.find(item)
	remove_item_at_index(old_index)
	slots[index] = item

func equip_item_at_index(index: int, item: InventorySlot):
	var old_index = slots.find(item)
	remove_item_at_index(old_index)
	equipment_slots[index] = item
	apply_item_effects(item.item)

func unequip_item_at_index(index: int):
	remove_item_effects(equipment_slots[index].item)
	equipment_slots[index] = InventorySlot.new()

func apply_item_effects(item: Item) -> void:
	for attribute in item.effects.keys():
		if attribute_modifiers.has(attribute):
			attribute_modifiers[attribute] += item.effects[attribute]
	emit_signal("item_equipped")

func remove_item_effects(item: Item) -> void:
	for attribute in item.effects.keys():
		if attribute_modifiers.has(attribute):
			attribute_modifiers[attribute] -= item.effects[attribute]
	emit_signal("item_equipped")

func get_total_attributes(base_attributes: Dictionary) -> Dictionary:
	var total_attributes := base_attributes.duplicate()
	for attribute in attribute_modifiers.keys():
		if total_attributes.has(attribute):
			total_attributes[attribute] += attribute_modifiers[attribute]
	return total_attributes
