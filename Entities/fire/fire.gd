extends Entity

export(PackedScene) var smoke_particle

onready var sprite = $Sprite
onready var fuel = $fuel
onready var spread = $spread
onready var hitbox = $hitbox

var smoke: Particles2D

func _ready():
	sprite.scale = Vector2(1, 1)
	sprite.self_modulate.a = 1.0
	$fire.playback_speed = rand_range(0.75, 1.25)
	
	smoke = smoke_particle.instance()
	global.nodes["ysort"].call_deferred("add_child", smoke)
	yield(smoke, "ready")
	smoke.global_position = global_position

func death():
	print("!")
	if smoke != null:
		smoke.stop()
	$death.play("death")

func _on_fuel_timeout() -> void:
	death()

func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.get_parent() is Melee or area.get_parent().components["stats"] == null: return
	var modifier = area.get_parent().components["stats"].modifiers["burning"]
	if modifier < 0 and abs(modifier) > hitbox.STATUS_LEVEL: return
	
	fuel.wait_time = fuel.time_left + 6.5
	fuel.start()
	print(fuel.wait_time)

func _on_spread_timeout() -> void:
	if fuel.time_left < 4: return
	
	var new_fire = self.duplicate()
	new_fire.global_position = global_position
	new_fire.velocity = Vector2(rand_range(-1, 1), rand_range(-1, 1)).normalized() * 125
	
	new_fire.find_node("fuel").wait_time = 1.0
	get_parent().call_deferred("add_child", new_fire)
