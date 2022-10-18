extends RigidBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var rnd = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	rnd.randomize()
	yield(get_tree().create_timer(rnd.randf_range(0.5,1.5)),"timeout")
	$CollisionShape2D.disabled = true
	mode = MODE_STATIC


func _process(delta):
	pass
	#yield(get_tree().create_timer(0.1),"timeout")
	#add_torque(-100)
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
