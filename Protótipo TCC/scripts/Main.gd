extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var main = preload("res://cenas//Main Screen.tscn")
onready var scn_container = get_node("Scene_Container")
onready var tela2 = preload("res://cenas//Tela 2.tscn")
onready var tela3 = preload("res://cenas//Tela 3.tscn")
onready var scn = main.instance()
onready var scn2 = tela2.instance()
onready var scn3 = tela3.instance()


# Called when the node enters the scene tree for the first time.
func _ready():
	scn_container.add_child(scn)
	scn.connect("b1",self,"on_b1")

func on_b1():
	print("B1 pressionado")
	scn_container.remove_child(scn)
	scn_container.add_child(scn2)
	scn2.connect("b2",self,"on_b2")

func on_b2():
	print("B2 pressionado")
	scn_container.remove_child(scn2)
	scn_container.add_child(scn3)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
