extends Control

onready var health = $health
onready var maxHealth = $max_health
onready var bonusHealth = $bonus_health
onready var maxArmor = $max_armor
onready var armor = $armor
onready var effect = $AnimationPlayer

var remHealth = 10
var remMaxHealth = 10
var remBonusHealth = 10

func _ready():
	refs.health_ui = weakref(self)
	global.connect("update_health", self, "update")
	update()
	effect.play("blue")
	visible = true

func update():
	if refs.player.get_ref() == null: return
	var player = refs.player.get_ref()
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
