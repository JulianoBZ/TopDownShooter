extends KinematicBody2D

export var primary = 1
export var secondary = 2
export var melee = 1
export var bullet_speed = 2000
onready var ShotSound = get_node("ShotSound")
onready var riflesound = preload("res://assets/Sounds/ak47-2.wav")
onready var riflesound2 = preload("res://assets/Sounds/m4a1-1.wav")
onready var ping = preload("res://assets/Sounds/PingSFX.mp3")
var speed = 200
export var fire_rate = 0.3
export var fire_rate2 = 1.3
var Pammo_count = 12
var Pammo_max = 12
var Sammo_count = 15
var Sammo_max = 15
var clips = 4
var PrelAux = 0
var SrelAux = 0
var Preserve = 120
var Sreserve = 60
var bullet = preload("res://Scenes/Bullet.tscn")
var can_fire = true
var can_melee = true
var recoil = 0
var max_recoil = 1
var rand = RandomNumberGenerator.new()
var reloading = false
var sprinting = false
export var last_rec = 2
var alive = true
var rifle_damage = 15
var shotgun_damage = 6
var is_master = true
var Pporcentagem = 1
var Sporcentagem = 1
export var Ptot_recoil = 0
export var Stot_recoil = 0
export var base_recoil = 0
onready var reload_texture = get_parent().get_node("TextureProgress")
onready var reload_timer = get_parent().get_node("TextureProgress/Timer")
var reloading_animation = true
onready var vision = $Visao
onready var shell = preload("res://Scenes/spent_casings.tscn")
onready var MenuPanel = get_parent().get_node("Esc_Menu/Panel")
onready var Pweapon1 = MenuPanel.get_node("Pweaponbut1")
onready var Pweapon2 = MenuPanel.get_node("Pweaponbut2")
onready var Pweapon3 = MenuPanel.get_node("Pweaponbut3")
onready var Sweapon1 = MenuPanel.get_node("Sweaponbut1")
onready var Sweapon2 = MenuPanel.get_node("Sweaponbut2")
var desired_primary
var desired_secondary
var desired_melee
var desired_frame
var active_weapon = 1
var ejected = false
var can_switch = true
var can_look = true
onready var meleeH = preload("res://Scenes/MeleeHitbox.tscn")


signal change_P
signal change_S
signal change_M

#puppet var puppet_rotation = 0 setget puppet_position_set

# Called when the node enters the scene tree for the first time.
func _ready():
	vision.visible = false
	can_fire = true
	primary = Global.primary
	secondary = Global.secondary
	desired_primary = primary
	if primary == 1:
		Pporcentagem = 3.333
		Pammo_max = 12
		Pweapon1.pressed = true
		Preserve = Pammo_max * clips
		active_weapon = 1
	if primary == 2:
		Pporcentagem = 12.5
		Pammo_count = 8
		Pammo_max = 8
		Pweapon2.pressed = true
		Preserve = Pammo_max * clips
		active_weapon = 1
	if primary == 3:
		Pammo_count = 1
		Pammo_max = 1
		Preserve = Pammo_max * 12
		active_weapon = 1
	if secondary == 1:
		Sammo_count = 15
		Sammo_max = 15
		Sporcentagem = 6.666666
		Sweapon1.pressed = true
		Sreserve = Sammo_max * clips
	if secondary == 2:
		Sammo_count = 6
		Sammo_max = 6
		Sporcentagem = 16.666666
		Sweapon2.pressed = true
		Sreserve = Sammo_max * clips


func _process(delta):
	if is_network_master():
		#Limit weapon ammo
		if primary == 3:
			if Preserve > Pammo_max*12:
				Preserve = Pammo_max*12
				print(primary)
		elif Preserve > Pammo_max*clips:
			Preserve = Pammo_max*clips
		
		if Sreserve > Sammo_max*clips:
			Sreserve = Sammo_max*clips
		
		
		#Change Weapon Slots
		if Input.is_action_just_pressed("wep1") && reloading == false && can_switch:
			active_weapon = 1
			reloading = false
			reload_texture.visible = false
			reload_texture.value = 0
		if Input.is_action_just_pressed("wep2") && reloading == false && can_switch:
			active_weapon = 2
			reloading = false
			reload_texture.visible = false
			reload_texture.value = 0
		if Input.is_action_just_pressed("wep3"):
			active_weapon = 3
			reloading = false
			reload_texture.visible = false
			reload_texture.value = 0
		
		#Look at mouse position
		if can_look:
			look_at(get_global_mouse_position())
			rpc_unreliable("update_rotation", rotation_degrees)
		
		#Sprinting
		sprinting = get_parent().sprinting
		if sprinting == true:
			base_recoil = 6
		
		#Recoil
		if max_recoil > recoil:
			max_recoil -= last_rec * delta
			last_rec = max_recoil
		else: 
			last_rec = 2
		
		rand.randomize()
		Ptot_recoil = rand.randf_range(deg2rad(recoil), deg2rad(max_recoil))
		var dir_recoil = rand.randi_range(0,1)
		if dir_recoil == 0:
			Ptot_recoil *= -1
		
		Stot_recoil = rand.randf_range(deg2rad(recoil), deg2rad(max_recoil + base_recoil))
		dir_recoil = rand.randi_range(0,1)
		if dir_recoil == 0:
			Stot_recoil *= -1
			
		#Rifle
		if Input.is_action_just_pressed("Reload") && reloading == false:
			if primary == 1 && Pammo_count < 12 && active_weapon == 1 && Preserve > 0:
				rpc("Reloading",ping)
				reload_texture.max_value = 90
				reloading = true
				max_recoil = 1
				reload_texture.visible = true
				while(reloading):
					yield(get_tree().create_timer(0.01),"timeout")
					reload_texture.value += 1
					if alive == false:
						reloading = false
						reload_texture.visible = false
						reload_texture.value = 0
						break
					if reload_texture.value == 90:
						reload_texture.visible = false
						reload_texture.value = 0
						PrelAux = Pammo_max - Pammo_count
						if PrelAux <= Preserve:
							Pammo_count += PrelAux
							Preserve -= PrelAux
						else:
							if PrelAux > Preserve:
								print(PrelAux,Preserve)
								Pammo_count += Preserve
								Preserve -= Preserve
						reloading = false
				#reload_timer.start()
				#reload_texture.value = reload_timer.time_left
				#yield(get_tree().create_timer(2.4),"timeout")
				
			#Shotgun
			if primary == 2 && Pammo_count < 8 && active_weapon == 1 && Preserve > 0 && can_fire:
				reload_texture.max_value = 40
				reloading = true
				while(reloading):
					can_fire = false
					reload_texture.visible = true
					yield(get_tree().create_timer(0.01),"timeout")
					reload_texture.value += 1
					if alive == false:
						reloading = false
						reload_texture.visible = false
						reload_texture.value = 0
						break
					if reload_texture.value == 40:
						reloading = false
						reload_texture.visible = false
						reload_texture.value = 0
						Pammo_count += 1
						Preserve -= 1
					if Pammo_count == 8:
						reloading = false
				can_fire = true
				#while reloading:
				#	yield(get_tree().create_timer(0.6),"timeout")
				#	if reloading:
				#		ammo_count += 1
				#		if ammo_count == 8:
				#			reloading = false
			
			#Bow
			if primary == 3 && Pammo_count < 1 && active_weapon == 1 && Preserve > 0:
				reload_texture.max_value = 40
				reloading = true
				while(reloading):
					can_fire = false
					reload_texture.visible = true
					yield(get_tree().create_timer(0.01),"timeout")
					reload_texture.value += 1
					if alive == false:
						reloading = false
						reload_texture.visible = false
						reload_texture.value = 0
						break
					if reload_texture.value == 40:
						reloading = false
						reload_texture.visible = false
						reload_texture.value = 0
						Pammo_count += 1
						Preserve -= 1
					if Pammo_count == 1:
						reloading = false
				can_fire = true
			#########################################################################################
			if secondary == 1 && Sammo_count < 15 && active_weapon == 2 && Sreserve > 0:
				reload_texture.max_value = 80
				reloading = true
				max_recoil = 1
				reload_texture.visible = true
				while(reloading):
					yield(get_tree().create_timer(0.01),"timeout")
					reload_texture.value += 1
					if alive == false:
						reloading = false
						reload_texture.visible = false
						reload_texture.value = 0
						break
					if reload_texture.value == 80:
						reload_texture.visible = false
						reload_texture.value = 0
						SrelAux = Sammo_max - Sammo_count
						if SrelAux <= Sreserve:
							Sammo_count += SrelAux
							Sreserve -= SrelAux
						else:
							if SrelAux > Sreserve:
								print(SrelAux,Sreserve)
								Sammo_count += Sreserve
								Sreserve -= Sreserve
						reloading = false
				
			if secondary == 2 && Sammo_count < 6 && active_weapon == 2 && Sreserve > 0:
				reload_texture.max_value = 100
				reloading = true
				SrelAux = Sammo_max - Sammo_count
				for each in SrelAux:
					rpc("spawn_cartridge")
				while(reloading):
					reload_texture.visible = true
					yield(get_tree().create_timer(0.01),"timeout")
					reload_texture.value += 1
					if alive == false:
						reloading = false
						reload_texture.visible = false
						reload_texture.value = 0
						break
					if reload_texture.value == 100:
						reload_texture.visible = false
						reload_texture.value = 0
						if SrelAux <= Sreserve:
							Sammo_count += SrelAux
							Sreserve -= SrelAux
						else:
							if SrelAux > Sreserve:
								print(SrelAux,Sreserve)
								Sammo_count += Sreserve
								Sreserve -= Sreserve
						reloading = false
				
				
		#sprinting = get_parent().sprinting
		#if sprinting == true:
		#	base_recoil = 12
		
		#Rifle
		if Input.is_action_just_pressed("fire") && can_fire && Pammo_count > 0 && !reloading && !sprinting && primary == 1 && active_weapon == 1:
			can_fire = false
			rpc("Shooting",riflesound2)
			rpc("spawn_bullet",get_tree().get_network_unique_id(),deg2rad(rand.randf_range(-2,2)))
			Pammo_count -= 1
			max_recoil += 1
			yield(get_tree().create_timer(fire_rate/2),"timeout")
			rpc("spawn_cartridge")
			yield(get_tree().create_timer(fire_rate/2),"timeout")
			if alive == true:
				can_fire = true
			
		#Shotgun
		if Input.is_action_pressed("fire") && can_fire && Pammo_count > 0 && !sprinting && primary == 2 && active_weapon == 1:
			can_fire = false
			rpc("spawn_shotgun", get_tree().get_network_unique_id())
			Pammo_count -= 1
			can_switch = false
			yield(get_tree().create_timer(fire_rate2/2),"timeout")
			rpc("spawn_shell")
			yield(get_tree().create_timer(fire_rate2/2),"timeout")
			can_switch = true
			if alive == true:
				can_fire = true
			
		#Bow
		if Input.is_action_pressed("fire") && can_fire && Pammo_count > 0 && !sprinting && primary == 3 && active_weapon == 1:
			get_parent().get_node("BowBar").value += 1
			get_parent().speed = get_parent().base_speed*0.6
		else:
			if get_parent().get_node("BowBar").value > 0:
				rpc("spawn_arrow",get_tree().get_network_unique_id(),get_parent().get_node("BowBar").value)
				Pammo_count -= 1
			get_parent().get_node("BowBar").value = 0
			get_parent().speed = get_parent().base_speed
		##################################################################################################
		#Pistol
		if Input.is_action_just_pressed("fire") && can_fire && Sammo_count > 0 && !reloading && secondary == 1 && active_weapon == 2:
			if can_fire:
				can_fire = false
				rpc("spawn_bullet",get_tree().get_network_unique_id(),Stot_recoil)
				Sammo_count -= 1
				max_recoil += 1
				yield(get_tree().create_timer(fire_rate/2),"timeout")
				rpc("spawn_cartridge")
				yield(get_tree().create_timer(fire_rate/2),"timeout")
				if alive == true:
					can_fire = true
		#Revolver
		if Input.is_action_just_pressed("fire") && can_fire && Sammo_count > 0 && !reloading && secondary == 2 && active_weapon == 2:
			if can_fire:
				can_fire = false
				rpc("spawn_bullet",get_tree().get_network_unique_id(),Stot_recoil)
				Sammo_count -= 1
				max_recoil += 1
				if alive == true:
					can_fire = true
		#################################################################################
		#Melee
		if Input.is_action_just_pressed("fire") && active_weapon == 3 && can_melee:
			can_melee = false
			rpc("melee",get_tree().get_network_unique_id())
			yield(get_tree().create_timer(0.3),"timeout")
			can_melee = true
			

remotesync func spawn_cartridge():
	var s = shell.instance()
	s.position = $Bulletpoint.get_global_position()
	s.add_torque(250000)
	s.rotation_degrees = rotation_degrees + 90
	s.apply_impulse(Vector2(0,0),Vector2(300,0).rotated(rotation - deg2rad(rand.randi_range(75,105))))
	s.get_node("Casing").visible = true
	Bullets.add_child(s)

remotesync func spawn_shell():
	var s = shell.instance()
	s.position = $Bulletpoint.get_global_position()
	s.add_torque(250000)
	s.rotation_degrees = rotation_degrees + 90
	s.apply_impulse(Vector2(0,0),Vector2(300,0).rotated(rotation - deg2rad(rand.randi_range(75,105))))
	s.get_node("Shell").visible = true
	Bullets.add_child(s)

remotesync func spawn_bullet(id,tot_recoil):
	var b = bullet.instance()
	b.name = "Bullet" + name + str(Net.network_object_name_index)
	b.flag = get_parent()
	b.type = 1
	b.damage = rifle_damage
	b.position = $Bulletpoint.get_global_position()
	b.rotation_degrees = rotation_degrees + tot_recoil
	b.apply_impulse(Vector2(0,0),Vector2(bullet_speed,0).rotated(rotation + tot_recoil))
	Bullets.add_child(b)
	b.set_network_master(id)
	Net.network_object_name_index += 1

remotesync func spawn_shotgun(id):
	reloading = false
	var bullets = {"1" : bullet.instance(),"2" : bullet.instance(),"3" : bullet.instance(),"4" : bullet.instance(),
	"5" : bullet.instance(),"6" : bullet.instance(),"7" : bullet.instance(),"8" : bullet.instance(),
	"9" : bullet.instance(),"10" : bullet.instance(),"11" : bullet.instance(),"12" : bullet.instance()}
	var graus = -6
	for x in bullets:
		bullets[x].name = "Bullet" + name + str(Net.network_object_name_index)
		bullets[x].type = 2
		bullets[x].damage = shotgun_damage
		bullets[x].rotation_degrees = rotation_degrees
		bullets[x].flag = get_parent()
		bullets[x].position = $Bulletpoint.get_global_position()
		bullets[x].rotation_degrees = rotation_degrees
		bullets[x].apply_impulse(Vector2(0,0),Vector2(bullet_speed,0).rotated(rotation + deg2rad(graus)))
		Bullets.add_child(bullets[x])
		graus += 1
		bullets[x].set_network_master(id)
		Net.network_object_name_index += 1

remotesync func spawn_arrow(id,value):
	var b = bullet.instance()
	var arrow_speed = 0.3
	b.name = "Bullet" + name + str(Net.network_object_name_index)
	b.flag = get_parent()
	b.type = 3
	if value < 30:
		b.damage = 30
		arrow_speed = lerp(arrow_speed,2,30)
	else:
		b.damage = value
		arrow_speed = lerp(arrow_speed,2,value)
	b.position = $Bulletpoint.get_global_position()
	b.rotation_degrees = rotation_degrees
	b.apply_impulse(Vector2(0,0),Vector2(bullet_speed*(arrow_speed/100),0).rotated(rotation))
	Bullets.add_child(b)
	b.set_network_master(id)
	Net.network_object_name_index += 1

remote func update_rotation(rot):
	rotation_degrees = rot

#func puppet_position_set(new_value):
#	puppet_rotation = new_value
#	var tween = get_parent().get_node("Tween")
#	tween.interpolate_property(self, "global_position",global_position,puppet_rotation,0.1)
#	tween.start()

#remote func update_bullet(bul,rot,rec,speed):
#	bul.position = $Bulletpoint.get_global_position()
#	bul.rotation_degrees = rotation_degrees
#	bul.apply_impulse(Vector2(0,0),Vector2(speed,0).rotated(rot + rec))

#func _physics_process(delta):
#	var direction = Vector2()
#	
#	if Input.is_action_pressed("up"):
#		direction.y -= 1
#	if Input.is_action_pressed("down"):
#		direction.y += 1
#	if Input.is_action_pressed("left"):
#		direction.x -= 1
#	if Input.is_action_pressed("right"):
#		direction.x += 1
#	
#	direction = direction.normalized()
#	#global_position += direction * speed * delta
#	move_and_slide(direction * speed)

remotesync func Shooting(source):
	#var sfx = load(source)
	ShotSound.stream = source
	ShotSound.play()

remotesync func Reloading(source):
	#var sfx = load(source)
	ShotSound.stream = source
	ShotSound.play()

func _on_Timer_timeout():
	reload_texture.visible = false

func _on_PlayerAll_pdeath():
	can_fire = false
	visible = false
	alive = false

func _on_PlayerAll_respawned():
	change_weapon(desired_primary,desired_secondary)
	if primary == 3:
		Pammo_count = Pammo_max
		Preserve = Pammo_max * 12
	else:
		Pammo_count = Pammo_max
		Preserve = Pammo_max * clips
	Sammo_count = Sammo_max
	Sreserve = Sammo_max * clips
	can_fire = true
	visible = true
	alive = true
	#primary = desired_primary

func _on_ApplyButton_pressed():
	if Pweapon1.pressed == true:
		desired_primary = 1
	if Pweapon2.pressed == true:
		desired_primary = 2
	if Pweapon3.pressed == true:
		desired_primary = 3
	if Sweapon1.pressed == true:
		desired_secondary = 1
	if Sweapon2.pressed == true:
		desired_secondary = 2
	
	MenuPanel.visible = false
	can_fire = true
	#get_parent().can_move = true
	#get_parent().esc_pressed = false
	#get_parent().camera_lock = false

func change_weapon(desired_p,desired_s):
	if desired_p == 1:
		Pporcentagem = 3.333
		Pammo_max = 12
		primary = 1
	if desired_p == 2:
		Pporcentagem = 12.5
		Pammo_max = 8
		primary = 2
	if desired_p == 3:
		Pammo_max = 1
		primary = 3
	if desired_s == 1:
		Sammo_max = 15
		secondary = 1
		Sporcentagem = 6.666666
	if desired_s == 2:
		Sammo_max = 6
		secondary = 2
		Sporcentagem = 16.666666

remotesync func melee(id):
	var mh = meleeH.instance()
	mh.name = "Melee" + name + str(Net.network_object_name_index)
	mh.flag = get_parent()
	mh.position = $Bulletpoint.get_global_position()
	mh.rotation_degrees = rotation_degrees
	Bullets.add_child(mh)
	mh.set_network_master(id)
	Net.network_object_name_index += 1
	#yield(get_tree().create_timer(0.3),"timeout")
