%macro scall 4
	mov rax, %1
	mov rdi, %2
	mov rsi, %3
	mov rdx, %4
	syscall
%endmacro

%macro exit 0
	mov rax, 60
	xor rdi, rdi
	syscall
%endmacro

section .data
	menu: db 10d, 13d, "		Menu" 
	      db 10d, "1. Hex to BCD conversion"
	      db 10d, "2. BCD to Hex conversion"
	      db 10d, "3. Exit",
	      db 10d, "Enter choice"
	menulen: equ $- menu
	msg1: db "Enter hex number: ", 10d, 13d
	len1: equ $- msg1
	msg2: db "Enter BCD number: ", 10d, 13d
	len2: equ $- msg2
	msg3: db "BCD equivalent is: ", 10d, 13d
	len3: equ $- msg3
	msg4: db "Hex equivalent is: ", 10d, 13d
	len4: equ $- msg4
	nwline: db 10d, 13d

section .bss
	choice resb 1
	num resb 16
	answer resb 16
	factor resb 16

section .text
	global _start:
	_start:
	
	Go:	scall 1, 1, menu, menulen
		scall 0, 0, choice, 2
		sub byte[choice], 30h

		cmp byte[choice], 1
		je HtoB
		cmp byte[choice], 2
		je BtoH
		cmp byte[choice], 3
		je stop
;**********************************************************************************************************************************
; Hex to Bcd Conversion
		
	
	HtoB:	scall 1, 1, nwline, 1
		scall 1, 1, msg1, len1
		scall 0, 0, num, 17
		call AtoH
					; rbx will contain the proper ascii_hex number after the process

		mov rax, rbx
		xor rbx, rbx
		mov rbx, 10
					; mov rdi to the last index of answer
					; as we have to store remainders in reverse order
		mov rdi, answer+15
		
	Loop1:	xor rdx, rdx
		div rbx
					; quotient will be in rax and remainder in rdx precisely in dl
					; convert number in dl in printable (ascii) form
		add dl, 30h
		mov [rdi], dl
		dec rdi			; mov rdi to previous index
		cmp rax, 0
		jnz Loop1

					; Now answer will contain the bcd number in ascii form...simply print it
		scall 1, 1, msg3, len3
		scall 1, 1, answer, 16
		jmp _start
		

;**********************************************************************************************************************************
;Bcd to Hex conversion

	BtoH:	scall 1, 1, nwline, 1
		scall 1, 1, msg2, len2	
		scall 0, 0, num, 17
					; let the accepted number be as it is (ie in its ascii form)

		mov rsi, num+15
		mov rcx, 16
		mov qword[factor], 1		
		xor rbx, rbx
		
	Loop2:	xor rax, rax
		mov al, [rsi]
					; digit pointed out by rsi will be stored in al
		sub al, 30h
					; convert this digit into proper ascii_hex form
		mul qword[factor]
					; factor and rax gets multiplied	
					;quotient in rax	
		add rbx, rax
					; rbx will add all the values in every iteration so finally ans would be in rbx
		mov rax, 10
		mul qword[factor]
					; every time value in factor will get multiplied by 10 
					; rax contains multiplication result
		mov qword[factor], rax
		dec rsi			; go to the previous index now
		loop Loop2		; rcx will be automatically decremented and loop will continue
		
	
		scall 1, 1, nwline, 1
		scall 1, 1, msg4, len4
					; rbx will contain the hex number in hex form
					; convert it to printable form by calling display
					; our display need that number to be converted should be in rax so mov it
		mov rax, rbx
		call display
		jmp _start


;**********************************************************************************************************************************
	stop:	exit

;**********************************************************************************************************************************
;PROCEDURES
AtoH:
	mov rsi,num
	mov rcx,16
	mov rbx,0
	mov rax,0
		
loop1:	rol rbx,04
	mov al,[rsi]
	cmp al,39h
	jbe skip1
	sub al,07h
skip1:	sub al,30h
	
	add rbx,rax
	
	inc rsi
	dec rcx
	jnz loop1	
ret	

display:
        mov rsi,answer+15
        mov rcx,16

loop2:	mov rdx,0
        mov rbx,16
        div rbx
        cmp dl,09h
        jbe skip2
        
        add dl,07h
skip2:	add dl,30h
        mov [rsi],dl
        
        dec rsi
        dec rcx
        jnz loop2
        scall 1,1,answer,16       
ret
