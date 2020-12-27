extends Entity

onready var sprite = $sprite

func death():
	emit_signal("death")
	
	# PROBLEM_NOTE: only gold chaser should have this, the brute and normal chaser should just have Entity.gd
	if sprite.texture.get_path() == "res://Graphics/Sprites/Entities/gold chaser.png":
		var gheart = global.aquire("Gold_Heart")
		gheart.global_position = global_position
		
		get_parent().call_deferred("add_child", gheart)
	
	queue_free()
