extends Area2D

onready var brain = get_parent()
onready var entity = brain.get_parent()
onready var warning_shape = $warning/CollisionShape2D

export(float, 0, 200) var WARNING_RANGE = 50

func _on_warning_lobe_tree_entered():
	get_parent().warning_lobe = self
	if get_parent().get_parent() is Entity:
		get_parent().get_parent().components["warning_lobe"] = self

func _ready() -> void:
	warning_shape.shape.radius = WARNING_RANGE

func _on_warning_lobe_area_entered(area: Area2D) -> void:
	if global.get_relation(entity, area.get_parent()) == "friendly": return
	if brain.action_lobe == null: return
	brain.action_lobe.act(true)
