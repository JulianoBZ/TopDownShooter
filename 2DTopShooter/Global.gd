extends Node

export var primary = 1
export var secondary = 1
export var player_name = "Player"
export var frame = 1
export var cursor = preload("res://assets/CursorAim.png")

func _ready():
	Input.set_custom_mouse_cursor(cursor,0,Vector2(16,16))

func instance_node_at_location(node: Object, parent: Object, location: Vector2):
	var node_instance = instance_node(node, parent)
	node_instance.global_position = location
	return node_instance

func instance_node(node: Object, parent: Object):
	var node_instance = node.instance()
	parent.add_child(node_instance)
	return node_instance
