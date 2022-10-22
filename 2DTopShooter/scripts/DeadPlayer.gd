extends Sprite

var counter = 0
var opacity = 205
onready var timer = $Timer

func _ready():
	timer.start()

#func _process(delta):
#	#if opacity < 100:
#	#	queue_free()

#remotesync func reduce_opacity():
#	yield(get_tree().create_timer(3),"timeout")
#	modulate.a8 = opacity
#	opacity = opacity/2
#	if opacity < 50:
#		queue_free()


func _on_Timer_timeout():
	modulate.a8 = opacity
	opacity -= 50
	if opacity < 50:
		queue_free()
	timer.start()
