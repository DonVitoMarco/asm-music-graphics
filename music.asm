Progr           segment
                assume  cs:Progr, ds:dane, ss:stosik

start:          mov     ax,dane
                mov     ds,ax
                mov     ax,stosik
                mov     ss,ax
                mov     sp,offset szczyt

;/////////////////////////////////////////////////////////////////////////////////////////////////////;

;skok do początku programu
JMP BEGIN

;/////////////////////// PROCEDURY ///////////////////////;

;***********************************************;
;                   PLAY_NUTE                   ;
;***********************************************;
; @wejscie:			                            ;
;   BX - kod nuty		                        ;
;   CX - czas trwania                           ;
;***********************************************;
playNute PROC
    mov     DX, 1Dh
    mov     AX, 7310h
    div     BX
    out     42h,al
    mov     al,ah       
    out     42h,al
    call 	delay
    call    printNute
    ret 
ENDP


;***********************************************;
;                    DELAY                      ;
;***********************************************;
; @wejscie:			                            ;
;   CX - czas trwania                           ;
;   (1/16- 1; 1/8- 2; 1/4- 4; 1/2- 8; 1- 16)    ;
;***********************************************;
delay PROC
	  xor     DX, DX
    mov     AH, 86h
    int     15h
    ret
ENDP


;***********************************************;
;                  PRINT_NUTE                   ;
;***********************************************;
printNute PROC
    mov     BH, Nuta

    cmp     BH, 'C'
    jz      colC
    cmp     BH, 'E'
    jz      colE
    cmp     BH, 'G'
    jz      colG
    cmp     BH, 'H'
    jz      colH
    cmp     BH, 'D'
    jz      colD
    cmp     BH, 'F'
    jz      colF
    cmp     BH, 'A'
    jz      colA
    jmp     endprintNute

colC:
    call    createColC
    jmp     endprintNute
colE:
    call    createColE
    jmp     endprintNute
colG:
    call    createColG
    jmp     endprintNute
colH:
    call    createColH
    jmp     endprintNute
colD:
    call    createColD
    jmp     endprintNute
colF:
    call    createColF
    jmp     endprintNute
colA:
    call    createColA
    jmp     endprintNute
endprintNute:
    mov     BX, Kolumna
    cmp     BX, 315
    jg      cleanScreen
    jmp     retprintNute
cleanScreen:
    mov     AH, 00h
    mov     AL, 13h
    int     10h
    mov     BX, 6h
    mov     Kolumna, BX
retprintNute:
    ret
ENDP


;***********************************************;
;                  READ_BYTE                    ;
;***********************************************;
ReadByte PROC
readB:
    mov     DX, OFFSET Buffer
    mov     BX, Handle
    mov     CX, 1
    mov     AH, 3Fh
    int     21h
    mov     AH, Buffer  
    cmp     AH, ' '
    jz      readB
    mov     AH, Buffer  
    cmp     AH, 13d
    jz      readB     
    mov     AH, Buffer  
    cmp     AH, 10d
    jz      readB
    ret
ENDP


;***********************************************;
;                   GET_NUTE                    ;
;***********************************************;
; @wejscie:                                     ;
;   BH - dzwiek                                 ;
;   BL - oktawa                                 ;
; @wyjscie:                                     ;
;   AX - nuta                                   ;
;***********************************************;
GetNute PROC
    lea     SI, nutes
    ;obliczanie offsetu
    sub     bh, 41h
    sub     bl, 31h
    add     bh, bh
    shl     bl, 4
    add     bl, bh
    xor     bh, bh
    add     si, bx
    ;nuta do ax
    mov     ax, word ptr [si]
    ret
ENDP


;***********************************************;
;                GET_HALF_NUTE                  ;
;***********************************************;
; @wejscie:                                     ;
;   BH - dzwiek                                 ;
;   BL - oktawa                                 ;
; @wyjscie:                                     ;
;   AX - nuta                                   ;
;***********************************************;
GetHalfNute PROC
    lea     SI, halftones
    ;obliczanie offsetu
    sub     bh, 41h
    sub     bl, 31h
    add     bh, bh
    shl     bl, 4
    add     bl, bh
    xor     bh, bh
    add     si, bx
    ;nuta do ax
    mov     ax, word ptr [si]
    ret
ENDP


;***********************************************;
;               CONVERT_PAUZA                   ;
;***********************************************;
; @wejscie:                                     ;
;   CX - pauza z pliku                          ;
; @wyjscie:                                     ;
;   CL - pauza                                  ;
;***********************************************;
ConvertPauza PROC 
    sub     CL, 30h
    cmp     CH, 31h
    jz      poprawka
    jnz     returnCon
poprawka:
    add     CL, 0Ah
returnCon:
    xor     CH, CH
    ret
ENDP


;***********************************************;
;                 PLAY_PAUSE                    ;
;***********************************************;
; @wejscie:                                     ;
;   CX - pauza                                  ;
;***********************************************;
PlayPause PROC 
    call    turnOffSpeakers
    xor     DX, DX
    mov     AH, 86h
    int     15h
    call    turnOnSpeakers
    call    createCol
    ret
ENDP


;***********************************************;
;               TURN_ON_SPEAKERS                ;
;***********************************************;
turnOnSpeakers PROC
    mov     DX, 61H
    in      AL, DX
    or      AL, 00000011B
    out     DX, AL 
;    mov     DX, OFFSET SpeakerOn
;    mov     AH, 09h
;    int     21h
    ret
ENDP


;***********************************************;
;               TURN_OFF_SPEAKERS               ;
;***********************************************;
turnOffSpeakers PROC
    mov     DX, 61H
    in      AL, DX
    and     AL, 11111100B
    out     DX,AL
;    mov     DX, OFFSET SpeakerOff
;    mov     AH, 09h
;    int     21h
    ret
ENDP

;***********************************************;
;                  NAME_FILE                    ;
;***********************************************;
NameFile PROC
	lea 	DX, FileNamePrompt
    mov 	AH, 09h
    int 	21h

    mov 	byte ptr [FileName], MaxFileSize
    lea 	DX, FileName
    mov 	AH, 0ah
    int 	21h

    xor 	CX, CX
    mov 	CL, byte ptr [FileName+1]
    lea 	SI, FileName
    add 	SI, CX
    add 	SI, 2
    mov 	byte ptr [si], 0

    ret
ENDP


;***********************************************;
;                  OPEN_FILE                    ;
;***********************************************;
OpenFile PROC
    mov     AH, 3Dh
    mov     AL, 02h
    mov     DX, OFFSET FileName+2
    int     21h 
    jc      ErrorOpen
    jmp     EndOpen
ErrorOpen:
    mov     DX, OFFSET ErrorOpenFile
    mov     AH, 09
    int     21h
    jmp     ReturnOpen
EndOpen:        
    mov     Handle, AX
    mov     DX, OFFSET OkOpenFile
    mov     AH, 09
    int     21h
ReturnOpen:
    ret
ENDP


;***********************************************;
;                  CLOSE_FILE                   ;
;***********************************************;
CloseFile PROC
    mov     BX, Handle
    mov     AH, 3Eh
    int     21h     
    jc      ErrorClose
    jmp     EndClose
ErrorClose:
    mov     DX, OFFSET ErrorCloseFile
    mov     AH, 09
    int     21h
    jmp     ReturnClose
EndClose:        
    mov     DX, OFFSET OkCloseFile
    mov     AH, 09
    int     21h
ReturnClose:
    ret
ENDP


;***********************************************;
;                TURN_ON_VGA_13h                ;
;***********************************************;
turnOnVga PROC

;Bufor Video
    mov AX, 0A000h
    mov ES, AX

;VGA Mode
    mov AX, 013h
    int 010h

    ret
ENDP


;***********************************************;
;               TURN_OFF_VGA_13h                ;
;***********************************************;
turnOffVga PROC
    mov     AX, 03h
    int     10h
    ret
ENDP


;***********************************************;
;                  CREATE_COL                   ;
;***********************************************;
createCol PROC 
pustacol:
    xor     CX, CX
    xor     BX, BX
    mov     BX, Kolumna
col:
    mov     DX, 5
    call    drawSpace
    call    drawLine
    inc     CX
    cmp     CX, 5
    jnz     col
retCol:
    mov     BX, Kolumna
    add     BX, 6h
    mov     Kolumna, BX
    ret
ENDP


;***********************************************;
;                CREATE_COL_C                   ;
;***********************************************;
createColC PROC 
    xor     CX, CX
    xor     BX, BX
    mov     BX, Kolumna
ccolC:
    mov     DX, 5
    call    drawSpace
    call    drawLine
    inc     CX
    cmp     CX, 5
    jnz     ccolC
nuteC:
    mov     DX, 2
    call    drawSpace
    call    drawNute
retColC:
    mov     BX, Kolumna
    add     BX, 6h
    mov     Kolumna, BX
    ret
ENDP


;***********************************************;
;                CREATE_COL_E                   ;
;***********************************************;
createColE PROC 
    xor     CX, CX
    xor     BX, BX
    mov     BX, Kolumna
ccolE:
    mov     DX, 5
    call    drawSpace
    call    drawLine
    inc     CX
    cmp     CX, 4
    jnz     ccolE
nuteE:
    mov     DX, 3
    call    drawSpace
    call    drawNute
retColE:
    mov     BX, Kolumna
    add     BX, 6h
    mov     Kolumna, BX
    ret
ENDP


;***********************************************;
;                CREATE_COL_G                   ;
;***********************************************;
createColG PROC 
    xor     CX, CX
    xor     BX, BX
    mov     BX, Kolumna
ccolG:
    mov     DX, 5
    call    drawSpace
    call    drawLine
    inc     CX
    cmp     CX, 3
    jnz     ccolG
nuteG:
    mov     DX, 3
    call    drawSpace
    call    drawNute
    mov     DX, 4
    call    drawSpace    
    call    drawLine
retColG:
    mov     BX, Kolumna
    add     BX, 6h
    mov     Kolumna, BX
    ret
ENDP


;***********************************************;
;                CREATE_COL_H                   ;
;***********************************************;
createColH PROC 
    xor     CX, CX
    xor     BX, BX
    mov     BX, Kolumna
ccolH:
    mov     DX, 5
    call    drawSpace
    call    drawLine
    inc     CX
    cmp     CX, 2
    jnz     ccolH
nuteH:
    mov     DX, 3
    call    drawSpace
    call    drawNute
    sub     BX, 280h
    xor     CX, CX
ccolH2:
    mov     DX, 5
    call    drawSpace
    call    drawLine
    inc     CX
    cmp     CX, 2
    jnz     ccolH2
retColH:
    mov     BX, Kolumna
    add     BX, 6h
    mov     Kolumna, BX
    ret
ENDP


;***********************************************;
;                CREATE_COL_D                   ;
;***********************************************;
createColD PROC 
    xor     CX, CX
    xor     BX, BX
    mov     BX, Kolumna

    mov     DX, 5
    call    drawSpace
    call    drawLine
nuteD:
    mov     DX, 3
    call    drawSpace
    call    drawNute
    sub     BX, 280h
ccolD:
    mov     DX, 5
    call    drawSpace
    call    drawLine
    inc     CX
    cmp     CX, 3
    jnz     ccolD
retColD:
    mov     BX, Kolumna
    add     BX, 6h
    mov     Kolumna, BX
    ret
ENDP


;***********************************************;
;                CREATE_COL_F                   ;
;***********************************************;
createColF PROC 
    xor     CX, CX
    xor     BX, BX
    mov     BX, Kolumna
nuteF:
    mov     DX, 3
    call    drawSpace
    call    drawNute
    sub     BX, 280h
ccolF:
    mov     DX, 5
    call    drawSpace
    call    drawLine
    inc     CX
    cmp     CX, 4
    jnz     ccolF
retColF:
    mov     BX, Kolumna
    add     BX, 6h
    mov     Kolumna, BX
    ret
ENDP


;***********************************************;
;                CREATE_COL_A                   ;
;***********************************************;
createColA PROC 
    xor     CX, CX
    xor     BX, BX
    mov     BX, Kolumna
nuteA:
    call    drawNute
    sub     BX, 280h
    sub     BX, 280h
    sub     BX, 280h
ccolA:
    mov     DX, 5
    call    drawSpace
    call    drawLine
    inc     CX
    cmp     CX, 5
    jnz     ccolA
retColA:
    mov     BX, Kolumna
    add     BX, 6h
    mov     Kolumna, BX
    ret
ENDP


;***********************************************;
;                  DRAW_SPACE                   ;
;***********************************************;
drawSpace PROC
space:
    add     BX, 280h
    dec     DX
    cmp     DX, 0
    jnz     space
    ret
ENDP


;***********************************************;
;                  DRAW_NUTE                    ;
;***********************************************;
drawNute PROC
    mov     AH, '*'
    mov     AL, 10h
    mov     ES:[BX], AX
    add     BX, 280h
    mov     AH, '*'
    mov     AL, 10h
    mov     ES:[BX], AX
    add     BX, 280h
    mov     AH, '*'
    mov     AL, 10h
    mov     ES:[BX], AX
    push    BX
    sub     BX, 2h
    mov     AH, '*'
    mov     AL, 10h
    mov     ES:[BX], AX
    pop     BX
    add     BX, 280h
    mov     AH, '*'
    mov     AL, 10h
    mov     ES:[BX], AX
    push    BX
    sub     BX, 2h
    mov     AH, '*'
    mov     AL, 10h
    mov     ES:[BX], AX
    pop     BX
    ret
ENDP


;***********************************************;
;                  DRAW_LINE                    ;
;***********************************************;
drawLine PROC
    mov     AH, '-'
    mov     AL, 2Ch
    mov     ES:[BX], AX
    ret
ENDP


;/////////////////////// START_PROGRAMU ///////////////////////;


BEGIN:
;*** OTWARCIE PLIKU ***;
    call 	NameFile
    call    OpenFile

;*** WLACZENIE GLOSNIKA ***;
    call    turnOnSpeakers

;*** WLACZENIE TRYBU GRAFICZNEGO ***;
    call    turnOnVga


CZYTAJ:
CZYTAJ_NUTA:
    call    ReadByte
    ;sprawdzenie konca melodii
    mov     AH, Buffer
    cmp     AH, 'Q'
    jz      KONIEC
    cmp     AH, 'P'
    jz      TYLKO_PAUZA
    cmp     AH, '#'
    jz      POLTON
    mov     Nuta, AH     

CZYTAJ_OKTAWA:
    call    ReadByte
    mov     BL, Buffer
    mov     BH, Nuta
    call    GetNute
    push    AX
    jmp     PAUZA

;jeżeli zamiast nuty 'H'
POLTON:
    call    ReadByte
    mov     Nuta, AH

    call    ReadByte
    mov     BL, Buffer
    mov     BH, Nuta
    call    GetHalfNute
    push    AX
    
    call    ReadByte
    mov     CH, Buffer
    call    ReadByte
    mov     CL, Buffer
    call    ConvertPauza

    pop     BX

    call    playNute
    jmp     CZYTAJ

;jezeli zamiast nuty 'P'
TYLKO_PAUZA:
    call    ReadByte
    mov     CH, Buffer
    call    ReadByte
    mov     CL, Buffer
    call    ConvertPauza
    call    PlayPause
    jmp     CZYTAJ

;czytaj pauze
PAUZA:
    call    ReadByte
    mov     CH, Buffer
    call    ReadByte
    mov     CL, Buffer
    call    ConvertPauza

    pop     BX

ZAGRAJ:
    call	playNute
    jmp     CZYTAJ


KONIEC:

;*** WYLACZENIE GLOSNIKA ***;
    call    turnOffSpeakers

;*** WYLACZENIE VGA ***;
    call    turnOffVga

;*** ZAMKNIECIE PLIKU ***;
    call   CloseFile



;/////////////////////////////////////////////////////////////////////////////////////////////////////;
      		mov     ah,4ch
	        mov	    al,0h
	        int	    21h
Progr           ends


;/////////////////////// DANE ///////////////////////;
dane            segment

	MaxFileSize 	equ		200
    FileName DB MaxFileSize dup(0)
    Kolumna DW 1
    Handle DW ?
    Buffer DB 1 dup(?)
    Nuta   DB 1 dup(?)
    ErrorOpenFile   DB  "Plik nie zostal otwarty poprawnie", 13, 10, "$"
    OkOpenFile      DB  "Plik zostal otwarty poprawnie", 13, 10, "$"
    ErrorCloseFile  DB  "Plik nie zostal zamkniety poprawnie", 13, 10, "$"
    OkCloseFile     DB  "Plik zostal zamkniety poprawnie", 13, 10, "$"
    SpeakerOff      DB  "Glosnik zostal wylaczony", 13, 10, "$"
    SpeakerOn       DB  "Glosnik zostal wlaczony", 13, 10, "$"
    FileNamePrompt	DB 	"Podaj nazwe pliku: ", "$"

    ;                   A    --   C    D    E    F    G    H
    nutes           dw 0055,0000,0033,0037,0041,0044,0049,0062
                    dw 0110,0000,0065,0073,0082,0087,0098,0123
                    dw 0220,0000,0131,0147,0165,0175,0196,0247
                    dw 0440,0000,0262,0294,0330,0349,0392,0494
                    dw 0880,0000,0523,0587,0659,0698,0784,0988
                    dw 1760,0000,1047,1175,1319,1397,1568,1976
                    dw 3520,0000,2093,2349,2637,2794,3136,3951

    ;                  Ais   --  Cis  Dis  Eis  Fis  Gis   --
    halftones       dw 0058,0000,0035,0039,0042,0046,0052,0000
                    dw 0116,0000,0069,0077,0084,0092,0104,0000
                    dw 0233,0000,0139,0156,0170,0185,0208,0000
                    dw 0466,0000,0277,0311,0339,0370,0415,0000
                    dw 0932,0000,0554,0622,0678,0740,0831,0000
                    dw 1865,0000,1109,1245,1357,1480,1661,0000
                    dw 3729,0000,2217,2489,2714,2960,3322,0000

dane            ends
;/////////////////////////////////////////////////////;



stosik          segment
                dw    100h dup(0)
szczyt          Label word
stosik          ends

end start
