extends "res://Entities/Items Pickups/item.gd"

func on_pickup(player):
	player.components["stats"].change_health(0, 1, "heal")
	queue_free()
