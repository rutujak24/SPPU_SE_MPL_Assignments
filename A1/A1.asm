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
	array: dq 7777711111112222h, -999999999442312h, 1111111111111100h, -4999999999999999h, 111111111111111h, -3333333333333333h, -1111111111777777h, 			  -4444444445555523h, -3333333333333333h, 1111111111778887h
	n: dq 10
	p_cnt: dq 0
	n_cnt: dq 0
	msg1: db 'Count of Positive numbers: '
	len1: equ $- msg1
	msg2: db 'Count of Negative numbers: '
	len2: equ $- msg2
	nwline: db 10d, 13d

section .bss
	ans_pos: resb 10
	ans_neg: resb 10
	

section .text
	global _start:
	_start:
	
	
		mov rsi, array			; point rsi to the base of array
		xor rax, rax		
		xor rcx, rcx			; clearing the registers
		mov rcx, qword[n]		; set the counter register
	

	loop1:
		mov rax, [rsi]			; mov the value at rsi into rax
		bt rax, 63			; test the 63rd bit of rax..if it is negative, then carry flag would be set
		jc neg				
		inc qword[p_cnt]		; increment positive count
		jmp update

	neg:			
		inc qword[n_cnt]		; increment negative count
	
	update:
		add rsi, 8			; make rsi point to the next index of array
		loop loop1
; -----------------------------------------------------

	
		xor rax, rax
		xor rbx, rbx
		xor rcx, rcx			
		
		mov rcx, 16			; for 16 digit display, initialise the counter register to 16
		mov rbx, [p_cnt]		; move the value to be displayed into rbx
		mov rdi, ans_pos		; make rdi point to the base of the answer variable
		call HexToAscii			; procedure call
		scall 1, 1, msg1, len1		
		scall 1, 1, ans_pos, 16		; display ans_pos ie count of positive numbers
		scall 1, 1, nwline, 1
	
		mov rcx, 16
		mov rbx, [n_cnt]
		mov rdi, ans_neg
		call HexToAscii
		scall 1, 1, msg2, len2
		scall 1, 1, ans_neg, 16		; display negative count
		scall 1, 1, nwline, 1
		
		exit				; exit macro

;---------------------------------------------------------------------------------------------------------------
HexToAscii:	
	
	up:
		rol rbx, 4
		mov al, bl
		and al, 0fh
		cmp al, 09h
		jbe skip
		add al, 07h
	skip:
		add al, 30h	
		mov [rdi], al
		inc rdi
		loop up
		ret
;-----------------------------------------------------------------------------------------------------------------

		
