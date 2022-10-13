extends ProgressBar


onready var player = get_parent().get_node("Player")


func _ready():
	pass # Replace with function body.

func _process(delta):
	var porcentagem = player.porcentagem
	value = porcentagem*player.ammo_count
