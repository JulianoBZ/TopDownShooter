extends Area2D

export var active = false
var flag
var bodies
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	monitoring = true
	visible = true
	bodies = get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("player") && body != flag:
			damage(flag,body)
	yield(get_tree().create_timer(0.1),"timeout")
	queue_free()

#func _process(delta):
#	bodies = get_overlapping_bodies()
#	for body in bodies:
#		if body.is_in_group("player") && body != flag:
#			damage(flag,body)

#func _on_MeleeHitbox_body_entered(body):
#	if body.is_in_group("player") && body != flag:
#		damage(flag,body)

remotesync func damage(attacker: Object,receiver: Object):
	print(str(attacker)+" damaged "+str(receiver))
	receiver.health -= 50
	receiver.lastdamage = attacker
	queue_free()
