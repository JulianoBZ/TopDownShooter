extends Node2D

onready var spawns = {"1":get_node("Spawn1"),"2":get_node("Spawn2"),"3":get_node("Spawn3"),"4":get_node("Spawn4")
,"5":get_node("Spawn5"),"6":get_node("Spawn6"),"7":get_node("Spawn7")}

var rng = RandomNumberGenerator.new()

func ready():
	rng.randomize()

#remotesync func _on_PlayerAll_pdeath(player):
#	print("dead1")
#	yield(get_tree().create_timer(3),"timeout")
#	player.position = spawns[str(rng.randi_range(1,7))].position
