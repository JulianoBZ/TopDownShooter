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


func _process(delta):
	oldcolor = color
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
	
	#if Net.hosting == true && color != oldcolor:
	#	UpdateColor(color,1)
		#print(color,get_tree().get_network_unique_id())
	
	if (Net.hosting || Net.onLobby) && color != oldcolor:
		#if color != oldcolor:
		#	if is_network_master():
		#		UpdateColor(color,1)
		#if color != oldcolor:
		rpc("UpdateColor",color,get_tree().get_network_unique_id())
			#print(color,get_tree().get_network_unique_id())

remotesync func UpdateColor(new_color,id):
	newcolor = new_color
	for p in get_parent().get_parent().playerList:
		if p[0] == id:
			p[2] = newcolor
			print(get_parent().get_parent().playerList)
