class_name acorn
extends Area3D

func _on_body_entered(body):
	if body is player:
		print("nom nom")
		body.score += 1
		get_tree().call_group("acornSpawners", "reSpawn")
		queue_free()
