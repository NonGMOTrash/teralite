extends Control

onready var health = $health
onready var maxHealth = $maxHealth
onready var bonusHealth = $bonusHealth
onready var maxArmor = $maxArmor
onready var armor = $armor
onready var effect = $AnimationPlayer

var remHealth = 10
var remMaxHealth = 10
var remBonusHealth = 10

func _ready():
	global.nodes["health_ui"] = self
	global.connect("update_health", self, "update")
	update()
	effect.play("blue")
	visible = true

func update():
	if global.nodes["player"] == null: return
	var player = get_tree().current_scene.get_node_or_null(global.nodes["player"])
	if player == null: return
	player = player.components["stats"]
	if player == null: return
	maxHealth.rect_size.x = 10 * player.MAX_HEALTH
	health.rect_size.x = 10 * player.HEALTH
	bonusHealth.rect_size.x = 10 * player.BONUS_HEALTH
	maxArmor.rect_size.x = 10 * player.DEFENCE
	armor.rect_size.x = 10 * player.armor
	if player.BONUS_HEALTH == 0:
		maxArmor.margin_top = 14
		armor.margin_top = 14
		maxArmor.rect_size.y = 19
		armor.rect_size.y = 19
	else:
		maxArmor.margin_top = 19
		armor.margin_top = 19
	
	if remHealth != player.HEALTH || remBonusHealth != player.BONUS_HEALTH:
		effect.play("flash")
	remHealth = player.HEALTH
	remMaxHealth = player.MAX_HEALTH
	remBonusHealth = player.BONUS_HEALTH
