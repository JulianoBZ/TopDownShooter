extends Node

const DEFAULT_PORT = 3333
const MAX_CLIENTS = 12
var external_ip = 0

var lobby_name = "Normal Lobby"

var server = null
var client = null
var gameStart = false

var n = ""
var color = "CC0000"
var myinfo = [0,n,color,0,0]
var hosting = false
var onLobby = false
var connected = false
var playerList = []

var ip_address = "127.0.0.1"
#var adapter
#var check = "ZeroTier One"
var lobby = preload("res://network2/Lobby.tscn").instance()

var network_object_name_index = 0 setget network_object_name_index_set
puppet var puppet_network_object_name_index = 0 setget puppet_network_object_name_index_set

func _ready():
	#adapter = get_local_interfaces()
	#for ad in IP.get_local_interfaces():
	#	if (check in ad["friendly"]):
	#		print(ad["friendly"])
	#		print(ad["addresses"][1])
	#print(IP.get_local_interfaces())
	
	if OS.get_name() == "Windows":
		ip_address = str(IP.get_local_addresses()[3])
	elif OS.get_name() == "Android":
		ip_address = IP.get_local_addresses()[0]
	else:
		ip_address = IP.get_local_addresses()[3]
	
	for ip in IP.get_local_addresses():
		if ip.begins_with("192.168.0."):
			ip_address = ip
	
	get_tree().connect("connected_to_server",self,"_connected_to_server")
	get_tree().connect("server_disconnected",self,"_server_disconnected")

func _process(_delta):
	if Net.hosting:
		update_player_list_lobby(playerList)

func create_server():
	pass
	###############################
	#server = NetworkedMultiplayerENet.new()
	#server.create_server(DEFAULT_PORT,MAX_CLIENTS)
	#get_tree().set_network_peer(server)

func join_server():
	client = NetworkedMultiplayerENet.new()
	client.create_client(ip_address, DEFAULT_PORT)
	get_tree().set_network_peer(client)
	

func _connected_to_server() -> void:
	print("Conectado ao servidor com sucesso")
	myinfo = [get_tree().get_network_unique_id(),Net.n,color,0,0]
	rpc_id(1,"Pconnected",myinfo)
	connected = true
	get_node("/root/Network_setup").hide_UI_show_Lobby()

func _server_disconnected() -> void:
	get_tree().network_peer = null
	Net.playerList.clear()
	hosting = false
	onLobby = false
	connected = false
	print("Desconectado do servidor")
	#get_tree().quit()
	#client = null
	print(client)
	get_node("/root/Network_setup").gameEnded()
	get_node("/root/Network_setup/Lobby").visible = false
	get_node("/root/Network_setup/Lobby/ReadyButton").pressed = false
	get_node("/root/Network_setup").visible = true
	get_node("/root/Network_setup/Multiplayer_configure").visible = true

func puppet_network_object_name_index_set(new_value):
	network_object_name_index = new_value

func network_object_name_index_set(new_value):
	network_object_name_index = new_value
	
	if get_tree().is_network_server():
		rset("puppet_network_object_name_index",network_object_name_index)

remotesync func update_player_list_lobby(list):
	playerList = list

#remote func connected(peerInfo):
#	playerList.append_array(peerInfo)

remote func Pconnected(PeerInfo):
	var peerinfo
	peerinfo = PeerInfo
	print(peerinfo)
	Net.playerList.append(peerinfo)
	#rpc("update_player_list_lobby",playerList)
	#print(PeerInfo)
	print(playerList)
