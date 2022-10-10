extends Area2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var screensize = Vector2()
onready var rnd = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	screensize = get_viewport_rect().size
	rnd.randomize()
	var random = rnd.randf_range(40,screensize.x-40)
	position.x = random
	pass # Replace with function body.


func _process(delta):
	
	position.y += (100 *delta)
	

func _on_Area2D_area_entered(area):
	self.queue_free()
