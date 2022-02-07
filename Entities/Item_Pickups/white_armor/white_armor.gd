extends Item

func on_pickup(player):
	player.components["stats"].DEFENCE += 1
	player.components["stats"].armor += 1
	refs.health_ui.update()
