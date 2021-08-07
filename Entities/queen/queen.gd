extends Entity

const SWORD_TEXTURE := preload("res://Entities/Item_Pickups/sword/sword.png")
#const XBOW_TEXTURE := preload("res://Entities/Item_Pickups/xbow/xbow.png")

export(float) var shoot_speed: float
export(float) var snipe_speed: float

var stored_attack: Attack
var stored_target: Entity
var stored_path: NodePath
var original_dist_min: int
var original_dist_max: int

onready var animation := $AnimationPlayer
onready var held_item := $held_item
onready var movement_spring := $brain/movement_lobe/spring

func _init() -> void:
	res.allocate("slash")
	res.allocate("arrow")

func _ready() -> void:
	held_item.animation.connect("animation_finished", self, "attack")
	original_dist_max = movement_spring.DISTANCE_MAX
	original_dist_min = movement_spring.DISTANCE_MIN

func _on_action_lobe_action(action, target) -> void:
	if held_item.animation.is_playing() == true:
		return
	
	stored_target = target 
	stored_path = target.get_path()
	
	if action == "slash":
		stored_attack = res.aquire_melee("slash")
		held_item.sprite.texture = SWORD_TEXTURE
		held_item.sprite.hframes = 1
		held_item.sprite.vframes = 1
		held_item.sprite.frame = 0
		held_item.sprite.offset = Vector2(0, -4)
		held_item.original_offset = Vector2(0, -4)
		held_item.animation.play("warn")
		held_item.animation.queue("warn")
	elif action == "shoot":
		stored_attack = res.aquire_projectile("arrow") 
		held_item.animation.play("bow_charge")
		held_item.sprite.offset = Vector2(0, 0)
		held_item.original_offset = Vector2(0, 0)
	elif action == "snipe":
		stored_attack = res.aquire_projectile("bolt")
		held_item.animation.play("xbow_charge")
		held_item.sprite.offset = Vector2(0, 0)
		held_item.original_offset = Vector2(0, 0)
		movement_spring.DISTANCE_MIN = 100
		movement_spring.DISTANCE_MAX = 150
		ACCELERATION *= 0.5

func attack(_finished_animation:String):
	if animation.get_queue().size() > 0 or get_node_or_null(stored_path) == null:
		return
	
	if stored_attack is Projectile:
		if stored_attack.truName == "arrow":
			stored_attack.SPEED = shoot_speed
		elif stored_attack.truName == "bolt":
			stored_attack.SPEED = snipe_speed
			movement_spring.DISTANCE_MIN = original_dist_min
			movement_spring.DISTANCE_MAX = original_dist_max
			ACCELERATION *= 2
		held_item.sprite.frame = 0
	
	if stored_attack.truName == "bolt":
		stored_attack.setup(self,
				stored_target.global_position + stored_target.velocity * get_physics_process_delta_time() * 15)
	else:
		stored_attack.setup(self, stored_target.global_position)
	stored_attack.SOURCE_PATH = get_path()
	refs.ysort.get_ref().add_child(stored_attack)
	yield(stored_attack, "tree_entered")
	stored_attack.global_position = global_position

