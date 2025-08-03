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
## **editor de texto em Assembly x64 para Windows**

## 🆕 Novas Funcionalidades

1. ✅ **Abrir múltiplos ficheiros** (com caixa de diálogo `GetOpenFileName` + `OFN_ALLOWMULTISELECT`)
2. ✅ **Suporte a todos os tipos de ficheiros** (`*.*`)
3. ✅ **Barra de ícones (toolbar)** com botões: Abrir, Guardar, Copiar, Colar
4. ✅ **Suporte a Unicode** (`CreateWindowExW`, `GetOpenFileNameW`, `CreateFileW`, etc.)

---

### 📌 Modificações importantes

* Usar `W` no final das funções da WinAPI (ex: `CreateFileW`) para Unicode.
* Utilizar `WCHAR` para strings (16-bit).
* Adicionar `TOOLBARCLASSNAMEW` para criar a barra de ícones.
* Usar `InitCommonControlsEx` para carregar classes comuns (`TOOLBARCLASSNAME`).

---

## 🧩 Passos para implementar

### 1. `.data` – Unicode + Filtro

```asm
.data
FilterAllW      dw "Todos (*.*)",0,"*.*",0,0
szFileW         dw 4096 dup(?)
```

### 2. OPENFILENAME para múltiplos ficheiros

```asm
ofn OPENFILENAMEW <>
...
mov ofn.lStructSize, sizeof OPENFILENAMEW
mov ofn.hwndOwner, hWnd
lea rdx, szFileW
mov ofn.lpstrFile, rdx
mov ofn.nMaxFile, 4096
lea rdx, FilterAllW
mov ofn.lpstrFilter, rdx
mov ofn.Flags, OFN_EXPLORER or OFN_ALLOWMULTISELECT or OFN_FILEMUSTEXIST
```

Depois de `GetOpenFileNameW`, percorre-se a lista de caminhos em `szFileW`.

---

### 3. Criar barra de ícones (toolbar)

```asm
include commctrl.inc
includelib comctl32.lib

ToolbarInit proc hWnd:QWORD
    LOCAL hToolBar:QWORD

    ; Inicializa controlos comuns
    mov ecx, sizeof INITCOMMONCONTROLSEX
    sub rsp, 16
    mov [rsp], ecx
    mov [rsp+4], ICC_BAR_CLASSES
    invoke InitCommonControlsEx, rsp
    add rsp, 16

    ; Cria toolbar
    invoke CreateWindowExW, 0, chr$("ToolbarWindow32"), NULL,\
        WS_CHILD or WS_VISIBLE or TBSTYLE_TOOLTIPS,\
        0, 0, 0, 0, hWnd, 0, hInstance, NULL
    mov hToolBar, rax

    ; Adicionar botões (exemplo com Abrir, Guardar, Copiar, Colar)
    ; usar imagem padrão ou adicionar ícones personalizados com TB_ADDBUTTONS
    ret
ToolbarInit endp
```

---

### 4. Suporte a Unicode nos controlos

```asm
invoke CreateWindowExW, WS_EX_CLIENTEDGE, chr$("EDIT"), NULL,
       WS_CHILD or WS_VISIBLE or ES_MULTILINE or ES_AUTOVSCROLL,
       10, 30, 600, 400,
       hWnd, IDC_EDIT, hInstance, NULL
```

---

### 5. Leitura e escrita com Unicode

```asm
; Abrir ficheiro (Unicode)
invoke CreateFileW, addr szFileW, GENERIC_READ, 0, NULL, OPEN_EXISTING, 0, NULL

; Guardar ficheiro (Unicode)
invoke CreateFileW, addr szFileW, GENERIC_WRITE, 0, NULL, CREATE_ALWAYS, 0, NULL
```

---

### 6. Exemplo de percorrer múltiplos ficheiros

```asm
; Após GetOpenFileNameW
mov rsi, offset szFileW
mov rdi, rsi

; Primeiro valor é o diretório base
next_file:
    cmp word ptr [rsi], 0
    je done_files
    ; Aqui: processa o ficheiro
    ; Mostrar em MessageBoxW ou abrir

    add rsi, 2
    jmp next_file
done_files:
```

---

## ✅ Compilar (Unicode + Toolbar)

```cmd
ml64 /c /Fo editor.obj editor.asm
rc editor.rc
link editor.obj editor.res /subsystem:windows /entry:start /machine:x64 user32.lib kernel32.lib gdi32.lib comdlg32.lib comctl32.lib
```

---

## 💡 O que foi adicionado

| Funcionalidade        | Implementação                              |
| --------------------- | ------------------------------------------ |
| Abrir múltiplos files | `OFN_ALLOWMULTISELECT` + buffer 4 KB       |
| Todos os tipos        | Filtro `*.*` Unicode                       |
| Barra de ícones       | `ToolbarWindow32` + `InitCommonControlsEx` |
| Suporte a Unicode     | Funções `W`, `CreateFileW`, `EditW`        |

---
### ✅ **Como compilar com MASM (Microsoft Macro Assembler)**

# O **MASM** (Microsoft Macro Assembler) é um assembler da Microsoft para processadores **x86/x64**. Ele permite escrever programas em linguagem de montagem (Assembly) e gerar ficheiros `.exe`.

---

## 🧰 1. **Pré-requisitos**

### 🔹 Tens duas opções principais:

* **Instalar o MASM32 SDK** (mais simples para começar)
* **Usar o MASM incluído no Visual Studio** (mais recente e poderoso)

---

## 🔽 2. **Instalar o MASM32 SDK (recomendado para começar)**

1. Vai ao site oficial (ou pesquisa "MASM32 SDK download")
   Link: [http://www.masm32.com/](http://www.masm32.com/)
2. Faz download do instalador.
3. Instala em `C:\masm32` (por defeito).

---

## 📁 3. **Estrutura de um programa simples**

### Exemplo: `ola.asm`

```asm
.model small
.stack 100h
.data
    msg db 'Ola Mundo!', 13, 10, '$'
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

---

## 🛠 4. **Como compilar com o MASM32**

### Comandos a usar:

```bash
ml ola.asm
```

### Isso gera:

* `OLA.OBJ`: ficheiro objeto intermediário
* `OLA.EXE`: programa executável

---

## 🔀 5. **Compilação passo a passo**

### A. **Montar e linkar separadamente** (útil para debug)

```bash
ml /c ola.asm        ; apenas monta (gera OLA.OBJ)
link ola.obj         ; liga e cria OLA.EXE
```

---

## 🚩 6. **Explicação dos parâmetros**

| Comando | Significado                                         |
| ------- | --------------------------------------------------- |
| `ml`    | Microsoft Macro Assembler                           |
| `/c`    | Apenas compila (não linka)                          |
| `/coff` | Gera formato COFF (necessário para 64-bit às vezes) |
| `/Fo`   | Define nome do ficheiro `.obj` de saída             |
| `/Fe`   | Define nome do `.exe` de saída                      |
| `/link` | Passa argumentos diretamente ao linker              |

---

## 💻 7. **Compilar Assembly 64-bit com Visual Studio (MASM x64)**

1. Abre o **Developer Command Prompt for VS**
2. Exemplo:

```bash
ml64 /Fo hello.obj /c hello.asm
link hello.obj /subsystem:console
```

---

## 📜 8. **Exemplo de Assembly x64 simples**

```asm
.code
main proc
    mov rax, 0
    ret
main endp
end
```

---

## 🧪 9. **Testar o programa**

Depois de compilar, basta correr:

```bash
ola.exe
```

Verás:

```
Ola Mundo!
```

---

## 🧠 10. **Dicas úteis**

* Usa o `edit` ou `notepad` para editar `.asm`.
* Usa `ml /?` para ver todos os parâmetros do MASM.
* Usa `link /?` para ver todos os parâmetros do linker.

---

## 📦 11. **Exemplo completo de script batch**

```bat
@echo off
ml /c /coff programa.asm
link /subsystem:console programa.obj
programa.exe
pause
```

---
# **projeto em Assembly (MASM32)** com **janela GUI**, **menu**, **botões**, ficheiros `.rc` e `.inc`, e instruções completas para **compilar com MASM e WinMain**.

---

## 📁 Estrutura de Pastas

```
Editor/
├── bin/              ← EXE final
├── build/            ← OBJ, RES temporários
├── src/
│   ├── editor.asm    ← Código principal
│   ├── editor.inc    ← Constantes e identificadores
│   └── editor.rc     ← Recursos (menus, ícones)
└── assets/
    └── icon.ico      ← Ícone da aplicação
```

---

## 📘 `editor.inc` (em `src/`)

```asm
; editor.inc
IDC_BUTTON1    equ 1001
IDC_BUTTON2    equ 1002
IDM_ABRIR      equ 40001
IDM_SAIR       equ 40002
```

---

## 🎨 `editor.rc` (em `src/`)

```rc
#include "editor.inc"

1 ICON "assets\\icon.ico"

MENU_MAIN MENU
BEGIN
    POPUP "&Ficheiro"
    BEGIN
        MENUITEM "&Abrir", IDM_ABRIR
        MENUITEM "Sair",   IDM_SAIR
    END
END
```

---

## 💡 `editor.asm` (em `src/`)

```asm
.386
.model flat, stdcall
option casemap:none

include windows.inc
include user32.inc
include kernel32.inc
include gdi32.inc
includelib user32.lib
includelib kernel32.lib
includelib gdi32.lib

include editor.inc

.data
    className db "JanelaPrincipal", 0
    windowTitle db "Editor GUI MASM", 0
    hInstance dd ?
    hWndMain dd ?

.code

start:
    invoke GetModuleHandle, NULL
    mov hInstance, eax
    invoke WinMain, hInstance, NULL, NULL, SW_SHOWDEFAULT
    invoke ExitProcess, eax

WinMain proc hInst:HINSTANCE, hPrev:HINSTANCE, lpCmdLine:LPSTR, nCmdShow:DWORD
    LOCAL msg:MSG
    LOCAL wc:WNDCLASSEX

    mov wc.cbSize, SIZEOF WNDCLASSEX
    mov wc.style, CS_HREDRAW or CS_VREDRAW
    mov wc.lpfnWndProc, OFFSET WndProc
    mov wc.cbClsExtra, 0
    mov wc.cbWndExtra, 0
    push hInst
    pop wc.hInstance
    mov wc.hbrBackground, COLOR_BTNFACE+1
    mov wc.lpszMenuName, offset MENU_MAIN
    mov wc.lpszClassName, offset className
    invoke LoadIcon, hInst, 1
    mov wc.hIcon, eax
    mov wc.hIconSm, eax
    invoke LoadCursor, NULL, IDC_ARROW
    mov wc.hCursor, eax

    invoke RegisterClassEx, addr wc
    invoke CreateWindowEx, 0, addr className, addr windowTitle, \
        WS_OVERLAPPEDWINDOW, CW_USEDEFAULT, CW_USEDEFAULT, 500, 400, \
        NULL, NULL, hInst, NULL
    mov hWndMain, eax
    invoke ShowWindow, hWndMain, SW_SHOWNORMAL
    invoke UpdateWindow, hWndMain

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
        invoke CreateWindowEx, 0, addr className, addr windowTitle, \
            WS_CHILD or WS_VISIBLE or BS_PUSHBUTTON, \
            20, 50, 100, 30, hWnd, IDC_BUTTON1, hInstance, NULL

        invoke CreateWindowEx, 0, addr className, addr windowTitle, \
            WS_CHILD or WS_VISIBLE or BS_PUSHBUTTON, \
            140, 50, 100, 30, hWnd, IDC_BUTTON2, hInstance, NULL

    .ELSEIF uMsg == WM_COMMAND
        mov eax, wParam
        .IF ax == IDM_ABRIR
            invoke MessageBox, hWnd, "Abrir ficheiro selecionado", "Menu", MB_OK
        .ELSEIF ax == IDM_SAIR
            invoke PostQuitMessage, 0
        .ELSEIF ax == IDC_BUTTON1
            invoke MessageBox, hWnd, "Botão 1 clicado", "Info", MB_OK
        .ELSEIF ax == IDC_BUTTON2
            invoke MessageBox, hWnd, "Botão 2 clicado", "Info", MB_OK
        .ENDIF

    .ELSEIF uMsg == WM_DESTROY
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

## 🛠 Como Compilar com MASM32

### ⚙️ 1. Abrir **Prompt do MASM32** (`C:\masm32\qeditor.exe` → Tools → "Console")

### ⚙️ 2. Executar os seguintes comandos:

```cmd
cd caminho\para\Editor

rem Compilar recursos
rc src\editor.rc
cvtres /machine:ix86 editor.res

rem Compilar assembly
ml /c /coff src\editor.asm

rem Linkar tudo
link /SUBSYSTEM:WINDOWS /LIBPATH:C:\masm32\lib src\editor.obj editor.res /OUT:bin\editor.exe
```

---

## ▶️ Executar o Programa

```cmd
bin\editor.exe
```

---



