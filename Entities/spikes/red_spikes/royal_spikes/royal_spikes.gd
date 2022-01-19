extends "res://Entities/spikes/red_spikes/red_spikes.gd"

var active := false
var entities := []

func _ready():
	animation.play("spikes")
	active = true

func _on_activation_area_entered(area: Area2D) -> void:
	var area_entity := area.get_parent() as Entity
	entities.append(area_entity)
	
	if area_entity.faction == "blue_kingdom":
		if active == true:
			animation.play_backwards("spikes")
			active = false
	else:
		if active == false:
			if active == false:
				for entity in entities:
					if entity.faction == "blue_kingdom":
						return
				animation.play("spikes")
				active = true

func _on_activation_area_exited(area: Area2D) -> void:
	var area_entity := area.get_parent() as Entity
	entities.remove(entities.find(area_entity))
	if active == true:
		return
	
	for entity in entities:
		if entity.faction == "blue_kingdom":
			return
	
	animation.play("spikes")
	active = true
