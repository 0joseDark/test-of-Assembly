# 📝 Text Editor in Assembly for Windows

This project includes a **GUI-based text editor**, written in **x86 (32-bit)** and **x64 (64-bit)** Assembly for Windows, with:

* Window with menu and buttons
* Text area (Edit control)
* File read/write support (`.txt`)
* Unicode support
* Icon toolbar
* Copy/Paste, Open/Save, Multi-selection
* Compatible with **MASM32**, **ml64.exe**, and `link.exe`

---

## ✅ Features

| Version          | Main Features                                                           |
| ---------------- | ----------------------------------------------------------------------- |
| **x86 (32-bit)** | Window with menu, button, Edit control, MessageBox, dynamic memory      |
| **x64 (64-bit)** | Open/save `.txt`, copy/paste, menu system, Unicode support              |
| **Advanced**     | Open multiple files, `*.*` support, toolbar with icons, Unicode support |

---

## 🗂 Folder Structure

```
Editor/
├── bin/              ← Final executable
├── build/            ← Temporary OBJ/RES files
├── src/
│   ├── editor.asm    ← Main code
│   ├── editor.inc    ← Constants and includes
│   └── editor.rc     ← Resources (menus, icons)
└── assets/
    └── icon.ico      ← Application icon
```

---

## 🧩 Files Overview

### `editor.asm`

Main Assembly source file. Implements the main window, menu, text area, and message/event handling (`WinMain`, `WndProc`).

### `editor.rc`

Defines the menu layout (File, Edit) and icons.

### `editor.inc`

Defines constants (button and menu IDs) and includes Windows API headers.

---

## ⚙️ Build with MASM

### Option 1 – MASM32 (32-bit)

```cmd
ml /c /coff src\editor.asm
rc src\editor.rc
link /SUBSYSTEM:WINDOWS src\editor.obj editor.res /OUT:bin\editor.exe
```

### Option 2 – MASM64 (64-bit with Visual Studio)

```cmd
ml64 /c /Fo editor.obj src\editor.asm
rc src\editor.rc
link editor.obj editor.res /subsystem:windows /entry:start /machine:x64 user32.lib kernel32.lib gdi32.lib comdlg32.lib comctl32.lib
```

---

## 💡 Main Functionalities

### 🖼️ Interface

* Main window with **File** (Open, Save, Exit) and **Edit** (Copy, Paste) menus
* Text editing area with scrollbar
* Toolbar (`ToolbarWindow32`) with icons (Open, Save, etc.)
* Optional application icon

### 📂 File Operations

* Uses `GetOpenFileName` and `CreateFileA/W` to open files
* Multi-file open with `OFN_ALLOWMULTISELECT`
* File filters (e.g., `*.*`, `*.txt`)

### 💾 Save Support

* Uses `GetSaveFileName` and `WriteFile` for saving text
* Supports Unicode with `CreateFileW`, `GetWindowTextW`, `SetWindowTextW`

### 📋 Copy and Paste

* Implemented using `SendMessage(WM_COPY)` and `SendMessage(WM_PASTE)`

---

## 📘 Simple Example (`hello.asm`)

```asm
.model small
.stack 100h
.data
    msg db 'Hello World!', 13, 10, '$'
.code
main:
    mov ax, @data
    mov ds, ax

    mov ah, 9
    mov dx, offset msg
    int 21h

    mov ah, 4Ch
    int 21h
end main
```

Build:

```cmd
ml hello.asm
```

---

## 🧪 Result

* Fully working windowed application
* 100% Assembly source (MASM)
* Runs on modern Windows x64
* Multi-file open, Unicode and menu interaction

---

## 📦 Batch Script Example

```bat
@echo off
cd src
rc editor.rc
ml /c /coff editor.asm
link /SUBSYSTEM:WINDOWS editor.obj editor.res /OUT:..\bin\editor.exe
pause
```

---

## 🧠 Final Tips

* Use `ml /?` and `link /?` to explore command-line options.
* Use `chr$()` macro when needed for runtime string conversion.
* For Unicode support, use `CreateFileW`, `GetOpenFileNameW`, and 16-bit `WCHAR` strings.
* Icons can be embedded using `.rc` and included via `LoadIcon`.
