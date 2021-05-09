extends "res://Entities/Item_Pickups/item.gd"

func on_pickup(player):
	player.components["stats"].DEFENCE += 1
	player.components["stats"].armor += 1
	global.nodes["health_ui"].update()
