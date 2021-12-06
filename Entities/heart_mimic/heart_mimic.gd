extends Entity

onready var animation: AnimationPlayer = $AnimationPlayer
onready var movement_lobe: Node2D = $brain/movement_lobe
onready var sprite: Sprite = $entity_sprite
onready var brain: Node2D = $brain

var original_top_speed: int
var has_awoken := false

func _ready() -> void:
	original_top_speed = TOP_SPEED
	TOP_SPEED = 0

func _on_detection_body_entered(body: Node) -> void:
	if body is Entity and not body.INANIMATE and not body == self and not body.INVISIBLE and not has_awoken:
		animation.play("awaken")

func _on_hurtbox_got_hit(_by_area, _type) -> void:
	if not has_awoken:
		animation.play("awaken")

func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	if anim_name == "awaken":
		has_awoken = true
		animation.play("run")
		TOP_SPEED = original_top_speed
		INVISIBLE = false
		sprite.auto_flip_mode = sprite.AFM.TARGET

func _on_brain_found_target() -> void:
	var newest_target: Entity = brain.targets[brain.targets.size()-1]
	if newest_target.truName == "heart_mimic":
		marked_allies.append(newest_target)
		prints(get_name(), "added", newest_target.get_name())
