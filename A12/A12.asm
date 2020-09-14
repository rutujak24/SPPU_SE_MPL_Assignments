global _start;



%macro print 2
	mov rax,01;
	mov rdi,02;
	mov rsi,%1;
	mov rdx,%2;
	syscall;
%endmacro



section .data
	array: dq 12.65,23.45,64.54,77.34,65.65,90.64,44.12,54.22,33.33
	lenArray: equ $-array;
	
	meanMsg: db "Mean = ";
	lenMeanMsg: equ  $-meanMsg;
	
	varianceMsg: db "Variance = ";
	lenVarianceMsg: equ $-varianceMsg;
	
	deviationMsg: db "Standard Deviation = ";
	lenDeviationMsg: equ $-deviationMsg;
		
	eight: dq 8.0;
	hundred: dq 100.0;
	dot: db ".";
	newLine: db 10;

	

section .bss
	count resq 1;
	mean resq 1;
	variance resq 1;
	deviation resq 1;
	temp resq 1;
	
	result rest 1;
	outAscii resb 21;
	digit resb 1
	
	
	
section .text
	_start:

;		//Count No. of Observations
		mov qword[count],lenArray;
		fild qword[count];
		fdiv qword[eight]
		fstp qword[count];
		

;		//Mean
		mov rsi,array;
		mov rcx,lenArray;
		fldz;
		
		init1:
		fadd qword[rsi];
		
		add rsi,08h;
		sub rcx,08h;
		jnz init1;
		
		fdiv qword[count];
		fstp qword[mean];
		
		
;		//Variance
		mov rsi,array;
		mov rcx,lenArray;
		fldz;
		
		init2:
		fld qword[rsi];
		fsub qword[mean];
		fmul st0;			//ST(0)=ST(0)*ST(0)		ie: Squaring
		fadd;				//ST(0)=ST(0)+ST(1)
	
		add rsi,08h;
		sub rcx,08h;
		jnz init2;
		
		fdiv qword[count];
		fstp qword[variance];
		
		
;		//Standard Deviation
		fld qword[variance];
		fsqrt;
		fstp qword[deviation];
		

;		//Display
		fld qword[mean];
		fstp qword[result];
		print meanMsg,lenMeanMsg;
		call _DoubleToAscii;
		print outAscii,21;
		print newLine,1;
		
		fld qword[variance];
		fstp qword[result];
		print varianceMsg,lenVarianceMsg;
		call _DoubleToAscii;
		print outAscii,21;	
		print newLine,1;	

		fld qword[deviation];
		fstp qword[result];
		print deviationMsg,lenDeviationMsg
		call _DoubleToAscii;
		print outAscii,21;	
		print newLine,1;	

	exit:
		mov rax,60;
		mov rdi,00
		syscall;
	
	
_DoubleToAscii:
;	DOC-STRING:
;	i)   converts Double value in qword[result] to packed BCD in tword[result]
;	ii)  converts packed BCD in tword[result] into 20 digits srting outAscii
;	iii) adds decimal point (.) at 100ths place in srting outAscii 

	fld qword[result]
	fmul qword[hundred];
	fbstp tword[result];
	
	mov rsi,result+9;
	mov rdi,0;
	mov rcx,10d;
	
	init0:
	xor rax,rax;
	xor rbx,rbx;
	
	mov al,byte[rsi];
	mov bl,al;
	shr al,04h;		//Higher Nibble
	and bl,0Fh;		//Lower Nibble
	add al,30h;
	add bl,30h;
	
	mov byte[outAscii+rdi],al;
	inc rdi;
	mov byte[outAscii+rdi],bl;
	inc rdi
	
	dec rsi;
	dec rcx;
	jnz init0;
	
	addDecimalPoint:
	mov al,byte[outAscii+19];
	mov bl,byte[outAscii+18];
	mov byte[outAscii+18],2Eh;
	mov byte[outAscii+19],bl;
	mov byte[outAscii+20],al;

end_DoubleToAscii:
ret
