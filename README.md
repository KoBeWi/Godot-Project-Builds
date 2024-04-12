# <img src="Icons/Icon.png" width="64" height="64"> Godot Project Builder

Godot Project Builder is an automation tool made in Godot Engine and focused on exporting and publishing Godot projects. The builder works by running "routines", which are composed of "tasks". Each task involves running a predefined command with customized arguments. The builder comes with numberous built-in tasks, which include exporting project, publishing to popular stores (Steam, GOG, Epic, itch.io), and file operations. Task setup is fully visual.

## Overview

Project Builder can be launched from a release executable or from source using Godot Engine (4.3 or newer). When you start Project Builder, the first thing you will see is the project list.

![](Media/ProjectList.png)

It's similar to Godot's own Project Manager, but more minimal. It automatically lists the projects you have registered in Godot, with information whether Project Builder is configured for that project and how many routines it has. Clicking a project will open the main project view.

![](Media/MainRoutines.png)

It shows projects title at the top and is divided in to 4 tabs: Routines, Templates, Tasks and Config. They are explained below.

### Routines

This tab shows overview of all routines in your project. You can create a routine by clicking Add Routine button, which will add an empty one:

![](Media/EmptyRoutine.png)

From the main view, routines can be executed, edited, duplicated or deleted. When you create and edit a routine, it will be automatically saved in a dedicated project build configuration file stored in your project's folder. By default the file is located at `res://project_builds_config.txt`.

#### Editing Routines

By clicking the Edit button in a routine, you will open an editing screen where you can assign tasks to a routine.

![](Media/RoutineEditing.png)

On this screen you'll see a list of all tasks assigned to the routine. You can add a task by clicking Add Task button and selecting a task from the list.

![](Media/RoutineTaskList.png)

After the task is added, you can use its controls to setup it. Reference about task usages and its cofniguration is available in the [Tasks](#tasks) tab or in the [task list](#list-of-available-tasks) in this README.

At the top of the task preview is its title and various buttons. The top-left button allows you to quickly execute a single task from the routine (see [Executing](#executing)). The top-right are buttons for rearranging tasks, a Copy button and a Delete button. Copy will copy the task data into an internal clipboard and you will be able to paste the task into the same routine, other routines, or even other projects. The Delete button requires double-click to activate, to prevent accidental deleting. A deleted task cannot be recovered, as currently the Project Builder does not support undo/redo.

Above the task list is the routine name field, where you can rename it. Note that each routine needs an unique name and if there is a conflict, you won't be able to leave this screen (unless you use the Discard Changes button). Aside from name, there is a dropdown for controlling what happens when a task fails (see [Executing](#executing)). Clicking Back will go back to the main screen and save the routine. The routine is also saved when you close the Project Builder.

#### Executing

By clicking the Execute button in a routine, by using using the quick-execute button in routine editing screen, you will enter the execution mode. If you did this by accident, you have 1 second to press Escape and cancel task (afterwards you have to close the application if you want to stop it).

![](Media/RoutineExecuting.gif)

Execution works simply by running tasks one after another. A task will run a commend with arguments and display the output in real time. Once a task finishes, you will see whether it succeeded or failed, its exit code, and the time it took to execute.

![](Media/FinishedTask.png)

Top of the task is its execution name (i.e. a more detailed task name) and the exact command that is executed when the task runs (in the example above, the task invoked Godot with `--export-release`). Below is Toggle Output button that allows you to hide output and Copy Output, which will copy it to the clipboard. Note that output is also written to log files that can be accessed from Open Log Folder on the main screen.

Normally when task fails, the whole execution will stop. You can configure that in routine settings; the other option is to continue executing normally. When a routine finishes, you will see the total time it took to execute.

![](Media/FinishedRoutine.png)

### Preset Templates

The second tab in the main screen. It allows defining templates for export presets. It's a way to share properties like file filters or feature tags between mutliple presets, making multiple export targets easier to manage. The templates are used only by one task.

![](Media/MainTemplates.png)

A template is composed of Name, Custom Features, Include Filters, Exclude Filters and Export Base. Name has to be unique; in case of conflict, duplicate templates will be ignored. Custom Features are equivalent of the custom features in Features tab of export dialog, while Filters are equivalent of Include/Exclude Filters in Resources tab. Images for reference:

![](Media/ExportFilters.png) ![](Media/ExportFeatures.png)

Export Base is a base directory used when exporting with this template. It's later prefixed with the actual file (see [Export Project From Template](#export-project-from-template)).

Templates can inherit other templates. Inheriting template will include features and filters of the parent and auto-update them, so you can e.g. make one configuration with your include filters and make all other templates use it. You no longer have to worry about updating all export presets when you add a new file extension. Export Base is not inherited.

### Tasks

The third tab in the main screen. It's a readonly list of all available tasks, with their descriptions and argument list. You can use it as a quick reference of what does what. More detailed information is available in this README.

![](Media/MainTasks.png)

#### Custom Tasks

### Config

The last tab in the main screen. Here you can configure Project Builder. It includes both global config that applies to all your projects and a local config, which is per-project. The local config is stored in the builds config file mentioned before, while global config is stored in Project Builder's user data folder.

![](Media/MainConfig.png)

### Project Builder Plugin

command palette

## List of Available Tasks

### Clear Directory Files

### Copy Files(s)

### Custom Task

### Export Project

### Export Project From Template

### Pack ZIP

### Sub-Routine

### Upload Epic

### Upload GOG

### Upload Itch

### Upload Steam
___
You can find all my addons on my [profile page](https://github.com/KoBeWi).

<a href='https://ko-fi.com/W7W7AD4W4' target='_blank'><img height='36' style='border:0px;height:36px;' src='https://cdn.ko-fi.com/cdn/kofi1.png?v=3' border='0' alt='Buy Me a Coffee at ko-fi.com' /></a>
