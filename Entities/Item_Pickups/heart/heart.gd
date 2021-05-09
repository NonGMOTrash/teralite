extends "res://Entities/Item_Pickups/item.gd"

func on_pickup(player):
	player.components["stats"].change_health(1, 0, "heal")
	queue_free()
