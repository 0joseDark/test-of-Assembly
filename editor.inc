; =====================
; editor.inc — Includes e constantes para o Editor Assembly x64
; =====================

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

chr$ macro texto
LOCAL __txt
.data
__txt db texto,0
.code
exitm <offset __txt>
endm
