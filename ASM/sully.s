; i = 5
default rel

section .data

source: db "; i = %4$d%1$cdefault rel%1$c%1$csection .data%1$c%1$csource: db %2$c%3$s%2$c, 0%1$cname_fmt: db %2$cSully_%%d.s%2$c, 0%1$ccomp_fmt: db %2$cnasm -f elf64 Sully_%%d.s -o Sully_%%d.o && gcc Sully_%%d.o -o Sully_%%d && rm -f Sully_%%d.o%2$c, 0%1$crun_fmt: db %2$c./Sully_%%d%2$c, 0%1$cmode: db %2$cw%2$c, 0%1$cfname: db __?FILE?__, 0%1$c%1$csection .text%1$cextern fopen%1$cextern fprintf%1$cextern fclose%1$cextern snprintf%1$cextern system%1$cextern execl%1$cglobal main%1$c%1$cmain:%1$c	push rbp%1$c	mov rbp, rsp%1$c	push rbx%1$c	push r12%1$c	sub rsp, 160%1$c	mov ebx, 5%1$c	lea rax, [fname]%1$c.find:%1$c	cmp byte [rax], 0%1$c	je .value%1$c	cmp byte [rax], 95%1$c	je .child%1$c	inc rax%1$c	jmp .find%1$c.child:%1$c	movzx ebx, byte [rax + 1]%1$c	sub ebx, 48%1$c	dec ebx%1$c.value:%1$c	test ebx, ebx%1$c	js .end%1$c	lea rdi, [rsp]%1$c	mov esi, 32%1$c	lea rdx, [name_fmt]%1$c	mov ecx, ebx%1$c	xor eax, eax%1$c	call snprintf wrt ..plt%1$c	lea rdi, [rsp]%1$c	lea rsi, [mode]%1$c	call fopen wrt ..plt%1$c	test rax, rax%1$c	jz .end%1$c	mov r12, rax%1$c	mov rdi, r12%1$c	lea rsi, [source]%1$c	mov edx, 10%1$c	mov ecx, 34%1$c	lea r8, [source]%1$c	mov r9d, ebx%1$c	xor eax, eax%1$c	call fprintf wrt ..plt%1$c	mov rdi, r12%1$c	call fclose wrt ..plt%1$c	lea rdi, [rsp+32]%1$c	mov esi, 128%1$c	lea rdx, [comp_fmt]%1$c	mov ecx, ebx%1$c	mov r8d, ebx%1$c	mov r9d, ebx%1$c	push rbx%1$c	push rbx%1$c	xor eax, eax%1$c	call snprintf wrt ..plt%1$c	add rsp, 16%1$c	lea rdi, [rsp+32]%1$c	call system wrt ..plt%1$c	test eax, eax%1$c	jnz .end%1$c	lea rdi, [rsp+32]%1$c	mov esi, 128%1$c	lea rdx, [run_fmt]%1$c	mov ecx, ebx%1$c	xor eax, eax%1$c	call snprintf wrt ..plt%1$c	lea rdi, [rsp+32]%1$c	lea rsi, [rsp+32]%1$c	xor edx, edx%1$c	xor eax, eax%1$c	call execl wrt ..plt%1$c.end:%1$c	xor eax, eax%1$c	add rsp, 160%1$c	pop r12%1$c	pop rbx%1$c	leave%1$c	ret%1$c", 0
name_fmt: db "Sully_%d.s", 0
comp_fmt: db "nasm -f elf64 Sully_%d.s -o Sully_%d.o && gcc Sully_%d.o -o Sully_%d && rm -f Sully_%d.o", 0
run_fmt: db "./Sully_%d", 0
mode: db "w", 0
fname: db __?FILE?__, 0

section .text
extern fopen
extern fprintf
extern fclose
extern snprintf
extern system
extern execl
global main

main:
	push rbp
	mov rbp, rsp
	push rbx
	push r12
	sub rsp, 160
	mov ebx, 5
	lea rax, [fname]
.find:
	cmp byte [rax], 0
	je .value
	cmp byte [rax], 95
	je .child
	inc rax
	jmp .find
.child:
	movzx ebx, byte [rax + 1]
	sub ebx, 48
	dec ebx
.value:
	test ebx, ebx
	js .end
	lea rdi, [rsp]
	mov esi, 32
	lea rdx, [name_fmt]
	mov ecx, ebx
	xor eax, eax
	call snprintf wrt ..plt
	lea rdi, [rsp]
	lea rsi, [mode]
	call fopen wrt ..plt
	test rax, rax
	jz .end
	mov r12, rax
	mov rdi, r12
	lea rsi, [source]
	mov edx, 10
	mov ecx, 34
	lea r8, [source]
	mov r9d, ebx
	xor eax, eax
	call fprintf wrt ..plt
	mov rdi, r12
	call fclose wrt ..plt
	lea rdi, [rsp+32]
	mov esi, 128
	lea rdx, [comp_fmt]
	mov ecx, ebx
	mov r8d, ebx
	mov r9d, ebx
	push rbx
	push rbx
	xor eax, eax
	call snprintf wrt ..plt
	add rsp, 16
	lea rdi, [rsp+32]
	call system wrt ..plt
	test eax, eax
	jnz .end
	lea rdi, [rsp+32]
	mov esi, 128
	lea rdx, [run_fmt]
	mov ecx, ebx
	xor eax, eax
	call snprintf wrt ..plt
	lea rdi, [rsp+32]
	lea rsi, [rsp+32]
	xor edx, edx
	xor eax, eax
	call execl wrt ..plt
.end:
	xor eax, eax
	add rsp, 160
	pop r12
	pop rbx
	leave
	ret
