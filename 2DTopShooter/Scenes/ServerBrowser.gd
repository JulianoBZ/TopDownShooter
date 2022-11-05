extends Control

export (NodePath) var serverListPath: NodePath
onready var serverList := get_node(serverListPath)
onready var found_server = preload("res://Scenes/Found_Server.tscn")


func _on_ServerListener_new_server(serverInfo):
	print("new server found")
	# Create some UI for the newly found server
	var serverNode := Label.new()
	var serverButton = Button.new()
	var FS = found_server.instance()
	#FS.get_node("Label").text = "%s - %s" % [serverInfo.ip, serverInfo.name]
	#FS.serverIP = str(serverInfo.ip)
	#FS.serverName = serverInfo.name
	
	#serverButton.text = "Join"
	#serverButton.rect_position = serverNode.rect_position
	#serverButton.connect("pressed",self,"_on_ServerButton_pressed")
	serverNode.text = "%s - %s" % [serverInfo.ip, serverInfo.name]
	
	serverList.add_child(serverNode)
	#serverList.add_child(serverButton)
	#serverList.add_child(FS)

func _on_ServerButton_pressed():
	#Net.ip_address = serverInfo.ip
	#Net.join_server()
	print("Tentando entrar")
	#var w = world.instance()

func _on_ServerListener_remove_server(serverIp):
	for serverNode in serverList.get_children():
		# Just a hacky way to identify the Node and remove it
		if serverNode.text.find(serverIp) > -1:
			serverList.remove_child(serverNode)
			break

func _on_BackButton_pressed():
	get_tree().change_scene("res://network2/Network_setup.tscn")
