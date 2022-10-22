extends Label

onready var player = get_parent()

func _process(delta):
	
	text = str(player.health)+"/"+str(player.max_health)
