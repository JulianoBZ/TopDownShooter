extends OptionButton


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var killLimit = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	add_item("3")
	add_item("5")
	add_item("7")
	add_item("10")
	add_item("15")
	add_item("20")
	add_item("25")
	add_item("30")
	add_item("35")
	add_item("40")

func _process(delta):
	match get_selected_id():
		0:
			killLimit = 3
		1:
			killLimit = 5
		2:
			killLimit = 7
		3:
			killLimit = 10
		4:
			killLimit = 15
		5:
			killLimit = 20
		6:
			killLimit = 25
		7:
			killLimit = 30
		8:
			killLimit = 35
		9:
			killLimit = 40

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
