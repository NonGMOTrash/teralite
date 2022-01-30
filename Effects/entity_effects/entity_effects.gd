extends Node

var CACHE = [
	load("res://Components/spawner/spawner.tscn"),
	load("res://Effects/dissolve_fade/dissolve_fade.tscn"),
	load("res://Effects/flip_fade/flip_fade.tscn"),
	load("res://Effects/left_fade/left_fade.tscn"),
	load("res://Effects/right_fade/right_fade.tscn"),
	load("res://Effects/spin_fade/spin_fade.tscn"),
	load("res://Effects/squish_fade/squish_fade.tscn"),
	load("res://Effects/triple_shrink/triple_shrink.tscn"),
	load("res://Effects/wiggle_fade/wiggle_fade.tscn"),
	load("res://Effects/hit_effect/hit_effect.tscn"),
	load("res://Effects/Particles/hit_particles.tscn"),
	load("res://Effects/block_spark/block_spark.tscn"),
]

enum DEATHS {
	HIT_EFFECT = -1,
	DISSOVE_FADE,
	FLIP_FADE,
	LEFT_FADE,
	RIGHT_FADE,
	SPIN_FADE,
	SQUISH_FADE,
	TRIPLE_SHRINK,
	WIGGLE_FADE
}

export var hit_effect = true
export var death_effect = true
export(DEATHS) var death_type = DEATHS.LEFT_FADE
export var block_effect = true
export var impact_particles = true

onready var entity: Entity = get_parent()

func _ready():
	if hit_effect == true:
		var spawner = load("res://Components/spawner/spawner.tscn").instance()
		spawner.thing = load("res://Effects/hit_effect/hit_effect.tscn")
		spawner.spawn_on_free = false
		spawner.spawn_on_hurt = true
		spawner.effect_frames = Vector2(5, 1)
		entity.call_deferred("add_child", spawner)
	
	if death_effect == true:
		var spawner = load("res://Components/spawner/spawner.tscn").instance()
		
		match death_type:
			DEATHS.HIT_EFFECT: 
				spawner.thing = load("res://Effects/hit_effect/hit_effect.tscn")
				spawner.effect_frames = Vector2(5, 1)
			DEATHS.DISSOVE_FADE: spawner.thing = load("res://Effects/dissolve_fade/dissolve_fade.tscn")
			DEATHS.FLIP_FADE: spawner.thing = load("res://Effects/flip_fade/flip_fade.tscn")
			DEATHS.LEFT_FADE: spawner.thing = load("res://Effects/left_fade/left_fade.tscn")
			DEATHS.RIGHT_FADE: spawner.thing = load("res://Effects/right_fade/right_fade.tscn")
			DEATHS.SPIN_FADE: spawner.thing = load("res://Effects/spin_fade/spin_fade.tscn")
			DEATHS.SQUISH_FADE: spawner.thing = load("res://Effects/squish_fade/squish_fade.tscn")
			DEATHS.TRIPLE_SHRINK: spawner.thing = load("res://Effects/triple_shrink/triple_shrink.tscn")
			DEATHS.WIGGLE_FADE: spawner.thing = load("res://Effects/wiggle_fade/wiggle_fade.tscn")
			_: push_error("%s is not a valid death_type" % death_type)
		
		if death_type != DEATHS.HIT_EFFECT:
			
			spawner.effect_inherit_texture = true
			var sprite: Sprite = entity.components["entity_sprite"]
			spawner.effect_frames = Vector2(sprite.hframes, sprite.vframes)
			
			if sprite.modulate != Color8(255, 255, 255, 255):
				spawner.use_modulate = true
				spawner.modulate = sprite.modulate
			elif sprite.self_modulate != Color8(255, 255, 255, 255):
				spawner.use_modulate = true
				spawner.modulate = sprite.self_modulate
		
		entity.call_deferred("add_child", spawner)
	
	if block_effect == true:
		var spawner = load("res://Components/spawner/spawner.tscn").instance()
		spawner.spawn_on_free = false
		spawner.spawn_on_block = true
		spawner.thing = load("res://Effects/block_spark/block_spark.tscn")
		spawner.rotation_mode = spawner.ROTATIONS.TOWARD_HITBOX
		spawner.effect_frames = Vector2(4, 1)
		entity.call_deferred("add_child", spawner)
	
	if impact_particles == true:
		var spawner = load("res://Components/spawner/spawner.tscn").instance()
		spawner.spawn_on_hurt = true
		spawner.thing = load("res://Effects/Particles/hit_particles.tscn")
		entity.call_deferred("add_child", spawner)
	
	queue_free()
