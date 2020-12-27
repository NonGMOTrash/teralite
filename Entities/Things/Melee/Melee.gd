extends Thing
class_name Melee

var SOURCE_PATH = "string"

func _ready():
	global_position.move_toward(target_pos, abs(RANGE - 6))

func setup(new_source = Entity.new(), new_target_pos = Vector2.ZERO):
	# base Thing.gd setup
	SOURCE = new_source
	target_pos = new_target_pos
	faction = SOURCE.faction
	start_pos = SOURCE.global_position
	DIRECTION = start_pos.direction_to(target_pos).normalized()
	# Melee.gd setup
	SOURCE_PATH = SOURCE.get_path()

func _physics_process(_delta):
	if get_node_or_null(SOURCE_PATH) != null and SOURCE.is_queued_for_deletion() == false:
		global_position = SOURCE.global_position + RANGE * DIRECTION

func death():
	if components["hitbox"] != null: 
		hitbox.queue_free()
	if sprite_persist == false:
		queue_free()

func _on_collision_body_entered(body: Node) -> void:
	if visible == false: return
	if body.get_name() == "WorldTiles":
		queue_free()

func _on_hitbox_area_entered(area: Area2D) -> void:
	if visible == false: return
	if global.get_relation(self, area.get_parent()) == "friendly": return
	if "ONHIT_SELF_DAMAGE" in area.get_parent(): return
	stats.change_health(0, -(ONHIT_SELF_DAMAGE))
