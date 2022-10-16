extends KinematicBody2D

onready var Pname = $Name
onready var player = $Player
var speed = 200
var pos = Vector2()
var sprinting = false
var health = 100
var alive = true
var direction = Vector2()
var lastdir = Vector2()
onready var camera = get_node("Camera2D")
#puppet var puppet_position = Vector2(0,0) #setget puppet_position_set
#puppet var puppet_direction = Vector2()
var can_move = true
#onready var tween = $Tween
onready var spawns = get_tree().get_root().get_node("/root/Map").get_child(0).spawns
var rng = RandomNumberGenerator.new()

signal pdeath
signal respawned

func _ready():
	rng.randomize()
	can_move = true
	Pname.text = "Player"
	print(spawns)
	#player.connect("pdeath",self,"_on_playerall_pdeath")

func _process(delta):
	if is_network_master() && can_move:
		camera.make_current()
		var mouse_pos = get_global_mouse_position()
		camera.offset_h = (mouse_pos.x - position.x) / (1366 / 3)
		camera.offset_v = (mouse_pos.y - position.y) / (768 / 3)
		
		if Input.is_action_pressed("Sprint"):
			sprinting = true
			speed = 400
		else:
			sprinting = false
			speed = 200
		
		if health <= 0:
			alive = false
			rpc("death")


func _physics_process(delta):
	if is_network_master() && can_move:
		direction = Vector2()
		if Input.is_action_pressed("up"):
			direction.y -= 1
		if Input.is_action_pressed("down"):
			direction.y += 1
		if Input.is_action_pressed("left"):
			direction.x -= 1
		if Input.is_action_pressed("right"):
			direction.x += 1
		if Input.is_action_just_pressed("kys"):
			health = 0
		direction = direction.normalized()
		#global_position = player.global_position
		move_and_slide(direction * speed)
		rpc_unreliable("update_position",position)
#	else:
#		if not tween.is_active():
#			move_and_slide(puppet_direction * speed)

remote func update_position(pos):
	position = pos

remotesync func death():
	can_move = false
	emit_signal("pdeath",self)
	yield(get_tree().create_timer(3),"timeout")
	position = spawns[str(rng.randi_range(1,7))].position
	health = 100
	can_move = true
	emit_signal("respawned")

#func puppet_position_set(new_value):
#	puppet_position = new_value
#	
#	tween.interpolate_property(self, "global_position",global_rotation,puppet_position,0.1)
#	tween.start()

