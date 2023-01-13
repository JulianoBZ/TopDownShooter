extends Area2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Ammo_pickup_body_entered(body):
	if body.is_in_group('player'):
		if body.get_node('Player').Preserve < (body.get_node('Player').Pammo_max * body.get_node('Player').clips) || body.get_node('Player').Sreserve < (body.get_node('Player').Sammo_max * body.get_node('Player').clips):
			body.get_node('Player').Preserve += body.get_node('Player').Pammo_max
			if body.get_node('Player').primary == 3:
				body.get_node('Player').Preserve += 4
			body.get_node('Player').Sreserve += body.get_node('Player').Sammo_max
			body.health += 30
			rpc("delete")

remotesync func delete():
	queue_free()
