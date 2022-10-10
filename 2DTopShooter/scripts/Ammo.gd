extends Label

onready var player = get_parent().get_node("Player")

func _process(delta):
	text = "Ammo: "+str(player.ammo_count)
