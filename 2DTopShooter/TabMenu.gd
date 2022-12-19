extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var PLU = preload("res://network2/PlayerListUnit.tscn")
onready var TabPlayerList = Net.playerList

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _process(delta):
	
	if Net.hosting:
		for p in Players.get_children():
			for pl in Net.playerList:
				if str(p.name) == str(pl[0]):
					pl[3] = p.kills
	TabPlayerList = Net.playerList
	if Net.hosting:
		TabPlayerList.sort_custom(self,"sort_TabList")
		rpc("UpdateTabList",TabPlayerList)
	for n in $TabList.get_children():
		n.queue_free()
	for p in TabPlayerList:
		var playerunit = PLU.instance()
		playerunit.get_node("ColorRect/Label").text = str(p[1]," - ",p[3])
		playerunit.get_node("ColorRect").color = Color(str(p[2]))
		$TabList.add_child(playerunit)

remotesync func UpdateTabList(list):
	TabPlayerList = list

func sort_TabList(a, b):
	if a[3] > b[3]:
		return true
	return false
