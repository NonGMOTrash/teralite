extends "res://Entities/Item_Pickups/item.gd"

func on_pickup(player: Entity):
	$AnimationPlayer.play("collected")
	
#	for entity in get_tree().get_nodes_in_group("entity"):
#		if (
#			global.get_relation(player, entity) == "hostile"
#			or player in entity.marked_enemies
#		):
#			entity.death()
	
	refs.level_completion.get_ref().start()
