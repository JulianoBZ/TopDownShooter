extends RigidBody2D

onready var flag
var damage = 10

func _ready():
	pass

func _on_Bullet_body_entered(body):
	if not body.is_in_group("player") && !self && !self.get_parent() && !body.is_in_group("bullet"):
		queue_free()
	
	if body.is_in_group("bullet"):
		body.add_collision_exception_with(body) 
	
	if flag != body && body.is_in_group("player"):
		damage(flag,body)
	
	if flag != body:
		queue_free()

remote func damage(attacker: Object,receiver: Object):
		receiver.health -= damage
		print(str(attacker)+" damaged "+str(receiver))
		queue_free()
