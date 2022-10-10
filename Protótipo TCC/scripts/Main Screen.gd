extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

signal b1

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_Button_pressed():
	emit_signal("b1")
	print("Sinal B1")



