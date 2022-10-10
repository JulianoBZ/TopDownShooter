extends Label

onready var player = get_parent()

func _process(delta):
	text = "Health: "+str(player.health)
