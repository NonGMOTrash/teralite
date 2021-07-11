extends Status_Effect

func _ready() -> void:
	$spawn_timer.connect("timeout", $spawner, "spawn")

func triggered():
	if stats.HEALTH + get_parent().BONUS_HEALTH > 1: 
		stats.change_health(0, -1, "poison")
