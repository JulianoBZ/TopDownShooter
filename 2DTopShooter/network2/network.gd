extends Node

const DEFAULT_PORT = 31400
const MAX_CLIENTS = 6

var server = null
var client = null

var ip_address = ""

var network_object_name_index = 0 setget network_object_name_index_set
puppet var puppet_network_object_name_index = 0 setget puppet_network_object_name_index_set

func _ready():
	if OS.get_name() == "Windows":
		ip_address = IP.get_local_addresses()[3]
	if OS.get_name() == "Windows":
		ip_address = IP.get_local_addresses()[3]
	if OS.get_name() == "Windows":
		ip_address = IP.get_local_addresses()[3]
	
	for ip in IP.get_local_addresses():
		if ip.begins_with("192.168.") && not ip.ends_with(".1"):
			ip_address = ip
	
	get_tree().connect("connected_to_server",self,"_connected_to_server")
	get_tree().connect("server_disconnected",self,"_server_disconnected")

func create_server():
	server = NetworkedMultiplayerENet.new()
	server.create_server(DEFAULT_PORT,MAX_CLIENTS)
	get_tree().set_network_peer(server)

func join_server():
	client = NetworkedMultiplayerENet.new()
	client.create_client(ip_address, DEFAULT_PORT)
	get_tree().set_network_peer(client)
	

func _connected_to_server() -> void:
	print("Conectado ao servidor com sucesso")

func _server_disconnected() -> void:
	print("Desconectado do servidor")

func puppet_network_object_name_index_set(new_value):
	network_object_name_index = new_value

func network_object_name_index_set(new_value):
	network_object_name_index = new_value
	
	if get_tree().is_network_server():
		rset("puppet_network_object_name_index",network_object_name_index)
