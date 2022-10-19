extends RigidBody2D

onready var flag
var damage = 0

var pos = Vector2()
var rot
var dir = Vector2()

#func _ready():
#	rpc_unreliable("spawn_bullet")

func _process(delta):
	pass

func _on_Bullet_body_entered(body):
	if not body.is_in_group("player") && !self && !self.get_parent() && !body.is_in_group("bullet"):
		queue_free()
	
	if body.is_in_group("bullet"):
		body.add_collision_exception_with(body) 
	
	if flag != body && body.is_in_group("player"):
		rpc("damage",flag,body)
	
	if flag != body:
		queue_free()

#func spawn_bullet():
#	var instance = Global.instance_node_at_location(self, Players, global_position)
	#instance.name = str(id)
	#instance.set_network_master(id)

remote func update_position(pos):
	global_position = pos

remotesync func damage(attacker: Object,receiver: Object):
	receiver.health -= damage
	print(str(attacker)+" damaged "+str(receiver))
	queue_free()
	if receiver.health <= 0:
		attacker.kills += 1
		attacker.health += 30
		if attacker.health > 100:
			attacker.health = 100
	#last_damage(attacker, receiver)

#remote func last_damage(attacker: Object,receiver: Object):
#	print(attacker , " " , receiver)
	
