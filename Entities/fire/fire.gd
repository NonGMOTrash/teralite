extends Entity

export(PackedScene) var smoke_particle

onready var sprite = $Sprite
onready var animation = $animation
onready var spread = $spread
onready var hitbox = $hitbox
onready var detection = $detection
onready var fuel: Timer = $fuel
onready var light: Light2D = $light

var smoke: Particles2D

func _ready():
	sprite.scale = Vector2(1, 1)
	sprite.self_modulate.a = 1.0
	animation.playback_speed = rand_range(0.75, 1.25)
	
	smoke = smoke_particle.instance()
	refs.ysort.get_ref().call_deferred("add_child", smoke)
	yield(smoke, "ready")
	smoke.global_position = global_position

# toggle light visibility if other fires nearby
# checking this every frame is kinda bad, but it seems to be the only (?) way to reliablely get
# the light combining to work which improves preformance overall
func _physics_process(delta: float) -> void:
	if global.settings["lighting"] == false or global.settings["combine_lights"] == false:
		set_physics_process(false)
		return
	
	for detected_entity in detection.get_overlapping_bodies():
		if detected_entity.truName != "fire":
			continue
		elif detected_entity.get_instance_id() < get_instance_id():
			light.visible = false
			set_physics_process(false)
			return
	light.visible = true

func death():
	animation.play("death")
	
	# give light to nearby fire with highest id
	if not light or light.visible == false:
		return
	var highest_id: int = -1
	var highest_fire: Entity
	for detected_entity in detection.get_overlapping_bodies():
		if detected_entity.truName == "fire" and detected_entity.get_instance_id() > highest_id:
			highest_fire = detected_entity
			highest_id = detected_entity.get_instance_id()

func _on_fuel_timeout() -> void:
	death()

func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.get_parent() is Melee or area.get_parent().components["stats"] == null: return
	var modifier = area.get_parent().components["stats"].burning_modifier
	if modifier < 0 and abs(modifier) > hitbox.STATUS_LEVEL: return
	
	fuel.wait_time = fuel.time_left + 1.0
	fuel.start()

func _on_spread_timeout() -> void:
	var lowest_dist: float = 999.9
	var entity: Entity
	for detected_entity in detection.get_overlapping_bodies():
		if detected_entity.truName == "fire":
			continue
		elif global_position.distance_to(detected_entity.global_position) < lowest_dist:
			entity = detected_entity
	if entity == null:
		return
	
	var new_fire = duplicate()
	new_fire.global_position = global_position
	new_fire.velocity = global_position.direction_to(entity.global_position).normalized() * 125
	
	new_fire.find_node("fuel").wait_time = 1.0
	get_parent().call_deferred("add_child", new_fire)
	yield(new_fire, "ready")
	new_fire.fuel.start()

func _on_fire_tree_exited() -> void:
	smoke.queue_free()
