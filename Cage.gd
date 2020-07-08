extends StaticBody2D

export var roomId = 1
export var letters = ""

signal cage_destroyed(letters)

onready var sprite = $AnimatedSprite
onready var label = $LettersLabel
#onready var sprite = get_node("/root/AnimatedSprite")

func _process(_delta):
	label.text = letters


func _on_ChainHit2_area_shape_entered(_area_id, _area, _area_shape, _self_shape):
	print("hit")
	#sprite.stop()
	sprite.play("damage")


func _on_AnimatedSprite_animation_finished():
	print(roomId)
	#print("finished")
	#print(sprite)
	#print($animatedSprite)
	#print(get_parent().name)
	#sprite.stop()
	#sprite.play("idle")
	destroy_cage()


func _on_ChainHit2_body_entered(_body):
	print("body enter")
	pass # Replace with function body.

func destroy_cage():
	queue_free()
	emit_signal("cage_destroyed", roomId, letters)
