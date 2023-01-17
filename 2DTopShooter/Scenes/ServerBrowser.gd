extends Control

onready var ServerList = $ColorRect/ServerList
onready var fetch = get_parent().fetch
var found = preload("res://Scenes/Found_Server.tscn")


func _on_next_pressed():
	for each in ServerList.get_children():
		queue_free()
	var f = found.instance()
	var lobbies = yield(fetch.next(), "completed")
	for i in lobbies:
		ServerList.add_child(f)
		f.get_node("Label").text = i.name
		f.lobby = i


func _on_previous_pressed():
	for each in ServerList.get_children():
		queue_free()
	var f = found.instance()
	var lobbies = yield(fetch.previous(), "completed")
	for i in lobbies:
		ServerList.add_child(f)
		f.get_node("Label").text = i.name
		f.lobby = i
