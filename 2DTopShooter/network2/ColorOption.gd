extends OptionButton


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var color = ""
var newcolor = ""
var oldcolor = ""

# Called when the node enters the scene tree for the first time.
func _ready():
	add_item("Red")
	add_item("Blue")
	add_item("Green")
	add_item("Pink")
	add_item("Yellow")


func _process(_delta):
	match get_selected_id():
		0:
			color = "CC0000"
		1:
			color = "000099"
		2:
			color = "009900"
		3:
			color = "FF00FF"
		4:
			color = "FFFF00"
	
	Net.color = color
	
	if (Net.connected || Net.hosting) && color != oldcolor:
		rpc("UpdateColor",color,get_tree().get_network_unique_id())
	oldcolor = color

remotesync func UpdateColor(new_color,id):
	color = new_color
	for p in Net.playerList:
		if p[0] == id:
			p[2] = color
			print(Net.playerList)

func UpdateColor2():
	rpc("UpdateColor",color,get_tree().get_network_unique_id())

