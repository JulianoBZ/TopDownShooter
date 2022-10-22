extends ProgressBar


onready var player = get_parent().get_node("Player")

func _ready():
	pass # Replace with function body.

func _process(delta):
	if player.active_weapon == 1:
		var porcentagem = player.Pporcentagem
		value = porcentagem*player.Pammo_count
	if player.active_weapon == 2:
		var porcentagem = player.Sporcentagem
		value = porcentagem * player.Sammo_count
