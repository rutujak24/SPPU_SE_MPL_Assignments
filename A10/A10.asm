%macro myprintf 1
mov rdi,formatpf
sub rsp,8
movsd xmm0,[%1]
mov rax,1
call printf
add rsp,8
%endmacro

%macro myscanf 1
mov rdi,formatsf
mov rax,0
sub rsp,8
mov rsi,rsp
call scanf
mov r8,qword[rsp]
mov qword[%1],r8
add rsp,8
%endmacro

%macro write 2
mov rax,1
mov rdi,1
mov rsi,%1
mov rdx,%2
syscall
%endmacro


section .data
msg1 db "Enter Value for a",10
len1 equ $-msg1
msg2 db "Enter Value for b",10
len2 equ $-msg2
msg3 db "Enter Value for c",10
len3 equ $-msg3
ff1: db "%lf +i %lf",10,0
ff2: db "%lf -i %lf",10,0
formatpf: db "%lf",10,0
formatsf: db "%lf",0
four: dq 4
two: dq 2

section .bss
a: resq 1
b: resq 1
c: resq 1
b2: resq 1
fac: resq 1
delta: resq 1
rdelta: resq 1
r1: resq 1
r2: resq 1
ta: resq 1
realn: resq 1
img1: resq 1
img2: resq 1


section .text
extern printf
extern scanf
global main
main:


;------scaning
write msg1,len1
myscanf a

write msg2,len2

myscanf b

write msg3,len3

myscanf c

;-----printing
;myprintf a
;myprintf b
;myprintf c

;----calculate b square
fld qword[b]
fmul qword[b]
fstp qword[b2]
;myprintf b2

;-----calculate 4ac
fild qword[four]
fmul qword[a]
fmul qword[c]
fstp qword[fac]


fld qword[b2]
fsub qword[fac]
fstp qword[delta]


fild qword[two]
fmul qword[a]
fstp qword[ta]



btr qword[delta],63  ;--------tests the bit, sets he carry flag if set and clears the bit too
jc imaginary

;--------------------real roots--------------------

fld qword[delta]
fsqrt
fstp qword[rdelta]


fldz
fsub qword[b]
fadd qword[rdelta]
fdiv qword[ta]
fstp qword[r1]
myprintf r1

fldz
fsub qword[b]
fsub qword[rdelta]
fdiv qword[ta]
fstp qword[r2]
myprintf r2

jmp exit

;-----------------------imaginary roots------------------
imaginary:
fld qword[delta]
fsqrt
fstp qword[rdelta]

fldz
fsub qword[b]
fdiv qword[ta]
fstp qword[realn]



fld qword[rdelta]
fdiv qword[ta]
fstp qword[img1]


;--------------printing img root1
mov rdi,ff1
sub rsp,8
movsd xmm0,[realn]
movsd xmm1,[img1]
mov rax,2
call printf
add rsp,8

mov rdi,ff2
sub rsp,8
movsd xmm0,[realn]
movsd xmm1,[img1]
mov rax,2
call printf
add rsp,8


exit:


mov rax,60
mov rdi,00
syscall
