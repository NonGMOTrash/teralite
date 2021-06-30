extends Item

export var healing: int

func on_pickup(player: Entity):
	if player.components["stats"] == null:
		return
	
	player.stats.MAX_HEALTH += 1
	player.components["stats"].change_health(healing, 0, "heal")
	queue_free()
