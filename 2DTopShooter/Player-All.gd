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

#onready var tween = $Tween

signal death

func _ready():
	Pname.text = "Player"

func _process(delta):
		var mouse_pos = get_global_mouse_position()
		$Camera2D.offset_h = (mouse_pos.x - position.x) / (1366 / 3)
		$Camera2D.offset_v = (mouse_pos.y - position.y) / (768 / 3)
		
		if Input.is_action_pressed("Sprint"):
			sprinting = true
			speed = 400
		else:
			sprinting = false
			speed = 200
		
		if health <= 0:
			alive = false
			emit_signal("death")
			death()

func _physics_process(delta):
	if is_network_master():
		direction = Vector2()
		if Input.is_action_pressed("up"):
			direction.y -= 1
		if Input.is_action_pressed("down"):
			direction.y += 1
		if Input.is_action_pressed("left"):
			direction.x -= 1
		if Input.is_action_pressed("right"):
			direction.x += 1
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
	queue_free()

#func puppet_position_set(new_value):
#	puppet_position = new_value
#	
#	tween.interpolate_property(self, "global_position",global_rotation,puppet_position,0.1)
#	tween.start()

#func _on_Network_tick_rate_timeout():
#	if is_network_master():
#		rset_unreliable("puppet_position", global_position)
#		rset_unreliable("puppet_direction", direction)
#		rset_unreliable("puppet_rotation", player.rotation_degrees)
