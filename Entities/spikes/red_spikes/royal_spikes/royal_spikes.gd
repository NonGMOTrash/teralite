extends "res://Entities/spikes/red_spikes/red_spikes.gd"

var active := false
var entities := []

func _ready():
	animation.play("spikes")
	active = true

func _on_activation_body_entered(body: Node) -> void:
	var entity := body as Entity
	entities.append(body)
	
	if entity.faction == "blue_kingdom":
		if active == true:
			animation.play_backwards("spikes")
			active = false
	else:
		if active == false:
			if active == false:
				for e in entities:
					if e.faction == "blue_kingdom":
						return
				animation.play("spikes")
				active = true

func _on_activation_body_exited(body: Node) -> void:
	var entity := body as Entity
	entities.remove(entities.find(entity))
	if active == true:
		return
	
	for e in entities:
		if e.faction == "blue_kingdom":
			return
	
	animation.play("spikes")
	active = true
