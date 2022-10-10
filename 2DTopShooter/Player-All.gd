extends KinematicBody2D

onready var Pname = $Name
onready var player = $Player
var speed = 200
var pos = Vector2()
var sprinting = false
var health = 100
var alive = true

signal death

func _ready():
	Pname.text = "Player"

func _process(delta):
	
	if Input.is_action_pressed("Sprint"):
		sprinting = true
		speed = 400
	else:
		sprinting = false
		speed = 200
	
	if health <= 0:
		alive = false
		emit_signal("death")
		queue_free()

func _physics_process(delta):
	var direction = Vector2()
	
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


