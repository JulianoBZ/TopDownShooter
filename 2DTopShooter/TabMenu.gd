extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var count = 0

onready var PLU = preload("res://network2/PlayerListUnit.tscn")
onready var TabPlayerList = Net.playerList

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _process(_delta):
	
	if Net.hosting:
		for p in Players.get_children():
			for pl in Net.playerList:
				if str(p.name) == str(pl[0]):
					pl[3] = p.kills
					pl[4] = p.deaths
	TabPlayerList = Net.playerList
	if Net.hosting:
		TabPlayerList.sort_custom(self,"sort_TabList")
		rpc("UpdateTabList",TabPlayerList)
	#for n in $TabList.get_children():
	#	n.queue_free()
	#for p in TabPlayerList:
	#	var playerunit = PLU.instance()
	#	playerunit.get_node("ReadyRect").hide()
	#	playerunit.get_node("FragRect").show()
	#	playerunit.get_node("FragRect/KillLabel").text = str(p[3])+'/'+str(p[4])
	#	playerunit.get_node("ColorRect/Label").text = str(p[1])
	#	playerunit.get_node("ColorRect").color = Color(str(p[2]))
	#	$TabList.add_child(playerunit)

remotesync func UpdateTabList(list):
	#Net.playerList = list
	count += 1
	if count == 30:
		Net.playerList = list
		###############
		for n in $TabList.get_children():
			n.queue_free()
		for p in TabPlayerList:
			var playerunit = PLU.instance()
			playerunit.get_node("ReadyRect").hide()
			playerunit.get_node("FragRect").show()
			playerunit.get_node("FragRect/KillLabel").text = str(p[3])+'/'+str(p[4])
			playerunit.get_node("ColorRect/Label").text = str(p[1])
			playerunit.get_node("ColorRect").color = Color(str(p[2]))
			$TabList.add_child(playerunit)
		#############
		count = 0

func sort_TabList(a, b):
	if a[3] > b[3]:
		return true
	return false
