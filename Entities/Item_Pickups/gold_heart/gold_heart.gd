extends "res://Entities/Item_Pickups/item.gd"

export(int) var healing := 1

func on_pickup(player):
	player.components["stats"].change_health(0, healing, "heal")
	queue_free()
