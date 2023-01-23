extends Node2D


onready var WinSound = $WinSound
onready var WinSound2 = $WinSound2
onready var spawns = {"1":get_node("Spawns/Spawn1"),"2":get_node("Spawns/Spawn2"),"3":get_node("Spawns/Spawn3"),"4":get_node("Spawns/Spawn4")
,"5":get_node("Spawns/Spawn5"),"6":get_node("Spawns/Spawn6"),"7":get_node("Spawns/Spawn7"),"8":get_node("Spawns/Spawn8")}

var totspawns = 8

var winkills = 1

var rng = RandomNumberGenerator.new()

var deathTimer = 3

const PORT := 3333

var PlayerList = Net.playerList

var winCounter = 0

func ready():
	rng.randomize()
	get_tree().get_node("Lobby").visible = false

func _process(_delta):
	for p in Players.get_children():
		for pl in Net.playerList:
			if str(p.name) == str(pl[0]):
				pl[3] = p.kills
				pl[4] = p.deaths
	PlayerList = Net.playerList
	
	#Win Condition
	if get_tree().is_network_server():
		for each in PlayerList:
			#print("Map ",each)
			#print("Map ",Net.playerList)
			if each[3] == winkills && winCounter == 0:
				rpc("WinGame",each[1])
				winCounter += 1
	#print(advertiser.serverInfo)

remotesync func WinGame(winner):
	WinSound2.play()
	yield(get_tree().create_timer(5),"timeout")
	for each in Net.playerList:
		each[3] = 0
		each[4] = 0
	get_node("/root/Network_setup").gameEnded()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
