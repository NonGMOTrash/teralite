extends Entity

onready var detection: Area2D = $detection
onready var animation: AnimationPlayer = $AnimationPlayer

var players := []

func _on_detection_body_entered(body: Node) -> void:
	if body.truName == "player":
		players.append(body)

func _on_detection_body_exited(body: Node) -> void:
	var i: int = players.find(body)
	if i != -1:
		players.remove(i)

func _physics_process(delta: float) -> void:
	for player in players:
		print(player.get_speed())
		if player.get_speed() > 100.0:
			print("lowering!")
			animation.play("spikes")

