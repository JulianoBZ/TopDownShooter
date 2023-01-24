extends OptionButton

var map = 0
var type = 1
var map_name = ""

#types: FFA = 0, TEAM = 1

func _ready():
	add_item("FFA - Warehouse")
	add_item("CTF - Warehouse")

func _process(delta):
	match get_selected_id():
		0:
			map = 0
			type = 0
			map_name = "FFA - Warehouse"
		1:
			map = 1
			type = 1
			map_name = "CTF - Warehouse"
