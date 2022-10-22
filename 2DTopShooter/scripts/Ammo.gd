extends Label

onready var player = get_parent().get_node("Player")

func _process(delta):
	if player.active_weapon == 1:
		text = str(player.Pammo_count) + "/" + str(player.Preserve)
	if player.active_weapon == 2:
		text = str(player.Sammo_count) + "/" + str(player.Sreserve)
	#text = "Ammo: "+str(player.ammo_count)
