extends PathFollow2D

@export var speed: float = 70.0
var dir: float = 1.0

func _process(delta: float) -> void:
	progress += speed * delta
	# ping-pong at ends
	if progress_ratio >= 1.0:
		progress_ratio = 1.0
		dir = -1.0
	elif progress_ratio <= 0.0:
		progress_ratio = 0.0
		dir = 1.0
