extends KinematicBody2D

onready var Pname = $Name
onready var player = $Player
var texture = ""
var frame = 2
var desired_frame = 2
var speed = 200
var base_speed = 200
var pos = Vector2()
var sprinting = false
export var health = 100
export var max_health = 100
#var vida = 100
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
export var kills = 0
var newkill = 0
var prev_kills = kills
var deaths = 0
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
onready var DashSound = $DashSound
var candash = true
var rushPressure = "res://assets/Sounds/PressureRelease.mp3"
onready var steam = preload("res://Scenes/Steam_Particle.tscn")
var PlayersCharacters
onready var t = preload("res://assets/t.png")
onready var c = preload("res://assets/c.png")
onready var q = preload("res://assets/q.png")

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
	set_stats(frame)
	
	
	#PlayersCharacters = Players.get_children()
	#for n in PlayersCharacters:
	#	var plname = Label.new()
	#	plname.text = n.Pname.text
	#	print(n.Pname.text)
	#	$TabMenu/VBoxContainer.add_child(plname)
	#player.connect("pdeath",self,"_on_playerall_pdeath")

func _process(delta):
	if is_network_master() && can_move:
		rpc_unreliable("set_name",Global.player_name)
		rpc_unreliable("update_stats",health, max_health,frame)
		#rpc_unreliable("update_sprite",get_tree().get_network_unique_id(),texture)
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
		
		if $BowBar.value > 0:
			$BowBar.show()
		else:
			$BowBar.hide()
		
		##########################################################################
		#Shift skills
		
		#frame2 = sprint
		if Input.is_action_pressed("Sprint") && frame == 2:
			speed = base_speed * 2
			#trysprint = true
			sprinting = true
		else:
			sprinting = false
			#trysprint = false
			speed = base_speed
		
		#frame1 = dash
		if Input.is_action_just_pressed("Sprint") && frame == 1 && candash:
			#sprinting = true
			dashing()
		
		#frame3 = bullrush
		if Input.is_action_pressed("Sprint") && frame == 3 && sprinting == false && candash && !dashing:
			shift_texture.max_value = 60
			yield(get_tree().create_timer(0.01),"timeout")
			shift_texture.value += 1
			if shift_texture.value == 60:
				#emit_signal("rushing")
				rushing()
		elif !Input.is_action_pressed("Sprint") && frame == 3:
			shift_texture.value -= 1
		
		if health <= 0:
			alive = false
			rpc("death")
		
		#Tab
		if Input.is_action_pressed("Tab"):
			$TabMenu.show()
			camera.offset_h = 0
			camera.offset_v = 0
		else:
			$TabMenu.hide()
		
		#for i in $TabMenu/VBoxContainer.get_children():
		#	i.queue_free()
		#PlayersCharacters = Players.get_children()
		#for n in PlayersCharacters:
		#	var plname = Label.new()
		#	plname.text = n.Pname.text
		#	$TabMenu/VBoxContainer.add_child(plname)
		
		#Esc
		if Input.is_action_just_pressed("Esc_Menu"):
			print(Menu.visible)
			if Menu.visible == true:
				Menu.visible = false
				print("Close")
				#print(Menu.visible)
				camera_lock = false
				#esc_pressed = false
				#can_move = true
				player.can_fire = true
			else:
				Menu.visible = true
				print("Open")
				#print(Menu.visible)
				camera.offset_h = 0
				camera.offset_v = 0
				camera_lock = true
				#esc_pressed = true
				#can_move = false
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
	if lastdamage != null:
		lastdamage.kills += 1
	deaths += 1
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
	
	yield(get_tree().create_timer(Map.get_child(0).deathTimer),"timeout")
	position = Map.get_child(0).spawns[str(rng.randi_range(1,spawns.size()))].position
	health = max_health
	can_move = true
	set_stats(desired_frame)
	yield(get_tree().create_timer(0.1),"timeout")
	$Corpo.disabled = false
	$KillCount.visible = true
	alive = true
	#$HealthBar.visible = true
	emit_signal("respawned")

remote func hide_bars():
	player.vision.visible = false
	$HealthBar.visible = false
	$Ammo.visible = false
	$Health.visible = false
	$BowBar.visible = false
	shift_texture.visible = false

remotesync func on_kill():
	if kills > prev_kills:
		prev_kills = kills
		#health += 30
		#rpc_id(1,"UpdateKills",kills,get_tree().get_network_unique_id())
		#if Net.onLobby:
		#	rpc_id(1,"UpdateKills",kills,get_tree().get_network_unique_id())
		#	print(Net.playerList)
		#if Net.hosting:
		#	for p in Net.playerList:
		#		if p[0] == 1:
		#			p[3] = kills
		#	rpc("UpdateKillList",Net.playerList)
			
	if health > max_health:
		health = max_health

#192.168.191.107

#No futuro isso vai ter que atualizar pra todo mundo certinho, mas por agora q se foda kkkk
func set_stats(f):
	if f == 1:
		speed = 300
		base_speed = 300
		health = 75
		max_health = 75
		frame = 1
		texture = t
	if f == 2:
		speed = 250
		base_speed = 200
		health = 125
		max_health = 125
		frame = 2
		texture = c
	if f == 3:
		speed = 200
		base_speed = 200
		health = 150
		max_health = 150
		frame = 3
		texture = q

remote func update_sprite(id,frame):
	if Net.playerList.size() == Players.get_child_count():
		for n in Players.get_children():
			if str(n.name) == str(id):
				match frame:
					1:
						get_node("Player/Sprite").texture = t
					2:
						get_node("Player/Sprite").texture = c
					3:
						get_node("Player/Sprite").texture = q
				#n.get_node("Player/Sprite").texture = tex
	#print(player.get_node("Sprite").texture)

remotesync func update_stats(h,mh,frame):
	health = h
	max_health = mh
	match frame:
		1:
			get_node("Player/Sprite").texture = t
		2:
			get_node("Player/Sprite").texture = c
		3:
			get_node("Player/Sprite").texture = q
	#get_node("Player/Sprite").texture = texture
	rpc("update_sprite",get_tree().get_network_unique_id(),frame)
	#print(tex)

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
	Menu.visible = false
	camera_lock = false


func dashing():
	#self.sprinting = true
	player.sprinting = true
	candash = false
	var spr = true
	var c = 0
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
		if shift_texture.value == 25:
			#shift_texture.visible = false
			#shift_texture.value = 0
			spr = false
			#sprinting = false
			speed = base_speed
			trysprint = false
			not_dashing()

remotesync func afterimage():
	var ai = afterimage.instance()
	ai.rotation_degrees = player.rotation_degrees + 90
	ai.position = position
	Bullets.add_child(ai)


func not_dashing():
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


func rushing():
	can_move = false
	var lookdir = Vector2(cos(deg2rad(player.rotation_degrees)), sin(deg2rad(player.rotation_degrees)))
	dashing = true
	#var lastdir = 0
	#var lookdir = Vector2()
	#var lookdeg = 0
	#print(dashing)
	while dashing:
		player.can_look = false
		#var lastdir = lookdir
		lookdir = Vector2(cos(deg2rad(clamp(player.rotation_degrees,player.rotation_degrees+2,player.rotation_degrees-2))), sin(deg2rad(player.rotation_degrees)))
		if camera_lock == false:
			var mouse_pos = get_global_mouse_position()
			camera.offset_h = (mouse_pos.x - position.x) / (1366 / 3)
			camera.offset_v = (mouse_pos.y - position.y) / (768 / 3)
		if Input.is_action_pressed("right"):
			player.rotation_degrees += 1.5
		if Input.is_action_pressed("left"):
			player.rotation_degrees -= 1.5
		#lastdir = lookdir
		#lookdeg = player.rotation_degrees
		#lookdir = Vector2(cos(deg2rad(player.rotation_degrees)), sin(deg2rad(player.rotation_degrees)))
		#print(lookdir[0] + lookdir[1])
		rpc_unreliable("update_position",position)
		yield(get_tree().create_timer(0.01),"timeout")
		shift_texture.value -= 1
		move_and_slide(lookdir * 700)
		if alive == false:
			self.sprinting = false
			shift_texture.visible = false
			shift_texture.value = 0
			break
		if shift_texture.value == 0:
			if dashing == true:
				rpc("DashSound",rushPressure)
			#shift_texture.visible = false
			#shift_texture.value = 0
			self.sprinting = false
			speed = base_speed
			trysprint = false
			dashing = false
			#emit_signal("not_dashing")
			can_move = true
			player.can_look = true
			#print(dashing)

remotesync func set_name(Gname):
	Pname.text = str(Gname)

#remote func UpdateKills(k,id):
#	for p in Net.playerList:
#		if p[0] == id:
#			p[3] = k
#	rpc("UpdateKillList")

#remote func UpdateKills(k,id):
#	newkill = k
#	var killid = id
#	for p in Net.playerList:
#		if p[0] == killid:
#			p[3] = newkill
#			newkill = 0
#	rpc("UpdateKillList",Net.playerList)
#	print(Net.playerList)

#remotesync func UpdateKillList(list):
#		Net.playerList = list

remotesync func DashSound(source):
	var sfx = load(source)
	DashSound.stream = sfx
	DashSound.play()
	var pcounter = 0
	while DashSound.is_playing() == true:
		candash = false
		yield(get_tree().create_timer(0.01),"timeout")
		if source == rushPressure:
			while pcounter < 10:
				var s = steam.instance()
				s.position = $Player.global_position
				s.process_material.set("initial_velocity",300)
				s.process_material.set("spread",180)
				Bullets.add_child(s)
				pcounter += 1
				if alive == false || health <= 0:
					DashSound.stop()
					break
			pcounter = 0
	candash = true
