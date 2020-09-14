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
	msg1: db 'File opened successfully', 10d, 13d
	len1: equ $- msg1
	msg2: db 'Error in opening file', 10d, 13d
	len2: equ $- msg2

section .bss
	fd: resb 20
	buffer: resb 200
	buff_len: resb 20
	cnt1: resb 20
	temp: resb 1
	fname1: resb 20
	fname2: resb 20
	fd1: resb 20
	fd2: resb 20
	choice: resb 8
section .text
	global _start:
	_start:
		
			pop rbx			; pop number of arguments from terminal
			pop rbx			; pop the exe file
		
			pop rbx			; get the 1st argument
			mov [choice], rbx
			mov rsi, choice
			sub byte[rsi], 37h
			cmp byte[rsi], 43h
			je copy
			cmp byte[rsi], 44h
			je delete
			jmp type
			
; -----------------------------------------------------------------------------------------------------------------------
copy:	
			pop rbx			; get the 1st file name
			mov [fname1], rbx
			pop rbx			; get the 2nd file name
			mov [fname2], rbx	
			
			scall 2, [fname1], 2, 0777			; open the 1st file
			mov [fd1], rax					; save the file descriptor 1 into fd1
			;scall 2, [fname2], 0102o, 0666o			; open 2nd file...create if not created
			scall 2, [fname2], 2, 0777
			mov [fd2], rax					; save the file descriptor 2 into fd2

			scall 0, [fd1], buffer, 200			; read the 1st file into buffer
			mov [buff_len], rax				; move no. of characters in the file into buff_len from rax
			scall 1, [fd2], buffer, [buff_len]
			
			mov rax, 3						; closing 1st file
			mov rdi, [fd1]
			syscall 
	
			mov rax, 3						; closing 2nd file
			mov rdi, [fd2]	
			syscall
			exit
; --------------------------------------------------------------------------------------------------------------------------
delete: 
			pop rbx				; get the file name to be deleted
			mov [fname1], rbx		; store the file name into fname1 variable
	
			mov rax, 87
			mov rdi, [fname1]
			syscall
			exit
; ---------------------------------------------------------------------------------------------------------------------------
type:
			pop rbx				; popping the file name
			mov [fname1], rbx
 			scall 2, [fname1], 2, 0777	;  file opening system call
			mov [fd], rax			; move the file descriptor from rax into fd
			bt rax, 63
			jc error_msg	
			scall 1, 1, msg1, len1		; file opened successfully

			scall 0, [fd], buffer, 200		; reading the file
			mov [cnt1], rax			; save the number of characters in the file into cnt1 variable

			scall 1, 1, buffer, [cnt1]	
			
			mov rax, 3				; closing the file
			mov rdi, [fd1]
			syscall		
			exit
; --------------------------------------------------------------------------------------------------------------------------
error_msg: 
			scall 1, 1, msg2, len2
			exit	
			
