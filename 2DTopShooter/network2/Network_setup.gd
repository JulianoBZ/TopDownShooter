extends Control

var firetype = 1
var player = preload("res://Player-All.tscn")
var world = preload("res://Maps/FreeForAll1.tscn").instance()
onready var multiplayer_config_ui = $Multiplayer_configure
onready var server_ip_address = $Multiplayer_configure/Server_IP_address
onready var device_ip_address = $Multiplayer_configure/CanvasLayer/Device_IP
onready var playername = $Multiplayer_configure/NameText
#onready var ffa1 = preload("res://Maps/FreeForAll1.tscn")
#var spawns = {"1":world.get_node("Spawn1"),"2":world.get_node("Spawn2"),"3":world.get_node("Spawn3"),"4":world.get_node("Spawn4")
#,"5":world.get_node("Spawn5"),"6":world.get_node("Spawn6"),"7":world.get_node("Spawn7")}
var rng = RandomNumberGenerator.new()


func _ready():
	rng.randomize()
	get_tree().connect("network_peer_connected",self,'_player_connected')
	get_tree().connect("network_peer_disconnected",self,'_player_disconnected')
	get_tree().connect("connected_to_server",self,'_connected_to_server')
	
	device_ip_address.text = Net.ip_address

func _player_connected(id):
	print("Player: "+str(playername.text)+" has connected")
	instance_player(id)

func _player_disconnected(id):
	print("Player: "+str(playername.text)+" has disconnected")
	
	if Players.has_node(str(playername.text)):
		Players.get_node(str(playername.text)).queue_free()

func _on_Create_Server_pressed():
	multiplayer_config_ui.hide()
	device_ip_address.hide()
	Net.create_server()
	#var w = world.instance()
	Map.add_child(world)
	#w.get_node("BlueSpawn")
	print("Server Created")
	instance_player(get_tree().get_network_unique_id())

func _on_Join_Server_pressed():
	if server_ip_address.text != "":
		multiplayer_config_ui.hide()
		device_ip_address.hide()
		Net.ip_address = server_ip_address.text
		Net.join_server()
		#var w = world.instance()
		Map.add_child(world)

func _connected_to_server():
	yield(get_tree().create_timer(0.1),"timeout")
	instance_player(get_tree().get_network_unique_id())

func instance_player(id):
	Global.player_name = str(playername.text)
	var player_instance = Global.instance_node_at_location(player, Players, (world.spawns[str(rng.randi_range(1,7))]).position)
	#player_instance.name = "Player: " + str(playername.text)
	player_instance.set_network_master(id)

func _on_weaponbut1_pressed():
	Global.firetype = 1

func _on_weaponbut2_pressed():
	Global.firetype = 2
