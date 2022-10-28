extends Area2D

export var active = false
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _on_MeleeHitbox_body_entered(body):
	if body.is_in_group("player") && body != get_parent() && body != get_parent().get_parent() && active:
		rpc("damage",get_parent(),body)

remotesync func damage(attacker: Object,receiver: Object):
	print(str(attacker)+" damaged "+str(receiver))
	receiver.health -= 50
	receiver.lastdamage = attacker
	queue_free()
