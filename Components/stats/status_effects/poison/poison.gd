extends Status_Effect

func _ready() -> void:
	$spawn_timer.connect("timeout", $spawner, "spawn")

func triggered():
	if get_parent().HEALTH + get_parent().BONUS_HEALTH > 1: 
		get_parent().change_health(0, -1, "poison")
