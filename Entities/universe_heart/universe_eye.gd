extends Entity

const BERSERKER := preload("res://Entities/berserker/berserker.tscn")
const CHASER := preload("res://Entities/chaser/chaser.tscn")
const GOLD_HEART := preload("res://Entities/Item_Pickups/gold_heart/gold_heart.tscn")
const WITCH := preload("res://Entities/witch/witch.tscn")
const MAGE := preload("res://Entities/archer/mage/mage.tscn")
const ZOMBIE := preload("res://Entities/zombie/zombie.tscn")
const ARCHER := preload("res://Entities/archer/archer.tscn")

export var pull_strength_init: float = 5.0
export var pull_strength_growth: float = 0.5
export var pull_strength_player_mult: float = 0.5
export var max_entites: int = 50

onready var spawn_timer: Timer = $spawn_timer
onready var pull_strength: float = pull_strength_init

var entity_count: int = 0

func _physics_process(delta: float) -> void:
	var entities: Array = get_tree().get_nodes_in_group("entity")
	entity_count = entities.size()
	for entity in entities:
		entity = entity as Entity
		if entity == self or entity.STATIC:
			continue
		elif entity is Item and entity.global_position.distance_to(global_position) <= 5:
			entity.queue_free()
		else:
			var modifier: float = 1
			if entity.truName == "player":
				modifier = pull_strength_player_mult
			
			entity.apply_force(
				entity.global_position.direction_to(global_position).normalized()
				* pull_strength * modifier
			)
	
	pull_strength += delta * pull_strength_growth

func _on_spawn_timer_timeout() -> void:
	if entity_count < max_entites:
		var entity: Entity
		match randi() % 6:
			0: entity = BERSERKER.instance()
			1: entity = CHASER.instance()
			2: entity = GOLD_HEART.instance()
			3: entity = WITCH.instance()
			4: entity = MAGE.instance()
			5: entity = ZOMBIE.instance()
			6: entity = ARCHER.instance()
		while true:
			entity.position = global_position + Vector2(rand_range(-1, 1), rand_range(-1, 1)) * 500
			
			var near_player: bool = false
			if is_instance_valid(refs.player):
				if entity.position.distance_to(refs.player.global_position) < 60:
					near_player = true
				elif global_position.direction_to(entity.position).dot( refs.player.global_position.direction_to(entity.position) ) > 0.8:
					near_player = true
			
			if (
				entity.position.x > 1000 or entity.position.x < 0 or
				entity.position.y > 1000 or entity.position.y < 0 or
				near_player
			):
				continue
			else:
				break
		
		refs.ysort.add_child(entity)
		
	spawn_timer.wait_time = 7.0 / pull_strength
	spawn_timer.start()

func death():
	$AnimationPlayer.play("death")

func death_real():
	for entity in get_tree().get_nodes_in_group("entities"):
		entity = entity as Entity
		if entity.truName != "player":
			entity.death()
	.death()
