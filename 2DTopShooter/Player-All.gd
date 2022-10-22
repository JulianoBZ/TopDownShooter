extends KinematicBody2D

onready var Pname = $Name
onready var player = $Player
var speed = 200
var pos = Vector2()
var sprinting = false
var health = 100
var vida = 100
var alive = true
var direction = Vector2()
var lastdir = Vector2()
onready var camera = get_node("Camera2D")
#puppet var puppet_position = Vector2(0,0) #setget puppet_position_set
#puppet var puppet_direction = Vector2()
var can_move = true
var camera_lock = false
var esc_pressed = false
#onready var tween = $Tween
onready var spawns = get_tree().get_root().get_node("/root/Map").get_child(0).spawns
var rng = RandomNumberGenerator.new()
onready var killcount = $KillCount
onready var Menu = $Esc_Menu/Panel
var kills = 0
var prev_kills = kills
onready var deathskull = preload("res://Scenes/DeadPlayer.tscn")
var trysprint = false

signal pdeath
signal respawned

func _ready():
	rng.randomize()
	can_move = true
	
	#player.connect("pdeath",self,"_on_playerall_pdeath")

func _process(delta):
	if is_network_master() && can_move:
		rpc("on_kill")
		#Menu.rect_global_position = global_position
		rpc("hide_bars")
		camera.make_current()
		#print(camera.get_camera_position())
		if camera_lock == false:
			var mouse_pos = get_global_mouse_position()
			camera.offset_h = (mouse_pos.x - position.x) / (1366 / 3)
			camera.offset_v = (mouse_pos.y - position.y) / (768 / 3)
		#$Health.rect_position = camera.get_camera_position()
		
		if Input.is_action_pressed("Sprint"):
			speed = 400
			trysprint = true
		else:
			sprinting = false
			speed = 200
		
		if health <= 0:
			alive = false
			rpc("death")
		
		if Input.is_action_just_pressed("Esc_Menu"):
			if esc_pressed:
				print("Error")
				camera_lock = false
				Menu.visible = false
				esc_pressed = false
				can_move = true
				player.can_fire = true
			else: 
				camera.offset_h = 0
				camera.offset_v = 0
				Menu.visible = true
				camera_lock = true
				esc_pressed = true
				can_move = false
				player.can_fire = false
		
		killcount.text = str(kills)


func _physics_process(delta):
	if is_network_master() && can_move:
		direction = Vector2()
		sprinting = false
		if Input.is_action_pressed("up"):
			direction.y -= 1
			if trysprint == true:
				sprinting = true
		if Input.is_action_pressed("down"):
			direction.y += 1
			if trysprint == true:
				sprinting = true
		if Input.is_action_pressed("left"):
			direction.x -= 1
			if trysprint == true:
				sprinting = true
		if Input.is_action_pressed("right"):
			direction.x += 1
			if trysprint == true:
				sprinting = true
		if Input.is_action_just_pressed("kys"):
			health = 0
		direction = direction.normalized()
		#global_position = player.global_position
		move_and_slide(direction * speed)
		rpc_unreliable("update_position",position)
#	else:
#		if not tween.is_active():
#			move_and_slide(puppet_direction * speed)

remote func update_position(pos):
	position = pos

remotesync func death():
	var skull = deathskull.instance()
	skull.position = position
	Bullets.add_child(skull)
	can_move = false
	$Corpo.disabled = true
	$KillCount.visible = false
	$HealthBar.visible = false
	$AmmoBar.visible = false
	emit_signal("pdeath",self)
	yield(get_tree().create_timer(3),"timeout")
	position = spawns[str(rng.randi_range(1,spawns.size()))].position
	health = 100
	can_move = true
	$Corpo.disabled = false
	$KillCount.visible = true
	$HealthBar.visible = true
	$AmmoBar.visible = true
	emit_signal("respawned")

remote func hide_bars():
	player.vision.visible = false
	$HealthBar.visible = false
	$AmmoBar.visible = false
	$Ammo.visible = false

remotesync func on_kill():
	if kills > prev_kills:
		prev_kills = kills
		health += 30
	if health > 100:
		health = 100

#func puppet_position_set(new_value):
#	puppet_position = new_value
#	
#	tween.interpolate_property(self, "global_position",global_rotation,puppet_position,0.1)
#	tween.start()
