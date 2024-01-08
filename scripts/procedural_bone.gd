class_name ProceduralBone
extends Spatial
tool

var _skeleton: Skeleton

var _cached_path: NodePath

func _ready() -> void:
	set_notify_transform(true)
	_skeleton = find_parent("Skeleton")
	_cached_path = _skeleton.get_path_to(self)

func _notification(what: int) -> void:
	if not _skeleton:
		return

	match what:
		NOTIFICATION_PATH_CHANGED:
			var path = _skeleton.get_path_to(self)
			if _cached_path != path:
				_skeleton.bone_path_changed(_cached_path, path)
		NOTIFICATION_TRANSFORM_CHANGED:
			_skeleton.bone_transform_changed(self)
