extends Entity

onready var blue_portal := $blue_portal
onready var orange_portal := $orange_portal

var blacklist := []

func _on_blue_portal_body_entered(body: Node) -> void:
	if body.get_instance_id() in blacklist:
		return
	
	body.global_position = orange_portal.global_position
	blacklist.append(body.get_instance_id())
	
	if body is Projectile:
		body.RANGE += blue_portal.global_position.distance_to(orange_portal.global_position)

func _on_link_b_body_entered(body: Node) -> void:
	if body.get_instance_id() in blacklist:
		return
	
	body.global_position = blue_portal.global_position
	blacklist.append(body.get_instance_id())

	if body is Projectile:
		body.RANGE += blue_portal.global_position.distance_to(orange_portal.global_position)

func _on_link_a_body_exited(body: Node) -> void:
	var i := blacklist.find(body.get_instance_id())
	if i != -1:
		blacklist.remove(i)

func _on_link_b_body_exited(body: Node) -> void:
	var i := blacklist.find(body.get_instance_id())
	if i != -1:
		blacklist.remove(i)
