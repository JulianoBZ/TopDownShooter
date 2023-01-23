extends Control

var lobby = null

func _on_Button_pressed():
	var success = yield(lobby.join(), "completed")
	if success:
		Net.join_server()
	else:
		get_node("root/Network_setup/MessageLabel").text = "Couldn't connect"

