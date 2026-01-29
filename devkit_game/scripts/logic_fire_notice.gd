extends Node

@export var notice_text := "This is a notice: hi :)"
@export var crash_after_notice := false
@export var delay := 0.0

func on_fire(_param):
	await get_tree().create_timer(delay).timeout
	OS.alert(notice_text,"DevKitGD - Developer Notice")
	if crash_after_notice:
		get_tree().quit()
