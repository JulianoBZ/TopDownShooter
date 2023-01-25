extends Area2D

var follow = 0
var carrier
var team = 2
var origin = Vector2()
var v = 0
#onready var carrier_alive

func _ready():
	if str(name) == "RedFlag":
		team = 0
		$Sprite.modulate = "CC0000"
	if str(name) == "BlueFlag":
		team = 1
		$Sprite.modulate = "000099"

func _on_Flag_body_entered(body):
	if body.is_in_group("player") && body.alive == true && body.RB != team:
		carrier = body
		follow = 1

func _on_PlayerAll_death():
	#carrier_alive = false
	follow = 0

func _process(_delta):
	if global_position == origin:
		$TimeLabel.visible = false
	if follow == 1 && is_instance_valid(carrier):
		rpc("is_carried",follow)
		$TimeLabel.visible = false
		position = carrier.position
		$Timer.stop()
		$Timer.wait_time = 20
		if carrier.alive == false:
			follow = 0
			v = 0
	if follow == 0 && global_position != origin && v == 0:
		rpc("is_carried",follow)
		$TimeLabel.visible = true
		$Timer.start()
		v = 1
	$TimeLabel.text = str(int($Timer.get_time_left()))
	rpc_unreliable("update_position",position)

func _on_Timer_timeout():
	global_position = origin

remotesync func is_carried(f):
	follow = f

remotesync func update_position(pos):
	global_position = pos
