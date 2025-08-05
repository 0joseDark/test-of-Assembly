# 📝 Editor de Texto em Assembly para Windows

Este projeto contém um **editor de texto com GUI**, escrito em **Assembly x86 (32 bits)** e **x64 (64 bits)** para Windows, com:

* Janela com menu e botões
* Área de texto (Edit control)
* Leitura e escrita de ficheiros `.txt`
* Suporte a Unicode
* Barra de ícones (Toolbar)
* Copiar/Colar, Abrir/Guardar, Multisseleção
* Compilável com **MASM32** ou **ml64.exe** + `link.exe`

---

## ✅ Funcionalidades

| Versão           | Funcionalidades principais                                                |
| ---------------- | ------------------------------------------------------------------------- |
| **x86 (32-bit)** | Janela com menu, botão, Edit, MessageBox, memória dinâmica                |
| **x64 (64-bit)** | Abrir e guardar `.txt`, copiar/colar, menus, suporte a Unicode            |
| **Avançado**     | Abrir múltiplos ficheiros, todos os tipos `*.*`, barra de ícones, Unicode |

---

## 🗂 Estrutura de Pastas

```
Editor/
├── bin/              ← Executável final
├── build/            ← Objetos e recursos temporários
├── src/
│   ├── editor.asm    ← Código principal
│   ├── editor.inc    ← Constantes e includes
│   └── editor.rc     ← Recursos (menus, ícones)
└── assets/
    └── icon.ico      ← Ícone da aplicação
```

---

## 🧩 Ficheiros

### `editor.asm`

Contém o código principal da aplicação em Assembly. Implementa a janela, menu, área de texto e tratamento de eventos (WinMain, WndProc).

### `editor.rc`

Define os menus (Ficheiro, Editar) e ícones.

### `editor.inc`

Define constantes (ID dos botões e menus) e inclui cabeçalhos da API do Windows.

---

## ⚙️ Compilação com MASM

### Opção 1 – MASM32 (32 bits)

```cmd
ml /c /coff src\editor.asm
rc src\editor.rc
link /SUBSYSTEM:WINDOWS src\editor.obj editor.res /OUT:bin\editor.exe
```

### Opção 2 – MASM64 (64 bits, Visual Studio)

```cmd
ml64 /c /Fo editor.obj src\editor.asm
rc src\editor.rc
link editor.obj editor.res /subsystem:windows /entry:start /machine:x64 user32.lib kernel32.lib gdi32.lib comdlg32.lib comctl32.lib
```

---

## 💡 Funcionalidades Detalhadas

### 🖼️ Interface

* Janela principal com menu “Ficheiro” (Abrir, Guardar, Sair) e “Editar” (Copiar, Colar)
* Área de edição de texto com scroll
* Barra de ícones (`ToolbarWindow32`) com botões
* Ícone da aplicação (`icon.ico`)

### 📂 Abertura de Ficheiros

* Suporte a diálogo `GetOpenFileName` (ANSI e Unicode)
* Suporte a múltiplos ficheiros (`OFN_ALLOWMULTISELECT`)
* Suporte a todos os tipos (`*.*`)

### 💾 Guardar Ficheiros

* Diálogo `GetSaveFileName`
* Escrita com `WriteFile` (`CreateFileA/W`)
* Suporte a Unicode com `CreateFileW`, `SetWindowTextW`, `GetWindowTextW`

### 📋 Copiar e Colar

* Usando `WM_COPY` e `WM_PASTE` com `SendMessage`

---

## 🧪 Exemplo Simples (Hello World)

```asm
.model small
.stack 100h
.data
    msg db 'Olá Mundo!', 13, 10, '$'
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

Compilar com:

```cmd
ml hello.asm
```

---

## 📘 Recursos Importantes

* [`CreateWindowEx`](https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-createwindowexa)
* [`GetOpenFileName`](https://learn.microsoft.com/en-us/windows/win32/api/commdlg/ns-commdlg-openfilenamea)
* [`ToolbarWindow32`](https://learn.microsoft.com/en-us/windows/win32/controls/create-a-toolbar)
* `comdlg32.lib`, `comctl32.lib` (linkagem para diálogos e controlos comuns)

---

## 📦 Batch de Compilação (opcional)

```bat
@echo off
cd src
rc editor.rc
ml /c /coff editor.asm
link /SUBSYSTEM:WINDOWS editor.obj editor.res /OUT:..\bin\editor.exe
pause
```

---

## 🧠 Dicas Finais

* Usa `ml /?` e `link /?` para explorar opções
* Usa `chr$()` para criar strings em runtime
* Para Unicode, termina strings com `0` e usa funções `W`

---

Se desejares, posso gerar um novo `README.md` com este conteúdo limpo e formatado. Queres que o crie e envie como ficheiro?
