extends "res://Entities/Items Pickups/item.gd"

func on_pickup(player):
	player.components["stats"].DEFENCE += 1
