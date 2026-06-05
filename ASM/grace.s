default rel

%define S "default rel%1$c%1$c%%define S %2$c%3$s%2$c%1$c%%define N %2$cGrace_kid.s%2$c%1$c%%macro MAIN 0%1$cmain:%1$c	push rbp%1$c	mov rbp, rsp%1$c	push rbx%1$c	sub rsp, 8%1$c	lea rdi, [name]%1$c	lea rsi, [mode]%1$c	call fopen wrt ..plt%1$c	test rax, rax%1$c	je .error%1$c	mov rbx, rax%1$c	mov rdi, rbx%1$c	lea rsi, [source]%1$c	mov edx, 10%1$c	mov ecx, 34%1$c	lea r8, [source]%1$c	xor eax, eax%1$c	call fprintf wrt ..plt%1$c	mov rdi, rbx%1$c	call fclose wrt ..plt%1$c	xor eax, eax%1$c	jmp .done%1$c.error:%1$c	mov eax, 1%1$c.done:%1$c	add rsp, 8%1$c	pop rbx%1$c	leave%1$c	ret%1$c%%endmacro%1$c%1$csection .data%1$c; Radio Git Git%1$csource: db S, 0%1$cname: db N, 0%1$cmode: db %2$cw%2$c, 0%1$c%1$csection .text%1$cextern fopen%1$cextern fprintf%1$cextern fclose%1$cglobal main%1$c%1$cMAIN%1$c"
%define N "Grace_kid.s"
%macro MAIN 0
main:
	push rbp
	mov rbp, rsp
	push rbx
	sub rsp, 8
	lea rdi, [name]
	lea rsi, [mode]
	call fopen wrt ..plt
	test rax, rax
	je .error
	mov rbx, rax
	mov rdi, rbx
	lea rsi, [source]
	mov edx, 10
	mov ecx, 34
	lea r8, [source]
	xor eax, eax
	call fprintf wrt ..plt
	mov rdi, rbx
	call fclose wrt ..plt
	xor eax, eax
	jmp .done
.error:
	mov eax, 1
.done:
	add rsp, 8
	pop rbx
	leave
	ret
%endmacro

section .data
; Radio Git Git
source: db S, 0
name: db N, 0
mode: db "w", 0

section .text
extern fopen
extern fprintf
extern fclose
global main

MAIN
