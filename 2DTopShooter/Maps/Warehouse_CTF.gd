extends Node2D

onready var RedFlag = $RedFlag
onready var BlueFlag = $BlueFlag
onready var WinSound = $WinSound
onready var WinSound2 = $WinSound2
onready var RedSpawn = {"1":get_node("RedSpawn/Spawn1"),"2":get_node("RedSpawn/Spawn2"),"3":get_node("RedSpawn/Spawn3"),"4":get_node("RedSpawn/Spawn4")}
onready var BlueSpawn = {"1":get_node("BlueSpawn/Spawn1"),"2":get_node("BlueSpawn/Spawn2"),"3":get_node("BlueSpawn/Spawn3"),"4":get_node("BlueSpawn/Spawn4")}
onready var spawns = {"1":get_node("Spawns/Spawn1")}

var totspawns = 1
var Ptotspawns = 4

var winkills = 1

var rng = RandomNumberGenerator.new()

var deathTimer = 3

const PORT := 3333

var PlayerList = Net.playerList

var winCounter = 0

var RedCaptures = 0
var BlueCaptures = 0

var originCounter = 0

func ready():
	RedFlag.position = $FlagRed.global_position
	RedFlag.origin = $FlagRed.global_position
	RedFlag.team = 0
	BlueFlag.position = $BlueFlag.global_position
	BlueFlag.origin = $BlueFlag.global_position
	BlueFlag.team = 1
	rng.randomize()
	get_tree().get_node("Lobby").visible = false

func _process(_delta):
	for p in Players.get_children():
		for pl in Net.playerList:
			if str(p.name) == str(pl[0]):
				pl[3] = p.kills
				pl[4] = p.deaths
	PlayerList = Net.playerList
	
	if originCounter == 0:
		RedFlag.origin = $FlagRed.global_position
		BlueFlag.origin = $FlagBlue.global_position
	
	#Win Condition
	if get_tree().is_network_server():
		if RedCaptures >= winkills && winCounter == 0:
			rpc("WinGame","Red Team")
			winCounter += 1
		if BlueCaptures >= winkills && winCounter == 0:
			rpc("WinGame","Blue Team")
			winCounter += 1

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


func _on_RedZone_area_entered(area):
	if area.is_in_group("flag") && area.team == 1:
		area.follow = 0
		area.position = $FlagBlue.position
		RedCaptures += 1
		print(RedCaptures)


func _on_BlueZone_area_entered(area):
	if area.is_in_group("flag") && area.team == 0:
		area.follow = 0
		area.position = $FlagRed.position
		BlueCaptures += 1
		print(BlueCaptures)
