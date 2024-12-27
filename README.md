# Haskell-Virtual-File-System-CLI

## Overview

This application is a basic command-line interface (CLI) for managing a virtual file system. It allows users to navigate directories, create files and directories, edit files, and persist the file system state to a file for later use.

The file system is modeled as a tree structure, where each node is either a `File` or a `Directory`. Users can interact with this structure using commands similar to those in a typical shell environment.

---

## Features

- **File System Navigation**:
  - `ls`: List the contents of the current directory.
  - `cd <dir>`: Change the current directory. Use `..` to go to the parent directory.

- **File and Directory Management**:
  - `mkdir <name>`: Create a new directory.
  - `touch <name>`: Create a new file.
  - `rm <name>`: Remove a file or directory.
  - `edit <name>`: Edit a file and append new content.

- **Persistence**:
  - `save <file>`: Save the current file system state to a file.
  - `load <file>`: Load a file system state from a file.

- **Exit**:
  - `exit`: Exit the program.

---

## Commands

| Command             | Description                                                   |
|---------------------|---------------------------------------------------------------|
| `ls`                | Lists the contents of the current directory.                  |
| `cd <dir>`          | Changes the current directory. Use `..` to go up one level.   |
| `mkdir <name>`      | Creates a new directory with the specified name.              |
| `touch <name>`      | Creates a new file with the specified name.                   |
| `rm <name>`         | Deletes a file or directory by name.                          |
| `edit <name>`       | Edits an existing file and appends new content to its name.   |
| `save <file>`       | Saves the current file system state to a specified file.      |
| `load <file>`       | Loads a file system state from a specified file.              |
| `exit`              | Exits the application.                                        |

---

## How It Works

### File System Structure

The file system is represented by the following data types:
- **`FileSystem`**:
  - `File String`: Represents a file with a name.
  - `Directory String [FileSystem]`: Represents a directory with a name and contents.

- **`FSState`**:
  - `path :: [String]`: Keeps track of the current directory path.
  - `currentDir :: FileSystem`: Represents the current directory.

### Persistence
- The `save` command writes the file system state to a file using Haskell's `show` function.
- The `load` command reads the file system state from a file using Haskell's `read` function.

---

## Running the Application

1. Save the code to a file named `Main.hs`.
2. Compile and run the program using GHC:
   ```bash
   ghc Main.hs -o vfs
   ./vfs
