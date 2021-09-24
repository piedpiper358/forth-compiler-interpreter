
%include "../lab1/lib.inc"
%include "lib.asm"	


section .bss
	user_mem:  resq 65536
	com_stack:  resq 65536
	
section .data
	word_ptr: dq 0;
	xt_exit: dq exit
	ifbranch: db 1
	srsp: dq 0
	program_stub: dq 0
	xt_interpreter: dq .interpreter
	.interpreter: dq execution
	last_word: dq link	
	
section .text

docol: 
	sub rstack, 8
	mov [rstack], pc
	add w, 8 
	mov pc, w
	jmp next

exit: 
	mov pc, [rstack]
	add rstack, 8
	jmp next

next:
	mov w, pc
	add pc, 8 
	mov w, [w]
	jmp [w]

find_word:
		mov rcx, [last_word]
	.loop:
		lea rsi, [rcx+8]
		push rcx
		call string_equals
		pop rcx
		test rax, rax
		jz .next
		mov rax, rcx 
		ret
	.next:
		mov rcx, [rcx]
		test rcx, rcx
		jnz .loop
		xor rax, rax
		ret

cfa:
		lea rax, [rdi+8] 
	.loop:
		inc rax
		cmp byte[rax], 0
		jne .loop
		add rax, 2
		ret	

execution:								   
			call read_word
			test rdx, rdx
			jz execution
			mov [word_ptr], rax
			mov rdi, rax;
			call find_word
			test rax, rax
			jz .number
			mov rdi, rax
			call cfa
			cmp byte [state], 0
			jz .interpreter_loop
	.compiler_loop:
			mov  dil, [rax-1]
			mov [ifbranch], dil
			test dil, dil
			jnz .notimmediate
	.interpreter_loop:
			mov qword[program_stub], rax
			mov pc, program_stub	
			jmp next
		.notimmediate:
			mov rdi, [here]
			mov [rdi], rax
			add qword [here], 8
			jmp execution
	.number:	
			mov rdi, [word_ptr]
			call parse_int
			test rdx, rdx
			jz execution
			cmp byte [state], 0
			jnz .compiler_number
		.interpreter_number:
			push rax
			jmp execution	
				
		.compiler_number:
				cmp byte [ifbranch], 2
				je .branch
				mov rdi, [here]
				mov qword [rdi], xt_lit
				add qword [here], 8
			.branch:	
				mov rdi, [here]
				mov qword [rdi], rax
				add qword [here], 8
				mov byte [ifbranch], 0
jmp execution
 
	global _start
	_start:
		mov [srsp], rsp
		lea rstack, [com_stack+65536]
		mov pc, xt_interpreter
		jmp next		
