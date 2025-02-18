@tool
extends Node3D

var acornInstance : acorn

@export var acornScene : PackedScene

func _ready():
	reSpawn()

func reSpawn():
	if !acornInstance and !is_instance_valid(acornInstance):
		acornInstance = acornScene.instantiate()
		add_child(acornInstance)
		acornInstance.global_position = global_position
		
