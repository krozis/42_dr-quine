; ============================================================
; DIRECTIVE RIP-relative (voir colleen_commented.s pour détails)
; ============================================================
default rel

; ============================================================
; MACRO 1 : %define S — le format string, cœur du quine
;
; %define en NASM = remplacement textuel pur (comme #define en C).
; Quand NASM rencontre S plus bas (ligne "source: db S, 0"),
; il substitue littéralement le texte de S à sa place.
;
; Le contenu encode le source entier avec des format specifiers :
;   %1$c → argument positionnel 1 = '\n' (valeur 10, passé dans edx)
;   %2$c → argument positionnel 2 = '"'  (valeur 34, passé dans ecx)
;   %3$s → argument positionnel 3 = la chaîne source elle-même (r8)
;   %%   → un seul '%' dans la sortie (%%define → %define, etc.)
;
; Pourquoi %% et pas % ?
;   À l'assemblage, NASM stocke %% comme deux bytes '%' '%' dans le binaire.
;   À l'exécution, fprintf voit '%%' et l'interprète comme un '%' littéral.
;   Sans ça, '%define' dans la sortie serait impossible à écrire directement
;   dans un format string sans déclencher une lecture d'argument.
; ============================================================
%define S "default rel%1$c%1$c%%define S %2$c%3$s%2$c%1$c%%define N %2$cGrace_kid.s%2$c%1$c%%macro MAIN 0%1$cmain:%1$c	push rbp%1$c	mov rbp, rsp%1$c	push rbx%1$c	sub rsp, 8%1$c	lea rdi, [name]%1$c	lea rsi, [mode]%1$c	call fopen wrt ..plt%1$c	test rax, rax%1$c	je .error%1$c	mov rbx, rax%1$c	mov rdi, rbx%1$c	lea rsi, [source]%1$c	mov edx, 10%1$c	mov ecx, 34%1$c	lea r8, [source]%1$c	xor eax, eax%1$c	call fprintf wrt ..plt%1$c	mov rdi, rbx%1$c	call fclose wrt ..plt%1$c	xor eax, eax%1$c	jmp .done%1$c.error:%1$c	mov eax, 1%1$c.done:%1$c	add rsp, 8%1$c	pop rbx%1$c	leave%1$c	ret%1$c%%endmacro%1$c%1$csection .data%1$c; It's a Quine of Magic%1$csource: db S, 0%1$cname: db N, 0%1$cmode: db %2$cw%2$c, 0%1$c%1$csection .text%1$cextern fopen%1$cextern fprintf%1$cextern fclose%1$cglobal main%1$c%1$cMAIN%1$c"

; ============================================================
; MACRO 2 : %define N — le nom du fichier de sortie
;
; Séparé de S pour deux raisons :
;   1. Clarté : le nom du fichier est modifiable sans toucher au format string
;   2. Contrainte du sujet : exactement 3 macros — S, N, MAIN
; ============================================================
%define N "Grace_kid.s"

; ============================================================
; MACRO 3 : %macro MAIN 0 — l'entry point encapsulé dans une macro
;
; "MAIN 0" signifie : macro nommée MAIN, prenant 0 paramètres.
; Elle sera invoquée plus bas par un simple "MAIN".
; Contrainte du sujet : le programme doit tourner via un appel de macro.
; ============================================================
%macro MAIN 0
main:
	push rbp          ; sauvegarde le base pointer de l'appelant
	mov rbp, rsp      ; établit notre stack frame
	push rbx          ; sauvegarde rbx (registre callee-saved en System V ABI)
	                  ; rbx sera utilisé pour stocker le file pointer
	sub rsp, 8        ; aligne rsp à 16 bytes
	                  ; état après ces 4 instructions :
	                  ;   rsp % 16 == 0  → prêt pour tout call ✓

	; --- Ouverture du fichier de sortie ---
	lea rdi, [name]   ; arg1 de fopen : chemin = "Grace_kid.s"
	lea rsi, [mode]   ; arg2 de fopen : mode   = "w" (écriture, crée/écrase)
	call fopen wrt ..plt
	                  ; retour dans rax : FILE* si succès, NULL si échec

	test rax, rax     ; test rax & rax : positionne ZF si rax == 0 (NULL)
	je .error         ; si NULL → saut vers gestion d'erreur

	mov rbx, rax      ; sauvegarde le FILE* dans rbx (callee-saved)
	                  ; on ne peut pas garder dans rax car les prochains
	                  ; calls l'écraseront

	; --- Écriture du source dans le fichier ---
	mov rdi, rbx      ; arg1 de fprintf : le FILE* sauvegardé
	lea rsi, [source] ; arg2 de fprintf : le format string (= la chaîne S)
	mov edx, 10       ; arg3 : '\n' → remplace tous les %1$c
	mov ecx, 34       ; arg4 : '"'  → remplace tous les %2$c
	lea r8, [source]  ; arg5 : la chaîne source elle-même → remplace %3$s
	                  ; fprintf affiche r8 via %3$s comme bytes bruts,
	                  ; sans retraiter les % qu'elle contient
	xor eax, eax      ; 0 args en registres SSE (obligatoire pour variadique)
	call fprintf wrt ..plt

	; --- Fermeture du fichier ---
	mov rdi, rbx      ; arg1 de fclose : le FILE*
	call fclose wrt ..plt

	xor eax, eax      ; return 0 (succès)
	jmp .done         ; saute la gestion d'erreur

.error:
	mov eax, 1        ; return 1 (échec — fopen a retourné NULL)

.done:
	add rsp, 8        ; libère les 8 bytes réservés par "sub rsp, 8"
	pop rbx           ; restaure rbx (callee-saved)
	leave             ; restaure rbp et rsp (épilogue)
	ret               ; retourne au runtime C
%endmacro

; ============================================================
; SECTION .DATA
; ============================================================
section .data

; It's a Quine of Magic
source: db S, 0   ; NASM substitue S ici → la chaîne format est assemblée
                  ; le ", 0" est le null-terminator pour fprintf
name: db N, 0     ; NASM substitue N → "Grace_kid.s\0"
mode: db "w", 0   ; mode fopen : écriture ("w" crée ou écrase le fichier)

; ============================================================
; SECTION .TEXT
; ============================================================
section .text

extern fopen      ; ouverture de fichier (libc)
extern fprintf    ; écriture formatée dans un fichier (libc)
extern fclose     ; fermeture de fichier (libc)
global main       ; expose main pour le linker

; Invocation de la macro MAIN :
; NASM remplace cette ligne par tout le contenu défini entre
; %macro MAIN 0 et %endmacro — comme un copier-coller à l'assemblage.
MAIN
