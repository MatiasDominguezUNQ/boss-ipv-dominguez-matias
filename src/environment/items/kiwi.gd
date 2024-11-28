extends Item

func equip_bonus(player: Player):
	var amount = player.max_health - player.health
	player.heal(amount)
