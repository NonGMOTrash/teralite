extends Area2D

export var strength = 14

onready var entity = get_parent()
onready var timer = $Timer

func _on_entity_push_tree_entered():
	get_parent().components["entity_push"] = self

func _ready() -> void:
	if $CollisionShape2D.shape == null:
		push_error("entity_push has no shape")
	
	if entity.get_name() == "YSort": 
		queue_free()
		return
	timer.start()

func push():
	var bodies := get_overlapping_bodies()
	if bodies == []:
		return
	
	var body: Entity = bodies[rand_range(0, get_overlapping_bodies().size()-1)]
	if body == entity or body.STATIC == true:
		return
	if body.components["sleeper"] != null and body.components["sleeper"].active == false:
		return
		
	var force := Vector2.ZERO
	var dir := global_position.direction_to(body.global_position).normalized()
	if dir == Vector2.ZERO:
		dir = Vector2(rand_range(-1.0, 1.0), rand_range(-1.0, 1.0)).normalized()
	var powr = clamp(strength - global_position.distance_to(body.global_position), 0, strength)
	if powr < strength / 2:
		return
	
	force = dir * -(powr)
	entity.apply_force(force)

func _on_Timer_timeout() -> void: 
	push()
	
	if get_overlapping_bodies().size() == 0: 
		timer.wait_time = rand_range(1.0, 3.0)
		return
	
	timer.wait_time = 0.1 #/ (get_overlapping_bodies().size() + 1)
