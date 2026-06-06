; ============================================================
; COMMENTAIRE DE TÊTE : l'entier i = 5 est déclaré ici.
; Il n'est PAS stocké en .data comme un dd — il est lu à
; l'exécution depuis le nom du fichier grâce à __?FILE?__.
; ============================================================
; i = 5
default rel

section .data

; ============================================================
; SOURCE — le format string du quine
;
; Même mécanique que Colleen / Grace, avec un 4e spécifieur :
;   %1$c → arg1 = '\n'  (edx=10)
;   %2$c → arg2 = '"'   (ecx=34)
;   %3$s → arg3 = source lui-même (r8=source)
;   %4$d → arg4 = ebx   (r9d=ebx) = la valeur entière à écrire
;   %%   → '%' littéral (pour préserver les %d des chaînes de format)
;
; La première chose produite est "; i = X\n", reproduisant
; le commentaire de tête avec la nouvelle valeur de i.
; ============================================================
source: db "; i = %4$d%1$cdefault rel%1$c%1$csection .data%1$c%1$csource: db %2$c%3$s%2$c, 0%1$cname_fmt: db %2$cSully_%%d.s%2$c, 0%1$ccomp_fmt: db %2$cnasm -f elf64 Sully_%%d.s -o Sully_%%d.o && gcc Sully_%%d.o -o Sully_%%d && rm -f Sully_%%d.o%2$c, 0%1$crun_fmt: db %2$c./Sully_%%d%2$c, 0%1$cmode: db %2$cw%2$c, 0%1$cfname: db __?FILE?__, 0%1$c%1$csection .text%1$cextern fopen%1$cextern fprintf%1$cextern fclose%1$cextern snprintf%1$cextern system%1$cextern execl%1$cglobal main%1$c%1$cmain:%1$c	push rbp%1$c	mov rbp, rsp%1$c	push rbx%1$c	push r12%1$c	sub rsp, 160%1$c	mov ebx, 5%1$c	lea rax, [fname]%1$c.find:%1$c	cmp byte [rax], 0%1$c	je .value%1$c	cmp byte [rax], 95%1$c	je .child%1$c	inc rax%1$c	jmp .find%1$c.child:%1$c	movzx ebx, byte [rax + 1]%1$c	sub ebx, 48%1$c	dec ebx%1$c.value:%1$c	test ebx, ebx%1$c	js .end%1$c	lea rdi, [rsp]%1$c	mov esi, 32%1$c	lea rdx, [name_fmt]%1$c	mov ecx, ebx%1$c	xor eax, eax%1$c	call snprintf wrt ..plt%1$c	lea rdi, [rsp]%1$c	lea rsi, [mode]%1$c	call fopen wrt ..plt%1$c	test rax, rax%1$c	jz .end%1$c	mov r12, rax%1$c	mov rdi, r12%1$c	lea rsi, [source]%1$c	mov edx, 10%1$c	mov ecx, 34%1$c	lea r8, [source]%1$c	mov r9d, ebx%1$c	xor eax, eax%1$c	call fprintf wrt ..plt%1$c	mov rdi, r12%1$c	call fclose wrt ..plt%1$c	lea rdi, [rsp+32]%1$c	mov esi, 128%1$c	lea rdx, [comp_fmt]%1$c	mov ecx, ebx%1$c	mov r8d, ebx%1$c	mov r9d, ebx%1$c	push rbx%1$c	push rbx%1$c	xor eax, eax%1$c	call snprintf wrt ..plt%1$c	add rsp, 16%1$c	lea rdi, [rsp+32]%1$c	call system wrt ..plt%1$c	test eax, eax%1$c	jnz .end%1$c	lea rdi, [rsp+32]%1$c	mov esi, 128%1$c	lea rdx, [run_fmt]%1$c	mov ecx, ebx%1$c	xor eax, eax%1$c	call snprintf wrt ..plt%1$c	lea rdi, [rsp+32]%1$c	lea rsi, [rsp+32]%1$c	xor edx, edx%1$c	xor eax, eax%1$c	call execl wrt ..plt%1$c.end:%1$c	xor eax, eax%1$c	add rsp, 160%1$c	pop r12%1$c	pop rbx%1$c	leave%1$c	ret%1$c", 0

; Format pour le nom du fichier fils : "Sully_X.s"
name_fmt: db "Sully_%d.s", 0

; Compile + link + supprime le .o intermédiaire en une seule commande shell.
; 5 occurrences de %d → 5 arguments passés à snprintf (voir plus bas).
comp_fmt: db "nasm -f elf64 Sully_%d.s -o Sully_%d.o && gcc Sully_%d.o -o Sully_%d && rm -f Sully_%d.o", 0

run_fmt: db "./Sully_%d", 0
mode: db "w", 0

; __?FILE?__ est un token spécial NASM : il est remplacé à l'ASSEMBLAGE
; par le nom du fichier source en cours de compilation.
; Résultat dans le binaire :
;   sully.s   → fname = "sully.s"
;   Sully_4.s → fname = "Sully_4.s"
; C'est ainsi que chaque génération connaît sa propre valeur de i.
; Quand le format string reproduit la ligne "fname: db __?FILE?__, 0",
; il écrit les caractères littéraux __?FILE?__ — NASM les réinterprète
; lors de l'assemblage du fichier généré.
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
	push rbp          ; prologue : sauvegarde base pointer
	mov rbp, rsp
	push rbx          ; rbx = callee-saved → contiendra la valeur de i à écrire
	push r12          ; r12 = callee-saved → contiendra le FILE*
	sub rsp, 160      ; réserve locals : name[32] à [rsp], cmd[128] à [rsp+32]
	                  ; alignement : entry rsp%16=8, push rbp→0, push rbx→8,
	                  ;              push r12→0, sub 160 (160%16=0) → 0 ✓

	; --- Déterminer la valeur de i depuis le nom de fichier ---
	mov ebx, 5        ; valeur par défaut pour "sully.s" (pas de '_' dans le nom)
	lea rax, [fname]  ; rax pointe sur le début du nom de fichier

.find:
	cmp byte [rax], 0  ; fin de chaîne ?
	je .value          ; oui → utiliser ebx tel quel (cas "sully.s")
	cmp byte [rax], 95 ; 95 = '_' (underscore) ?
	je .child          ; oui → le chiffre suivant est la valeur courante de i
	inc rax            ; non → avancer d'un byte
	jmp .find

.child:
	; On est sur le '_' de "Sully_X.s".
	; Le byte suivant est le chiffre ASCII de i (ex. '4' = 52).
	movzx ebx, byte [rax + 1]  ; lire le chiffre, zero-étendu dans ebx
	sub ebx, 48                  ; convertir ASCII → entier : '4'-48 = 4
	dec ebx                      ; décrémenter : 4-1 = 3 (valeur à écrire)

.value:
	; ebx = valeur à écrire dans le fichier fils
	; Si ebx < 0 : on s'arrête (la prochaine valeur serait négative)
	test ebx, ebx   ; positionne SF si ebx < 0
	js .end         ; saut si négatif → fin sans rien écrire

	; --- Construire le nom du fichier fils : "Sully_X.s" ---
	lea rdi, [rsp]       ; buf = name (à [rsp])
	mov esi, 32          ; taille max
	lea rdx, [name_fmt]  ; "Sully_%d.s"
	mov ecx, ebx         ; X = ebx
	xor eax, eax
	call snprintf wrt ..plt

	; --- Ouvrir le fichier en écriture ---
	lea rdi, [rsp]    ; name
	lea rsi, [mode]   ; "w"
	call fopen wrt ..plt
	test rax, rax     ; NULL si échec
	jz .end
	mov r12, rax      ; sauvegarder FILE* dans r12 (survit aux prochains calls)

	; --- Écrire le source dans le fichier ---
	; fprintf(f, source, '\n', '"', source, ebx)
	mov rdi, r12         ; FILE*
	lea rsi, [source]    ; format string
	mov edx, 10          ; %1$c = '\n'
	mov ecx, 34          ; %2$c = '"'
	lea r8, [source]     ; %3$s = source (affiché tel quel, sans re-traitement)
	mov r9d, ebx         ; %4$d = valeur entière → reproduit "; i = X" et les noms
	xor eax, eax         ; 0 args SSE
	call fprintf wrt ..plt

	; --- Fermer le fichier ---
	mov rdi, r12
	call fclose wrt ..plt

	; --- Construire la commande de compilation ---
	; comp_fmt a 5 occurrences de %d → snprintf prend 8 args au total.
	; rdi,rsi,rdx,rcx,r8,r9 = 6 args registres.
	; Les 2 args restants (4e et 5e %d) passent par la stack.
	; On fait "push rbx; push rbx" : 2 pushes = 16 bytes → alignement maintenu.
	;   Avant : rsp%16 = 0  (BASE)
	;   Après push 1 : rsp%16 = 8
	;   Après push 2 : rsp%16 = 0  ✓ avant le call
	lea rdi, [rsp+32]    ; cmd buffer (à [BASE+32])
	mov esi, 128
	lea rdx, [comp_fmt]
	mov ecx, ebx         ; arg4 des %d : Sully_%d.s
	mov r8d, ebx         ; arg5 des %d : Sully_%d.o (nasm output)
	mov r9d, ebx         ; arg6 des %d : Sully_%d.o (gcc input)
	push rbx             ; arg8 (5e %d) : rm Sully_%d.o
	push rbx             ; arg7 (4e %d) : Sully_%d (gcc output)
	xor eax, eax
	call snprintf wrt ..plt
	add rsp, 16          ; nettoie les 2 pushes → rsp revient à BASE

	; --- Compiler ---
	lea rdi, [rsp+32]    ; cmd = "nasm ... && gcc ... && rm ..."
	call system wrt ..plt
	test eax, eax        ; system() retourne 0 si succès
	jnz .end             ; si compilation échouée → ne pas tenter d'exécuter

	; --- Construire la commande d'exécution : "./Sully_X" ---
	lea rdi, [rsp+32]
	mov esi, 128
	lea rdx, [run_fmt]   ; "./Sully_%d"
	mov ecx, ebx
	xor eax, eax
	call snprintf wrt ..plt

	; --- Exécuter le programme fils ---
	; execl(path, argv0, NULL) remplace le processus courant.
	; Si succès : on ne revient jamais ici.
	; Si échec  : on tombe dans .end (return 0).
	lea rdi, [rsp+32]    ; path  = "./Sully_X"
	lea rsi, [rsp+32]    ; argv0 = "./Sully_X" (même valeur)
	xor edx, edx         ; NULL  = fin de la liste d'arguments
	xor eax, eax
	call execl wrt ..plt

.end:
	xor eax, eax    ; return 0
	add rsp, 160    ; libère les locals
	pop r12         ; restaure r12 (callee-saved)
	pop rbx         ; restaure rbx (callee-saved)
	leave           ; restaure rbp + rsp
	ret
