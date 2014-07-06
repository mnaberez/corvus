; z80dasm 1.1.3
; command line: z80dasm --labels hardbox.bin

	org	00100h

	ld a,003h
	out (06ah),a
	out (06bh),a
	ld hl,00000h
	ld (06012h),hl
	call 00074h
	ld a,003h
	out (07eh),a
	ld bc,00001h
	call 0007dh
	ld a,(hl)
	or a
	jr z,l012dh  ; command 0 (reset drive)

	cp 001h
	jr z,l013ch  ; command 1 (format drive)

	cp 032h
	jr z,l0153h  ; command 32h (read firmware block 512 bytes)

	cp 033h
	jr z,l016ah  ; command 33h (write firmware block 512 bytes)

	cp 007h
	jr z,l018eh  ; command 7 (verify drive)

;reset drive
l012dh:
	call 000a7h
	ld hl,00000h
	ld (06012h),hl
	call 00074h
	jp 00000h

;format drive
l013ch:
	ld bc,l0200h
	call 0007dh
	ld de,08200h
	ldir
	call 0003dh
	ld hl,00000h
	ld (06012h),hl
	jp 0818ah

;read sector 512 bytes
l0153h:
	ld bc,00001h
	call 0007dh
	ld a,(hl)
	ld b,004h
	ld c,a
	ld de,08061h
	rst 28h
	ld hl,0b600h
	ld (06012h),hl
	jp 0818ah

;write sector 512 bytes
l016ah:
	ld bc,l0200h+1
	call 0007dh
	ld a,(hl)
	ld (081fdh),a
	ld hl,00000h
	ld (081feh),hl
	rst 20h
	jp nz,0818ah
	ld hl,00001h
	ld (081feh),hl
	rst 20h
	ld hl,00000h
	ld (06012h),hl
	jp 0818ah

;verify drive
l018eh:
	ld hl,0a201h
	ld (06012h),hl
	ld a,000h
	ld (0a200h),a
	xor a
	ld (081fdh),a
	ld hl,00000h
	ld (081feh),hl
l01a3h:
	call 080cah
	call 080e8h
	jr z,l01a3h
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
	jp 0818ah
	call 0000bh
	call 08193h
	ret nz
	ld a,(081fdh)
	and 0e0h
	ld c,000h
	call 08116h
	ld a,(081fdh)
	and 0e0h
	add a,001h
	call 08116h
	jp 08193h
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
	jr c,l0213h
	xor a
	ld (081fdh),a
l0200h:
	ld hl,(081feh)
	inc hl
	ld (081feh),hl
	ex de,hl
	ld hl,(06002h)
	or a
	sbc hl,de
	jr nc,l0213h
	or 0ffh
	ret
l0213h:
	jp 000a4h
	ld hl,060cah
	ld b,a
	ld a,014h
	srl a
	ld (hl),a
	ld a,b
	ld (081fdh),a
	rst 30h
	call 00013h
	jr nc,l027dh
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
	jr nc,l0258h
	pop hl
	pop hl
	jp 080abh
l0258h:
	ld (0a200h),a
	ld hl,06200h
	ld de,08200h
	ld bc,l0200h
	ldir
	rst 18h
	call 000a7h
	ld a,(081fdh)
	add a,002h
	ld (081fdh),a
	ld hl,060cah
	dec (hl)
	ret z
	ld a,(081fdh)
	jp 08120h
l027dh:
	ld a,(081fdh)
	add a,002h
	ld hl,060cah
	dec (hl)
	jp nz,08120h
	ret
	ld sp,061edh
	call 00074h
	jp 0800fh
	ld a,(06014h)
	cp 0ffh
	ret
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	and d
	ld bc,00000h
	ld (bc),a
	nop
	ld bc,00001h
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
