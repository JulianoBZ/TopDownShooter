extends KinematicBody2D

onready var Pname = $Name
onready var player = $Player
var frame = 2
var desired_frame = 2
var speed = 200
var base_speed = 200
var pos = Vector2()
var sprinting = false
export var health = 100
export var max_health = 100
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
onready var ammo_crate = preload("res://Scenes/Ammo_pickup.tscn")
onready var Classbut1 = get_node("Esc_Menu/Panel/Classbut1")
onready var Classbut2 = get_node("Esc_Menu/Panel/Classbut2")
onready var Classbut3 = get_node("Esc_Menu/Panel/Classbut3")
var trysprint = false
var lastdamage
var sprint
onready var shift_texture = get_node("ShiftSkill")
onready var shift_timer = get_node("ShiftSkill/Timer")
onready var afterimage = preload("res://Scenes/player_afterimage.tscn")
signal pdeath
signal respawned
signal dashing
signal not_dashing
signal rushing
var dashing
var candash = true

func _ready():
	rng.randomize()
	can_move = true
	if Global.frame == 1:
		frame = 1
		Classbut1.pressed = true
		desired_frame = 1
	if Global.frame == 2:
		frame = 2
		Classbut2.pressed = true
		desired_frame = 2
	if Global.frame == 3:
		frame = 3
		Classbut3.pressed = true
		desired_frame = 3
	#rset_unreliable("frame",frame)
	set_stats(frame)
	#rpc("set_stats",frame,self)
	
	
	#player.connect("pdeath",self,"_on_playerall_pdeath")

func _process(delta):
	if is_network_master() && can_move:
		rpc_unreliable("update_stats",health, max_health)
		rpc("on_kill")
		#Menu.rect_global_position = global_position
		#rpc("hide_bars")
		camera.make_current()
		#print(camera.get_camera_position())
		if camera_lock == false:
			var mouse_pos = get_global_mouse_position()
			camera.offset_h = (mouse_pos.x - position.x) / (1366 / 3)
			camera.offset_v = (mouse_pos.y - position.y) / (768 / 3)
		#$Health.rect_position = camera.get_camera_position()
		
		##########################################################################
		#Shift skills
		
		#frame2 = sprint
		if Input.is_action_pressed("Sprint") && frame == 2:
			print("run")
			speed = base_speed * 2
			trysprint = true
		else:
			sprinting = false
			speed = base_speed
		
		#frame1 = dash
		if Input.is_action_just_pressed("Sprint") && frame == 1 && candash:
			#sprinting = true
			emit_signal("dashing")
		
		#frame3 = bullrush
		if Input.is_action_pressed("Sprint") && frame == 3 && sprinting == false && candash && !dashing:
			shift_texture.max_value = 60
			yield(get_tree().create_timer(0.01),"timeout")
			shift_texture.value += 1
			if shift_texture.value == 60:
				emit_signal("rushing")
		elif !Input.is_action_pressed("Sprint") && frame == 3:
			shift_texture.value -= 1
		
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
	lastdamage.kills += 1
	
	var skull = deathskull.instance()
	skull.position = position
	var ammo = ammo_crate.instance()
	ammo.position = position
	Bullets.add_child(ammo)
	Bullets.add_child(skull)
	
	can_move = false
	$Corpo.disabled = true
	$KillCount.visible = false
	#$HealthBar.visible = false
	emit_signal("pdeath")
	
	yield(get_tree().create_timer(3),"timeout")
	position = spawns[str(rng.randi_range(1,spawns.size()))].position
	health = max_health
	can_move = true
	set_stats(desired_frame)
	yield(get_tree().create_timer(0.1),"timeout")
	$Corpo.disabled = false
	$KillCount.visible = true
	#$HealthBar.visible = true
	emit_signal("respawned")

remote func hide_bars():
	player.vision.visible = false
	$HealthBar.visible = false
	$Ammo.visible = false
	$Health.visible = false
	shift_texture.visible = false

remotesync func on_kill():
	if kills > prev_kills:
		prev_kills = kills
		health += 30
	if health > max_health:
		health = max_health

#192.168.191.107

#No futuro isso vai ter que atualizar pra todo mundo certinho, mas por agora q se foda kkkk
func set_stats(f):
	if f == 1:
		speed = 300
		base_speed = 350
		health = 50
		max_health = 50
	if f == 2:
		speed = 200
		base_speed = 250
		health = 100
		max_health = 100
	if f == 3:
		speed = 100
		base_speed = 200
		health = 175
		max_health = 175

remote func update_stats(h,mh):
	health = h
	max_health = mh

#func puppet_position_set(new_value):
#	puppet_position = new_value
#	
#	tween.interpolate_property(self, "global_position",global_rotation,puppet_position,0.1)
#	tween.start()


func _on_ApplyButton_pressed():
	if Classbut1.pressed == true:
		desired_frame = 1
	if Classbut2.pressed == true:
		desired_frame = 2
	if Classbut3.pressed == true:
		desired_frame = 3
	
	can_move = true
	esc_pressed = false
	camera_lock = false


func _on_PlayerAll_dashing():
	#self.sprinting = true
	player.sprinting = true
	candash = false
	var spr = true
	var c = 0
	#print(sprinting)
	shift_texture.max_value = 25
	#shift_texture.visible = true
	while spr:
		#self.sprinting = true
		speed = 1000
		yield(get_tree().create_timer(0.01),"timeout")
		shift_texture.value += 1
		c += 1
		if c == 3:
			c = 0
			rpc("afterimage")
		if alive == false:
			#sprinting = false
			shift_texture.visible = false
			shift_texture.value = 0
			break
		if shift_texture.value == 25:
			#shift_texture.visible = false
			#shift_texture.value = 0
			spr = false
			#sprinting = false
			speed = base_speed
			trysprint = false
			emit_signal("not_dashing")

remotesync func afterimage():
	var ai = afterimage.instance()
	ai.rotation_degrees = player.rotation_degrees + 90
	ai.position = position
	Players.add_child(ai)


func _on_PlayerAll_not_dashing():
	var nspr = true
	self.sprinting = true
	while nspr:
		yield(get_tree().create_timer(0.1),"timeout")
		shift_texture.value -= 1
		if shift_texture.value == 0:
			nspr = false
			self.sprinting = false
			trysprint = false
			candash = true


func _on_PlayerAll_rushing():
	can_move = false
	var lookdir = Vector2(cos(deg2rad(player.rotation_degrees)), sin(deg2rad(player.rotation_degrees)))
	dashing = true
	#shift_texture.max_value = 50
	while dashing:
		rpc_unreliable("update_position",position)
		yield(get_tree().create_timer(0.01),"timeout")
		shift_texture.value -= 1
		move_and_slide(lookdir * 500)
		if alive == false:
			self.sprinting = false
			shift_texture.visible = false
			shift_texture.value = 0
			break
		if shift_texture.value == 0:
			#shift_texture.visible = false
			#shift_texture.value = 0
			self.sprinting = false
			speed = base_speed
			trysprint = false
			dashing = false
			#emit_signal("not_dashing")
			can_move = true
