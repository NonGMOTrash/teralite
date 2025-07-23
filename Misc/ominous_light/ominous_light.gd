extends LightSource

var original_energy: float

onready var sfx: Sound = $Sound

func _ready() -> void:
	original_energy = energy
	energy = 0

func _on_Area2D_body_entered(body):
	if energy == original_energy:
		return
	
	if body is Entity and body.truName == "player":
		energy = original_energy
		sfx.play()
