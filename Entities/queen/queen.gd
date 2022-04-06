extends Entity

const SLASH := preload("res://Entities/Attacks/Melee/slash/slash.tscn")
const ARROW := preload("res://Entities/Attacks/Projectile/arrow/arrow.tscn")
const BOLT := preload("res://Entities/Attacks/Projectile/bolt/bolt.tscn")
const SWORD_TEXTURE := preload("res://Entities/Item_Pickups/sword/sword.png")
const POTION_TEXTURE := preload("res://Entities/Item_Pickups/health_potion/health_potion.png")

export(float) var shoot_speed: float
export(float) var snipe_speed: float
export(int) var danger_threshold: int
export(int) var potions: int

var stored_attack: Attack
var stored_target: Entity
var stored_path: NodePath

onready var animation := $AnimationPlayer
onready var held_item := $held_item
onready var movement_lobe := $brain/movement_lobe
onready var stats := $stats

func _ready() -> void:
	held_item.animation.connect("animation_finished", self, "attack")

func _physics_process(delta: float) -> void:
	if input_vector == Vector2.ZERO:
		animation.play("stand")
	else:
		animation.play("walk")

func _on_action_lobe_action(action, target) -> void:
	if held_item.animation.is_playing() == true:
		return
	
	stored_target = target 
	stored_path = target.get_path()
	
	if action == "slash":
		stored_attack = SLASH.instance() as Melee
		held_item.sprite.texture = SWORD_TEXTURE
		held_item.sprite.hframes = 1
		held_item.sprite.vframes = 1
		held_item.sprite.frame = 0
		held_item.sprite.offset = Vector2(0, -4)
		held_item.original_offset = Vector2(0, -4)
		held_item.animation.play("warn")
		held_item.animation.queue("warn")
	elif action == "shoot":
		stored_attack = ARROW.instance() as Projectile
		held_item.animation.play("bow_charge")
		held_item.sprite.offset = Vector2(0, 0)
		held_item.original_offset = Vector2(0, 0)
	elif action == "snipe":
		stored_attack = BOLT.instance() as Projectile
		held_item.animation.play("xbow_charge")
		held_item.sprite.offset = Vector2(0, 0)
		held_item.original_offset = Vector2(0, 0)
		movement_lobe.general_springs["hostile"] = "space"
		ACCELERATION *= 0.5
	elif action == "heal" and stats.HEALTH < (stats.MAX_HEALTH * 0.8):
		held_item.animation.play("spin")
		held_item.sprite.offset = Vector2(0, 0)
		held_item.original_offset = Vector2(0, 0)
		held_item.sprite.texture = POTION_TEXTURE
		held_item.sprite.frame = 0
		held_item.sprite.hframes = 1
		held_item.sprite.vframes = 1
		movement_lobe.general_springs["hostile"] = "space"
		TOP_SPEED *= 0.1
		potions -= 1
		if potions <= 0:
			$brain/action_lobe/heal.queue_free()

func attack(finished_animation:String):
	if animation.get_queue().size() > 0 or get_node_or_null(stored_path) == null:
		return
	
	held_item.sprite.texture = null
	
	if finished_animation == "spin":
		stats.change_health(3, 0, "heal")
		TOP_SPEED *= 10
		return
	
	if stored_attack is Projectile:
		if stored_attack.truName == "arrow":
			stored_attack.SPEED = shoot_speed
		elif stored_attack.truName == "bolt":
			stored_attack.SPEED = snipe_speed
			movement_lobe.general_springs["hostile"] = "attack"
			ACCELERATION *= 2
		held_item.sprite.frame = 0
	
	if stored_attack.truName == "bolt":
		stored_attack.setup(self,
				stored_target.global_position + stored_target.velocity * get_physics_process_delta_time() * 15)
	elif is_instance_valid(stored_target):
		stored_attack.setup(self, stored_target.global_position)
	stored_attack.SOURCE_PATH = get_path()
	refs.ysort.add_child(stored_attack)
	yield(stored_attack, "tree_entered")
	stored_attack.global_position = global_position

func _on_stats_health_changed(type, result, net) -> void:
	if stats.HEALTH <= danger_threshold:
		movement_lobe.general_springs["hostile"] = "run"
	else:
		movement_lobe.general_springs["hostile"] = "attack"
