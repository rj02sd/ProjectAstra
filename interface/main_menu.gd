extends CanvasLayer


func _ready():
	pass


func _process(delta):
	pass


func _on_button_pressed():
	SceneLoader.load_scene("res://levels/prototyping_scene.tscn", true)
	SceneLoader.change_scene_to_loading_screen()