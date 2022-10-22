extends Label

onready var player = get_parent()
onready var pos = Vector2(rect_position)
onready var camera = get_node("Camera2D")

func _process(delta):
	#rect_position = camera.get_camera_position()
	
	text = "Health: "+str(player.health)
