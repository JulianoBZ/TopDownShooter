extends Node

var success = false

func _process(delta):
	if success == false:
		get_parent().move_child(self, get_parent().get_child_count())
		success = true

