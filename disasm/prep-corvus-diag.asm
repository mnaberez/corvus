; z80dasm 1.1.3
; command line: z80dasm --origin=256 --address --labels --output=prep-corvus-diag.asm prep-corvus-diag.bin

cmd_reset:       equ 00h  ;Reset (exit prep mode)
cmd_format_drv:  equ 01h  ;Format drive
cmd_verify_drv:  equ 07h  ;Verify drive
cmd_read_firm:   equ 32h  ;Read a firmware block
cmd_writ_firm:   equ 33h  ;Write a firmare block

    org 0100h

    nop                 ;0100 00
    nop                 ;0101 00
    ld a,03h            ;0102 3e 03
    out (6ah),a         ;0104 d3 6a
    out (6bh),a         ;0106 d3 6b
    xor a               ;0108 af
    ld (6011h),a        ;0109 32 11 60
    ld hl,0000h         ;010c 21 00 00
    ld (6012h),hl       ;010f 22 12 60
    call 0074h          ;0112 cd 74 00
    ld a,03h            ;0115 3e 03
    out (7eh),a         ;0117 d3 7e
    call 81afh          ;0119 cd af 81
    or a
    jr z,reset          ;Reset drive (exit prep mode)
    cp cmd_format_drv
    jr z,format_drive   ;Format drive
    cp cmd_read_firm
    jr z,read_firm_blk  ;Read a firmware block
    cp cmd_writ_firm
    jr z,writ_firm_blk  ;Write a firmware block
    cp cmd_verify_drv
    jr z,verify_drive   ;Verify drive
    ld a,8fh            ;012f 3e 8f
    ld (6011h),a        ;0131 32 11 60
    ld hl,0000h         ;0134 21 00 00
    ld (6012h),hl       ;0137 22 12 60
    jp 81a0h            ;013a c3 a0 81

reset:
    call 00a7h          ;013d cd a7 00
    ld hl,0000h         ;0140 21 00 00
    ld (6012h),hl       ;0143 22 12 60
    call 0074h          ;0146 cd 74 00
    jp 0000h            ;0149 c3 00 00

format_drive:
    ld bc,l0200h        ;014c 01 00 02
    call 81e9h          ;014f cd e9 81
    ld de,8200h         ;0152 11 00 82
    ldir                ;0155 ed b0
    ld hl,0000h         ;0157 21 00 00
    ld (81feh),hl       ;015a 22 fe 81
    call 003dh          ;015d cd 3d 00
    ld hl,0000h         ;0160 21 00 00
    ld (6012h),hl       ;0163 22 12 60
    jp 81a0h            ;0166 c3 a0 81

read_firm_blk:
    call 81afh          ;0169 cd af 81
    ld (81fdh),a        ;016c 32 fd 81
    ld hl,0000h         ;016f 21 00 00
    ld (81feh),hl       ;0172 22 fe 81
    rst 10h             ;0175 d7
    ld hl,7600h         ;0176 21 00 76
    ld (6012h),hl       ;0179 22 12 60
    jp 81a0h            ;017c c3 a0 81

writ_firm_blk:
    ld bc,l0200h+1      ;017f 01 01 02
    call 81e9h          ;0182 cd e9 81
    ld a,(hl)           ;0185 7e
    ld (81fdh),a        ;0186 32 fd 81
    ld hl,0000h         ;0189 21 00 00
    ld (81feh),hl       ;018c 22 fe 81
    rst 20h             ;018f e7
    jp nz,81a0h         ;0190 c2 a0 81
    ld hl,0001h         ;0193 21 01 00
    ld (81feh),hl       ;0196 22 fe 81
    rst 20h             ;0199 e7
    ld hl,0000h         ;019a 21 00 00
    ld (6012h),hl       ;019d 22 12 60
    jp 81a0h            ;01a0 c3 a0 81

verify_drive:
    ld hl,0a201h        ;01a3 21 01 a2
    ld (6012h),hl       ;01a6 22 12 60
    xor a               ;01a9 af
    ld (0a200h),a       ;01aa 32 00 a2
    ld (81fdh),a        ;01ad 32 fd 81
    ld hl,0000h         ;01b0 21 00 00
    ld (81feh),hl       ;01b3 22 fe 81
l01b6h:
    call 80ddh          ;01b6 cd dd 80
    call 810dh          ;01b9 cd 0d 81
    jr z,l01b6h         ;01bc 28 f8
    ld hl,0a400h        ;01be 21 00 a4
    ld bc,(0a200h)      ;01c1 ed 4b 00 a2
    ld b,00h            ;01c5 06 00
    inc bc              ;01c7 03
    or a                ;01c8 b7
    sbc hl,bc           ;01c9 ed 42
    ex de,hl            ;01cb eb
    push de             ;01cc d5
    ld hl,0a200h        ;01cd 21 00 a2
    ldir                ;01d0 ed b0
    pop hl              ;01d2 e1
    ld de,1400h         ;01d3 11 00 14
    add hl,de           ;01d6 19
    ld (6012h),hl       ;01d7 22 12 60
    jp 81a0h            ;01da c3 a0 81
    call 000bh          ;01dd cd 0b 00
    call 81a9h          ;01e0 cd a9 81
    ret nz              ;01e3 c0
    ld a,(81fdh)        ;01e4 3a fd 81
    and 0e0h            ;01e7 e6 e0
    call 813bh          ;01e9 cd 3b 81
    ld a,(81fdh)        ;01ec 3a fd 81
    and 0e0h            ;01ef e6 e0
    add a,01h           ;01f1 c6 01
    call 813bh          ;01f3 cd 3b 81
    ld a,(81fdh)        ;01f6 3a fd 81
    and 0e0h            ;01f9 e6 e0
    add a,02h           ;01fb c6 02
    call 813bh          ;01fd cd 3b 81
l0200h:
    ld a,(81fdh)        ;0200 3a fd 81
    and 0e0h            ;0203 e6 e0
    add a,03h           ;0205 c6 03
    call 813bh          ;0207 cd 3b 81
    jp 81a9h            ;020a c3 a9 81
    ld a,(6009h)        ;020d 3a 09 60
    rrca                ;0210 0f
    rrca                ;0211 0f
    rrca                ;0212 0f
    ld b,a              ;0213 47
    ld a,(81fdh)        ;0214 3a fd 81
    and 0e0h            ;0217 e6 e0
    add a,20h           ;0219 c6 20
    ld (81fdh),a        ;021b 32 fd 81
    cp b                ;021e b8
    jr c,l0238h         ;021f 38 17
    xor a               ;0221 af
    ld (81fdh),a        ;0222 32 fd 81
    ld hl,(81feh)       ;0225 2a fe 81
    inc hl              ;0228 23
    ld (81feh),hl       ;0229 22 fe 81
    ex de,hl            ;022c eb
    ld hl,(6002h)       ;022d 2a 02 60
    or a                ;0230 b7
    sbc hl,de           ;0231 ed 52
    jr nc,l0238h        ;0233 30 03
    or 0ffh             ;0235 f6 ff
    ret                 ;0237 c9
l0238h:
    jp 00a4h            ;0238 c3 a4 00
    ld hl,60cah         ;023b 21 ca 60
    ld b,a              ;023e 47
    ld a,14h            ;023f 3e 14
    srl a               ;0241 cb 3f
    srl a               ;0243 cb 3f
    ld (hl),a           ;0245 77
    ld a,b              ;0246 78
    ld (81fdh),a        ;0247 32 fd 81
    rst 30h             ;024a f7
    call 0013h          ;024b cd 13 00
    jr nc,l0293h        ;024e 30 43
    rst 10h             ;0250 d7
    ld hl,(6012h)       ;0251 2a 12 60
    ld a,(81fdh)        ;0254 3a fd 81
    rlc a               ;0257 cb 07
    rlc a               ;0259 cb 07
    rlc a               ;025b cb 07
    and 07h             ;025d e6 07
    ld (hl),a           ;025f 77
    inc hl              ;0260 23
    ld bc,(81feh)       ;0261 ed 4b fe 81
    ld (hl),c           ;0265 71
    inc hl              ;0266 23
    ld (hl),b           ;0267 70
    inc hl              ;0268 23
    ld a,(81fdh)        ;0269 3a fd 81
    and 1fh             ;026c e6 1f
    ld (hl),a           ;026e 77
    inc hl              ;026f 23
    ld (6012h),hl       ;0270 22 12 60
    ld a,(0a200h)       ;0273 3a 00 a2
    add a,04h           ;0276 c6 04
    ld (0a200h),a       ;0278 32 00 a2
    jr nc,l0284h        ;027b 30 07
    ld a,10h            ;027d 3e 10
    ld (6015h),a        ;027f 32 15 60
    jr l02a0h           ;0282 18 1c
l0284h:
    ld hl,6200h         ;0284 21 00 62
    ld de,8200h         ;0287 11 00 82
    ld bc,l0200h        ;028a 01 00 02
    ldir                ;028d ed b0
    rst 18h             ;028f df
    call 00a7h          ;0290 cd a7 00
l0293h:
    ld a,(81fdh)        ;0293 3a fd 81
    add a,04h           ;0296 c6 04
    ld hl,60cah         ;0298 21 ca 60
    dec (hl)            ;029b 35
    jp nz,8147h         ;029c c2 47 81
    ret                 ;029f c9
l02a0h:
    ld sp,61edh         ;02a0 31 ed 61
    call 0074h          ;02a3 cd 74 00
    jp 8015h            ;02a6 c3 15 80
    ld a,(6014h)        ;02a9 3a 14 60
    cp 0ffh             ;02ac fe ff
    ret                 ;02ae c9

    di                  ;02af f3
    ld a,0c3h           ;02b0 3e c3
    ld (480ch),a        ;02b2 32 0c 48
    ld hl,81d5h         ;02b5 21 d5 81
    ld (480dh),hl       ;02b8 22 0d 48
    in a,(74h)          ;02bb db 74
    call 0077h          ;02bd cd 77 00
    ld a,4fh            ;02c0 3e 4f
    out (6bh),a         ;02c2 d3 6b
    in a,(69h)          ;02c4 db 69
    ld a,44h            ;02c6 3e 44
    out (6bh),a         ;02c8 d3 6b
    ld a,83h            ;02ca 3e 83
    out (6bh),a         ;02cc d3 6b
    ld a,0edh           ;02ce 3e ed
    out (68h),a         ;02d0 d3 68
    ei                  ;02d2 fb
l02d3h:
    jr l02d3h           ;02d3 18 fe
    ld a,0cdh           ;02d5 3e cd
    out (68h),a         ;02d7 d3 68
    ld a,01h            ;02d9 3e 01
    out (7fh),a         ;02db d3 7f
    ld a,03h            ;02dd 3e 03
    out (6bh),a         ;02df d3 6b
    out (6ah),a         ;02e1 d3 6a
    in a,(69h)          ;02e3 db 69
    pop hl              ;02e5 e1
    ei                  ;02e6 fb
    reti                ;02e7 ed 4d
    ld a,0d5h           ;02e9 3e d5
    out (68h),a         ;02eb d3 68
    jp 007dh            ;02ed c3 7d 00
    nop                 ;02f0 00
    nop                 ;02f1 00
    nop                 ;02f2 00
    nop                 ;02f3 00
    nop                 ;02f4 00
    nop                 ;02f5 00
    nop                 ;02f6 00
    nop                 ;02f7 00
    ret m               ;02f8 f8
    ld bc,0000h         ;02f9 01 00 00
    ld (bc),a           ;02fc 02
    nop                 ;02fd 00
    defb 01h,001h       ;02fe 01 01
