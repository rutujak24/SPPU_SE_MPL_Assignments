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
	menu: db 	'MENU', 10d, 13d
	      db 'Enter choice:', 10d, 13d
	      db '1: successive addition method', 10d, 13d
	      db '2: add and shift method', 10d, 13d
	      db '3: exit', 10d, 13d
	lenm: equ $- menu
	msg1: db 'Enter 1st number', 10d, 13d
	len1: equ $- msg1
	msg2: db 'Enter 2nd number', 10d, 13d
	len2: equ $- msg2
	msg3: db 'Result after succ.addn: '
	len3: equ $- msg3
	msg4: db 'Result after add-shift: '
	len4: equ $- msg4

	nwline: db 10d, 13d

section .bss
	num1: resb 16
	num2: resb 16
	num: resb 16
	answer: resb 16
	count: resb 16
	choice resb 1

section .data
	global _start:
	_start:


;**************************************************************************************************************************
;Accepting numbers

	scall 1, 1, msg1, len1
	scall 0, 0, num, 17
	call AtoH
	;now rbx contains proper ascii-hex number
	mov qword[num1], rbx	; assign num1

	scall 1, 1, msg2, len2
	scall 0, 0, num, 17
	call AtoH
	mov qword[num2], rbx	; assign num2
	; both num1 and num2 are converted to proper form

;**************************************************************************************************************************
;Accepting choice from user
	
	scall 1, 1, menu, lenm
	scall 0, 0, choice, 2
	sub byte[choice], 30h

	cmp byte[choice], 1
	je succ_add
	cmp byte[choice], 2
	je add_shift
;*********************************
	exit	

;**************************************************************************************************************************
;SUCCESSIVE ADDITION

	succ_add:
	
	scall 1, 1, msg3, len3
	xor rax, rax
	xor rcx, rcx
	mov rcx, qword[num2]
	mov qword[count], rcx
	cmp qword[count], 0
	je skip

	Loop1:
		add rax, qword[num1]
		dec qword[count]
		jnz Loop1
	
	; after the execution of loop, rax contains final answer..convert it to printable form and print it
	skip:	call display	
		scall 1, 1, nwline, 1
	jmp _start

;**************************************************************************************************************************
;ADD AND SHIFT

	add_shift:

	xor rax, rax
	scall 1, 1, msg4, len4
	xor rbx, rbx
	xor rdx, rdx
	xor rcx, rcx	
	xor rax, rax		;rax is used to store answer
	mov rbx, qword[num1]
	mov rdx, qword[num2]
	mov rcx, 64

	Loop2:
		shl rax, 1
		rol rbx, 1
		jnc down
		add rax, rdx

	down:
		loop Loop2
		
	call display
	scall 1, 1, nwline, 1
	jmp _start

;**************************************************************************************************************************
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
