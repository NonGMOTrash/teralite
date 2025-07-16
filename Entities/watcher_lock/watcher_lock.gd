extends Entity

onready var animation := $AnimationPlayer
onready var sound_player := $sound_player
onready var cooldown := $cooldown
onready var detection: Area2D = $detection

var alive_entities: int = 0

func entity_died():
	alive_entities -= 1
	
	if alive_entities == 0:
		animation.play_backwards("rise")
		sound_player.play_sound("lower")

func _on_detection_body_entered(body) -> void:
	if (!body is Entity):
		return
	var entity: Entity = body as Entity
	
	if (
		entity.truName == "watcher_lock" or
		entity is Item or
		global.get_relation(refs.player, entity) != "hostile"
	):
		return
	
	var ss := get_world_2d().direct_space_state
	var ray := ss.intersect_ray(global_position, entity.global_position, [self], 1)
	if ray.size() != 0:
		return
	
	alive_entities += 1
	entity.connect("death", self, "entity_died")
	
	if (alive_entities == 1):
		animation.play("rise")
		sound_player.play_sound("rise")
