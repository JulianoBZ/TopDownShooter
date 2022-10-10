extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

signal b3
signal b4

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_Button3_pressed():
	emit_signal("b3")
	print("b3")


func _on_Button4_pressed():
	emit_signal("b4")
	print("b4")
