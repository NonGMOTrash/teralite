extends "res://Entities/spikes/red_spikes/red_spikes.gd"

var active := false
var entities := []

func _ready():
	animation.play("spikes")
	active = true

func _on_activation_area_entered(area: Area2D) -> void:
	var area_entity := area.get_parent() as Entity
	entities.append(area_entity)
	if name == "royal_spikes": print("added %s" % area_entity.get_name())
	
	if area_entity.faction == "blue_kingdom":
		if active == true:
			animation.play_backwards("spikes")
			active = false
			if name == "royal_spikes": print("lowering")
	else:
		if active == false:
			if active == false:
				for entity in entities:
					if entity.faction == "blue_kingdom":
						return
				animation.play("spikes")
				active = true
				if name == "royal_spikes": print("raising")

func _on_activation_area_exited(area: Area2D) -> void:
	var area_entity := area.get_parent() as Entity
	entities.remove(entities.find(area_entity))
	if name == "royal_spikes":
		print("removed %s, dist = %s" % [area_entity.get_name(), area_entity.global_position.distance_to(global_position)])
		if area_entity.get_name() == "knight": pass#breakpoint
	if active == true:
		return
	
	for entity in entities:
		if entity.faction == "blue_kingdom":
			return
	
	animation.play("spikes")
	active = true
	if name == "royal_spikes": print("raising")
