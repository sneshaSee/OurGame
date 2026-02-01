extends Node2D


func _ready():
	var player = get_tree().get_first_node_in_group("player")
	if player == null:
		return

	for node in get_tree().get_nodes_in_group("spawn_points"):
		if node is SpawnPoint and node.spawn_id == SpawnManager.spawn_id:
			player.global_position = node.global_position
			return
