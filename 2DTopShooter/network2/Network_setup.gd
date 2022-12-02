extends Control

#export (NodePath) var advertiserPath: NodePath
#onready var advertiser := get_node(advertiserPath)
const PORT := 3333

var firetype = 1
var player = preload("res://Player-All.tscn")
var world = preload("res://Maps/FreeForAll1.tscn").instance()
var browser = preload("res://Scenes/ServerBrowser.tscn").instance()
var lobby = preload("res://network2/Lobby.tscn").instance()
var playerList = []
var myinfo = {}
var player_info = {}
onready var multiplayer_config_ui = $Multiplayer_configure
onready var server_ip_address = $Multiplayer_configure/Server_IP_address
onready var device_ip_address = $Multiplayer_configure/CanvasLayer/Device_IP
onready var playername = $Multiplayer_configure/NameText
onready var servername = $Multiplayer_configure/ServerName
#onready var ffa1 = preload("res://Maps/FreeForAll1.tscn")
#var spawns = {"1":world.get_node("Spawn1"),"2":world.get_node("Spawn2"),"3":world.get_node("Spawn3"),"4":world.get_node("Spawn4")
#,"5":world.get_node("Spawn5"),"6":world.get_node("Spawn6"),"7":world.get_node("Spawn7")}
var rng = RandomNumberGenerator.new()

func _ready():
	rng.randomize()
	get_tree().connect("network_peer_connected",self,'_player_connected')
	get_tree().connect("network_peer_disconnected",self,'_player_disconnected')
	get_tree().connect("connected_to_server",self,'_connected_to_server')
	rpc("register_player",myinfo)
	device_ip_address.text = Net.ip_address

func _player_connected(id):
	print("Player: "+str(playername.text)+" has connected")
	playerList.append(id)
	rpc_id(id,"register_player",myinfo)
	#instance_player(id)

func _player_disconnected(id):
	print("Player: "+str(playername.text)+" has disconnected")
	for p in playerList:
		if p == id:
			playerList.erase(p)
	rpc("dc",id)

func _on_Create_Server_pressed():
	myinfo = {name = str($Multiplayer_configure/NameText.text)}
	if servername.text != "":
		Net.lobby_name = servername.text
	multiplayer_config_ui.hide()
	device_ip_address.hide()
	var peer = NetworkedMultiplayerENet.new()
	var result = peer.create_server(PORT)
	if result == OK:
		get_tree().set_network_peer(peer)
		playerList.append(get_tree().get_network_unique_id())
		self.add_child(lobby)
		print("Game hosted")
	else:
		print("Failed to host game")
	
	#w.get_node("BlueSpawn")
	#print("Server Created")
	#advertiser.serverInfo["name"] = "A great lobby"
	#advertiser.serverInfo["port"] = Net.DEFAULT_PORT
	#print(advertiser.serverInfo)
	

func _on_Join_Server_pressed():
	if server_ip_address.text != "":
		multiplayer_config_ui.hide()
		device_ip_address.hide()
		if browser:
			browser.queue_free()
		Net.ip_address = server_ip_address.text
		Net.join_server()
		#var w = world.instance()
		playerList.append(get_tree().get_network_unique_id())
		self.add_child(lobby)

func _connected_to_server():
	yield(get_tree().create_timer(0.1),"timeout")
	#instance_player(get_tree().get_network_unique_id())

func instance_player(id):
	#Global.player_name = str(playername.text)
	var player_instance = Global.instance_node_at_location(player, Players, (world.spawns[str(rng.randi_range(1,7))]).position)
	player_instance.name = str(id)
	player_instance.set_network_master(id)

func _on_weaponbut1_pressed():
	Global.primary = 1

func _on_weaponbut2_pressed():
	Global.primary = 2

func _on_Sweaponbut1_pressed():
	Global.secondary = 1

func _on_Sweaponbut2_pressed():
	Global.secondary = 2

func _on_classbut1_pressed():
	Global.frame = 1

func _on_classbut2_pressed():
	Global.frame = 2

func _on_classbut3_pressed():
	Global.frame = 3

func _on_BrowseServer_pressed():
	self.add_child(browser)
	#get_tree().change_scene("res://Scenes/ServerBrowser.tscn")

remotesync func dc(id):
	pass
	for c in Players.get_children():
		if str(c.name) == str(id):
			c.queue_free()

remote func register_player(info):
	var id = get_tree().get_rpc_sender_id()
	player_info[id] = info
	print(player_info)


func _on_SetName_pressed():
	Global.player_name = str(playername.text)
