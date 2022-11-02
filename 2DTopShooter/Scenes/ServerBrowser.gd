extends Control

export (NodePath) var serverListPath: NodePath
onready var serverList := get_node(serverListPath)

func _on_ServerListener_new_server(serverInfo):
	print("new server found")
	# Create some UI for the newly found server
	var serverNode := Label.new()
	var serverButton = Button.new()
	serverButton.text = "Join"
	#serverButton.position = serverNode.rect_position
	serverButton.connect("pressed",self,"_on_ServerButton_pressed")
	serverNode.text = "%s - %s" % [serverInfo.ip, serverInfo.name]
	serverList.add_child(serverNode)

func _on_ServerButton_pressed(serverInfo):
	Net.ip_address = serverInfo.ip
	Net.join_server()
	#var w = world.instance()

func _on_ServerListener_remove_server(serverIp):
	for serverNode in serverList.get_children():
		# Just a hacky way to identify the Node and remove it
		if serverNode.text.find(serverIp) > -1:
			serverList.remove_child(serverNode)
			break
