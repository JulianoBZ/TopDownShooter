extends KinematicBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var screensize = Vector2()
var speed = 500

# Called when the node enters the scene tree for the first time.
func _ready():
	screensize = get_viewport_rect().size
	position.x = screensize.x / 2
	print(screensize.x)
	pass # Replace with function body.

func _process(delta):
	if Input.is_action_pressed("ui_right"):
		position.x += speed * delta
	if Input.is_action_pressed("ui_left"):
		position.x -= speed * delta
	
	position.x = clamp(position.x,40,screensize.x-40)






# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
