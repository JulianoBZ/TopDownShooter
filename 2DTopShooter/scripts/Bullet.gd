extends RigidBody2D

onready var flag

func _ready():
	pass

func _on_Bullet_body_entered(body):
	if not body.is_in_group("player") && !self && !self.get_parent() && !body.is_in_group("bullet"):
		queue_free()
	
	if body.is_in_group("bullet"):
		body.add_collision_exception_with(body) 
	
	if flag != body && body.is_in_group("player"):
		body.health -= 10
		print("damaged "+str(body))
		queue_free()
	
	if flag != body:
		queue_free()
		
	print(flag)
