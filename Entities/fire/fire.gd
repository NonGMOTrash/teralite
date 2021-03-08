extends Entity

onready var sprite = $Sprite
onready var fuel = $fuel
onready var spread = $spread
onready var hitbox = $hitbox

func _ready():
	sprite.scale = Vector2(1, 1)
	sprite.self_modulate.a = 1.0
	$fire.playback_speed = rand_range(0.75, 1.25)

func death():
	$death.play("death")

func _on_fuel_timeout() -> void:
	death()

func _on_hitbox_area_entered(area: Area2D) -> void:
#	match area.get_parent().truName:
#		"Timber_Pot": 
#			# this is a dumb way of having the timber_pot relite, it should be done in it's script
#			# instead so it can detect from any fire source, but idk how to find if a status effect 
#			# is added. i might need to make some new signals or something
#			area.get_parent().find_node("fuel").wait_time += 15.0
#			area.get_parent().find_node("fuel").start()
#			area.get_parent().find_node("spread").start()
#			area.get_parent().find_node("Sprite").visible = true
#			return
#		"Bullet": return
#		"Slash": return
	if area.get_parent() is Melee or area.get_parent().components["stats"] == null: return
	var modifier = area.get_parent().components["stats"].modifiers["burning"]
	if modifier < 0 and abs(modifier) > hitbox.STATUS_EFFECT_LEVEL: return
	
	fuel.wait_time = fuel.time_left + 6.5
	fuel.start()

func _on_spread_timeout() -> void:
	if fuel.time_left < 4: return
	
	var new_fire = global.aquire("Fire")
	new_fire.global_position = global_position
	new_fire.velocity = Vector2(rand_range(-1, 1), rand_range(-1, 1)).normalized() * 125
	
	new_fire.find_node("fuel").wait_time = 1.0
	get_parent().call_deferred("add_child", new_fire)
