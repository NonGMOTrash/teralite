extends Status_Effect

func _ready() -> void:
	pass

func trigger():
	if get_parent().HEALTH + get_parent().BONUS_HEALTH > 1: 
		get_parent().change_health(0, -1, "poison")
