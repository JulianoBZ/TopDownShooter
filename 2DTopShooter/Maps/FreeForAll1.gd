extends Node2D

onready var spawns = {"1":get_node("Spawn1"),"2":get_node("Spawn2"),"3":get_node("Spawn3"),"4":get_node("Spawn4")
,"5":get_node("Spawn5"),"6":get_node("Spawn6"),"7":get_node("Spawn7")}

var rng = RandomNumberGenerator.new()

const PORT := 3333

export (NodePath) var advertiserPath: NodePath
onready var advertiser := get_node(advertiserPath)

func ready():
	rng.randomize()

func _process(delta):
	advertiser.serverInfo["name"] = Net.lobby_name
	advertiser.serverInfo["port"] = PORT
	#print(advertiser.serverInfo)

#remotesync func _on_PlayerAll_pdeath(player):
#	print("dead1")
#	yield(get_tree().create_timer(3),"timeout")
#	player.position = spawns[str(rng.randi_range(1,7))].position
