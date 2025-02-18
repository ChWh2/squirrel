class_name player
extends CharacterBody3D

const SPEED = 20.0
const JUMP_VELOCITY = 10

const CameraSmoothing = .05

@onready var camera_pivot_real = $CameraPivotReal
@onready var camera_pivot : Node3D = $CameraPivotReal/CameraPivot
@onready var camera : Node3D = $CameraPivotReal/CameraPivot/Camera
@onready var squirrel = $Squirrel

static var score := 0

static var instance : player

func _ready():
	instance = self
	score = 0
	
	$CameraPivotReal.global_position = global_position
	
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		camera_pivot.rotate_y(-deg_to_rad(event.relative.x))
		camera.rotate_x(-deg_to_rad(event.relative.y))
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(45))
	
	if Input.is_action_just_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	if event is InputEventMouseButton:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta):
	$Ui/Score.text = str("Acorns: ", score)
	
	
	if global_position.y <= 1:
		global_position.y = 2
		velocity.y = 0
	
	if $ShapeCast3D.is_colliding():
		var point = $ShapeCast3D.get_collision_point(0)
		var normal = $ShapeCast3D.get_collision_normal(0)
		
		global_position = point + normal
		
		var newBasis = global_basis
		newBasis.y = normal
		newBasis.x = -newBasis.z.cross(normal)
		newBasis = newBasis.orthonormalized()
		
		if newBasis.determinant() != 0:
			global_basis = newBasis
		
		var input_dir = Input.get_vector("Left", "Right", "Up", "Down")
		
		var forward = squirrel.global_basis.z
		var right = squirrel.global_basis.x
		
		var direction = (forward * input_dir.y + right * input_dir.x).normalized()
		if direction:
			$AnimationPlayer.play("Walk")
			squirrel.rotation = camera_pivot.rotation
			squirrel.rotation.x = 0
			squirrel.rotation.z = 0
			
			velocity = direction * SPEED
			
			$Squirrel/Pivot.look_at(velocity + global_position)
			$Squirrel/Pivot.rotation.x = 0
			$Squirrel/Pivot.rotation.z = 0
		else:
			$AnimationPlayer.play("RESET")
			velocity.x = move_toward(velocity.x, 0, SPEED)
			velocity.y = move_toward(velocity.y, 0, SPEED)
			velocity.z = move_toward(velocity.z, 0, SPEED)
			
		if Input.is_action_pressed("ui_accept"):
			velocity += JUMP_VELOCITY * global_basis.y
	
	else:
		$AnimationPlayer.play("fall")
		velocity += get_gravity() * delta
	
	move_and_slide()
	
	cameraSmoothing(delta)

func cameraSmoothing(_delta):
	camera_pivot_real.global_position = global_position
	
	#Rotation Smoothing
	var camRot : Vector3 = camera_pivot_real.global_rotation
	camRot = global_rotation
	
	camera_pivot_real.global_rotation = camRot

func die():
	get_tree().change_scene_to_file("res://scene/die.tscn")
