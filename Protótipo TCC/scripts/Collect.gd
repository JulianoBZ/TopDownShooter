extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var screensize = Vector2()
onready var cube = preload("res://cenas/Requisito.tscn")
onready var container = get_node("container")
onready var scoretext = get_node("scoretext")
onready var rnd = RandomNumberGenerator.new()
var score = 0
var limite = 0
var ReqList = ["RF1","RF2","RF3","RNF1","RNF2","RNF3"]

# Called when the node enters the scene tree for the first time.
func _ready():
	ReqList = shuffleList(ReqList)
	for i in range (ReqList.size()):
		print(ReqList[i])
	screensize = get_viewport_rect().size

func _process(delta):
	scoretext.set_text(String(score))

func shuffleList(list):
	var shuffledList = []
	var indexList = range(list.size())
	for i in range(list.size()):
		randomize()
		var x = randi()%indexList.size()
		shuffledList.append(list[x])
		indexList.remove(x)
		list.remove(x)
	return shuffledList

func _on_Timer_timeout():
	if limite < 6:
		rnd.randomize()
		#var reqrand = rnd.randi_range(1,2)
		#var randomindex = rnd.randi_range(1,3)
		print(ReqList[limite])
		var c = cube.instance()
		var reqtext = c.get_node("reqtext")
		reqtext.set_text(String(ReqList[limite]))
		container.add_child(c)
		limite += 1
	else:
		print("Acabou!")

func _on_Area2D_area_entered(area):
	score += 1
