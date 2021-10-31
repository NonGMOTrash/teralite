extends Entity

export var ressurect_delay: float

onready var ressurect := $ressurrect
onready var animation := $AnimationPlayer

func _ready() -> void:
	ressurect.wait_time = ressurect_delay
	ressurect.start()

func _on_ressurrect_timeout() -> void:
	animation.play("ressurect")

func ressurect():
	# remove spawners to prevent death effect
	for child in get_children():
		if "spawner" in child.name:
			child.queue_free()
	
	var skeleton: Entity = res.aquire_entity("skeleton")
	skeleton.global_position = global_position
	refs.ysort.get_ref().add_child(skeleton)
	queue_free()
