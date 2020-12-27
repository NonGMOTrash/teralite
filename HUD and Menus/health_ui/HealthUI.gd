extends Control

onready var health = $health
onready var maxHealth = $maxHealth
onready var bonusHealth = $bonusHealth
onready var effect = $AnimationPlayer

var remHealth = 10
var remMaxHealth = 10
var remBonusHealth = 10

func _ready():
	global.connect("update_health", self, "main")
	main()
	effect.play("blue")
	visible = true

func main():
	if global.players_path == null: return
	var player = get_tree().current_scene.get_node_or_null(global.players_path)
	if player == null: return
	player = player.components["stats"]
	if player == null: return
	maxHealth.rect_size.x = 10 * player.MAX_HEALTH
	health.rect_size.x = 10 * player.HEALTH
	bonusHealth.rect_size.x = 10 * player.BONUS_HEALTH
	
	if remHealth != player.HEALTH || remBonusHealth != player.BONUS_HEALTH:
		effect.play("flash")
	remHealth = player.HEALTH
	remMaxHealth = player.MAX_HEALTH
	remBonusHealth = player.BONUS_HEALTH
