extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$GameTitle.text = GlobalScope.GameInfo.GameName
	if GlobalScope.GameInfo.GameHasCustomSupport:
		$TitleButtonElements/BonusContentButton.disabled = false
	if GlobalScope.GameInfo.GameHasLoadSupport:
		$TitleButtonElements/LoadGameButton.disabled = false
	if GlobalScope.GameInfo.Achievements != {}:
		$TitleButtonElements/AchievementsButton.disabled = false
	pass # Replace with function body.

# get_tree().change_scene_to_file("res://devkit_game/maps/" + GlobalScope.GameInfo.StartingLevel + ".tscn")
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_new_game_button_pressed() -> void:
	get_tree().change_scene_to_file("res://devkit_game/maps/" + GlobalScope.GameInfo.StartingLevel + ".tscn")
	pass # Replace with function body.


func _on_load_game_button_pressed() -> void:
	OS.alert("You cheeky hacker.","DevkitGD - Critical Error")
	pass # Replace with function body.


func _on_achievements_button_pressed() -> void:
	OS.alert("You cheeky hacker.","DevkitGD - Critical Error")
	pass # Replace with function body.


func _on_settings_button_pressed() -> void:
	pass # Replace with function body.


func _on_bonus_content_button_pressed() -> void:
	OS.alert("You cheeky hacker.","DevkitGD - Critical Error")
	pass # Replace with function body.


func _on_quit_button_pressed() -> void:
	$QuitConfirmDialog.dialog_text = GlobalScope.QuitMessageList[randi_range(0,len(GlobalScope.QuitMessageList) - 1)]
	$QuitConfirmDialog.visible = true
	pass # Replace with function body.


func _on_quit_confirm_dialog_confirmed() -> void:
	pass # Replace with function body.


func _on_quit_confirm_dialog_canceled() -> void:
	pass # Replace with function body.
