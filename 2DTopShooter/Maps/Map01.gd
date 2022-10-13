extends Node2D

#const PLAYER = preload("res://Player-All.tscn")

var contador = 1
onready var red_spawn = $RedSpawn
onready var blue_spawn = $BlueSpawn

#onready var players = $Players

#func _ready():
#	rpc_id(1,"spawn_players", Server.local_player_id)

#remote func spawn_player(id):
#	var player = PLAYER.instance()
#	player.name = str(id)
#	players.add_child(player)
#	player.set_network_master(id)
#	player.position = player_spawn.position

#func _ready():
#	Net.set_ids()
#	create_players()
#
#func create_players():
#	for id in Net.peer_ids:
#		create_player(id)
#	create_player(Net.net_id)
#	
#
#func create_player(id):
#	#var p = preload("res://Player-All.tscn").instance()
#	if contador % 2 == 0:
#		var p1 = preload("res://Player-All.tscn").instance()
#		add_child(p1)
#		p1.position = red_spawn.position
#		p1.initialize(id)
#		contador += 1
#	else:
#		var p2 = preload("res://Player-All.tscn").instance()
#		add_child(p2)
#		p2.position = blue_spawn.position
#		p2.initialize(id)
#		contador += 1
#
