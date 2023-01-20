extends RigidBody2D

onready var flag
var damage = 10
#Type of bullet
var type = 1
var lifespan = 0.5
var can_bounce = false
var num_bounce = 0


var pos = Vector2()
var rot
var dir = Vector2()
onready var trail = preload("res://Scenes/Bullet_Particle.tscn")
onready var arc = preload("res://Scenes/Spark1.tscn")
var receiverint
var receiverinst


func _on_Bullet_tree_entered():
	if type == 1:
		lifespan = 0.5
	if type == 2:
		lifespan = 0.25
	if type == 3:
		lifespan = 0.3
		$Sprite.hide()
		$Arrow.show()

func _ready():
	if can_bounce:
		set_bounce(1.0)
		set_friction(0)
		#contacts_reported = 0
	else:
		set_bounce(0)
		set_friction(1)
		#contacts_reported = 1
	#if type == 1:
	#	lifespan = 0.5
	#if type == 2:
	#	lifespan = 0.35
	$Timer.wait_time = lifespan
	$Timer.start()

func _process(delta):
	#Trail
	if type == 1 || type == 2:
		var t = trail.instance()
		t.position = position
		Bullets.add_child(t)
	if type == 3:
		var a = arc.instance()
		a.position = position
		a.rotation_degrees = rotation_degrees + 90
		Bullets.add_child(a)
	

func _on_Bullet_body_entered(body):
	if not body.is_in_group("player") && !self && !self.get_parent() && !body.is_in_group("bullet") && num_bounce == 0:
			queue_free()
	
	if body.is_in_group("bullet"):
		body.add_collision_exception_with(body) 
	
	if flag != body && body.is_in_group("player"):
		damage(flag,body)
	
	if flag != body && (!body.is_in_group("mapObject") || body.is_in_group("mapObject")) && !can_bounce:
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
