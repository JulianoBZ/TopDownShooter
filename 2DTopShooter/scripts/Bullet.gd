extends RigidBody2D

onready var flag
var damage = 10
#Type of bullet
var type = 1
var lifespan = 0.5

var pos = Vector2()
var rot
var dir = Vector2()
onready var trail = preload("res://Scenes/Bullet_Particle.tscn")
var receiverint
var receiverinst


func _on_Bullet_tree_entered():
	if type == 1:
		lifespan = 0.5
	if type == 2:
		lifespan = 0.35

func _ready():
	#if type == 1:
	#	lifespan = 0.5
	#if type == 2:
	#	lifespan = 0.35
	$Timer.wait_time = lifespan
	$Timer.start()

func _process(delta):
	var t = trail.instance()
	t.position = position
	Bullets.add_child(t)

func _on_Bullet_body_entered(body):
	if not body.is_in_group("player") && !self && !self.get_parent() && !body.is_in_group("bullet"):
		queue_free()
	
	if body.is_in_group("bullet"):
		body.add_collision_exception_with(body) 
	
	if flag != body && body.is_in_group("player"):
		damage(flag,body)
	
	if flag != body:
		queue_free()

remote func update_position(pos):
	global_position = pos

remotesync func damage(attacker: Object,receiver: Object):
	print(str(attacker)+" damaged "+str(receiver))
	receiver.health -= damage
	receiver.lastdamage = attacker
	queue_free()
	
#remote func last_damage(attacker: Object,receiver: Object):
#	print(attacker , " " , receiver)
	

func _on_Timer_timeout():
	queue_free()
