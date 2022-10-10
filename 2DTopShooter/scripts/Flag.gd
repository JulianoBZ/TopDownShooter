extends Area2D

var follow = 0
var carrier
#onready var carrier_alive

func _on_Flag_body_entered(body):
	if body.is_in_group("player"):
		carrier = body
		print(carrier)
		follow = 1
		#carrier_alive = carrier.alive

func _on_PlayerAll_death():
	#carrier_alive = false
	follow = 0

func _process(delta):
	if follow == 1 && is_instance_valid(carrier):
		position = carrier.position


