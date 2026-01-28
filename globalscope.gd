extends Node
class_name TransitionContext

var player_position = Vector3.ZERO
var player_camera_rotation = Vector3.ZERO
var player_rotation = Vector3.ZERO
var player_velocity = Vector3.ZERO
var player_accel = Vector3.ZERO
var player_speed = 5.0
var player_cx = 0.0
var player_by = 0.0
var accel_status = 0.0
var friction_status = 0.0
var current_level_transition = ""
var game_wallrun_enabled := true

var DevKit_VersionHistory = {
	"LATEST":"The latest version of [3D-FPS-Game-Template::UPCOMING]",
	"2307eb5":"3D basic FPS controller - Wallrunning toggle update",
	"14c08d5":"3D basic FPS controller - Wallrunning and level transition patchwork",
	"4d32e48":"3D basic FPS controller - Extreme version of the ABH-like logic",
	"47364e2":"3D basic FPS controller - ABH-like logic",
	"bfccf7d":"3D basic FPS controller - Git merge fix",
	"6e9d63a":"3D basic FPS controller - Movement Lerp Update",
	"1252dbe":"3D basic FPS controller - The Divergence",
	"15ea040":"3D basic FPS controller [ORIGINAL BRANCH] - YT tutorial upload content / initial commit"
}

var GameInfo = {
	"GameName":"3D basic FPS controller (LATEST)",
	"WallrunningEnabled":true,
	"StartingLevel":"test_scene",
	"SpeedrunTimer":false,
	"DevMode":true,
	"Achievements":{},
	"AchievementIcons":{},
	"ChapterList":{},
	"ChapterIcons":{},
	"GameHasCustomSupport":false,
	"GameHasLoadSupport":false,
	"AllowInfiniteDoubleJumps":true,
	"intended_version":"LATEST"
}

var QuitMessageList = ["Failed to load quit message list."]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_user_signal("gameinfo_load_completed")
	GameInfo = JSON.parse_string(FileAccess.get_file_as_string("res://devkit_game/gameinfo.json"))
	QuitMessageList = JSON.parse_string(FileAccess.get_file_as_string("res://devkit_game/resource/QuitMessageList.json"))
	if "WindowTitle" in GameInfo.keys():
		DisplayServer.window_set_title(GameInfo.WindowTitle)
	else:
		DisplayServer.window_set_title(GameInfo.GameName)
	emit_signal("gameinfo_load_completed")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
