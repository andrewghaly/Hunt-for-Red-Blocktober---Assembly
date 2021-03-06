TITLE 16-Bit Example
INCLUDE C:\Irvine\Irvine16.inc
INCLUDELIB C:\Irvine\Irvine16.lib

;-------------------------------------------------------------------
;--------------------------------Data-------------------------------
;-------------------------------------------------------------------

.data
;------Boxes------
box_Red BYTE 219					;Block
box_white BYTE 32					;Space

;------Click Contents------
RB_Click word 0						;Keep a record of clicks
RB_Count word 0						;Block counter
RB_Multi word 1						;Score Multiplier

;------Level Content------
level_Count byte 1					;Current Level
level_Next word 5					;Requirement to next level
level_Remaining word 5				;Remaining to next Level
level_Max word 50					;Max block limit for level
level_Win byte 11					;Beat N-1 to win
level_Score word 0					;Score

;------Delay in milliseconds------
time_Delay word 3000			;Time before next block (ms)
time_Decrement word 100			;Value to reduce delay per level


;------Text Information------
text_lost BYTE "You lost the game! You suck!",0
text_win BYTE "You beat the game!",0
text_level BYTE "Level ",0
text_bc BYTE "Block count: ",0
text_max BYTE "out of ",0
text_score BYTE "Score: ",0
text_next BYTE "Next Level: ",0

;------Mouse Stuff-------
mouseX WORD ?
mouseY WORD ?
SHOW_MOUSE = 1
GET_MOUSE_POSITION_STATUS_Click = 5

count WORD 0

;-------------------------------------------------------------------
;--------------------------------Code-------------------------------
;-------------------------------------------------------------------

.code
main PROC
	mov ax, @data
	mov ds, ax
	mov ax, SHOW_MOUSE
	int 33h
Doop:
	call DelayTimer
	call BlockSpawn
	call PrintLabels
	mov ah, 11h 
	int 16h
	jz Doop
	mov ah, 10h
	int 16h
	cmp al, 1Bh 
	je quit

	jmp Doop

COMMENT %
progLoop:
	

	;---------Click Info -----------
	mov ax, GET_MOUSE_POSITION_STATUS_Click
	mov bx, 0
	int 33h
	cmp ax, 1
	jne progLoop

	;------Display X,Y------
	mov ax, cx
	call writeDec
	mov al, ','
	call writeChar
	mov ax, dx
	call writeDec
	call Crlf
	;---------ESC----------
%
	;----------------------
	;jmp progLoop

quit:
	mov ah, 4Ch
	mov al, 0 
	int 21h
main ENDP

;-------------------------------------------------------------------
;----------------------------DelayTimer-----------------------------
;-------------------------------------------------------------------

DelayTimer PROC
	mov cx,1						;Start of delay (milliseconds)
	mov ax,time_Delay				;End of delay (milliseconds)
	call Delay						;Does delaying stuff
	ret
DelayTimer endp

;-------------------------------------------------------------------
;----------------------------BlockSpawn-----------------------------
;-------------------------------------------------------------------

BlockSpawn PROC uses ax dx
	mov dx,0
	mov ax,0

	mov ax,79											
	sub ax,2
	call RandomRange
	add ax,2											
	mov dl,al						;Randomly generates a number 2-79 for X

	mov ax,0
	mov ax,24
	sub ax,2
	call RandomRange
	add ax,2
	mov dh,al						;Randomly generates a number 2-24 for Y

	mov ax,0
	call Gotoxy						;Go to the generated X,Y
	mov al,4						;Set the color to Red
	call setTextcolor									
	mov al,box_Red										
	call writeChar					;Print the red block
	inc RB_Count					;Increment block count

	;call NextEvent					;Check progression
	call PrintLabels				;Update Labels
	;call LoseEvent					;Check if lost requirements met

	mov al,15						;Set color back to white
	call setTextColor
	ret
BlockSpawn ENDP

;-------------------------------------------------------------------
;----------------------------PrintLabels----------------------------
;-------------------------------------------------------------------

PrintLabels PROC uses ax dx
	
;------Print Level------
	mov dx,0
	mov ax,0
	call Gotoxy
	mov dx,offset text_level
	call writeString
	mov al, level_Count
	call WriteDec  

;------Print Next level Count------

	mov dx,0
	mov ax,0
	mov dl,9
	call Gotoxy
	mov dx,offset text_next
	call writeString
	mov ax, level_Remaining
	call WriteDec

;------Print Block Count------
	mov dx,0
	mov ax,0
	mov dl,25
	call Gotoxy
	mov dx,offset text_bc
	call writeString
	mov ax,RB_Count
	call writeDec

	mov dx,0
	mov ax,0
	mov dl,41
	call Gotoxy
	mov dx,offset text_max
	call writeString
	mov ax,level_Max
	call writeDec

;------Print Score------
	mov dx,0
	mov ax,0
	mov dl,65
	call Gotoxy
	mov dx,offset text_score
	call writeString
	mov ax,level_Score
	call writeDec

	ret
PrintLabels ENDP


;-------------------------------------------------------------------
;-----------------------------NextEvent-----------------------------
;-------------------------------------------------------------------

NextEvent PROC uses ax dx
	mov ax,0
	mov dx,0
	cmp level_Remaining,0			;Check if next level								
	je ChangeLevel					;If so, change level
	ret								;else, continue
ChangeLevel:
	inc level_Count					;Increment Level
	mov al,level_Win					
	cmp level_Count,al				;Check if beat max level
	jge Won							;If so, proceed WinEvent						
	add level_Next,5				;Increment Requirements
	mov ax,level_Next
	mov level_Remaining,ax			;Set remaining blocks required
	sub level_Max,5					;Decrease max block limit
	mov bx,time_Decrement				
	sub time_Delay,bx				;Decrease delay
	ret
Won:
	call WinEvent
	ret
NextEvent ENDP

;-------------------------------------------------------------------
;------------------------------WinEvent-----------------------------
;-------------------------------------------------------------------

WinEvent PROC uses ax dx
	mov ax,0
	mov al,2
	call SetTextColor				;Make text green
	call ClrScr
	mov dx,offset text_Win			;Print winning text
	call WriteString
	call Crlf
	mov dx,offset text_score
	call WriteString
	mov ax, level_Score			;Print score
	call writeDec
	call Crlf
	mov ah, 4Ch
	mov al, 0 
	int 21h							;End game
	ret
WinEvent ENDP

;-------------------------------------------------------------------
;-----------------------------LoseEvent-----------------------------
;-------------------------------------------------------------------

LoseEvent PROC uses ax
	mov ax,level_Max
	cmp ax,RB_Count					;Check if max block is reached
	je EndGameL						;If so, proceed to end the game
	ret								;else, continue game
EndGameL:
	call ClrScr						;Clear screen
	mov dx,offset text_lost		;Print Losing text
	call WriteString
	call Crlf
	mov dx,offset text_score		;Print score
	call WriteString
	mov ax, level_Score
	call writeDec
	call Crlf
	mov ah, 4Ch
	mov al, 0 
	int 21h							;End Game
LoseEvent ENDP

;-------------------------------------------------------------------
;-------------------------------------------------------------------
;-------------------------------------------------------------------

END main