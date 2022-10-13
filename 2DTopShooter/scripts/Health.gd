extends Label

onready var player = get_parent()
onready var pos = Vector2(rect_position)

func _process(delta):
	text = "Health: "+str(player.health)
