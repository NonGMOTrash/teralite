extends Node

const SPAWNER = preload("res://Components/spawner/spawner.tscn")
const HIT_EFFECT = preload("res://Effects/hit_effect/hit_effect.tscn")
const DISSOLVE_FADE = preload("res://Effects/dissolve_fade/dissolve_fade.tscn")
const FLIP_FADE = preload("res://Effects/flip_fade/flip_fade.tscn")
const LEFT_FADE = preload("res://Effects/left_fade/left_fade.tscn")
const RIGHT_FADE = preload("res://Effects/right_fade/right_fade.tscn")
const SPIN_FADE = preload("res://Effects/spin_fade/spin_fade.tscn")
const SQUISH_FADE = preload("res://Effects/squish_fade/squish_fade.tscn")
const TRIPLE_SHRINK = preload("res://Effects/triple_shrink/triple_shrink.tscn")
const WIGGLE_FADE = preload("res://Effects/wiggle_fade/wiggle_fade.tscn")
const BLOCK_SPARK = preload("res://Effects/blocked_spark/blocked_spark.tscn")
const HIT_PARTICLES = preload("res://Effects/Particles/hit_particles.tscn")

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

func _ready():
	if hit_effect == true:
		var spawner = SPAWNER.instance()
		spawner.thing = HIT_EFFECT
		spawner.spawn_on_free = false
		spawner.spawn_on_hurt = true
		spawner.effect_hframes = 3
		spawner.effect_vframes = 3
		get_parent().call_deferred("add_child", spawner)
	
	if death_effect == true:
		var spawner = SPAWNER.instance()
		
		match death_type:
			DEATHS.HIT_EFFECT: 
				spawner.thing = HIT_EFFECT
				spawner.effect_hframes = 3
				spawner.effect_vframes = 3
			DEATHS.DISSOVE_FADE: spawner.thing = DISSOLVE_FADE
			DEATHS.FLIP_FADE: spawner.thing = FLIP_FADE
			DEATHS.LEFT_FADE: spawner.thing = LEFT_FADE
			DEATHS.RIGHT_FADE: spawner.thing = RIGHT_FADE
			DEATHS.SPIN_FADE: spawner.thing = SPIN_FADE
			DEATHS.SQUISH_FADE: spawner.thing = SQUISH_FADE
			DEATHS.TRIPLE_SHRINK: spawner.thing = TRIPLE_SHRINK
			DEATHS.WIGGLE_FADE: spawner.thing = WIGGLE_FADE
		
		var sprite: Sprite = get_parent().components["entity_sprite"]
		spawner.effect_texture = sprite.texture
		spawner.effect_hframes = sprite.hframes
		spawner.effect_vframes = sprite.vframes
		
		get_parent().call_deferred("add_child", spawner)
	
	if block_effect == true:
		var spawner = SPAWNER.instance()
		spawner.spawn_on_free = false
		spawner.spawn_on_block = true
		spawner.thing = BLOCK_SPARK
		spawner.rotate_away_from_me = true
		get_parent().call_deferred("add_child", spawner)
	
	if impact_particles == true:
		var spawner = SPAWNER.instance()
		spawner.spawn_on_hurt = true
		spawner.thing = HIT_PARTICLES
		get_parent().call_deferred("add_child", spawner)