extends GutTest

const Scene := preload("res://Scenes/Execution.tscn")
var scene: Node
var original_exec_delay

func before_all():
	original_exec_delay = Data.global_config["execution_delay"]
	Data.global_config["execution_delay"] = 0

func before_each():
	scene = Scene.instantiate()

func after_all():
	Data.global_config["execution_delay"] = original_exec_delay

func test_copy_files():
	const project_path = "res://Tests/Projects/TestProject1/"
	
	# Check assumptions
	assert_true(FileAccess.file_exists(project_path + "file1.txt"))
	assert_false(FileAccess.file_exists(project_path + "file1-copy.txt"))
	assert_false(FileAccess.file_exists(project_path + "EmptyDir/file1-copy.txt"))
	
	# Setup
	Data.load_project(project_path)
	Data.current_routine = Data.routines[0]
	
	# Execute
	add_child_autofree(scene)
	await wait_seconds(1.5)
	
	# Check results
	assert_true(FileAccess.file_exists(project_path + "file1.txt"))
	assert_true(FileAccess.file_exists(project_path + "file1-copy.txt"))
	assert_true(FileAccess.file_exists(project_path + "EmptyDir/file1-copy.txt"))

	# Cleanup
	DirAccess.remove_absolute(project_path + "file1-copy.txt")
	DirAccess.remove_absolute(project_path + "EmptyDir/file1-copy.txt")
