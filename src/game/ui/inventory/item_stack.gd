extends Panel
class_name ItemStack
@onready var item_sprite: Sprite2D = $ItemSprite
@onready var amount_label: Label = %Amount

var inventorySlot: InventorySlot
var item: Item
var amount: int

func update():
	if !inventorySlot || !inventorySlot.item: return
	item = inventorySlot.item
	amount = inventorySlot.amount
	item_sprite.texture = inventorySlot.texture
	item_sprite.show()
	if amount < 2:
		amount_label.text = ""
	else:
		amount_label.text = str(amount)
