extends Entity

const FIRE = preload("res://Entities/fire/fire.tscn")

onready var fire_sprite = $Sprite
onready var fuel = $fuel
onready var spread = $spread

func _on_fuel_timeout() -> void:
	fire_sprite.visible = false
	spread.stop()

func death():
	if fuel.time_left == 0: 
		queue_free()
		return
	
	var new_fire = FIRE.instance()
	new_fire.global_position = global_position
	refs.ysort.get_ref().call_deferred("add_child", new_fire)
	
	for i in 5:
		var newer_fire = FIRE.instance()
		newer_fire.global_position = global_position
		newer_fire.velocity = Vector2(rand_range(-1, 1), rand_range(-1, 1)).normalized() * 150
		refs.ysort.get_ref().call_deferred("add_child", newer_fire)
	queue_free()

func _on_spread_timeout() -> void:
	var new_fire = FIRE.instance()
	new_fire.global_position = global_position
	new_fire.velocity = Vector2(rand_range(-1, 1), rand_range(-1, 1)).normalized() * 100
	new_fire.find_node("fuel").wait_time = 2.0
	refs.ysort.get_ref().call_deferred("add_child", new_fire)

func _on_hitbox_area_entered(area: Area2D) -> void:
	fuel.wait_time = fuel.time_left + 96.0
	fuel.start()

func _on_stats_status_recieved(status) -> void:
	if status == "burning":
		fuel.wait_time += 15
		fuel.start()

func _on_detection_body_entered(body: Node) -> void:
	return # don't want to inherit the light disable from fire.gd
