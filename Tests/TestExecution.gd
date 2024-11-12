extends GutTest

const PROJECTS := {
	1: "res://Tests/Projects/TestProject1/",
}
const ROUTINES := {
	# TestProject1
	"copy_files": 0,
	"clear_directory_files": 1,
	"pack_zip": 2,
	"sub_routine": 3,
	"cyclic_sub_routine_1": 7,
	"cyclic_sub_routine_2": 9,
}
const EXECUTION_TIMEOUT := 5.0
const Scene := preload("res://Scenes/Execution.tscn")
var scene: Node
var original_exec_delay

func before_all():
	original_exec_delay = Data.global_config["execution_delay"]
	Data.global_config["execution_delay"] = 0

func before_each():
	scene = Scene.instantiate()

func after_each():
	scene.free()

func after_all():
	Data.global_config["execution_delay"] = original_exec_delay

func test_copy_files():
	# Check assumptions
	assert_true(FileAccess.file_exists(PROJECTS[1] + "File1.txt"))
	assert_false(FileAccess.file_exists(PROJECTS[1] + "File1Copy.txt"))
	assert_false(FileAccess.file_exists(PROJECTS[1] + "EmptyDir/File1Copy.txt"))
	assert_true(DirAccess.dir_exists_absolute(PROJECTS[1] + "DeepDir"))
	assert_false(DirAccess.dir_exists_absolute(PROJECTS[1] + "EmptyDir/DirCopyRecursive"))
	assert_false(DirAccess.dir_exists_absolute(PROJECTS[1] + "EmptyDir/DirCopyNotRecursive"))
	
	# Setup
	Data.load_project(PROJECTS[1])
	Data.current_routine = Data.routines[ROUTINES.copy_files]
	
	# Execute
	add_child.call_deferred(scene)
	await wait_for_signal(scene.finished, EXECUTION_TIMEOUT)
	
	# Check results
	assert_true(FileAccess.file_exists(PROJECTS[1] + "File1.txt"))
	assert_true(DirAccess.dir_exists_absolute(PROJECTS[1] + "DeepDir"))
	
	assert_true(FileAccess.file_exists(PROJECTS[1] + "File1Copy.txt"))
	assert_true(FileAccess.file_exists(PROJECTS[1] + "EmptyDir/File1Copy.txt"))
	
	assert_true(FileAccess.file_exists(PROJECTS[1] + "EmptyDir/DirCopyRecursive/DirFile1.txt"))
	assert_true(FileAccess.file_exists(PROJECTS[1] + "EmptyDir/DirCopyRecursive/DirFile2.txt"))
	assert_true(FileAccess.file_exists(PROJECTS[1] + "EmptyDir/DirCopyRecursive/SubDir/SubDirFile1.txt"))
	
	assert_true(FileAccess.file_exists(PROJECTS[1] + "EmptyDir/DirCopyNotRecursive/DirFile1.txt"))
	assert_true(FileAccess.file_exists(PROJECTS[1] + "EmptyDir/DirCopyNotRecursive/DirFile2.txt"))
	assert_false(DirAccess.dir_exists_absolute(PROJECTS[1] + "EmptyDir/DirCopyNotRecursive/SubDir"))

	# Cleanup
	DirAccess.remove_absolute(PROJECTS[1] + "File1Copy.txt")
	DirAccess.remove_absolute(PROJECTS[1] + "EmptyDir/File1Copy.txt")
	
	DirAccess.remove_absolute(PROJECTS[1] + "EmptyDir/DirCopyRecursive/DirFile1.txt")
	DirAccess.remove_absolute(PROJECTS[1] + "EmptyDir/DirCopyRecursive/DirFile2.txt")
	DirAccess.remove_absolute(PROJECTS[1] + "EmptyDir/DirCopyRecursive/SubDir/SubDirFile1.txt")
	DirAccess.remove_absolute(PROJECTS[1] + "EmptyDir/DirCopyRecursive/SubDir")
	DirAccess.remove_absolute(PROJECTS[1] + "EmptyDir/DirCopyRecursive")
	
	DirAccess.remove_absolute(PROJECTS[1] + "EmptyDir/DirCopyNotRecursive/DirFile1.txt")
	DirAccess.remove_absolute(PROJECTS[1] + "EmptyDir/DirCopyNotRecursive/DirFile2.txt")
	DirAccess.remove_absolute(PROJECTS[1] + "EmptyDir/DirCopyNotRecursive/SubDir/SubDirFile1.txt")
	DirAccess.remove_absolute(PROJECTS[1] + "EmptyDir/DirCopyNotRecursive/SubDir")
	DirAccess.remove_absolute(PROJECTS[1] + "EmptyDir/DirCopyNotRecursive")

func test_clear_directory_files():
	# Check assumptions
	assert_true(FileAccess.file_exists(PROJECTS[1] + "DeepDir/DirFile1.txt"))
	assert_true(FileAccess.file_exists(PROJECTS[1] + "DeepDir/DirFile2.txt"))
	assert_true(FileAccess.file_exists(PROJECTS[1] + "DeepDir/SubDir/SubDirFile1.txt"))
	
	# Setup
	DirAccess.copy_absolute(PROJECTS[1] + "DeepDir/DirFile1.txt", PROJECTS[1] + "EmptyDir/DirFile1.txt")
	DirAccess.copy_absolute(PROJECTS[1] + "DeepDir/DirFile2.txt", PROJECTS[1] + "EmptyDir/DirFile2.txt")
	Data.load_project(PROJECTS[1])
	Data.current_routine = Data.routines[ROUTINES.clear_directory_files]
	
	# Execute
	add_child.call_deferred(scene)
	await wait_for_signal(scene.finished, EXECUTION_TIMEOUT)
	
	# Check results
	assert_false(FileAccess.file_exists(PROJECTS[1] + "DeepDir/DirFile1.txt"))
	assert_false(FileAccess.file_exists(PROJECTS[1] + "DeepDir/DirFile2.txt"))
	assert_true(FileAccess.file_exists(PROJECTS[1] + "DeepDir/SubDir/SubDirFile1.txt"))

	# Cleanup
	DirAccess.rename_absolute(PROJECTS[1] + "EmptyDir/DirFile1.txt", PROJECTS[1] + "DeepDir/DirFile1.txt")
	DirAccess.rename_absolute(PROJECTS[1] + "EmptyDir/DirFile2.txt", PROJECTS[1] + "DeepDir/DirFile2.txt")

func test_pack_zip():
	# Check assumptions
	assert_true(DirAccess.dir_exists_absolute(PROJECTS[1] + "DeepDir"))
	assert_true(DirAccess.dir_exists_absolute(PROJECTS[1] + "MixedDir"))
	assert_false(FileAccess.file_exists(PROJECTS[1] + "DeepDir.zip"))
	assert_false(FileAccess.file_exists(PROJECTS[1] + "IncludeBlob.zip"))
	assert_false(FileAccess.file_exists(PROJECTS[1] + "Exclude.zip"))
	assert_false(FileAccess.file_exists(PROJECTS[1] + "IncludeExclude.zip"))
	
	# Setup
	Data.load_project(PROJECTS[1])
	Data.current_routine = Data.routines[ROUTINES.pack_zip]
	
	# Execute
	add_child.call_deferred(scene)
	await wait_for_signal(scene.finished, EXECUTION_TIMEOUT)
	
	# Check results
	assert_true(DirAccess.dir_exists_absolute(PROJECTS[1] + "DeepDir"))
	assert_true(DirAccess.dir_exists_absolute(PROJECTS[1] + "MixedDir"))
	assert_true(FileAccess.file_exists(PROJECTS[1] + "DeepDir.zip"))
	assert_true(FileAccess.file_exists(PROJECTS[1] + "IncludeBlob.zip"))
	assert_true(FileAccess.file_exists(PROJECTS[1] + "Exclude.zip"))
	assert_true(FileAccess.file_exists(PROJECTS[1] + "IncludeExclude.zip"))
	
	var reader := ZIPReader.new()
	var error := reader.open(PROJECTS[1] + "DeepDir.zip")
	var files := reader.get_files()
	reader.close()
	assert_true(error == OK)
	assert_true(files.has("DirFile1.txt"))
	assert_true(files.has("DirFile2.txt"))
	assert_true(files.has("SubDir/SubDirFile1.txt"))
	
	reader = ZIPReader.new()
	error = reader.open(PROJECTS[1] + "IncludeBlob.zip")
	files = reader.get_files()
	reader.close()
	assert_true(error == OK)
	assert_false(files.has("TxtFile1.txt"))
	assert_false(files.has("TxtFile2.txt"))
	assert_true(files.has("MdFile1.md"))
	assert_true(files.has("MdFile2.md"))
	
	reader = ZIPReader.new()
	error = reader.open(PROJECTS[1] + "Exclude.zip")
	files = reader.get_files()
	reader.close()
	assert_true(error == OK)
	assert_true(files.has("DirFile1.txt"))
	assert_true(files.has("DirFile2.txt"))
	assert_false(files.has("SubDir/SubDirFile1.txt"))
	
	reader = ZIPReader.new()
	error = reader.open(PROJECTS[1] + "IncludeExclude.zip")
	files = reader.get_files()
	reader.close()
	assert_true(error == OK)
	assert_false(files.has("TxtFile1.txt"))
	assert_true(files.has("TxtFile2.txt"))
	assert_false(files.has("MdFile1.md"))
	assert_false(files.has("MdFile2.md"))

	# Cleanup
	DirAccess.remove_absolute(PROJECTS[1] + "DeepDir.zip")
	DirAccess.remove_absolute(PROJECTS[1] + "IncludeBlob.zip")
	DirAccess.remove_absolute(PROJECTS[1] + "Exclude.zip")
	DirAccess.remove_absolute(PROJECTS[1] + "IncludeExclude.zip")

func test_sub_routine():
	# Check assumptions
	assert_true(FileAccess.file_exists(PROJECTS[1] + "File1.txt"))
	assert_false(FileAccess.file_exists(PROJECTS[1] + "Copy1.txt"))
	assert_false(FileAccess.file_exists(PROJECTS[1] + "Copy2.txt"))
	assert_false(FileAccess.file_exists(PROJECTS[1] + "Copy3.txt"))
	assert_false(FileAccess.file_exists(PROJECTS[1] + "Copy4.txt"))
	
	# Setup
	Data.load_project(PROJECTS[1])
	Data.current_routine = Data.routines[ROUTINES.sub_routine]
	
	# Execute
	add_child.call_deferred(scene)
	await wait_for_signal(scene.finished, EXECUTION_TIMEOUT)
	
	# Check results
	assert_true(FileAccess.file_exists(PROJECTS[1] + "File1.txt"))
	assert_true(FileAccess.file_exists(PROJECTS[1] + "Copy1.txt"))
	assert_true(FileAccess.file_exists(PROJECTS[1] + "Copy2.txt"))
	assert_true(FileAccess.file_exists(PROJECTS[1] + "Copy3.txt"))
	assert_true(FileAccess.file_exists(PROJECTS[1] + "Copy4.txt"))

	# Cleanup
	DirAccess.remove_absolute(PROJECTS[1] + "Copy1.txt")
	DirAccess.remove_absolute(PROJECTS[1] + "Copy2.txt")
	DirAccess.remove_absolute(PROJECTS[1] + "Copy3.txt")
	DirAccess.remove_absolute(PROJECTS[1] + "Copy4.txt")

func test_cyclic_sub_routine_1():
	# Setup
	Data.load_project(PROJECTS[1])
	Data.current_routine = Data.routines[ROUTINES.cyclic_sub_routine_1]
	
	# Execute
	watch_signals(scene)
	add_child.call_deferred(scene)
	await wait_for_signal(scene.finished, EXECUTION_TIMEOUT)
	
	# Check results
	assert_signal_emitted(scene, "finished")

func test_cyclic_sub_routine_2():
	# Setup
	Data.load_project(PROJECTS[1])
	Data.current_routine = Data.routines[ROUTINES.cyclic_sub_routine_2]
	
	# Execute
	watch_signals(scene)
	add_child.call_deferred(scene)
	await wait_for_signal(scene.finished, EXECUTION_TIMEOUT)
	
	# Check results
	assert_signal_emitted(scene, "finished")
