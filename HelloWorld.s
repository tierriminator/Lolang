	.text
	.file	"main"
	.globl	resolve                 # -- Begin function resolve
	.p2align	4, 0x90
	.type	resolve,@function
resolve:                                # @resolve
	.cfi_startproc
# BB#0:                                 # %entry
	pushq	%rbp
.Lcfi0:
	.cfi_def_cfa_offset 16
.Lcfi1:
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
.Lcfi2:
	.cfi_def_cfa_register %rbp
	pushq	%r15
	pushq	%r14
	pushq	%rbx
	pushq	%rax
.Lcfi3:
	.cfi_offset %rbx, -40
.Lcfi4:
	.cfi_offset %r14, -32
.Lcfi5:
	.cfi_offset %r15, -24
	movb	$0, -25(%rbp)
	movabsq	$1099511627775, %rax    # imm = 0xFFFFFFFFFF
	andq	%rdi, %rax
	.p2align	4, 0x90
.LBB0_1:                                # %offsetBuilderLoop
                                        # =>This Inner Loop Header: Depth=1
	movsbq	-25(%rbp), %rdx
	movl	%edx, %ecx
	shlb	$3, %cl
	movq	%rax, %rsi
	shrq	%cl, %rsi
	movb	%sil, -30(%rbp,%rdx)
	incb	%dl
	movb	%dl, -25(%rbp)
	cmpb	$5, %dl
	jne	.LBB0_1
# BB#2:                                 # %resolutionInit
	movq	%rsp, %rax
	leaq	-16(%rax), %r14
	movq	%r14, %rsp
	movsbq	-26(%rbp), %rcx
	shlq	$3, %rcx
	addq	rootPt(%rip), %rcx
	movb	$3, -25(%rbp)
	movq	%rcx, -16(%rax)
	.p2align	4, 0x90
.LBB0_3:                                # %resolutionLoop
                                        # =>This Inner Loop Header: Depth=1
	movq	(%r14), %r15
	movzbl	-25(%rbp), %ebx
	cmpq	$0, (%r15)
	jne	.LBB0_5
# BB#4:                                 # %callocCondition
                                        #   in Loop: Header=BB0_3 Depth=1
	movl	$2048, %edi             # imm = 0x800
	movl	$1, %esi
	callq	calloc
	movq	%rax, (%r15)
.LBB0_5:                                # %resolutionLoopEnd
                                        #   in Loop: Header=BB0_3 Depth=1
	decb	%bl
	movsbq	%bl, %rcx
	movsbq	-30(%rbp,%rcx), %rax
	shlq	$3, %rax
	addq	(%r15), %rax
	movq	%rax, (%r14)
	movb	%cl, -25(%rbp)
	testb	%cl, %cl
	jne	.LBB0_3
# BB#6:                                 # %ret
	leaq	-24(%rbp), %rsp
	popq	%rbx
	popq	%r14
	popq	%r15
	popq	%rbp
	retq
.Lfunc_end0:
	.size	resolve, .Lfunc_end0-resolve
	.cfi_endproc
                                        # -- End function
	.globl	main                    # -- Begin function main
	.p2align	4, 0x90
	.type	main,@function
main:                                   # @main
	.cfi_startproc
# BB#0:                                 # %entry
	pushq	%rbx
.Lcfi6:
	.cfi_def_cfa_offset 16
.Lcfi7:
	.cfi_offset %rbx, -16
	movl	$2048, %edi             # imm = 0x800
	movl	$1, %esi
	callq	calloc
	movq	%rax, rootPt(%rip)
	movl	curRegPtr(%rip), %eax
	movzbl	curRegPtr+4(%rip), %ecx
	shlq	$32, %rcx
	leaq	1(%rax,%rcx), %rdi
	movl	%edi, curRegPtr(%rip)
	movq	%rdi, %rax
	shrq	$32, %rax
	movb	%al, curRegPtr+4(%rip)
	callq	resolve
	addq	$7, (%rax)
	jmp	.LBB1_1
	.p2align	4, 0x90
.LBB1_2:                                # %RoflBody
                                        #   in Loop: Header=BB1_1 Depth=1
	movl	curRegPtr(%rip), %eax
	movzbl	curRegPtr+4(%rip), %edi
	shlq	$32, %rdi
	orq	%rax, %rdi
	callq	resolve
	decq	(%rax)
	movl	curRegPtr(%rip), %eax
	movzbl	curRegPtr+4(%rip), %ecx
	shlq	$32, %rcx
	leaq	-1(%rax,%rcx), %rdi
	movl	%edi, curRegPtr(%rip)
	movq	%rdi, %rax
	shrq	$32, %rax
	movb	%al, curRegPtr+4(%rip)
	callq	resolve
	addq	$10, (%rax)
	movl	curRegPtr(%rip), %eax
	movzbl	curRegPtr+4(%rip), %ecx
	shlq	$32, %rcx
	leaq	1(%rax,%rcx), %rax
	movl	%eax, curRegPtr(%rip)
	shrq	$32, %rax
	movb	%al, curRegPtr+4(%rip)
.LBB1_1:                                # %RoflCond
                                        # =>This Inner Loop Header: Depth=1
	movl	curRegPtr(%rip), %eax
	movzbl	curRegPtr+4(%rip), %edi
	shlq	$32, %rdi
	orq	%rax, %rdi
	callq	resolve
	cmpq	$0, (%rax)
	jne	.LBB1_2
# BB#3:                                 # %Copter
	movl	curRegPtr(%rip), %eax
	movzbl	curRegPtr+4(%rip), %ecx
	shlq	$32, %rcx
	leaq	-1(%rax,%rcx), %rdi
	movl	%edi, curRegPtr(%rip)
	movq	%rdi, %rax
	shrq	$32, %rax
	movb	%al, curRegPtr+4(%rip)
	callq	resolve
	addq	$2, (%rax)
	movl	curRegPtr(%rip), %eax
	movzbl	curRegPtr+4(%rip), %edi
	shlq	$32, %rdi
	orq	%rax, %rdi
	callq	resolve
	movq	(%rax), %rbx
	movl	$1, %edi
	callq	resolve
	movq	%rbx, (%rax)
	movb	$0, curRegPtr+4(%rip)
	movl	$1, curRegPtr(%rip)
	movl	$1, %edi
	callq	resolve
	addq	$-3, (%rax)
	movb	$0, curRegPtr+4(%rip)
	movl	$0, curRegPtr(%rip)
	xorl	%edi, %edi
	callq	resolve
	movq	(%rax), %rbx
	movl	$2, %edi
	callq	resolve
	movq	%rbx, (%rax)
	movb	$0, curRegPtr+4(%rip)
	movl	$2, curRegPtr(%rip)
	movl	$2, %edi
	callq	resolve
	addq	$4, (%rax)
	movl	curRegPtr(%rip), %eax
	movzbl	curRegPtr+4(%rip), %edi
	shlq	$32, %rdi
	orq	%rax, %rdi
	callq	resolve
	movq	(%rax), %rbx
	movl	$3, %edi
	callq	resolve
	movq	%rbx, (%rax)
	movb	$0, curRegPtr+4(%rip)
	movl	$3, curRegPtr(%rip)
	movl	$3, %edi
	callq	resolve
	movq	(%rax), %rbx
	movl	$4, %edi
	callq	resolve
	movq	%rbx, (%rax)
	movb	$0, curRegPtr+4(%rip)
	movl	$4, curRegPtr(%rip)
	movl	$4, %edi
	callq	resolve
	addq	$3, (%rax)
	movl	curRegPtr(%rip), %eax
	movzbl	curRegPtr+4(%rip), %ecx
	shlq	$32, %rcx
	leaq	2(%rax,%rcx), %rdi
	movl	%edi, curRegPtr(%rip)
	movq	%rdi, %rax
	shrq	$32, %rax
	movb	%al, curRegPtr+4(%rip)
	callq	resolve
	addq	$4, (%rax)
	jmp	.LBB1_4
	.p2align	4, 0x90
.LBB1_5:                                # %RoflBody2
                                        #   in Loop: Header=BB1_4 Depth=1
	movl	curRegPtr(%rip), %eax
	movzbl	curRegPtr+4(%rip), %edi
	shlq	$32, %rdi
	orq	%rax, %rdi
	callq	resolve
	decq	(%rax)
	movl	curRegPtr(%rip), %eax
	movzbl	curRegPtr+4(%rip), %ecx
	shlq	$32, %rcx
	leaq	-1(%rax,%rcx), %rdi
	movl	%edi, curRegPtr(%rip)
	movq	%rdi, %rax
	shrq	$32, %rax
	movb	%al, curRegPtr+4(%rip)
	callq	resolve
	addq	$8, (%rax)
	movl	curRegPtr(%rip), %eax
	movzbl	curRegPtr+4(%rip), %ecx
	shlq	$32, %rcx
	leaq	1(%rax,%rcx), %rax
	movl	%eax, curRegPtr(%rip)
	shrq	$32, %rax
	movb	%al, curRegPtr+4(%rip)
.LBB1_4:                                # %RoflCond1
                                        # =>This Inner Loop Header: Depth=1
	movl	curRegPtr(%rip), %eax
	movzbl	curRegPtr+4(%rip), %edi
	shlq	$32, %rdi
	orq	%rax, %rdi
	callq	resolve
	cmpq	$0, (%rax)
	jne	.LBB1_5
# BB#6:                                 # %Copter3
	movb	$0, curRegPtr+4(%rip)
	movl	$4, curRegPtr(%rip)
	movl	$4, %edi
	callq	resolve
	movq	(%rax), %rbx
	movl	$6, %edi
	callq	resolve
	movq	%rbx, (%rax)
	movb	$0, curRegPtr+4(%rip)
	movl	$6, curRegPtr(%rip)
	movl	$6, %edi
	callq	resolve
	addq	$8, (%rax)
	movb	$0, curRegPtr+4(%rip)
	movl	$4, curRegPtr(%rip)
	movl	$4, %edi
	callq	resolve
	movq	(%rax), %rbx
	movl	$7, %edi
	callq	resolve
	movq	%rbx, (%rax)
	movb	$0, curRegPtr+4(%rip)
	movl	$7, curRegPtr(%rip)
	movl	$7, %edi
	callq	resolve
	movq	(%rax), %rbx
	movl	$8, %edi
	callq	resolve
	movq	%rbx, (%rax)
	movb	$0, curRegPtr+4(%rip)
	movl	$8, curRegPtr(%rip)
	movl	$8, %edi
	callq	resolve
	addq	$3, (%rax)
	movb	$0, curRegPtr+4(%rip)
	movl	$4, curRegPtr(%rip)
	movl	$4, %edi
	callq	resolve
	movq	(%rax), %rbx
	movl	$9, %edi
	callq	resolve
	movq	%rbx, (%rax)
	movb	$0, curRegPtr+4(%rip)
	movl	$9, curRegPtr(%rip)
	movl	$9, %edi
	callq	resolve
	addq	$-3, (%rax)
	movb	$0, curRegPtr+4(%rip)
	movl	$1, curRegPtr(%rip)
	movl	$1, %edi
	callq	resolve
	movq	(%rax), %rbx
	movl	$10, %edi
	callq	resolve
	movq	%rbx, (%rax)
	movb	$0, curRegPtr+4(%rip)
	movl	$10, curRegPtr(%rip)
	movl	$10, %edi
	callq	resolve
	decq	(%rax)
	movl	curRegPtr(%rip), %eax
	movzbl	curRegPtr+4(%rip), %ecx
	shlq	$32, %rcx
	leaq	1(%rax,%rcx), %rdi
	movl	%edi, curRegPtr(%rip)
	movq	%rdi, %rax
	shrq	$32, %rax
	movb	%al, curRegPtr+4(%rip)
	callq	resolve
	addq	$10, (%rax)
	movb	$0, curRegPtr+4(%rip)
	movl	$0, curRegPtr(%rip)
	jmp	.LBB1_7
	.p2align	4, 0x90
.LBB1_8:                                # %RoflBody5
                                        #   in Loop: Header=BB1_7 Depth=1
	movl	curRegPtr(%rip), %eax
	movzbl	curRegPtr+4(%rip), %edi
	shlq	$32, %rdi
	orq	%rax, %rdi
	callq	resolve
	movq	(%rax), %rsi
	movl	$.L__unnamed_1, %edi
	xorl	%eax, %eax
	callq	printf
	movl	curRegPtr(%rip), %eax
	movzbl	curRegPtr+4(%rip), %ecx
	shlq	$32, %rcx
	leaq	1(%rax,%rcx), %rax
	movl	%eax, curRegPtr(%rip)
	shrq	$32, %rax
	movb	%al, curRegPtr+4(%rip)
.LBB1_7:                                # %RoflCond4
                                        # =>This Inner Loop Header: Depth=1
	movl	curRegPtr(%rip), %eax
	movzbl	curRegPtr+4(%rip), %edi
	shlq	$32, %rdi
	orq	%rax, %rdi
	callq	resolve
	cmpq	$0, (%rax)
	jne	.LBB1_8
# BB#9:                                 # %Copter6
	popq	%rbx
	retq
.Lfunc_end1:
	.size	main, .Lfunc_end1-main
	.cfi_endproc
                                        # -- End function
	.type	rootPt,@object          # @rootPt
	.bss
	.globl	rootPt
	.p2align	3
rootPt:
	.quad	0
	.size	rootPt, 8

	.type	curRegPtr,@object       # @curRegPtr
	.globl	curRegPtr
	.p2align	3
curRegPtr:
	.quad	0                       # 0x0
	.size	curRegPtr, 8

	.type	.L__unnamed_1,@object   # @0
	.section	.rodata.str1.1,"aMS",@progbits,1
.L__unnamed_1:
	.asciz	"%c"
	.size	.L__unnamed_1, 3


	.section	".note.GNU-stack","",@progbits
