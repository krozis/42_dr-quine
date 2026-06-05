; ============================================================
; DIRECTIVE : dit à NASM que toutes les références mémoire
; sont implicitement RIP-relative (adressage relatif au PC).
; Nécessaire en elf64 pour éviter des relocations absolues.
; ============================================================
default rel

; ============================================================
; SECTION .DATA : données initialisées (lecture/écriture)
; On y stocke notre chaîne source — le cœur du quine.
; ============================================================
section .data

; 'source' est à la fois :
;   - le FORMAT STRING passé à printf (contient les %1$c etc.)
;   - la DONNÉE passée en %3$s (son propre contenu, tel quel)
;
; Les caractères spéciaux sont encodés avec des format specifiers
; positionnels pour éviter de les stocker directement dans la chaîne :
;   %1$c → argument 1 = 10  = '\n'  (saut de ligne)
;   %2$c → argument 2 = 34  = '"'   (guillemet double)
;   %3$s → argument 3 = source lui-même (affiché comme string brut)
;
; IMPORTANT : quand printf substitue %3$s, il copie les bytes
; de 'source' SANS les retraiter — les %1$c qui se trouvent
; dans la substitution sont affichés littéralement, pas évalués.
; C'est ce qui empêche la boucle infinie.
source: db "default rel%1$c%1$csection .data%1$c; It's a Quine of Magic%1$csource: db %2$c%3$s%2$c, 0%1$c%1$csection .text%1$cextern printf%1$cglobal main%1$c%1$cmain:%1$c	push rbp%1$c	mov rbp, rsp%1$c	; I Want to Make Free%1$c	call print%1$c	xor eax, eax%1$c	leave%1$c	ret%1$c%1$cprint:%1$c	push rbp%1$c	mov rbp, rsp%1$c	lea rdi, [source]%1$c	mov esi, 10%1$c	mov edx, 34%1$c	lea rcx, [source]%1$c	xor eax, eax%1$c	call printf wrt ..plt%1$c	leave%1$c	ret%1$c", 0
; Le ", 0" final est le null-terminator — printf s'arrête là.

; ============================================================
; SECTION .TEXT : code exécutable
; ============================================================
section .text

; Déclare printf comme symbole externe (résolu par le linker/libc).
extern printf

; Expose 'main' comme symbole global pour que gcc/ld trouve l'entry point.
global main

; ============================================================
; ENTRY POINT : main
; Appelé par le runtime C (crt0) avant d'entrer dans le programme.
; Convention x86-64 System V : à l'entrée de main, rsp est aligné
; à 16 bytes MOINS 8 (à cause du ret addr pushé par l'appelant).
; ============================================================
main:
	push rbp        ; sauvegarde le base pointer de l'appelant
	                ; rsp -= 8 → rsp est maintenant aligné 16 bytes ✓
	mov rbp, rsp    ; établit notre stack frame (prologue standard)
	; I Want to Make Free
	call print      ; appelle notre routine d'affichage
	                ; avant ce call, rsp est aligné 16 bytes → correct
	xor eax, eax    ; return 0 (convention : valeur de retour dans eax)
	leave           ; restaure rsp et rbp (équivalent : mov rsp,rbp / pop rbp)
	ret             ; retourne au runtime C

; ============================================================
; ROUTINE : print
; Prépare les arguments pour printf et l'appelle.
; Convention x86-64 System V (registres pour les 6 premiers args) :
;   rdi = arg1, rsi = arg2, rdx = arg3, rcx = arg4
; Pour les fonctions variadiques, eax = nb d'args en registres SSE (ici 0).
; ============================================================
print:
	push rbp        ; sauvegarde base pointer
	                ; rsp -= 8 → aligné 16 bytes ✓
	mov rbp, rsp    ; établit la stack frame

	lea rdi, [source]  ; arg1 : adresse de 'source' = le format string
	                   ; lea avec [source] utilise l'adressage RIP-relatif
	                   ; (grâce à 'default rel' en haut du fichier)

	mov esi, 10        ; arg2 : valeur entière 10 = code ASCII de '\n'
	                   ; sera utilisé par chaque %1$c dans le format string
	                   ; mov esi zero-étend automatiquement vers rsi

	mov edx, 34        ; arg3 : valeur entière 34 = code ASCII de '"'
	                   ; sera utilisé par chaque %2$c dans le format string

	lea rcx, [source]  ; arg4 : adresse de 'source' encore une fois
	                   ; sera utilisé par %3$s → affiche la chaîne brute

	xor eax, eax       ; eax = 0 : indique à printf qu'on passe 0 args
	                   ; en registres vectoriels (XMM) — obligatoire pour
	                   ; toute fonction variadique en System V ABI

	call printf wrt ..plt
	                   ; appelle printf via la PLT (Procedure Linkage Table)
	                   ; wrt ..plt = résolution dynamique par le linker
	                   ; à ce point rsp est aligné 16 bytes → correct

	leave              ; restaure stack frame
	ret                ; retourne dans main
