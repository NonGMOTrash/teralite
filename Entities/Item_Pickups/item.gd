extends Entity
class_name Item

const ITEM_PICKUP_EFFECT = preload("res://Effects/item_pickup_effect/item_pickup_effect.tscn")

enum item_types {
	ACTIVE,
	PASSIVE,
	POWERUP
}

export(item_types) var type = item_types.ACTIVE
export(PackedScene) var thinker
export(AudioStream) var pickup_sound
export(bool) var player_only := true
var SOURCE

var the_body = null
var the_body_used = false

func _init():
	if type != item_types.POWERUP:
		assert(player_only == true)

func _on_Area2D_body_entered(body: Node) -> void:
	if (
		body == SOURCE or
		body == self or
		body is Attack or
		body.truName != "player" and player_only == true
	): 
		return
	
	if the_body == null: the_body = body
	
	if body != the_body: return
	if the_body_used == true: return
	
	the_body_used = true
	
	if pickup_sound != null:
		$sound_player.create_sound(pickup_sound, true, Sound.MODES.ONESHOT, true, true)
	
	var effect = ITEM_PICKUP_EFFECT.instance()
	effect.global_position = global_position
	get_parent().call_deferred("add_child", effect)
	
	match type:
		item_types.POWERUP:
			on_pickup(body)
			return
		
		item_types.ACTIVE:
			var x = 0
			
			if body.inventory[2] == null: x = 2
			if body.inventory[1] == null: x = 1
			if body.inventory[0] == null: x = 0
			if body.inventory[global.selection] == null: x = global.selection
			
			if body.inventory[x] != null:
				velocity = global_position.direction_to(global_position + Vector2(rand_range(-1, 1), rand_range(-1, 1))) * 125
				set_physics_process(true)
				return
			else:
				body.inventory[x] = truName
				global.update_cursor()
				if thinker == null && type != item_types.POWERUP:
					push_warning("item was not given a thinker")
				else:
					body.call_deferred("add_child", thinker.instance())
			
		item_types.PASSIVE:
			var x = 3
			
			if body.inventory[5] == null: x = 5
			if body.inventory[4] == null: x = 4
			if body.inventory[3] == null: x = 3
			if body.inventory[3] != null && body.inventory[1] != null && body.inventory[4] != null:
				if body.inventory[5] != truName: x = 5
				if body.inventory[4] != truName:x = 4
				if body.inventory[3] != truName:x = 3
			if body.inventory[x] != null:
				velocity = global_position.direction_to(global_position + Vector2(rand_range(-1, 1), rand_range(-1, 1))) * 125
				set_physics_process(true)
				return
			
			body.inventory[x] = truName
			if thinker != null: body.call_deferred("add_child", thinker.instance())
			if body.get_name() == "player":
				global.emit_signal("update_item_bar", body.inventory)
	
	on_pickup(body)
	
	queue_free()

func on_pickup(player): pass

func _on_Area2D_body_exited(body: Node) -> void:
	if body == SOURCE:
		SOURCE = null
	if body == the_body:
		the_body = null
		the_body_used = false
