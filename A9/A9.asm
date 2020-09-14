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

section .text
	msg1: db 'Enter a number', 10d, 13d
	len1: equ $- msg1
	msg2: db 'Factorial: '
	len2: equ $- msg2
	msg3: db 'Factorial: 0000000000000001', 10d, 13d
	len3: equ $- msg3
	nwline: db 10d, 13d


section .bss
	num: resb 2
	fact: resb 2

section .text
	global _start:
	_start:
			
			xor rbx, rbx		; clear rbx 	
			pop rbx			; pop the number of arguments from the stack
			pop rbx			; pop the exe file name
			pop rbx			; pop the number given by the user
	
	
			mov [num], rbx	
			xor rax, rax
			xor rbx, rbx
			xor rcx, rcx
			mov rcx, 2		; user gives 2 digit number thus counter is set to 2
			mov rsi, [num]		; make rsi point to the base of num
			call AsciiToHex		; ascii to hex procedure call
			mov [num], rbx		; store the converted number into num
	
			cmp byte[num], 0	; special case zero factorial
			je zero	
			
			mov rax, 1		; rax will contain the factorial after multiplication, thus initialise it to 1
			mov rbx, [num]		; mov number into rbx
			call factorial		; procedure call
			mov rbx, rax		; put the factorial into rbx
			xor rax, rax
			xor rcx, rcx
			mov rcx, 16		; for 16 digit factorial display
			mov rdi, fact		; make rdi point to the base of fact variable
			call HexToAscii 	; hex to ascii procedure call
			scall 1, 1, msg2, len2	
			scall 1, 1, fact, 16	; display factorial
			scall 1, 1, nwline, 1
			exit
zero:
			scall 1, 1, msg3, len3	; zero factorial case
			exit

;------------------------------------------------------------------------------------------------------------------------------------------
factorial:
		cmp bl, 0			
		je stop
		push rbx
		dec rbx
		call factorial
		pop rbx
		mul rbx
		ret
	stop:
		ret
; the above procedure recursively calculates factorial..we push the number onto the stack and then decrement the number...
; This process continues till the number reachs zero
; After that we start popping the number and multiply it to rax
; Thus rax will accumulate the factorial
;--------------------------------------------------------------------------------------------------------------------------------------------

AsciiToHex:
	
	up:
		rol bx, 4
		mov al, [rsi]
		cmp al, 39h
		jbe skip
		sub al, 07h
	skip:
		sub al, 30h
		add bl, al
		inc rsi
		loop up	
		ret

HexToAscii:
	
	up2:
		rol rbx, 4			
		mov al, bl
		and al, 0fh
		cmp al, 09h
		jbe skip2
		add al, 07h
	skip2:
		add al, 30h
		mov [rdi], al
		inc rdi
		loop up2
		ret
;-----------------------------------------------------------------------------------------------------------------------------------------

; prathamesh@prathamesh-Inspiron-3576:~/Documents/git_MPL$ ./a9 09
; Factorial: 0000000000058980
; prathamesh@prathamesh-Inspiron-3576:~/Documents/git_MPL$ ./a9 04
; Factorial: 0000000000000018
; prathamesh@prathamesh-Inspiron-3576:~/Documents/git_MPL$ ./a9 03
; Factorial: 0000000000000006
; prathamesh@prathamesh-Inspiron-3576:~/Documents/git_MPL$ ./a9 02
; Factorial: 0000000000000002
; prathamesh@prathamesh-Inspiron-3576:~/Documents/git_MPL$ ./a9 01
; Factorial: 0000000000000001
; prathamesh@prathamesh-Inspiron-3576:~/Documents/git_MPL$ ./a9 00
; Factorial: 0000000000000001
; prathamesh@prathamesh-Inspiron-3576:~/Documents/git_MPL$ 





			
