
%define pc r12;rax ;указывает на следующую forth-команду ;указыаает на ячейку памяти, в кторой лежит следующий XT 
%define w r13 ;rax ;в начале выполнения невстраиваемых слов указывает на первый адрес сразу после залоговка
%define rstack r14;rax; rsp стека адресов возврата

section .data
	here:  dq user_mem
	state: db 0

%define link 0
%macro native 3
	section .data
		w_%2:
			%%link: dq link
			ww_%2: db %1, 0
			db %3
		xt_%2:
			dq %2_impl
	
	section .text
	 %2_impl:
	%define link %%link
%endmacro

%macro native 2
native %1, %2, 1
%endmacro

%macro colon 3
	section .data
		w_%2:
			%%link: dq link
			db %1, 0
			db %3
			xt_%2: 
			dq docol
	%define link %%link
%endmacro

%macro colon 2
colon %1, %2, 1
%endmacro


colon '>', greater
	dq xt_swap
	dq xt_less
	dq xt_exit

native 'S' , stack
		push rbx
		mov rbx, rsp
	.loop:
		add rbx, 8
		cmp rbx, [srsp]
		jge .quit
		mov rdi, [rbx]
		call print_int
		call print_newline
		jmp .loop 
	.quit:
		pop rbx
		jmp next
	
native '+' , plus
	pop rax
	add [rsp], rax
	jmp next

native '-' , minus
	pop rax
	sub [rsp], rax
	jmp next
	
native '*' , asterisk
	pop rax
	pop rdx
	mul rdx
	push rax
	jmp next
	
native '/' , slash
	pop rcx
	pop rax
	xor rdx, rdx
	div rcx
	push rax
	jmp next

native '=' , es
		pop rax
		pop rdx
		cmp rax, rdx
		je .equal
		push 0
		jmp next
	.equal:
		push 1
		jmp next

native '<' , less
		pop rax
		pop rdx
		 cmp rdx, rax
		 jl .less
		 push 0
		 jmp next
	 .less:
		 push 1
		 jmp next	

native 'and' , and
	pop rax
	pop rdx
	and rax, rdx
	push rax
	jmp next

native 'not' , not
	pop rax 
	not rax
	push rax
	jmp next		
	
native 'rot' , rot
	pop rax ;c
	pop rdx ;b
	pop rcx ;a
	push rdx
	push rax
	push rcx
	jmp next
	
native 'swap' , swap
	pop rax
	pop rdx
	push rax
	push rdx
	jmp next	

native 'dup' , dup
	pop rax
	push rax
	push rax
	jmp next	
	
native 'drop' , drop
	pop rax
	jmp next

native '.' , dot
	pop rdi
	call print_int
	call print_newline
	jmp next	
	
native 'key' , key
	call read_char
	push rax
	jmp next	
	
native 'emit' , emit
	pop rdi
	call print_char
	call print_newline
	jmp next	
	
native 'number' , number
	call read_word
	mov rdi, rax
	call parse_int
	push rax
	jmp next	
	
native 'mem' , mem
	push user_mem
	jmp next	
	
native '!' , em
	pop rax
	pop rdi
	mov [rax], rdi
	jmp next	
	
native '@' , at
	pop rax
	push qword [rax]
	jmp next
	
read_word_ptr:
		mov [word_ptr],rdi
		push rbx
		xor rbx, rbx
	.loop1:
		call read_char
		cmp rax, 0x20
		je .loop1
		cmp rax, 0x09
		je .loop1
		cmp rax, 0x0A
		je .loop1
		cmp rax, 0x00
		je .quit
	.loop2: 
		mov rdx, [word_ptr]
		mov byte [rdx+rbx], al 
		inc rbx
		call read_char
		cmp rax, 0x20
		je .quit
		cmp rax, 0x9
		je .quit
		cmp rax, 0xA
		je .quit
		cmp rax, 0x0
		je .quit
		jmp .loop2
	.quit:
		mov rdx, [word_ptr]
		mov byte [rdx+rbx], 0x0 
		mov rdx, rbx  
		pop rbx
		xor rax, rax
		ret

native ':' , colon
	mov rdi, [here]
	mov rax, [last_word]
	mov qword [rdi], rax
	mov qword [last_word], rdi
	add rdi, 8
	call read_word_ptr
	mov rdi, [here]
	add rdi, rdx
	add rdi, 8
	inc rdi
	mov byte [rdi], 0
	inc rdi
	mov qword [rdi], docol
	add rdi, 8
	mov [here], rdi
	mov byte [state], 1
	jmp next	

native ';' , semicolon, 0
	mov rdi, [here]
	mov qword [rdi], xt_exit
	add qword [here], 8
	mov byte [state], 0 
	jmp next
	
native 'q' , quit
	mov rax, 60
	xor rdi, rdi
	syscall
	
native 'lit' , lit
	mov w, pc
	add pc, 8 
	mov w, [w]
	add pc, w
	jmp next
	
native 'branch' , branch, 2
	mov w, pc
	add pc, 8 
	mov w, [w]
	sal w, 3
	add pc, w
	jmp next
	
native '0branch', branch0,  2
	pop rax
	test rax, rax
	jz branch_impl
	add pc, 8
	jmp next
	
