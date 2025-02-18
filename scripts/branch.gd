@tool
class_name branch
extends CSGPolygon3D

@export var Width : float = 1
@export var height : float = 10
@export var topEndSegmentHeight : float = 3
@export var bottomEndSegmentHeight : float = .5

func _ready():
	mode = MODE_SPIN
	polygon = [Vector2(1,0), Vector2(1,1), Vector2(0,1), Vector2(0,0)]
	generate()

func _process(_delta):
	if Engine.is_editor_hint():
		generate()

func generate():
	polygon[0] = Vector2(0, height)
	polygon[1] = Vector2(Width * 0.8, height - topEndSegmentHeight)
	polygon[2] = Vector2(Width * 0.8, bottomEndSegmentHeight)
	polygon[3] = Vector2(0, 0)
