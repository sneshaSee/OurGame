extends PathFollow2D

@export var patrol_speed: float = 70.0

func _physics_process(delta: float) -> void:
	# When the goblin detaches to chase, it is no longer our child.
	# Pause path movement until it comes back.
	if get_child_count() == 0:
		return

	# Looping motion (Godot wraps progress automatically when Loop is enabled)
	progress += patrol_speed * delta
