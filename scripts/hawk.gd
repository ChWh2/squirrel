extends Area3D
class_name hawk

@export var circleAround : Node3D
@export var circleHeight : float
@export var circleRadius : float
@export var velocity : float
@export var swoopVelocity : float
@export var timeNeeded : float

var radsPerSec := 0.0

@onready var ray = $RayCast3D

var timeSeen : float = 0.0

static var instance : hawk

func _ready():
	$SubViewport/ProgressBar.max_value = timeNeeded
	
	instance = self
	radsPerSec = velocity / circleRadius

func _physics_process(delta):
	if player.instance:
		ray.look_at(player.instance.global_position)
		ray.force_raycast_update()
		
		if ray.is_colliding() and ray.get_collider() == player.instance:
			timeSeen+=delta
		elif timeSeen < timeNeeded:
			timeSeen -= delta
			timeSeen = clamp(timeSeen, 0, timeNeeded)
		
		if timeSeen >= timeNeeded:
			$SubViewport/ProgressBar.visible = false
			swoop(delta)
		else:
			$SubViewport/ProgressBar.visible = true
			$SubViewport/ProgressBar.value = timeSeen
			circle()
		
	else:
		$SubViewport/ProgressBar.visible = false
		circle()

func swoop(delta):
	global_position += global_position.direction_to(player.instance.global_position) * swoopVelocity * delta
	look_at(player.instance.global_position)

func circle():
	var timeElapsed = Time.get_ticks_msec() / 1000.0
	
	global_position = circleRadius * Vector3(cos(timeElapsed * radsPerSec), 0, sin(timeElapsed * radsPerSec))
	global_position += Vector3.UP * circleHeight
	global_position += circleAround.position
	
	global_basis.y = Vector3.UP.normalized()
	global_basis.z = -Vector3(-radsPerSec * sin(timeElapsed * radsPerSec), 0, radsPerSec * cos(timeElapsed * radsPerSec)).normalized()
	global_basis.x = global_basis.y.cross(global_basis.z).normalized()
	global_basis = global_basis.orthonormalized()

func _on_body_entered(body):
	if body is player:
		body.call_deferred("die")
