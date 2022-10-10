extends Label


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var Player = get_tree().get_root().get_node("Node/Player")
var ammo_pos = Vector2(15,557)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _process(delta):
	text = "Ammo: " + str(Player.ammo_count)
