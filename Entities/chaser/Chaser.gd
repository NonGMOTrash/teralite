extends Entity

const GOLD_HEART = preload("res://Entities/Item_Pickups/gold_heart/gold_heart.tscn")

onready var sprite = $sprite

func death():
	emit_signal("death")
	
	# PROBLEM_NOTE: only gold chaser should have this, the brute and normal chaser should just have Entity.gd
	# also i should probably just use a death_spawn component instead of a script
	if sprite.texture.get_path() == "res://Graphics/Sprites/Entities/gold chaser.png":
		var gheart: Entity = GOLD_HEART.instance()
		gheart.global_position = global_position
		
		get_parent().call_deferred("add_child", gheart)
	
	queue_free()
