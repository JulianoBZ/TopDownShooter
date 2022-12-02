extends Control


const PORT := 3333

onready var network = get_parent()
var list_last_value

export (NodePath) var advertiserPath: NodePath
onready var advertiser := get_node(advertiserPath)

var playerChar = preload("res://Player-All.tscn")
var world = preload("res://Maps/FreeForAll1.tscn").instance()
var rng = RandomNumberGenerator.new()


func ready():
	rng.randomize()
	list_last_value = network.playerList.size()
	print(list_last_value)
	print(get_tree().multiplayer.get_network_connected_peers())

func _process(delta):
	advertiser.serverInfo["name"] = Net.lobby_name
	advertiser.serverInfo["port"] = PORT
	if list_last_value != network.playerList.size():
		changed_playerList()
		list_last_value = network.playerList.size()
	if get_tree().get_network_unique_id() == 1:
		$StartGame.show()

func changed_playerList():
	for n in $PlayerList.get_children():
		n.queue_free()
	for p in network.playerList:
		var player = Label.new()
		player.text = str(p)
		$PlayerList.add_child(player)


func _on_StartGame_pressed():
	rpc("start_game")
	Net.lobby_name = "Game Started, do not Join"

remotesync func start_game():
	Map.add_child(world)
	self.hide()
	for each in network.playerList:
		if each != get_tree().get_network_unique_id():
			instance_player(each)
	instance_player(get_tree().get_network_unique_id())

remotesync func instance_player(id):
	#Global.player_name = str(playername.text)
	var player_instance = Global.instance_node_at_location(playerChar, Players, (world.spawns[str(rng.randi_range(1,7))]).position)
	player_instance.name = str(id)
	player_instance.set_network_master(id)
