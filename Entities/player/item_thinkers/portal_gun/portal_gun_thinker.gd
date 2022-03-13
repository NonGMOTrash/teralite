extends Thinker

const PORTAL := preload("res://Entities/portal/portal.tscn")
const PORTAL_RAY := preload("res://Entities/Attacks/Projectile/portal_ray/portal_ray.tscn")
const BLUE_RAY_TEXTURE := preload("res://Entities/Attacks/Projectile/portal_ray/portal_ray_blue.png")

onready var portals: Entity = PORTAL.instance()
var blue_ray: Projectile
var orange_ray: Projectile

func _ready() -> void:
	portals.global_position = Vector2(-999, -999)
	refs.ysort.add_child(portals)

func primary():
	if is_instance_valid(blue_ray):
		return
	
	blue_ray = PORTAL_RAY.instance()
	blue_ray.setup(player, player.get_global_mouse_position())
	blue_ray.connect("tree_exiting", self, "make_blue_portal")
	refs.ysort.add_child(blue_ray)
	# it's orange by default so i only change the texture for blue
	blue_ray.find_node("entity_sprite").texture = BLUE_RAY_TEXTURE

func make_blue_portal():
	portals.blue_portal.global_position = blue_ray.old_pos.move_toward(blue_ray.start_pos, 5)

func secondary():
	if is_instance_valid(orange_ray):
		return
	
	orange_ray = PORTAL_RAY.instance()
	orange_ray.setup(player, player.get_global_mouse_position())
	orange_ray.connect("tree_exiting", self, "make_orange_portal")
	refs.ysort.add_child(orange_ray)

func make_orange_portal():
	portals.orange_portal.global_position = orange_ray.old_pos.move_toward(orange_ray.start_pos, 5)
