;Description: This program prompts for user to input a 4-digit deciman number. It then
;converts the number into binary and hexidecimal. After converting, it displays the 
;numbers onto the screen.
;
;Author: Kent Chow
;
;Date: November 26, 2012

 org 100h 
 
section .text 
 
displayStart: 
    mov  bx, message    ; get address of first char in message
 
displayLoop:
    mov dl, [bx]        ; get char at address in BX 
    inc bx              ; point BX to next char in message
    cmp dl, 0           ; Is DL = null (that is, 0)?
    je  inputStart      ; If yes, then quit
    mov ah, 06          ; If no, then call int 21h service 06h
    int 21h             ; to print the character 
    jmp displayLoop     ; Repeat for the next character	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
inputStart:
	mov bx, input    ; set bx to address of input
	mov cx, 4 	     ; set cx to 4
	
inputLoop:
	mov ah, 00h      ; prompt input
	int 16h
	cmp al, 0dh      ; if user presses return too early
	je displayStart  ; then reset message
	mov [bx], al     ; else store value of input
	inc bx
	loop inputLoop   ; loop until cx is 0	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
convertStart:
	sub ax, ax     ; set ax to 0
	mov bx, input  ; set bx to address of input
	mov ch, 3      ; set ch to 3
	mov cl, 0      ; set cl to 0
	mov dx, 10     ; set dx to 10
	
convertSet:
	mov al, [bx]   ; assign al with first ASCII value in input
	sub al, 48     ; subtract 48 to convert to numeric value

convertMultiply:
	cmp cl, ch       	; compare cl with ch   
    jge convertStore 	; if cl equals or greater than ch then stop multiplying
	mul dx			 	; multiply number by 10	
	mov dl, 10		 	; reset dl back to 10
	inc cl              ; increase cl                    
	jmp convertMultiply ; and store the value into number
		
convertStore:
	add [number], ax  ; add the value of ax into number
	dec ch            ; decrease ch
	mov cl, 0         ; set cl back to 0
	inc bx			  ; point bx to next address
	sub ax, ax		  ; set ax to 0
	cmp [bx], byte 0  ; compare value to 0
	je binaryStart    ; if 0, start printing number in binary
	jmp convertSet    ; else continue converting
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
binaryStart:
	mov bx, binary   ; set bx to point to address of binary
	add bx, 15       ; point address of bx to the end of variable
    mov ax, [number] ; set ax with value of number
    sub dx, dx       ; let dx be 0
    mov cx, 2        ; let cx be 2
	
binaryDivide:
	div cx           ; divide value in ax with 2
    cmp ax, 0        ; compare ax with 0
    je binaryLast    ; jump to store last binary if true
	jmp binaryStore  ; jump to store binary if false
	
binaryStore:
    add dl, 48       ; ASCII '1' = 49 (or 31h) so add 30h
    mov [bx], dl     ; Store ASCII char in binary
    dec bx           ; point to next char in binary 
    sub dx, dx       ; clear remainder 
    jmp binaryDivide ; jump to divide ax	
	
binaryLast:
    add dl, 48       ; ASCII '1' = 49 (or 31h) so add 30h
    mov [bx], dl     ; Store ASCII char in binary
	mov bx, binary   ; Point bx to binary variable
	
binaryPrint:
    mov dl, [bx]     ; get char at address in BX
    inc bx           ; point BX to next char in message 
    cmp dl, 0        ; Is DL = 30h
    jle hexStart	 ; If yes, then quit
    mov ah, 06       ; If no, then call int 21h service 06h to print
    int 21h
    jmp binaryPrint  ; Repeat for the next character 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;   
hexStart:
	mov bx, hex      ; set bx to point to address of binary
	add bx, 3        ; point bx to end of variable
    mov ax, [number] ; set ax with value of number
    sub dx, dx       ; let dx be 0
    mov cx, 16       ; let cx be 2
	
hexDivide:
	div cx           ; divide value in ax with 2
    cmp ax, 0        ; compare ax with 0
    je hexLast       ; jump to store last hex number if true
	jmp hexStore     ; jump to store hex number if false
	
hexStore:
	cmp dl, 10       ; compare dl with 10
	jge hexAdd       ; if 10, then jump to add 10
    add dl, 48       ; ASCII '1' = 49 (or 31h) so add 30h
    mov [bx], dl     ; Store ASCII char in hex
    dec bx           ; point to next char in hex 
    sub dx, dx       ; clear remainder 
    jmp hexDivide    ; jump to divide ax	
		
hexAdd:
	add dl, 55       ; Adds 55 to display alphabets for hex in ASCII
	mov [bx], dl     ; Store ASCII char in hex
    dec bx           ; point to next char in hex 
    sub dx, dx       ; clear remainder 
    jmp hexDivide    ; jump to divide ax
	
hexLast:
	cmp dl, 10       ; compare dl with 10
	jge hexAddLast   ; if 10, then jump to add 10
    add dl, 48       ; ASCII '1' = 49 (or 31h) so add 30h
    mov [bx], dl     ; Store ASCII char in hex
	mov bx, hex      ; Set bx to point to hex variable
	jmp hexPrint     ; Jump to print
	
hexAddLast:
	add dl, 55       ; Adds 55 to display alphabets for hex in ASCII
	mov [bx], dl     ; Store ASCII char in hex
	mov bx, hex      ; Jump to print
	
hexPrint:
    mov dl, [bx]     ; get char at address in BX
    inc bx           ; point BX to next char in message 
    cmp dl, 0        ; Is DL = 30h
    jle quit	     ; If yes, then quit
    mov ah, 06       ; If no, then call int 21h service 06h to print
    int 21h
    jmp hexPrint     ; Repeat for the next character 
  
quit: 
    int 20h  ; Quit program
	
section .data  
    message db "Enter a 4-digit decimal number:" , 10, 13, 0
	input db 0,0,0,0,0
	number dw 0
	binary db 48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,10,13,0
	hex db 48,48,48,48,10,13,0