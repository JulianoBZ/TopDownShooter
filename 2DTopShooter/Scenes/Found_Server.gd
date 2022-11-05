extends Control

onready var world = preload("res://Maps/FreeForAll1.tscn").instance()
onready var ui = self
var serverIP = ""
var serverName = ""

func _on_Button_pressed():
	print(serverIP)
	get_parent().get_parent().hide()
	self.hide()
	Net.ip_address = str(serverIP)
	Net.join_server()
	print("join server "+Net.ip_address)
	Map.add_child(world)

