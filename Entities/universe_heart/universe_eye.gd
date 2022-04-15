extends Entity

const BERSERKER := preload("res://Entities/berserker/berserker.tscn")
const CHASER := preload("res://Entities/chaser/chaser.tscn")
const GOLD_HEART := preload("res://Entities/Item_Pickups/gold_heart/gold_heart.tscn")
const WITCH := preload("res://Entities/witch/witch.tscn")
const MAGE := preload("res://Entities/archer/mage/mage.tscn")
const ZOMBIE := preload("res://Entities/zombie/zombie.tscn")
const ARCHER := preload("res://Entities/archer/archer.tscn")

var pull_strength: float = 5.0

onready var spawn_timer: Timer = $spawn_timer

func _physics_process(delta: float) -> void:
	var entities: Array = get_tree().get_nodes_in_group("entity")
	for entity in entities:
		entity = entity as Entity
		if entity == self or entity.STATIC:
			continue
		else:
			entity.apply_force(
				entity.global_position.direction_to(global_position).normalized() * pull_strength)
	
	pull_strength += 0.01

func _on_spawn_timer_timeout() -> void:
	var entity: Entity
	match randi() % 6:
		0: entity = BERSERKER.instance()
		1: entity = CHASER.instance()
		2: entity = GOLD_HEART.instance()
		3: entity = WITCH.instance()
		4: entity = MAGE.instance()
		5: entity = ZOMBIE.instance()
		6: entity = ARCHER.instance()
	entity.position = global_position + Vector2(rand_range(-1, 1), rand_range(-1, 1)) * 500
	refs.ysort.add_child(entity)
	
	spawn_timer.wait_time = 8.0 / pull_strength
	spawn_timer.start()

func death():
	$AnimationPlayer.play("death")

func death_real():
	for entity in get_tree().get_nodes_in_group("entities"):
		entity = entity as Entity
		if entity.truName != "player":
			entity.death()
	.death()
