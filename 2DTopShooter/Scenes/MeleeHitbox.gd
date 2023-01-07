extends Area2D

var active = true
var flag
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

func _ready():
	$Timer.wait_time = 0.05
	$Timer.start()

remotesync func damage(attacker: Object,receiver: Object):
	print(str(attacker)+" damaged "+str(receiver))
	receiver.health -= 50
	receiver.lastdamage = attacker
	queue_free()

func _on_Timer_timeout():
	queue_free()

func _on_MeleeHitbox_body_entered(body):
	if body.is_in_group("player") && body != flag:
		rpc("damage",flag,body)
	if body.is_in_group("bullet"):
		body.queue_free()
