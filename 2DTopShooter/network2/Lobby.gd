extends Control


const PORT := 3333

onready var network = get_parent()
var list_last_value
var playerList_aux = 0

var playerList = []
var peerinfo = []
var myinfo = []
onready var PLU = preload("res://network2/PlayerListUnit.tscn")

export (NodePath) var advertiserPath: NodePath
onready var advertiser := get_node(advertiserPath)

var playerChar = preload("res://Player-All.tscn")
var world = preload("res://Maps/FreeForAll1.tscn").instance()
var rng = RandomNumberGenerator.new()

onready var connected_player_list = {}

func ready():
	rng.randomize()
	list_last_value = network.playerList.size()
	print(list_last_value)
	print(get_tree().multiplayer.get_network_connected_peers())
	#playerList.append(myinfo)

func _process(delta):
	if Net.hosting:
		rpc("update_player_list_lobby",playerList)
	#print(playerList)
	advertiser.serverInfo["name"] = Net.lobby_name
	advertiser.serverInfo["port"] = PORT
	if Net.connected == true:
		rpc_id(1,"Pconnected",Net.myinfo)
		Net.onLobby = true
		Net.connected = false
	
	
	#if get_tree().get_network_unique_id() != null:
	#	Net.myinfo = [get_tree().get_network_unique_id(),Global.player_name]
	#if get_tree().is_network_server():
	#	if get_tree().get_network_unique_id() == 1 && playerList == []:
	#		playerList.append(Net.myinfo)
	
	#rpc("update_player_list_lobby",playerList)
	#if get_tree().is_network_server() == false:
	#	if playerList_aux == 0 && (get_tree().get_network_unique_id() != 1 || get_tree().get_network_unique_id() != null ):
	#		rpc_id(1,"Pconnected",myinfo)
			#rpc("update_player_list_lobby",playerList)
	#		playerList_aux += 1
	
	#for p in playerList:
	#	if p[0] == get_tree().get_network_unique_id():
	#		playerList_aux += 1
	#	if playerList_aux == 0:
	#		rpc_id(1,"Pconnected",[get_tree().get_network_unique_id(),Global.player_name])
	#	playerList_aux = 0
	
	#rpc_id(1,"connected",[get_tree().get_network_unique_id(),Global.player_name])
	#rpc("update_player_list_lobby",network.playerList)
	#if list_last_value != network.playerList.size():
	changed_playerList()
	#	list_last_value = network.playerList.size()
	if get_tree().is_network_server():
		$StartGame.show()

func changed_playerList():
	#rpc("update_player_list_lobby",playerList)
	#if get_tree().get_network_unique_id() == 1:
	for n in $PlayerList.get_children():
		n.queue_free()
	for p in playerList:
		
		#var player = Label.new()
		#var Pcolor = ColorRect.new()
		#player.text = str(p[1])
		#Pcolor.color = Color(1,0,0,1)
		#Pcolor.rect_position = player.rect_position
		#player.add_child(Pcolor)
		#$PlayerList.add_child(player)
		
		var playerunit = PLU.instance()
		playerunit.get_node("ColorRect/Label").text = str(p[1])
		#print(str(p[2]))
		#print(Net.color)
		playerunit.get_node("ColorRect").color = Color(str(p[2]))
		#print(str(playerunit.get_node("Label").text))
		$PlayerList.add_child(playerunit)
		#print(str($PlayerList.get_children()))
		
	Net.playerList = playerList

func _on_StartGame_pressed():
	rpc("start_game")
	Net.lobby_name = "Game Started, do not Join"

remotesync func start_game():
	for p in playerList:
		p.append(0)
	Net.playerList = playerList
	print(Net.playerList)
	Map.add_child(world)
	self.hide()
	for each in playerList:
		var pl_id = each[0]
		if pl_id != get_tree().get_network_unique_id():
			instance_player(pl_id)
	instance_player(get_tree().get_network_unique_id())

remotesync func instance_player(id):
	#Global.player_name = str(playername.text)
	var player_instance = Global.instance_node_at_location(playerChar, Players, (world.spawns[str(rng.randi_range(1,7))]).position)
	player_instance.name = str(id)
	player_instance.set_network_master(id)

remote func Pconnected(PeerInfo):
	peerinfo = PeerInfo
	print(peerinfo)
	playerList.append(peerinfo)
	#rpc("update_player_list_lobby",playerList)
	#print(PeerInfo)
	print(playerList)

remotesync func update_player_list_lobby(list):
	playerList = list
	Net.playerList = playerList
