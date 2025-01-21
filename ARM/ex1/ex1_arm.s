	.arch armv4t
	.fpu softvfp
	.eabi_attribute 20, 1
	.eabi_attribute 21, 1
	.eabi_attribute 23, 3
	.eabi_attribute 24, 1
	.eabi_attribute 25, 1
	.eabi_attribute 26, 2
	.eabi_attribute 30, 4
	.eabi_attribute 34, 0
	.eabi_attribute 18, 4
	.file	"ex1.c"
	.global	__aeabi_idivmod
	.text
	.align	2
	.global	transform
	.type	transform, %function
transform:
	@ Function supports interworking.
	@ args = 0, pretend = 0, frame = 0
	@ frame_needed = 0, uses_anonymous_args = 0
	stmfd	sp!, {r3, r4, r5, r6, r7, lr}
	mov	r5, r1
	mov	r7, r2
	mov	r4, r1
	sub	r6, r0, #1
.L2:
	rsb	r3, r5, r4
	cmp	r3, r7
	bge	.L11
	ldrb	r0, [r6, #1]!	@ zero_extendqisi2
	sub	r2, r0, #48
	cmp	r2, #9
	bhi	.L3
	sub	r0, r0, #43
	mov	r1, #10
	bl	__aeabi_idivmod
	add	r1, r1, #48
	strb	r1, [r4]
	b	.L4
.L3:
	sub	r2, r0, #97
	cmp	r2, #25
	subls	r3, r0, #32
	bls	.L9
	sub	r2, r0, #65
	cmp	r2, #25
	strhib	r0, [r4]
	bhi	.L4
	add	r3, r0, #32
.L9:
	strb	r3, [r4]
.L4:
	add	r4, r4, #1
	b	.L2
.L11:
	ldmfd	sp!, {r3, r4, r5, r6, r7, lr}
	bx	lr
	.size	transform, .-transform
	.section	.text.startup,"ax",%progbits
	.align	2
	.global	main
	.type	main, %function
main:
	@ Function supports interworking.
	@ args = 0, pretend = 0, frame = 64
	@ frame_needed = 0, uses_anonymous_args = 0
	stmfd	sp!, {r4, r5, lr}
	ldr	r5, .L20
	sub	sp, sp, #68
.L16:
	ldr	r4, [r5]
	mov	r0, r4
	bl	strlen
	mov	r1, r4
	mov	r2, r0
	mov	r0, #1
	bl	write
	mov	r0, #0
	mov	r1, sp
	mov	r2, #32
	bl	read
	cmp	r0, #2
	mov	r4, r0
	bne	.L13
	ldrb	r3, [sp]	@ zero_extendqisi2
	and	r3, r3, #223
	cmp	r3, #81
	beq	.L18
.L13:
	mov	r0, sp
	add	r1, sp, #32
	mov	r2, r4
	bl	transform
	mov	r0, #1
	add	r1, sp, #32
	mov	r2, r4
	bl	write
.L14:
	cmp	r4, #32
	bne	.L16
	mov	r2, r4
	mov	r0, #0
	mov	r1, sp
	bl	read
	mov	r4, r0
	b	.L14
.L18:
	ldr	r3, .L20
	ldr	r4, [r3, #4]
	mov	r0, r4
	bl	strlen
	mov	r1, r4
	mov	r2, r0
	mov	r0, #1
	bl	write
	mov	r0, #0
	add	sp, sp, #68
	@ sp needed
	ldmfd	sp!, {r4, r5, lr}
	bx	lr
.L21:
	.align	2
.L20:
	.word	.LANCHOR0
	.size	main, .-main
	.global	exit_msg
	.global	input_msg
	.section	.rodata.str1.1,"aMS",%progbits,1
.LC0:
	.ascii	"Exiting...\012\000"
.LC1:
	.ascii	"\012Input a string up to 32-bytes long\012\000"
	.data
	.align	2
.LANCHOR0 = . + 0
	.type	input_msg, %object
	.size	input_msg, 4
input_msg:
	.word	.LC1
	.type	exit_msg, %object
	.size	exit_msg, 4
exit_msg:
	.word	.LC0
	.ident	"GCC: (Debian 4.9.2-10+deb8u2) 4.9.2"
	.section	.note.GNU-stack,"",%progbits