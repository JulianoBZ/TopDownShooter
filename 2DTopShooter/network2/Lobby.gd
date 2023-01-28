extends Control


const PORT := 3333

onready var network = get_parent()
var list_last_value

var counter = 0
var oldtype = 0
var type = 0
var playerListRED = []
var playerListBLUE = []
var peerinfo = []
var myinfo = []
onready var PLU = preload("res://network2/PlayerListUnit.tscn")

var playerChar = preload("res://Player-All.tscn")
var FFA1 = preload("res://Maps/FreeForAll1.tscn")
var WRHFFA = preload("res://Maps/WareHouse_FFA.tscn").instance()
var WRHCTF = preload("res://Maps/Warehouse_CTF.tscn").instance()
onready var rng = RandomNumberGenerator.new()

var map = 0
var world

onready var connected_player_list = {}

func ready():
	rng.randomize()
	list_last_value = network.playerList.size()
	print(list_last_value)
	print(get_tree().multiplayer.get_network_connected_peers())

func _process(_delta):
	if Input.is_action_just_pressed("Debug"):
		OS.dump_memory_to_file("MemoryDump")
	if Net.hosting:
		$ReadyButton.hide()
		for p in Net.playerList:
			if p[0] == 1:
				p[3] = 1
	
	if Net.hosting:
		#$Debug.text = str(Gotm.lobby)+"-"+str(Gotm.lobby.name)
		rpc("update_player_list_lobby",Net.playerList)
		if $"Map Selection".type == 0:
			rpc("show_type_0")
		if $"Map Selection".type == 1:
			rpc("show_type_1")
	
	if Net.gameStart == false:
		changed_playerList()
	var readycount = 0
	for p in Net.playerList:
		if p[3] == 1:
			readycount += 1
	if get_tree().is_network_server() && get_parent().peer != null:
		$OptionButtonKills.show()
		$"Map Selection".show()
		rpc("update_lobby_map",$"Map Selection".map_name,$"Map Selection".map)
		rpc("update_lobby_score",$OptionButtonKills.killLimit)
	if readycount == Net.playerList.size():
		if get_tree().is_network_server() && get_parent().peer != null:
			$Score.hide()
			$StartGame.show()
	else:
		$StartGame.hide()
	

func changed_playerList():
	if Net.gameStart == false:
		for n in $PlayerList.get_children():
			n.queue_free()
		for n in $PlayerListRED.get_children():
			n.queue_free()
		for n in $PlayerListBLUE.get_children():
			n.queue_free()
	if $"Map Selection".type == 0 && Net.gameStart == false:
		if Net.hosting:
			type = 0
			rpc("update_lobby_type",type)
		for p in Net.playerList:
			var playerunit = PLU.instance()
			playerunit.get_node("ColorRect/Label").text = str(p[1])
			playerunit.get_node("ColorRect").color = Color(str(p[2]))
			if p[3] == 1:
				playerunit.get_node("ReadyRect").color = Color("5bd700")
			else:
				playerunit.get_node("ReadyRect").color = Color("000000")
			#print(str(playerunit.get_node("Label").text))
			$PlayerList.add_child(playerunit)
			#print(str($PlayerList.get_children()))
			
		
	if $"Map Selection".type == 1 && Net.gameStart == false:
		if Net.hosting:
			type = 1
			rpc("update_lobby_type",type)
			#sort_teams()
	for p in Net.playerList:
		#var playerunit = PLU.instance()
		if str(p[2]) == "CC0000":
			var playerunit = PLU.instance()
			playerunit.get_node("ColorRect/Label").text = str(p[1])
			playerunit.get_node("ColorRect").color = Color(str(p[2]))
			if p[3] == 1:
				playerunit.get_node("ReadyRect").color = Color("5bd700")
			else:
				playerunit.get_node("ReadyRect").color = Color("000000")
			$PlayerListRED.add_child(playerunit)
		if str(p[2]) == "000099":
			var playerunit = PLU.instance()
			playerunit.get_node("ColorRect/Label").text = str(p[1])
			playerunit.get_node("ColorRect").color = Color(str(p[2]))
			if p[3] == 1:
				playerunit.get_node("ReadyRect").color = Color("5bd700")
			else:
				playerunit.get_node("ReadyRect").color = Color("000000")
			$PlayerListBLUE.add_child(playerunit)
			##############
			#playerunit.get_node("ColorRect/Label").text = str(p[1])
			#playerunit.get_node("ColorRect").color = Color(str(p[2]))
			#if p[3] == 1:
			#	playerunit.get_node("ReadyRect").color = Color("5bd700")
			#else:
			#	playerunit.get_node("ReadyRect").color = Color("000000")
			############
			
			#print(str(playerunit.get_node("Label").text))
			#if playerunit.get_node("ColorRect/Label").text == "CC0000":
			#	$PlayerListRED.add_child(playerunit)
			#	Net.playerListRED.append(p)
			#	print(Net.playerListRED)
			#if playerunit.get_node("ColorRect/Label").text == "000099":
			#	$PlayerListBLUE.add_child(playerunit)
			#	Net.playerListBLUE.append(p)
			#	print(Net.playerListBLUE)
				
			#$PlayerList.add_child(playerunit)
			#print(str($PlayerList.get_children()))
			

func _on_StartGame_pressed():
	rpc("start_game")
	#$ServerAdvertiser.socketUDP.set_broadcast_enabled(false)
	Gotm.lobby.name += " - Game Started"
	Gotm.lobby.locked = true
	

remotesync func start_game():
	Net.gameStart = true
	
	#print(Net.playerList)
	world.winkills = $OptionButtonKills.killLimit
	Map.add_child(world)
	#print(world.winkills)
	#visible = false
	#self.queue_free()
	for each in Net.playerList:
		
		rng.randomize()
		var pl_id = each[0]
		each[3] = 0
		if pl_id != get_tree().get_network_unique_id():
			instance_player(pl_id, each[2])
		if pl_id == get_tree().get_network_unique_id():
			instance_player(get_tree().get_network_unique_id(),each[2])

remotesync func instance_player(id,color):
	if type == 0:
		var player_instance = Global.instance_node_at_location(playerChar, Players, (Map.get_child(0).spawns[str(rng.randi_range(1,Map.get_child(0).totspawns))]).position)
		player_instance.name = str(id)
		player_instance.get_node('Player').get_node('Body').modulate = color
		player_instance.set_network_master(id)
	if type == 1:
		var player_instance = Global.instance_node_at_location(playerChar, Players, (Map.get_child(0).spawns[str(rng.randi_range(1,Map.get_child(0).totspawns))]).position)
		player_instance.name = str(id)
		player_instance.get_node('Player').get_node('Body').modulate = color
		player_instance.team = true
		player_instance.set_network_master(id)
		if color == "CC0000":
			player_instance.position = (Map.get_child(0).RedSpawn[str(rng.randi_range(1,Map.get_child(0).Ptotspawns))]).position
		if color == "000099":
			player_instance.position = (Map.get_child(0).BlueSpawn[str(rng.randi_range(1,Map.get_child(0).Ptotspawns))]).position

remote func Pconnected(PeerInfo):
	peerinfo = PeerInfo
	print(peerinfo)
	Net.playerList.append(peerinfo)
	#rpc("update_player_list_lobby",playerList)
	#print(PeerInfo)
	print(Net.playerList)

remotesync func update_player_list_lobby(list):
	Net.playerList = list

remotesync func update_lobby_map(map_name,m):
	$Map.text = "Map: "+str(map_name)
	map = m
	match map:
		0:
			world = WRHFFA
		1:
			world = WRHCTF

remotesync func show_type_0():
	$PlayerLoadout/ColorOption.show()
	$PlayerLoadout/TeamOption.hide()
	$PlayerListBLUE.hide()
	$PlayerListRED.hide()

remotesync func show_type_1():
	$PlayerLoadout/TeamOption.show()
	$PlayerLoadout/ColorOption.hide()
	$PlayerListBLUE.show()
	$PlayerListRED.show()

func _on_ReadyButton_pressed():
	if $ReadyButton.text == "Ready":
		rpc_id(1,"UpdateReady",get_tree().get_network_unique_id())
		$ReadyButton.text = "Unready"
	if $ReadyButton.text == "Unready":
		rpc_id(1,"UpdateUnReady",get_tree().get_network_unique_id())
		$ReadyButton.text = "Ready"

remote func UpdateReady(id):
	for p in Net.playerList:
		if p[0] == id:
			p[3] = 1
			print(Net.playerList)
	
remote func UpdateUnReady(id):
	for p in Net.playerList:
		if p[0] == id:
			p[3] = 0
			print(Net.playerList)


func _on_ReadyButton_toggled(button_pressed):
	if button_pressed && Net.connected:
		rpc_id(1,"UpdateReady",get_tree().get_network_unique_id())
		$ReadyButton.text = "Unready"
	if !button_pressed && Net.connected:
		rpc_id(1,"UpdateUnReady",get_tree().get_network_unique_id())
		$ReadyButton.text = "Ready"

remote func update_lobby_score(score):
	$Score.text = "Score: "+str(score)

remote func update_lobby_type(t):
	type = t
	if oldtype != type:
		$"Map Selection".type = t
		if type == 0:
			$PlayerLoadout/ColorOption.UpdateColor2()
			$PlayerList.show()
			$PlayerListBLUE.hide()
			$PlayerListRED.hide()
		if type == 1:
			$PlayerLoadout/TeamOption.UpdateColor2()
			$PlayerList.hide()
			$PlayerListBLUE.show()
			$PlayerListRED.show()
	oldtype = type

