default rel

section .data
; It's a Quine of Magic
source: db "default rel%1$c%1$csection .data%1$c; It's a Quine of Magic%1$csource: db %2$c%3$s%2$c, 0%1$c%1$csection .text%1$cextern printf%1$cglobal main%1$c%1$cmain:%1$c	push rbp%1$c	mov rbp, rsp%1$c	; I Want to Make Free%1$c	call print%1$c	xor eax, eax%1$c	leave%1$c	ret%1$c%1$cprint:%1$c	push rbp%1$c	mov rbp, rsp%1$c	lea rdi, [source]%1$c	mov esi, 10%1$c	mov edx, 34%1$c	lea rcx, [source]%1$c	xor eax, eax%1$c	call printf wrt ..plt%1$c	leave%1$c	ret%1$c", 0

section .text
extern printf
global main

main:
	push rbp
	mov rbp, rsp
	; I Want to Make Free
	call print
	xor eax, eax
	leave
	ret

print:
	push rbp
	mov rbp, rsp
	lea rdi, [source]
	mov esi, 10
	mov edx, 34
	lea rcx, [source]
	xor eax, eax
	call printf wrt ..plt
	leave
	ret
