extends KinematicBody2D

var firetype = 2
export var bullet_speed = 3000
var speed = 200
export var fire_rate = 0.1
export var fire_rate2 = 1.3
var ammo_count = 30
var bullet = preload("res://Scenes/Bullet.tscn")
var can_fire = true
var recoil = 0
var max_recoil = 1
var rand = RandomNumberGenerator.new()
var reloading = false
var sprinting = false
var last_rec = 2
var alive = true
var damage = 8

# Called when the node enters the scene tree for the first time.
func _ready():
	if firetype == 2:
		ammo_count = 8
		damage = 8
	pass # Replace with function body.


func _process(delta):
	look_at(get_global_mouse_position())
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
	
	if Input.is_action_just_pressed("Reload"):
		if firetype == 1:
			reloading = true
			max_recoil = 1
			yield(get_tree().create_timer(2.4),"timeout")
			ammo_count = 30
			reloading = false
		if firetype == 2:
			reloading = true
			while reloading:
				yield(get_tree().create_timer(0.6),"timeout")
				if reloading:
					ammo_count += 1
					if ammo_count == 8:
						reloading = false
				
	
	sprinting = get_parent().sprinting
	
	if Input.is_action_pressed("fire") && can_fire && ammo_count > 0 && !reloading && !sprinting && firetype == 1:
		var b = bullet.instance()
		b.flag = get_parent()
		print("alo"+str(b.flag))
		b.position = $Bulletpoint.get_global_position()
		b.rotation_degrees = rotation_degrees
		b.apply_impulse(Vector2(0,0),Vector2(bullet_speed,0).rotated(rotation + tot_recoil))
		get_tree().get_root().add_child(b)
		can_fire = false
		yield(get_tree().create_timer(fire_rate),"timeout")
		can_fire = true
		ammo_count -= 1
		max_recoil += 1
	
	if Input.is_action_pressed("fire") && can_fire && ammo_count > 0 && !sprinting && firetype == 2:
		reloading = false
		var bullets = {"1" : bullet.instance(),"2" : bullet.instance(),"3" : bullet.instance(),"4" : bullet.instance(),
		"5" : bullet.instance(),"6" : bullet.instance(),"7" : bullet.instance(),"8" : bullet.instance(),
		"9" : bullet.instance(),"10" : bullet.instance(),"11" : bullet.instance(),"12" : bullet.instance()}
		var graus = -6
		for x in bullets:
			bullets[x].damage = damage
			bullets[x].rotation_degrees = rotation_degrees
			bullets[x].flag = get_parent()
			bullets[x].position = $Bulletpoint.get_global_position()
			bullets[x].rotation_degrees = rotation_degrees
			bullets[x].apply_impulse(Vector2(0,0),Vector2(bullet_speed,0).rotated(rotation + deg2rad(graus)))
			get_tree().get_root().add_child(bullets[x])
			graus += 1
		ammo_count -= 1
		can_fire = false
		yield(get_tree().create_timer(fire_rate2),"timeout")
		can_fire = true


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
	
