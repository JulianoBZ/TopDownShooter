extends KinematicBody2D

export var firetype = 1
export var bullet_speed = 3500
var speed = 200
export var fire_rate = 0.1
export var fire_rate2 = 1.3
var ammo_count = 30
var ammo_max = 30
var bullet = preload("res://Scenes/Bullet.tscn")
var can_fire = true
export var recoil = 0
var max_recoil = 1
var rand = RandomNumberGenerator.new()
var reloading = false
var sprinting = false
export var last_rec = 2
var alive = true
var damage = 0
var is_master = true
var porcentagem = 1
export var tot_recoil = 0
onready var reload_texture = get_parent().get_node("TextureProgress")
onready var reload_timer = get_parent().get_node("TextureProgress/Timer")
var reloading_animation = true
onready var vision = $Visao
onready var shell = preload("res://Scenes/spent_casings.tscn")

#puppet var puppet_rotation = 0 setget puppet_position_set

# Called when the node enters the scene tree for the first time.
func _ready():
	vision.visible = false
	can_fire = true
	firetype = Global.firetype
	if firetype == 1:
		porcentagem = 3.333
		damage = 15
		ammo_max = 30
		#reload_timer.wait_time = 2.4
	if firetype == 2:
		ammo_count = 8
		damage = 6
		porcentagem = 12.5
		ammo_max = 8
	#reload_timer.wait_time = reload_texture.value
	pass # Replace with function body.


func _process(delta):
	if is_network_master():
		#vision.visible = true
		look_at(get_global_mouse_position())
		rpc_unreliable("update_rotation", rotation_degrees)
		
		if max_recoil > recoil:
			max_recoil -= last_rec * delta
			last_rec = max_recoil
		else: 
			last_rec = 2
			
		rand.randomize()
		var tot_recoil = rand.randf_range(deg2rad(recoil), deg2rad(max_recoil))
		var dir_recoil = rand.randi_range(0,1)
		if dir_recoil == 0:
			tot_recoil *= -1
			
		if Input.is_action_just_pressed("Reload") && reloading == false:
			if firetype == 1 && ammo_count < 30:
				reloading = true
				max_recoil = 1
				reload_texture.visible = true
				while(reloading):
					yield(get_tree().create_timer(0.01),"timeout")
					reload_texture.value += 1
					if reload_texture.value == 240:
						reload_texture.visible = false
						reload_texture.value = 0
						ammo_count = 30
						reloading = false
				#reload_timer.start()
				#reload_texture.value = reload_timer.time_left
				#yield(get_tree().create_timer(2.4),"timeout")
				
			if firetype == 2 && ammo_count < 8:
				reload_texture.max_value = 60
				reloading = true
				while(reloading):
					can_fire = false
					reload_texture.visible = true
					yield(get_tree().create_timer(0.01),"timeout")
					reload_texture.value += 1
					if reload_texture.value == 60:
						reloading = false
						reload_texture.visible = false
						reload_texture.value = 0
						ammo_count += 1
					if ammo_count == 8:
						reloading = false
				can_fire = true
				#while reloading:
				#	yield(get_tree().create_timer(0.6),"timeout")
				#	if reloading:
				#		ammo_count += 1
				#		if ammo_count == 8:
				#			reloading = false
			
		sprinting = get_parent().sprinting
			
		if Input.is_action_pressed("fire") && can_fire && ammo_count > 0 && !reloading && !sprinting && firetype == 1:
			if can_fire:
				can_fire = false
				rpc("spawn_bullet",get_tree().get_network_unique_id(),tot_recoil)
				ammo_count -= 1
				max_recoil += 1
				yield(get_tree().create_timer(fire_rate/2),"timeout")
				rpc("spawn_cartridge")
				yield(get_tree().create_timer(fire_rate/2),"timeout")
				if alive == true:
					can_fire = true
			#var b = bullet.instance()
			#b.flag = get_parent()
			#b.position = $Bulletpoint.get_global_position()
			#b.rotation_degrees = rotation_degrees
			#b.apply_impulse(Vector2(0,0),Vector2(bullet_speed,0).rotated(rotation + tot_recoil))
			#get_tree().get_root().add_child(b)
			#can_fire = false
			#ammo_count -= 1
			#max_recoil += 1
			#yield(get_tree().create_timer(fire_rate),"timeout")
			#can_fire = true
			
		if Input.is_action_pressed("fire") && can_fire && ammo_count > 0 && !sprinting && firetype == 2:
			#reloading = false
			#var bullets = {"1" : bullet.instance(),"2" : bullet.instance(),"3" : bullet.instance(),"4" : bullet.instance(),
			#"5" : bullet.instance(),"6" : bullet.instance(),"7" : bullet.instance(),"8" : bullet.instance(),
			#"9" : bullet.instance(),"10" : bullet.instance(),"11" : bullet.instance(),"12" : bullet.instance()}
			#var graus = -6
			#for x in bullets:
			#	bullets[x].damage = damage
			#	bullets[x].rotation_degrees = rotation_degrees
			#	bullets[x].flag = get_parent()
			#	bullets[x].position = $Bulletpoint.get_global_position()
			#	bullets[x].rotation_degrees = rotation_degrees
			#	bullets[x].apply_impulse(Vector2(0,0),Vector2(bullet_speed,0).rotated(rotation + deg2rad(graus)))
			#	get_tree().get_root().add_child(bullets[x])
			#	graus += 1
			can_fire = false
			rpc("spawn_shotgun", get_tree().get_network_unique_id())
			ammo_count -= 1
			yield(get_tree().create_timer(fire_rate2/2),"timeout")
			rpc("spawn_shell")
			yield(get_tree().create_timer(fire_rate2/2),"timeout")
			if alive == true:
				can_fire = true

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
	b.damage = damage
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
		bullets[x].damage = damage
		bullets[x].rotation_degrees = rotation_degrees
		bullets[x].flag = get_parent()
		bullets[x].damage = damage
		bullets[x].position = $Bulletpoint.get_global_position()
		bullets[x].rotation_degrees = rotation_degrees
		bullets[x].apply_impulse(Vector2(0,0),Vector2(bullet_speed,0).rotated(rotation + deg2rad(graus)))
		Bullets.add_child(bullets[x])
		graus += 1
		bullets[x].set_network_master(id)
		Net.network_object_name_index += 1

#por algum caralho de motivo essa merda ainda rotaciona outros player que não sejam o host, mas fodase ainda funciona
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

func _on_Timer_timeout():
	reload_texture.visible = false

func _on_PlayerAll_pdeath(player):
	can_fire = false
	visible = false
	alive = false

func _on_PlayerAll_respawned():
	ammo_count = ammo_max
	can_fire = true
	visible = true
	alive = true

