extends CharacterBody2D

@export var patrol_speed: float = 70.0
@export var chase_speed: float = 190.0

# Path following
var follow_node: PathFollow2D = null
var path_node: Path2D = null
var world_node: Node = null
var saved_progress: float = 0.0
var going_forward: bool = true
var saved_direction: bool = true  # Save the direction too

# Vision & Chase
@onready var ray: RayCast2D = $RayCast2D
@onready var vision_area: Area2D = $VisionArea
@onready var catch_area: Area2D = $CatchArea
var player: CharacterBody2D = null
var player_in_vision: bool = false

enum State { PATROL, CHASE, RETURNING }
var state: State = State.PATROL

func _ready() -> void:
	# Find player
	player = get_tree().get_first_node_in_group("Player") as CharacterBody2D
	if player == null:
		print("ERROR: No player found. Add player to 'Player' group.")
		return
	
	# Get world node
	world_node = get_tree().current_scene
	
	# Save PathFollow2D reference
	if get_parent() is PathFollow2D:
		follow_node = get_parent() as PathFollow2D
		if follow_node.get_parent() is Path2D:
			path_node = follow_node.get_parent() as Path2D
			follow_node.loop = true
	
	# Connect catch area
	if catch_area:
		catch_area.body_entered.connect(_on_catch_area_body_entered)
	
	# Setup raycast
	if ray:
		ray.enabled = true
		ray.collide_with_areas = false
		ray.collide_with_bodies = true

func _physics_process(delta: float) -> void:
	if player == null:
		return
	
	# Check if should chase (only when in PATROL state)
	if state == State.PATROL or state == State.RETURNING:
		var mask_off: bool = (player.toggle_mask == false)
		var los: bool = _has_line_of_sight()
		var should_chase: bool = player_in_vision and mask_off and los
		
		if should_chase:
			_start_chase()
	
	# If chasing, check if should stop
	elif state == State.CHASE:
		var mask_on: bool = (player.toggle_mask == true)
		var lost_vision: bool = not player_in_vision
		var no_los: bool = not _has_line_of_sight()
		
		if mask_on or lost_vision or no_los:
			_stop_chase()
	
	# Execute state behavior
	match state:
		State.PATROL:
			_patrol(delta)
		State.CHASE:
			_chase()
			move_and_slide()
		State.RETURNING:
			_return_to_path(delta)

func _patrol(delta: float) -> void:
	# PathFollow2D controls position during patrol
	if follow_node == null or path_node == null or path_node.curve == null:
		return
	
	var max_progress = path_node.curve.get_baked_length()
	
	# Move along the path
	if going_forward:
		follow_node.progress += patrol_speed * delta
		
		if follow_node.progress >= max_progress:
			follow_node.progress = max_progress
			going_forward = false
	else:
		follow_node.progress -= patrol_speed * delta
		
		if follow_node.progress <= 0:
			follow_node.progress = 0
			going_forward = true

func _start_chase() -> void:
	state = State.CHASE
	
	# Save current position AND direction on path
	if follow_node != null:
		saved_progress = follow_node.progress
		saved_direction = going_forward  # SAVE THE DIRECTION
		
		# Freeze the PathFollow2D
		follow_node.set_process(false)
		follow_node.set_physics_process(false)
	
	# Detach from PathFollow2D
	if follow_node != null and get_parent() == follow_node:
		var pos := global_position
		follow_node.remove_child(self)
		world_node.add_child(self)
		global_position = pos

func _stop_chase() -> void:
	state = State.RETURNING
	velocity = Vector2.ZERO

func _return_to_path(delta: float) -> void:
	# Calculate where the saved path position actually is in world space
	if follow_node == null or path_node == null:
		return
	
	# Temporarily set the PathFollow2D to our saved progress to get the world position
	var old_progress = follow_node.progress
	follow_node.progress = saved_progress
	var target_pos = follow_node.global_position
	follow_node.progress = old_progress
	
	# Move towards that position
	var to_target = target_pos - global_position
	var distance = to_target.length()
	
	# Close enough? Reattach to path
	if distance < 10.0:
		_reattach_to_path()
		return
	
	# Move towards the saved path position
	velocity = to_target.normalized() * patrol_speed
	move_and_slide()

func _reattach_to_path() -> void:
	state = State.PATROL
	velocity = Vector2.ZERO
	
	# Restore BOTH progress and direction
	if follow_node != null:
		follow_node.progress = saved_progress
		going_forward = saved_direction  # RESTORE THE DIRECTION
	
	# Reattach to PathFollow2D
	if follow_node != null and get_parent() != follow_node:
		world_node.remove_child(self)
		follow_node.add_child(self)
		position = Vector2.ZERO  # Reset local position
	
	# Unfreeze PathFollow2D
	if follow_node != null:
		follow_node.set_process(true)
		follow_node.set_physics_process(true)

func _chase() -> void:
	var to_player: Vector2 = player.global_position - global_position
	
	if to_player.length() == 0:
		velocity = Vector2.ZERO
		return
	
	velocity = to_player.normalized() * chase_speed

func _on_VisionArea_body_entered(body: Node) -> void:
	if body == player:
		player_in_vision = true

func _on_VisionArea_body_exited(body: Node) -> void:
	if body == player:
		player_in_vision = false

func _on_catch_area_body_entered(body: Node) -> void:
	if body == player and state == State.CHASE:
		# Only game over if mask is down
		if player.toggle_mask == false:
			get_tree().call_group("game_over_ui", "game_over")

func _has_line_of_sight() -> bool:
	if ray == null or player == null:
		return false
	
	# Point ray at player
	ray.target_position = to_local(player.global_position)
	ray.force_raycast_update()
	
	# If ray hits something, check if it's the player
	if ray.is_colliding():
		var collider = ray.get_collider()
		return collider == player
	
	# Nothing blocking, can see player
	return true


func _on_vision_area_body_entered(body: Node2D) -> void:
	pass # Replace with function body.


func _on_vision_area_body_exited(body: Node2D) -> void:
	pass # Replace with function body.
