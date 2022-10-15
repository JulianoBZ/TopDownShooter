extends Control

var player = preload("res://Player-All.tscn")
var world = preload("res://Maps/Map01.tscn")
onready var multiplayer_config_ui = $Multiplayer_configure
onready var server_ip_address = $Multiplayer_configure/Server_IP_address
onready var device_ip_address = $Multiplayer_configure/CanvasLayer/Device_IP

func _ready():
	get_tree().connect("network_peer_connected",self,'_player_connected')
	get_tree().connect("network_peer_disconnected",self,'_player_disconnected')
	get_tree().connect("connected_to_server",self,'_connected_to_server')
	
	device_ip_address.text = Net.ip_address

func _player_connected(id):
	print("Player: "+str(id)+" has connected")
	instance_player(id)

func _player_disconnected(id):
	print("Player: "+str(id)+" has disconnected")
	
	if Players.has_node(str(id)):
		Players.get_node(str(id)).queue_free()


func _on_Create_Server_pressed():
	multiplayer_config_ui.hide()
	Net.create_server()
	var w = world.instance()
	Map.add_child(w)
	w.get_node("BlueSpawn")
	print("Server Created")
	instance_player(get_tree().get_network_unique_id())

func _on_Join_Server_pressed():
	if server_ip_address.text != "":
		multiplayer_config_ui.hide()
		Net.ip_address = server_ip_address.text
		Net.join_server()
		var w = world.instance()
		Map.add_child(w)

func _connected_to_server():
	yield(get_tree().create_timer(0.1),"timeout")
	instance_player(get_tree().get_network_unique_id())

func instance_player(id):
	var player_instance = Global.instance_node_at_location(player, Players, Vector2(rand_range(0,1366), rand_range(0,768)))
	player_instance.name = str(id)
	player_instance.set_network_master(id)
	
	
	
