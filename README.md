# **editor de texto com janela, menu e botões em Assembly (Assembler)**
- Abaixo está um **exemplo mínimo funcional** em **Assembly x86 (32 bits)** para Windows usando o **Win32 API**, com:

* Uma janela com menu,
* Um botão,
* Uma área de texto (Edit control),
* Comentários passo a passo,
* Uso de memória dinâmica (`GlobalAlloc`),
* Compilável com **MASM** (Microsoft Macro Assembler) e **GoLink** ou **Link.exe**.

---

## ✅ Pré-requisitos

1. Instalar o **MASM32 SDK** → [http://www.masm32.com/](http://www.masm32.com/)
2. Ter `ml` (assembler) e `link` (linker)
3. Criar três ficheiros:

   * `editor.asm` — Código Assembly
   * `editor.rc` — Recursos (menu)
   * `editor.ico` (opcional)

---

## 📄 `editor.asm` – Código principal

```asm
.386
.model flat, stdcall
option casemap:none

include windows.inc
include user32.inc
include kernel32.inc
include gdi32.inc
include comctl32.inc
includelib user32.lib
includelib kernel32.lib
includelib gdi32.lib
includelib comctl32.lib

WinMain proto :DWORD,:DWORD,:DWORD,:DWORD

.const
IDC_EDIT     equ 1001
IDC_BTN      equ 1002
IDM_ABRIR    equ 2001
IDM_SAIR     equ 2002

.data
ClassName   db "JanelaClasse",0
AppName     db "Editor Assembly",0
TextMsg     db "Olá, edita-me!",0
ButtonTxt   db "Guardar",0

.data?
hInstance   HINSTANCE ?
hEdit       HWND ?
hMem        DWORD ?

.code

start:
    invoke GetModuleHandle, NULL
    mov    hInstance, eax
    invoke WinMain, hInstance, NULL, NULL, SW_SHOWDEFAULT
    invoke ExitProcess, eax

WinMain proc hInst:HINSTANCE, hPrev:HINSTANCE, lpCmdLine:DWORD, nCmdShow:DWORD
    LOCAL wc:WNDCLASSEX
    LOCAL msg:MSG
    LOCAL hwnd:HWND

    ;--- Registo da classe da janela
    mov wc.cbSize, SIZEOF WNDCLASSEX
    mov wc.style, CS_HREDRAW or CS_VREDRAW
    mov wc.lpfnWndProc, OFFSET WndProc
    mov wc.cbClsExtra, NULL
    mov wc.cbWndExtra, NULL
    push hInst
    pop wc.hInstance
    mov wc.hbrBackground, COLOR_WINDOW+1
    mov wc.lpszMenuName, NULL
    mov wc.lpszClassName, OFFSET ClassName
    invoke LoadIcon, NULL, IDI_APPLICATION
    mov wc.hIcon, eax
    mov wc.hIconSm, eax
    invoke LoadCursor, NULL, IDC_ARROW
    mov wc.hCursor, eax

    invoke RegisterClassEx, addr wc

    ;--- Criar Janela
    invoke CreateWindowEx, 0, addr ClassName, addr AppName,\
           WS_OVERLAPPEDWINDOW, CW_USEDEFAULT, CW_USEDEFAULT,\
           500, 400, NULL, NULL, hInst, NULL
    mov hwnd, eax

    invoke ShowWindow, hwnd, SW_SHOWNORMAL
    invoke UpdateWindow, hwnd

    ;--- Loop de Mensagens
    .WHILE TRUE
        invoke GetMessage, addr msg, NULL, 0, 0
        .BREAK .IF eax == 0
        invoke TranslateMessage, addr msg
        invoke DispatchMessage, addr msg
    .ENDW
    mov eax, msg.wParam
    ret
WinMain endp

WndProc proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM

    .IF uMsg == WM_CREATE
        ;--- Criar Área de Edição
        invoke CreateWindowEx, WS_EX_CLIENTEDGE, addr TextMsg, NULL,\
               WS_CHILD or WS_VISIBLE or WS_VSCROLL or\
               ES_MULTILINE or ES_AUTOVSCROLL,\
               10, 10, 460, 280,\
               hWnd, IDC_EDIT, hInstance, NULL
        mov hEdit, eax

        ;--- Criar Botão
        invoke CreateWindowEx, 0, addr ButtonTxt, addr ButtonTxt,\
               WS_CHILD or WS_VISIBLE or BS_PUSHBUTTON,\
               380, 300, 80, 25,\
               hWnd, IDC_BTN, hInstance, NULL

        ;--- Alocar memória
        invoke GlobalAlloc, GMEM_FIXED, 2048
        mov hMem, eax

    .ELSEIF uMsg == WM_COMMAND
        mov eax, wParam
        .IF ax == IDC_BTN
            ;--- Obter texto do Edit e guardar em memória
            invoke GetWindowText, hEdit, hMem, 2048
            ;--- Mostrar MsgBox com texto
            invoke MessageBox, hWnd, hMem, addr AppName, MB_OK
        .ENDIF

    .ELSEIF uMsg == WM_DESTROY
        ;--- Libertar memória
        invoke GlobalFree, hMem
        invoke PostQuitMessage, 0

    .ELSE
        invoke DefWindowProc, hWnd, uMsg, wParam, lParam
        ret
    .ENDIF
    xor eax, eax
    ret
WndProc endp

end start
```

---

## 📄 `editor.rc` – Recursos (opcional, se quiser menus ou ícones)

```rc
EditorMenu MENU
BEGIN
    POPUP "&Ficheiro"
    BEGIN
        MENUITEM "&Abrir", IDM_ABRIR
        MENUITEM "Sair", IDM_SAIR
    END
END
```

---

## ⚙️ Como compilar

No terminal `cmd` do Windows com o MASM instalado:

```cmd
ml /c /coff editor.asm
rc editor.rc
link /SUBSYSTEM:WINDOWS editor.obj editor.res user32.lib kernel32.lib gdi32.lib comctl32.lib
```

---

## 💡 Explicações passo a passo

| Parte            | Explicação                                             |
| ---------------- | ------------------------------------------------------ |
| `.data`          | Define dados estáticos como strings e identificadores. |
| `CreateWindowEx` | Cria os controlos (área de texto e botão).             |
| `GetWindowText`  | Lê o texto digitado pelo utilizador.                   |
| `GlobalAlloc`    | Reserva memória para guardar texto temporariamente.    |
| `MessageBox`     | Mostra o texto como confirmação.                       |
| `WndProc`        | Função principal que trata os eventos da janela.       |
| `WM_COMMAND`     | Quando o botão é clicado.                              |
| `WM_DESTROY`     | Finaliza o programa e liberta memória.                 |

---

## 📌 Observações

* Este exemplo **usa a API Win32 diretamente** — sem bibliotecas de terceiros.
* Pode adicionar **menus**, **ícones**, e **abrir ficheiros** com funções como `GetOpenFileName`.
* Pode compilar em **x64**, mas muda os registradores e chamadas.

---
# **editor de texto em Assembly x64 para Windows**, com:

* ✅ **Leitura e escrita em ficheiros `.txt`**
* ✅ **Abrir ficheiros com rato (caixa de diálogo `GetOpenFileName`)**
* ✅ **Menu com opções de copiar/colar**
* ✅ **Versão x64 compatível com MASM64 (ml64.exe)**

---

## 🧩 Estrutura do Projeto

Ficheiros necessários:

```
editor.asm     ; Código principal
editor.rc      ; Recursos (menu)
editor.inc     ; Constantes e includes
```

---

## 📁 `editor.inc` — Includes e constantes

```asm
include windows.inc
include kernel32.inc
include user32.inc
include comdlg32.inc
include gdi32.inc
include comctl32.inc

includelib kernel32.lib
includelib user32.lib
includelib gdi32.lib
includelib comdlg32.lib
includelib comctl32.lib

IDC_EDIT     equ 1001
IDC_BTN      equ 1002
IDM_ABRIR    equ 2001
IDM_GUARDAR  equ 2002
IDM_SAIR     equ 2003
IDM_COPIAR   equ 2004
IDM_COLAR    equ 2005
```

---

## 🗂 `editor.rc` — Recursos com menu

```rc
EditorMenu MENU
BEGIN
    POPUP "&Ficheiro"
    BEGIN
        MENUITEM "&Abrir", IDM_ABRIR
        MENUITEM "&Guardar", IDM_GUARDAR
        MENUITEM SEPARATOR
        MENUITEM "Sair", IDM_SAIR
    END
    POPUP "&Editar"
    BEGIN
        MENUITEM "Copiar", IDM_COPIAR
        MENUITEM "Colar", IDM_COLAR
    END
END
```

---

## 🧠 `editor.asm` — Código em Assembly x64

### Começo

```asm
include editor.inc

.data
ClassName   db "JanelaClasse",0
AppName     db "Editor Assembly x64",0
FilterTxt   db "Text Files (*.txt)",0,"*.txt",0,0
ButtonTxt   db "Guardar",0

.data?
hInstance   dq ?
hEdit       dq ?
szFile      db 260 dup(?)
ofn         OPENFILENAME <>
```

### `start` e `WinMain` (iguais à versão anterior, exceto ponteiros de 64 bits)

---

### ✨ `WndProc` — Tratamento dos comandos

```asm
WndProc proc hWnd:QWORD, uMsg:QWORD, wParam:QWORD, lParam:QWORD
    .if uMsg == WM_CREATE
        invoke CreateWindowExA, WS_EX_CLIENTEDGE, chr$("EDIT"), 0,
                WS_CHILD or WS_VISIBLE or WS_VSCROLL or ES_LEFT or ES_MULTILINE or ES_AUTOVSCROLL,
                10, 10, 700, 500, hWnd, IDC_EDIT, hInstance, NULL
        mov hEdit, rax

    .elseif uMsg == WM_COMMAND
        mov eax, dword ptr wParam
        .if eax == IDM_ABRIR
            ;--- Diálogo para abrir ficheiro
            lea rcx, ofn
            mov ofn.lStructSize, sizeof OPENFILENAME
            mov ofn.hwndOwner, hWnd
            lea rdx, szFile
            mov ofn.lpstrFile, rdx
            mov ofn.nMaxFile, 260
            lea rdx, FilterTxt
            mov ofn.lpstrFilter, rdx
            mov ofn.Flags, OFN_PATHMUSTEXIST or OFN_FILEMUSTEXIST
            invoke GetOpenFileNameA, rcx
            .if rax
                ;--- Abrir ficheiro
                invoke CreateFileA, addr szFile, GENERIC_READ, 0, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL
                mov r8, rax
                .if r8 != INVALID_HANDLE_VALUE
                    sub rsp, 2048
                    lea rdx, [rsp]
                    invoke ReadFile, r8, rdx, 2048, addr rax, NULL
                    invoke CloseHandle, r8
                    invoke SetWindowTextA, hEdit, rdx
                    add rsp, 2048
                .endif
            .endif

        .elseif eax == IDM_GUARDAR
            ;--- Guardar ficheiro
            lea rcx, ofn
            mov ofn.lStructSize, sizeof OPENFILENAME
            mov ofn.hwndOwner, hWnd
            lea rdx, szFile
            mov ofn.lpstrFile, rdx
            mov ofn.nMaxFile, 260
            lea rdx, FilterTxt
            mov ofn.lpstrFilter, rdx
            mov ofn.Flags, OFN_PATHMUSTEXIST or OFN_OVERWRITEPROMPT
            invoke GetSaveFileNameA, rcx
            .if rax
                ;--- Obter texto e guardar
                sub rsp, 2048
                lea rdx, [rsp]
                invoke GetWindowTextA, hEdit, rdx, 2048
                invoke CreateFileA, addr szFile, GENERIC_WRITE, 0, NULL, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL
                mov r8, rax
                .if r8 != INVALID_HANDLE_VALUE
                    invoke WriteFile, r8, rdx, rax, addr rax, NULL
                    invoke CloseHandle, r8
                .endif
                add rsp, 2048
            .endif

        .elseif eax == IDM_COPIAR
            invoke SendMessageA, hEdit, WM_COPY, 0, 0

        .elseif eax == IDM_COLAR
            invoke SendMessageA, hEdit, WM_PASTE, 0, 0

        .elseif eax == IDM_SAIR
            invoke PostQuitMessage, 0
        .endif

    .elseif uMsg == WM_DESTROY
        invoke PostQuitMessage, 0

    .else
        invoke DefWindowProcA, hWnd, uMsg, wParam, lParam
        ret
    .endif
    xor eax, eax
    ret
WndProc endp
```

---

## ⚙️ Compilar (x64)

```cmd
ml64 /c /Fo editor.obj editor.asm
rc editor.rc
link editor.obj editor.res /subsystem:windows /entry:start /machine:x64 user32.lib kernel32.lib comdlg32.lib gdi32.lib
```

---

## ✅ Resultado

* Uma janela com menu: **Ficheiro (Abrir, Guardar, Sair)** e **Editar (Copiar, Colar)**
* Área de edição
* Usa `GetOpenFileName` e `CreateFileA` para abrir `.txt`
* Usa `WriteFile` para guardar texto
* Usa `WM_COPY` e `WM_PASTE` para copiar/colar
* Código 100% Assembly x64

---

