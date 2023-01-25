extends Area2D

var follow = 0
var carrier
var team = 2
#onready var carrier_alive

func _ready():
	print(team)
	if str(name) == "RedFlag":
		team = 0
		modulate = "CC0000"
	if str(name) == "BlueFlag":
		team = 1
		modulate = "000099"

func _on_Flag_body_entered(body):
	if body.is_in_group("player") && body.alive == true && body.RB != team:
		carrier = body
		print(carrier)
		follow = 1
		#carrier_alive = carrier.alive

func _on_PlayerAll_death():
	#carrier_alive = false
	follow = 0

func _process(_delta):
	if follow == 1 && is_instance_valid(carrier):
		position = carrier.position
		if carrier.alive == false:
			follow = 0
	if follow == 0:
		follow = 2
		$Timer.start()


func _on_Timer_timeout():
	if team == 0:
		position = $FlagRed.position
	if team == 1:
		position = $FlagBlue.position
