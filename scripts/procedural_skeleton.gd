class_name ProceduralSkeleton
extends Skeleton
tool

export(NodePath) var animation_player_path
export(bool) var bind: bool setget set_bind

export(Array, NodePath) var _bone_node_paths: Array

func set_bind(new_bind: bool) -> void:
	if new_bind:
		bind()
		property_list_changed_notify()

func clear() -> void:
	clear_bones()
	_bone_node_paths.clear()

func bind() -> void:
	clear()

	var animation_player := get_node_or_null(animation_player_path) as AnimationPlayer
	var animation: Animation
	if animation_player:
		animation = Animation.new()
		animation.set_name("bind")

	for child in get_children():
		traverse_child(-1, child, animation)

	if animation_player:
		animation_player.remove_animation("bind")
		animation_player.add_animation("bind", animation)

func traverse_child(parent_bone_idx: int, child: Node, animation: Animation) -> void:
	if not child is ProceduralBone:
		return

	_bone_node_paths.append(get_path_to(child))

	var bone_name = child.get_name()
	var bone_idx = get_bone_count()
	add_bone(bone_name)

	set_bone_rest(bone_idx, child.transform)

	if animation:
		var track = animation.add_track(Animation.TYPE_TRANSFORM)
		animation.track_set_path(track, "%s:transform" % [get_path_to(child)])
		animation.transform_track_insert_key(track, 0.0, child.translation, child.transform.basis.get_rotation_quat(), child.scale)

	if parent_bone_idx >= 0:
		set_bone_parent(bone_idx, parent_bone_idx)

	for grandchild in child.get_children():
		traverse_child(bone_idx, grandchild, animation)

func bone_path_changed(from: NodePath, to: NodePath) -> void:
	var bone_index = _bone_node_paths.find(from)
	if bone_index < 0:
		return

	_bone_node_paths.insert(bone_index, to)
	_bone_node_paths.erase(from)

func bone_transform_changed(bone: ProceduralBone) -> void:
	var bone_path = get_path_to(bone)
	var bone_idx = _bone_node_paths.find(bone_path)
	if bone_idx < 0:
		return

	set_bone_pose(bone_idx, get_bone_rest(bone_idx).inverse() * bone.transform)
