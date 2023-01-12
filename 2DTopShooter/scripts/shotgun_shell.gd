extends RigidBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var rnd = RandomNumberGenerator.new()
onready var shotgunShell = preload("res://assets/Sounds/ShotgunShell.wav")
onready var rifleCasing = preload("res://assets/Sounds/casingDrop.wav")

# Called when the node enters the scene tree for the first time.
func _ready():
	rnd.randomize()
	yield(get_tree().create_timer(rnd.randf_range(0.1,0.3)),"timeout")
	$CollisionShape2D.disabled = true
	mode = MODE_STATIC
	$Timer.wait_time = 120
	if $Shell.is_visible():
		rpc("sound",shotgunShell)
	if $Casing.is_visible():
		rpc("sound",rifleCasing)

remotesync func sound(source):
	$AudioStreamPlayer2D.stream = source
	$AudioStreamPlayer2D.play()

func _on_Timer_timeout():
	queue_free()
