extends ProgressBar


onready var player = get_parent()


func _ready():
	pass # Replace with function body.

func _process(delta):
	value = player.health
