; nasm -f elf64 -l 1-nasm.lst 1-nasm.s  ;  ld -s -o 1-nasm 1-nasm.o

; section .text

global Printf      

extern strlen

; _start:     
;         mov rdi, Msg

; 		push qword 255
; 		push qword 33
; 		push qword 100
; 		push qword 3802
; 		push string

; 		push qword 'a'
; 		push qword 'p'
; 		push qword 'o'
; 		push qword 'z'

; 		push qword 228
; 		push qword 228
; 		push qword 228
; 		push qword 228
; 		push cry

; 		push rbp
;         mov rbp, rsp
; 		add rbp, 0x8

;         call Printf
; 		mov rcx, rbp
;         pop rbp
        
;         sub rcx, rsp
;         add rsp, rcx

;         mov rax, 0x3C   
;         xor rdi, rdi
;         syscall

Printf:
		pop rax
		push r9
		push r8
		push rcx
		push rdx
		push rsi

		mov rbp, rsp 
PrintfLoop:

        cmp byte [rdi], 0
        je  PrintfEnd

        cmp byte [rdi], '%'
        jne simSym
        inc rdi

		cmp byte [rdi], '%'
        je simSym

		xor rbx, rbx
		mov bl, [rdi]
		sub bl, 'a'
                 
		shl rbx, 3
                 
		add rbx,jumpTable

		jmp [rbx]
dSym:
		mov rdx, 10d

		call pSomeN
		jmp PrintfLoop
xSym:
		mov rdx, 0x10

		call pSomeN
		jmp PrintfLoop
cSym:
		push rdi

		mov rax, 0x01
        mov rdi, 1

		mov rsi, rbp
        mov rdx, 1
        syscall
		
		pop rdi

		inc rdi
		add rbp, 8

		jmp PrintfLoop
oSym:
		mov rdx, 0x8

		call pSomeN
		jmp PrintfLoop
sSym:
		push rdi

		mov rdi, [rbp]
		add rbp, 8

		call strlen
        mov rdx, rax
		mov rax, 0x01
		mov rsi, rdi
        mov rdi, 1
        
        syscall

		pop rdi
		inc rdi
		jmp PrintfLoop
bSym:
		mov rdx, 0x2

		call pSomeN
		jmp PrintfLoop
simSym:
        push rdi

		mov rdx, 1
		mov rax, 0x01
		mov rsi, rdi
        mov rdi, 1
        
        syscall

        pop rdi
        inc rdi
        jmp PrintfLoop

PrintfEnd:
		add rsp, 6 * 8
        ret                  
;-------------------------------------------------------	
jumpTable:
		dq simSym
		dq bSym
		dq cSym
		dq dSym
		times 10 dq simSym
		dq oSym
		times 3 dq simSym
		dq sSym
		times 4 dq simSym
		dq xSym
		times 2 dq simSym
;-------------------------------------------------------	
pSomeN:
		push rdi
        
        mov rdi, [rbp]
        add rbp, 8

        mov rsi, tempStr

        call itoa

        mov rax, 0x01

        sub rsi, tempStr
        mov rdx, rsi

        mov rsi, tempStr
        mov rdi, 1
        
        syscall

        pop rdi
        inc rdi
		ret
;---------------------------------------------------------------------
itoa:	
		cmp rdx, 2
		jne nextcheck
		
		mov rcx, rdi
		and rcx, 0x1

		shr rdi, 1		

		cmp rdi, 0
		je itoaIF2

		push rdi
		push rcx

		call itoa

		pop rcx
		pop rdi
itoaIF2:
		mov rax, rcx
		add rax, '0'

        mov rdi, rsi
		stosb
        inc rsi

		ret
nextcheck: 	
		cmp rdx, 8
		jne nextcheck1

		mov rcx, rdi
		and rcx, 0x7

		shr rdi, 3	

		cmp rdi, 0
		je itoaIF8

		push rdi
		push rcx

		call itoa

		pop rcx
		pop rdi
itoaIF8:
		mov rax, rcx
		add rax, '0'

        mov rdi, rsi
                 
		stosb
        inc rsi

		ret
nextcheck1:
		cmp rdx, 16
		jne finita

		mov rcx, rdi
		and rcx, 0xf

		shr rdi, 4	

		cmp rdi, 0
		je itoaIF16

		push rdi
		push rcx

		call itoa

		pop rcx
		pop rdi
itoaIF16:
		mov rax, rcx

		cmp rax, 9
		jbe greater

		add rax, 'a' - '0' - 0xa

greater:
		add rax, '0'
		
        mov rdi, rsi
                 
		stosb
        inc rsi
		ret
finita:	
        mov rax, rdi
        div dl
            
        mov rdi, rax
		cmp al, 0
		je itoaIF

        push rdi
                
	    xor ah, ah
        mov rdi, rax
                
        call itoa
		pop rdi
itoaIF:		
		mov rax, rdi
		cmp ah, 9

		jbe alphav
		
		add ah, 'a' - '0' - 0xa
alphav:
		add ah, '0'

		mov byte [rsi], ah
		inc rsi
	
		ret
;-------------------------------------------------------

section     .data
            
; Msg:        db "I %s %x %d%%%c%b", 0x0a, 0
; string:		db "LOVE", 0

tempStr:    db "0000000000"
; MsgLen      equ $ - Msg

