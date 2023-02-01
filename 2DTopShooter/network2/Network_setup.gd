extends Control

#export (NodePath) var advertiserPath: NodePath
#onready var advertiser := get_node(advertiserPath)
const PORT := 3333
var peer = null

var firetype = 1
var player = preload("res://Player-All.tscn")
var world
var found = preload("res://Scenes/Found_Server.tscn")
onready var browser = $ServerBrowser
onready var lobby = $Lobby
var playerList = []
var peerinfo = []
var myinfo = []
var player_info = {}
var list_aux = []
onready var fetch = GotmLobbyFetch.new()
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
	$Debug.text = str(Gotm.user)+" - "+str(Gotm.user.id)+" - "+str(Gotm.lobby)
	Gotm.initialize()
	rng.randomize()
	lobby.hide()
	browser.hide()
	get_tree().connect("network_peer_connected",self,'_player_connected')
	get_tree().connect("network_peer_disconnected",self,'_player_disconnected')
	get_tree().connect("connected_to_server",self,'_connected_to_server')
	#rpc("register_player",myinfo)
	device_ip_address.text = Net.ip_address
	#myinfo = Net.myinfo
	myinfo = [0,Global.player_name,"CC0000",0,0]
	#print(self.get_children())

func _player_connected(_id):
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
	if Players.get_child_count() > 0:
		for p in Players.get_children():
			if str(p.name) == str(id):
				dc(id)
				p.queue_free()
	#rpc("dc",id)

func _on_Create_Server_pressed():
	Net.hosting = true
	if servername.text != "":
		Net.lobby_name = servername.text
	hide_UI_show_Lobby()
	peer = NetworkedMultiplayerENet.new()
	#print(peer)
	var result = peer.create_server(PORT)
	if result == OK:
		Gotm.host_lobby()
		Gotm.lobby.name = Net.lobby_name
		Gotm.lobby.hidden = false
		
		get_tree().set_network_peer(peer)
		#playerList.append(Global.player_name)
		#self.add_child(lobby)
		lobby.show()
		#print("Game hosted")
		myinfo = [get_tree().get_network_unique_id(), Net.n, "CC0000",0,0]
		Net.playerList.append(myinfo)
		print(Net.playerList)
		#print(peer)
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
	
func _process(_delta):
	if (Net.connected || Net.hosting) == false:
		if Gotm.user.display_name == "":
			Net.n = str(playername.text)
		else:
			Net.n = Gotm.user.display_name
			$Multiplayer_configure/NameText.hide()
			$Multiplayer_configure/NameLabel.hide()
	if Net.gameStart == true:
		lobby.hide()

func _on_Join_Server_pressed():
	if server_ip_address.text != "":
		Net.ip_address = "127.0.0.1"
		Net.join_server()
		if Net.connected:
			hide_UI_show_Lobby()
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
	browser.show()
	for n in browser.get_children():
		n.queue_free()
	var f = found.instance()
	#get_tree().change_scene("res://Scenes/ServerBrowser.tscn")
	var lobbies = yield(fetch.first(), "completed")
	#print(lobbies)
	$Debug.text = "Fetch: "+str(lobbies)
	for i in lobbies:
		browser.get_node("ColorRect/ServerList").add_child(f)
		f.get_node("Label").text = i.name
		f.lobby = i

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

#func _on_SetName_pressed():
#	Global.player_name = str(playername.text)
#	GotmUser.display_name = str(playername.text)
	#$Debug.text = str(GotmUser.display_name)

remotesync func gameEnded():
	Net.gameStart = false
	lobby.visible = true
	camera.make_current()
	if Map.get_child_count() > 0:
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
	

func hide_UI_show_Lobby():
	multiplayer_config_ui.hide()
	device_ip_address.hide()
	lobby.show()
	browser.hide()


#remote func connected(PeerInfo):
#	playerList.append(PeerInfo)

#remote func update_player_list_lobby(list):
#	playerList = list

