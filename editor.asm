; =====================
; editor.asm — Editor de Texto x64 em Assembly para Windows
; =====================
include editor.inc

.data
ClassNameW      dw "EditorClasse",0
AppNameW        dw "Editor Assembly x64",0
FilterAllW      dw "Todos (*.*)",0,"*.*",0,0
ButtonTxtW      dw "Guardar",0

.data?
hInstance       dq ?
hEdit           dq ?
szFileW         dw 4096 dup(?)
ofn             OPENFILENAMEW <>

.code
start:
    sub rsp, 28h
    invoke GetModuleHandleW, NULL
    mov hInstance, rax
    invoke WinMain, hInstance, NULL, NULL, SW_SHOWDEFAULT
    invoke ExitProcess, eax

WinMain proc hInst:QWORD, hPrev:QWORD, lpCmdLine:QWORD, nCmdShow:QWORD
    LOCAL wc:WNDCLASSEXW
    LOCAL msg:MSG
    LOCAL hwnd:QWORD

    mov wc.cbSize, SIZEOF WNDCLASSEXW
    mov wc.style, CS_HREDRAW or CS_VREDRAW
    mov wc.lpfnWndProc, OFFSET WndProc
    mov wc.cbClsExtra, 0
    mov wc.cbWndExtra, 0
    mov wc.hInstance, hInst
    mov wc.hbrBackground, COLOR_WINDOW+1
    mov wc.lpszMenuName, NULL
    mov wc.lpszClassName, OFFSET ClassNameW
    invoke LoadIconW, NULL, IDI_APPLICATION
    mov wc.hIcon, rax
    mov wc.hIconSm, rax
    invoke LoadCursorW, NULL, IDC_ARROW
    mov wc.hCursor, rax

    invoke RegisterClassExW, addr wc

    invoke CreateWindowExW, 0, addr ClassNameW, addr AppNameW,
           WS_OVERLAPPEDWINDOW, CW_USEDEFAULT, CW_USEDEFAULT,
           800, 600, NULL, NULL, hInst, NULL
    mov hwnd, rax

    invoke ShowWindow, hwnd, SW_SHOWNORMAL
    invoke UpdateWindow, hwnd

.WHILE TRUE
    invoke GetMessageW, addr msg, NULL, 0, 0
    .BREAK .IF eax == 0
    invoke TranslateMessage, addr msg
    invoke DispatchMessageW, addr msg
.ENDW

    mov rax, msg.wParam
    ret
WinMain endp

WndProc proc hWnd:QWORD, uMsg:QWORD, wParam:QWORD, lParam:QWORD
    .if uMsg == WM_CREATE
        ; Criar Edit Unicode
        invoke CreateWindowExW, WS_EX_CLIENTEDGE, chr$("EDIT"), NULL,
               WS_CHILD or WS_VISIBLE or WS_VSCROLL or ES_MULTILINE or ES_AUTOVSCROLL,
               10, 40, 760, 500, hWnd, 1001, hInstance, NULL
        mov hEdit, rax

        ; Criar barra de ícones
        invoke ToolbarInit, hWnd

    .elseif uMsg == WM_COMMAND
        mov eax, dword ptr wParam
        .if eax == 2001
            ; Abrir ficheiro
            mov ofn.lStructSize, sizeof OPENFILENAMEW
            mov ofn.hwndOwner, hWnd
            lea rdx, szFileW
            mov ofn.lpstrFile, rdx
            mov ofn.nMaxFile, 4096
            lea rdx, FilterAllW
            mov ofn.lpstrFilter, rdx
            mov ofn.Flags, OFN_EXPLORER or OFN_ALLOWMULTISELECT or OFN_FILEMUSTEXIST
            invoke GetOpenFileNameW, addr ofn
            .if rax
                invoke CreateFileW, addr szFileW, GENERIC_READ, 0, NULL, OPEN_EXISTING, 0, NULL
                mov rcx, rax
                .if rcx != -1
                    sub rsp, 8192
                    lea rdx, [rsp]
                    invoke ReadFile, rcx, rdx, 8192, addr rax, NULL
                    invoke CloseHandle, rcx
                    invoke SetWindowTextW, hEdit, rdx
                    add rsp, 8192
                .endif
            .endif

        .elseif eax == 2002
            ; Guardar ficheiro
            mov ofn.lStructSize, sizeof OPENFILENAMEW
            mov ofn.hwndOwner, hWnd
            lea rdx, szFileW
            mov ofn.lpstrFile, rdx
            mov ofn.nMaxFile, 4096
            lea rdx, FilterAllW
            mov ofn.lpstrFilter, rdx
            mov ofn.Flags, OFN_OVERWRITEPROMPT
            invoke GetSaveFileNameW, addr ofn
            .if rax
                sub rsp, 8192
                lea rdx, [rsp]
                invoke GetWindowTextW, hEdit, rdx, 4096
                invoke CreateFileW, addr szFileW, GENERIC_WRITE, 0, NULL, CREATE_ALWAYS, 0, NULL
                mov rcx, rax
                .if rcx != -1
                    invoke WriteFile, rcx, rdx, rax, addr rax, NULL
                    invoke CloseHandle, rcx
                .endif
                add rsp, 8192
            .endif

        .elseif eax == 2003
            invoke PostQuitMessage, 0

        .elseif eax == 2004
            invoke SendMessageW, hEdit, WM_COPY, 0, 0
        .elseif eax == 2005
            invoke SendMessageW, hEdit, WM_PASTE, 0, 0
        .endif

    .elseif uMsg == WM_DESTROY
        invoke PostQuitMessage, 0

    .else
        invoke DefWindowProcW, hWnd, uMsg, wParam, lParam
        ret
    .endif
    xor rax, rax
    ret
WndProc endp

ToolbarInit proc hWnd:QWORD
    LOCAL hToolbar:QWORD

    sub rsp, 32
    mov rcx, 32
    mov rdx, ICC_BAR_CLASSES
    mov qword ptr [rsp], rcx
    mov qword ptr [rsp+8], rdx
    invoke InitCommonControlsEx, rsp
    add rsp, 32

    invoke CreateWindowExW, 0, chr$("ToolbarWindow32"), NULL,
        WS_CHILD or WS_VISIBLE or TBSTYLE_TOOLTIPS,
        0, 0, 0, 0, hWnd, 0, hInstance, NULL
    mov hToolbar, rax

    ret
ToolbarInit endp

end start
