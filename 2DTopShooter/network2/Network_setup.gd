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
var peerinfo = []
var myinfo = []
var player_info = {}
var list_aux = []
var upnp = UPNP.new()
onready var camera = get_node("Camera2D")
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
	add_child(lobby)
	lobby.hide()
	get_tree().connect("network_peer_connected",self,'_player_connected')
	get_tree().connect("network_peer_disconnected",self,'_player_disconnected')
	get_tree().connect("connected_to_server",self,'_connected_to_server')
	#rpc("register_player",myinfo)
	device_ip_address.text = Net.ip_address
	#myinfo = Net.myinfo
	myinfo = [0,Global.player_name,"CC0000",0,0]

func _player_connected(id):
	print("Player: has connected")
	#rpc("update_player_list_lobby",playerList)
	#rpc_id(1,"connected",get_tree().get_network_unique_id(),Global.player_name)
	#playerList.append(id)
	#rpc_id(1,"register_player",myinfo,Global.player_name)
	#instance_player(id)

func _player_disconnected(id):
	#print("Player: "+str(playername.text)+" has disconnected")
	for p in Net.playerList:
		if p[0] == id:
			dc(id)
			Net.playerList.erase(p)
	#rpc("dc",id)

func _on_Create_Server_pressed():
	#########################################
	#var discover_result = upnp.discover()
	
	#while true:
	#	if discover_result == UPNP.UPNP_RESULT_SUCCESS:
	#		if upnp.get_gateway() and upnp.get_gateway().is_valid_gateway():
	#			var map_result_udp = upnp.add_port_mapping(PORT,PORT,"godot_udp","UDP",0)
	#			print("map udp:",map_result_udp)
	#			var map_result_tcp = upnp.add_port_mapping(PORT,PORT,"godot_tcp","TCP",0)
	#			print("map tcp:",map_result_tcp)
	#			
	#			if not map_result_udp == UPNP.UPNP_RESULT_SUCCESS:
	#				upnp.add_port_mapping(PORT,PORT,"","UDP")
	#				print("UPD criado")
	#			if not map_result_tcp == UPNP.UPNP_RESULT_SUCCESS:
	#				print("TCP criado")
	#				upnp.add_port_mapping(PORT,PORT,"","TCP")
	#			break
	##external_ip = upnp.query_external_address()
	#Net.external_ip = upnp.query_external_address()
	########################################
	Net.hosting = true
	if servername.text != "":
		Net.lobby_name = servername.text
	multiplayer_config_ui.hide()
	device_ip_address.hide()
	var peer = NetworkedMultiplayerENet.new()
	var result = peer.create_server(PORT)
	if result == OK:
		get_tree().set_network_peer(peer)
		#playerList.append(Global.player_name)
		#self.add_child(lobby)
		lobby.show()
		#print("Game hosted")
		myinfo = [get_tree().get_network_unique_id(), Global.player_name, "CC0000",0,0]
		lobby.playerList.append(myinfo)
		print(lobby.playerList)
		#myinfo["name"] = Global.player_name
		#print(myinfo)
		#print(playerList)
	else:
		print("Failed to host game")
	
	#w.get_node("BlueSpawn")
	#print("Server Created")
	#advertiser.serverInfo["name"] = "A great lobby"
	#advertiser.serverInfo["port"] = Net.DEFAULT_PORT
	#print(advertiser.serverInfo)
	
func _process(delta):
	#print(playerList)
	#rpc("update_player_list_lobby",playerList)
	if Net.connecting == true:
			multiplayer_config_ui.hide()
			device_ip_address.hide()
			for i in get_children():
				if i == browser:
					browser.queue_free()
			#Net.ip_address = server_ip_address.text
			#Net.join_server()
			#var w = world.instance()
			#playerList.append(get_tree().get_network_unique_id())
			#self.add_child(lobby)
			lobby.show()
			#rpc_id(1,"connected",[get_tree().get_network_unique_id(),Global.player_name])
			Net.connecting == false
	if Net.gameStart == true:
		lobby.hide()

func _on_Join_Server_pressed():
	if server_ip_address.text != "":
		Net.ip_address = server_ip_address.text
		Net.join_server()
		print(Net.connecting)
		#if Net.connecting == true:
		#	multiplayer_config_ui.hide()
		#	device_ip_address.hide()
		#	if browser:
		#		browser.queue_free()
		#	#Net.ip_address = server_ip_address.text
		#	#Net.join_server()
		#	#var w = world.instance()
		#	playerList.append(get_tree().get_network_unique_id())
		#	self.add_child(lobby)

func _connected_to_server():
	yield(get_tree().create_timer(0.1),"timeout")
	#rpc_id(1,"connected",[get_tree().get_network_unique_id(),Global.player_name])
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

func dc(id):
	var count = 0
	for c in Net.playerList:
		if c[0] == id:
			print("Player ",c[1]," has Disconnected")
			Net.playerList.remove(count)
		count += 1

#remote func register_player(info,self_name):
#	var id = get_tree().get_rpc_sender_id()
#	myinfo = [id,self_name]
	#print(player_info)

func _on_SetName_pressed():
	Global.player_name = str(playername.text)

remotesync func gameEnded():
	Net.gameStart = false
	lobby.visible = true
	camera.make_current()
	Map.get_child(0).queue_free()
	for each in Players.get_children():
		each.queue_free()
	for each in Bullets.get_children():
		each.queue_free()
	get_node("Lobby/ReadyButton").pressed = false
	get_node("Lobby/ReadyButton").text = "Ready"
	for each in Net.playerList:
		each[3] = 1
		each[4] = 0
		if each[0] == 1:
			each[3] = 1
	

#remote func connected(PeerInfo):
#	playerList.append(PeerInfo)

#remote func update_player_list_lobby(list):
#	playerList = list
