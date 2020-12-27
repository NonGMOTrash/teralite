extends Sprite

onready var stats = get_parent().components["stats"]

func _on_healthBar_tree_entered() -> void:
	get_parent().components["health_bar"] = self

func _ready(): 
	if stats == null:
		queue_free()
		return
	update()
	stats.connect("health_changed", self, "update_bar")

func update_bar(type) -> void:
	var f 
	f = float(stats.HEALTH) / float(stats.MAX_HEALTH)
	f = f * 100
	f = 5 * round(f / 5)
	f /= 5
	f -= 1
	f = clamp(f, 0, 19)
	frame = f
	if stats.HEALTH == stats.MAX_HEALTH or get_parent().get_name() == "player":
		visible = false
	else:
		visible = true
