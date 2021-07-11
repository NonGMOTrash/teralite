extends Status_Effect

func _init():
	TRIGGER_TIME *= (1 / level)

func triggered():
	stats.change_health(1, 0, "heal")
