; z80dasm 1.1.3
; command line: z80dasm --labels corvus.bin

	org	00100h

	nop
	nop
	ld a,003h
	out (06ah),a
	out (06bh),a
	xor a
	ld (06011h),a
	ld hl,00000h
	ld (06012h),hl
	call 00074h
	ld a,003h
	out (07eh),a
	call 081afh
	or a
	jr z,l013dh 	;command 0 (reset drive)

	cp 001h
	jr z,l014ch 	;command 1 (format drive)

	cp 032h
	jr z,l0169h 	;command 32h (read firmware block 512 bytes)

	cp 033h
	jr z,l017fh 	;command 33h (write firmware block 512 bytes)

	cp 007h
	jr z,l01a3h 	;command 7 (verify drive)

	ld a,08fh
	ld (06011h),a
	ld hl,00000h
	ld (06012h),hl
	jp 081a0h
l013dh:
	call 000a7h
	ld hl,00000h
	ld (06012h),hl
	call 00074h
	jp 00000h
l014ch:
	ld bc,l0200h
	call 081e9h
	ld de,08200h
	ldir
	ld hl,00000h
	ld (081feh),hl
	call 0003dh
	ld hl,00000h
	ld (06012h),hl
	jp 081a0h
l0169h:
	call 081afh
	ld (081fdh),a
	ld hl,00000h
	ld (081feh),hl
	rst 10h
	ld hl,07600h
	ld (06012h),hl
	jp 081a0h
l017fh:
	ld bc,l0200h+1
	call 081e9h
	ld a,(hl)
	ld (081fdh),a
	ld hl,00000h
	ld (081feh),hl
	rst 20h
	jp nz,081a0h
	ld hl,00001h
	ld (081feh),hl
	rst 20h
	ld hl,00000h
	ld (06012h),hl
	jp 081a0h
l01a3h:
	ld hl,0a201h
	ld (06012h),hl
	xor a
	ld (0a200h),a
	ld (081fdh),a
	ld hl,00000h
	ld (081feh),hl
l01b6h:
	call 080ddh
	call 0810dh
	jr z,l01b6h
	ld hl,0a400h
	ld bc,(0a200h)
	ld b,000h
	inc bc
	or a
	sbc hl,bc
	ex de,hl
	push de
	ld hl,0a200h
	ldir
	pop hl
	ld de,01400h
	add hl,de
	ld (06012h),hl
	jp 081a0h
	call 0000bh
	call 081a9h
	ret nz
	ld a,(081fdh)
	and 0e0h
	call 0813bh
	ld a,(081fdh)
	and 0e0h
	add a,001h
	call 0813bh
	ld a,(081fdh)
	and 0e0h
	add a,002h
	call 0813bh
l0200h:
	ld a,(081fdh)
	and 0e0h
	add a,003h
	call 0813bh
	jp 081a9h
	ld a,(06009h)
	rrca
	rrca
	rrca
	ld b,a
	ld a,(081fdh)
	and 0e0h
	add a,020h
	ld (081fdh),a
	cp b
	jr c,l0238h
	xor a
	ld (081fdh),a
	ld hl,(081feh)
	inc hl
	ld (081feh),hl
	ex de,hl
	ld hl,(06002h)
	or a
	sbc hl,de
	jr nc,l0238h
	or 0ffh
	ret
l0238h:
	jp 000a4h
	ld hl,060cah
	ld b,a
	ld a,014h
	srl a
	srl a
	ld (hl),a
	ld a,b
	ld (081fdh),a
	rst 30h
	call 00013h
	jr nc,l0293h
	rst 10h
	ld hl,(06012h)
	ld a,(081fdh)
	rlc a
	rlc a
	rlc a
	and 007h
	ld (hl),a
	inc hl
	ld bc,(081feh)
	ld (hl),c
	inc hl
	ld (hl),b
	inc hl
	ld a,(081fdh)
	and 01fh
	ld (hl),a
	inc hl
	ld (06012h),hl
	ld a,(0a200h)
	add a,004h
	ld (0a200h),a
	jr nc,l0284h
	ld a,010h
	ld (06015h),a
	jr l02a0h
l0284h:
	ld hl,06200h
	ld de,08200h
	ld bc,l0200h
	ldir
	rst 18h
	call 000a7h
l0293h:
	ld a,(081fdh)
	add a,004h
	ld hl,060cah
	dec (hl)
	jp nz,08147h
	ret
l02a0h:
	ld sp,061edh
	call 00074h
	jp 08015h
	ld a,(06014h)
	cp 0ffh
	ret
	di
	ld a,0c3h
	ld (0480ch),a
	ld hl,081d5h
	ld (0480dh),hl
	in a,(074h)
	call 00077h
	ld a,04fh
	out (06bh),a
	in a,(069h)
	ld a,044h
	out (06bh),a
	ld a,083h
	out (06bh),a
	ld a,0edh
	out (068h),a
	ei
l02d3h:
	jr l02d3h
	ld a,0cdh
	out (068h),a
	ld a,001h
	out (07fh),a
	ld a,003h
	out (06bh),a
	out (06ah),a
	in a,(069h)
	pop hl
	ei
	reti
	ld a,0d5h
	out (068h),a
	jp 0007dh
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	ret m
	ld bc,00000h
	ld (bc),a
	nop
	defb 001h,001h
