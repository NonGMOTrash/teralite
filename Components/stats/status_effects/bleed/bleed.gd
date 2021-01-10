extends Status_Effect

func triggered():
	get_parent().change_health(0, -1, "bleed")
