; z80dasm 1.1.3
; command line: z80dasm --origin=256 --address --labels --output=prep-corvus-diag.asm prep-corvus-diag.bin

cmd_reset:       equ 00h  ;Reset drive (exit prep mode)
cmd_format_drv:  equ 01h  ;Format drive
cmd_verify_drv:  equ 07h  ;Verify drive
cmd_read_firm:   equ 32h  ;Read a firmware block
cmd_writ_firm:   equ 33h  ;Write a firmare block

    org 8000h

    nop                 ;8000 00
    nop                 ;8001 00

    ld a,03h            ;8002 3e 03
    out (6ah),a         ;8004 d3 6a
    out (6bh),a         ;8006 d3 6b

    xor a               ;8008 af
    ld (6011h),a        ;8009 32 11 60
    ld hl,0000h         ;800c 21 00 00
    ld (6012h),hl       ;800f 22 12 60
    call 0074h          ;8012 cd 74 00

cmd_loop:
    ld a,03h            ;8015 3e 03
    out (7eh),a         ;8017 d3 7e
    call sub_81afh      ;8019 cd af 81

    or a
    jr z,reset_drive    ;Reset drive (exit prep mode)

    cp cmd_format_drv
    jr z,format_drive   ;Format drive

    cp cmd_read_firm
    jr z,read_firm_blk  ;Read a firmware block

    cp cmd_writ_firm
    jr z,writ_firm_blk  ;Write a firmware block

    cp cmd_verify_drv
    jr z,verify_drive   ;Verify drive

    ld a,8fh            ;8Fh = Illegal Command response
    ld (6011h),a        ;8031 32 11 60
    ld hl,0000h         ;8034 21 00 00
    ld (6012h),hl       ;8037 22 12 60
    jp finish_cmd       ;803a c3 a0 81

reset_drive:
;Reset drive (exit prep mode)
;
;Command byte (0x00) has already been read
;No bytes left to read
;
    call 00a7h          ;803d cd a7 00
    ld hl,0000h         ;8040 21 00 00
    ld (6012h),hl       ;8043 22 12 60
    call 0074h          ;8046 cd 74 00
    jp 0000h            ;8049 c3 00 00

format_drive:
;Format drive
;
;Command byte (0x01) has already been read
;512 bytes left to read: format pattern
;
    ld bc,0200h         ;804c 01 00 02
    call sub_81e9h      ;804f cd e9 81
    ld de,8200h         ;8052 11 00 82
    ldir                ;8055 ed b0
    ld hl,0000h         ;8057 21 00 00
    ld (var_2),hl       ;805a 22 fe 81
    call 003dh          ;805d cd 3d 00
    ld hl,0000h         ;8060 21 00 00
    ld (6012h),hl       ;8063 22 12 60
    jp finish_cmd       ;8066 c3 a0 81

read_firm_blk:
;Read a block of Corvus firmware
;
;Command byte (0x32) has already been read
;1 byte left to read: head/sector
;
    call sub_81afh      ;8069 cd af 81
    ld (var_1),a        ;806c 32 fd 81
    ld hl,0000h         ;806f 21 00 00
    ld (var_2),hl       ;8072 22 fe 81
    rst 10h             ;8075 d7
    ld hl,7600h         ;8076 21 00 76
    ld (6012h),hl       ;8079 22 12 60
    jp finish_cmd       ;807c c3 a0 81

writ_firm_blk:
;Write a block of Corvus firmware
;
;Command byte (0x33) has already been read
;513 bytes left to read: 1 byte head/sector, 512 bytes data
;
    ld bc,0201h         ;807f 01 01 02
    call sub_81e9h      ;8082 cd e9 81
    ld a,(hl)           ;8085 7e
    ld (var_1),a        ;8086 32 fd 81
    ld hl,0000h         ;8089 21 00 00
    ld (var_2),hl       ;808c 22 fe 81
    rst 20h             ;808f e7
    jp nz,finish_cmd    ;8090 c2 a0 81
    ld hl,0001h         ;8093 21 01 00
    ld (var_2),hl       ;8096 22 fe 81
    rst 20h             ;8099 e7
    ld hl,0000h         ;809a 21 00 00
    ld (6012h),hl       ;809d 22 12 60
    jp finish_cmd       ;80a0 c3 a0 81

verify_drive:
;Verify drive
;
;Command byte (0x07) has already been read
;No more left bytes to read
;
    ld hl,0a201h        ;80a3 21 01 a2
    ld (6012h),hl       ;80a6 22 12 60
    xor a               ;80a9 af
    ld (0a200h),a       ;80aa 32 00 a2
    ld (var_1),a        ;80ad 32 fd 81
    ld hl,0000h         ;80b0 21 00 00
    ld (var_2),hl       ;80b3 22 fe 81
l80b6h:
    call sub_80ddh      ;80b6 cd dd 80
    call sub_810dh      ;80b9 cd 0d 81
    jr z,l80b6h         ;80bc 28 f8
    ld hl,0a400h        ;80be 21 00 a4
    ld bc,(0a200h)      ;80c1 ed 4b 00 a2
    ld b,00h            ;80c5 06 00
    inc bc              ;80c7 03
    or a                ;80c8 b7
    sbc hl,bc           ;80c9 ed 42
    ex de,hl            ;80cb eb
    push de             ;80cc d5
    ld hl,0a200h        ;80cd 21 00 a2
    ldir                ;80d0 ed b0
    pop hl              ;80d2 e1
    ld de,1400h         ;80d3 11 00 14
    add hl,de           ;80d6 19
    ld (6012h),hl       ;80d7 22 12 60
    jp finish_cmd       ;80da c3 a0 81
sub_80ddh:
    call 000bh          ;80dd cd 0b 00
    call sub_81a9h      ;80e0 cd a9 81
    ret nz              ;80e3 c0
    ld a,(var_1)        ;80e4 3a fd 81
    and 0e0h            ;80e7 e6 e0
    call sub_813bh      ;80e9 cd 3b 81
    ld a,(var_1)        ;80ec 3a fd 81
    and 0e0h            ;80ef e6 e0
    add a,01h           ;80f1 c6 01
    call sub_813bh      ;80f3 cd 3b 81
    ld a,(var_1)        ;80f6 3a fd 81
    and 0e0h            ;80f9 e6 e0
    add a,02h           ;80fb c6 02
    call sub_813bh      ;80fd cd 3b 81
    ld a,(var_1)        ;8100 3a fd 81
    and 0e0h            ;8103 e6 e0
    add a,03h           ;8105 c6 03
    call sub_813bh      ;8107 cd 3b 81
    jp sub_81a9h        ;810a c3 a9 81
sub_810dh:
    ld a,(6009h)        ;810d 3a 09 60
    rrca                ;8110 0f
    rrca                ;8111 0f
    rrca                ;8112 0f
    ld b,a              ;8113 47
    ld a,(var_1)        ;8114 3a fd 81
    and 0e0h            ;8117 e6 e0
    add a,20h           ;8119 c6 20
    ld (var_1),a        ;811b 32 fd 81
    cp b                ;811e b8
    jr c,l8138h         ;811f 38 17
    xor a               ;8121 af
    ld (var_1),a        ;8122 32 fd 81
    ld hl,(var_2)       ;8125 2a fe 81
    inc hl              ;8128 23
    ld (var_2),hl       ;8129 22 fe 81
    ex de,hl            ;812c eb
    ld hl,(6002h)       ;812d 2a 02 60
    or a                ;8130 b7
    sbc hl,de           ;8131 ed 52
    jr nc,l8138h        ;8133 30 03
    or 0ffh             ;8135 f6 ff
    ret                 ;8137 c9
l8138h:
    jp 00a4h            ;8138 c3 a4 00
sub_813bh:
    ld hl,60cah         ;813b 21 ca 60
    ld b,a              ;813e 47
    ld a,14h            ;813f 3e 14
    srl a               ;8141 cb 3f
    srl a               ;8143 cb 3f
    ld (hl),a           ;8145 77
    ld a,b              ;8146 78
l8147h:
    ld (var_1),a        ;8147 32 fd 81
    rst 30h             ;814a f7
    call 0013h          ;814b cd 13 00
    jr nc,l8193h        ;814e 30 43
    rst 10h             ;8150 d7
    ld hl,(6012h)       ;8151 2a 12 60
    ld a,(var_1)        ;8154 3a fd 81
    rlc a               ;8157 cb 07
    rlc a               ;8159 cb 07
    rlc a               ;815b cb 07
    and 07h             ;815d e6 07
    ld (hl),a           ;815f 77
    inc hl              ;8160 23
    ld bc,(var_2)       ;8161 ed 4b fe 81
    ld (hl),c           ;8165 71
    inc hl              ;8166 23
    ld (hl),b           ;8167 70
    inc hl              ;8168 23
    ld a,(var_1)        ;8169 3a fd 81
    and 1fh             ;816c e6 1f
    ld (hl),a           ;816e 77
    inc hl              ;816f 23
    ld (6012h),hl       ;8170 22 12 60
    ld a,(0a200h)       ;8173 3a 00 a2
    add a,04h           ;8176 c6 04
    ld (0a200h),a       ;8178 32 00 a2
    jr nc,l8184h        ;817b 30 07
    ld a,10h            ;817d 3e 10
    ld (6015h),a        ;817f 32 15 60
    jr finish_cmd       ;8182 18 1c
l8184h:
    ld hl,6200h         ;8184 21 00 62
    ld de,8200h         ;8187 11 00 82
    ld bc,0200h         ;818a 01 00 02
    ldir                ;818d ed b0
    rst 18h             ;818f df
    call 00a7h          ;8190 cd a7 00
l8193h:
    ld a,(var_1)        ;8193 3a fd 81
    add a,04h           ;8196 c6 04
    ld hl,60cah         ;8198 21 ca 60
    dec (hl)            ;819b 35
    jp nz,l8147h        ;819c c2 47 81
    ret                 ;819f c9

finish_cmd:
    ld sp,61edh         ;81a0 31 ed 61
    call 0074h          ;81a3 cd 74 00
    jp cmd_loop         ;81a6 c3 15 80

sub_81a9h:
    ld a,(6014h)        ;81a9 3a 14 60
    cp 0ffh             ;81ac fe ff
    ret                 ;81ae c9

sub_81afh:
    di                  ;81af f3
    ld a,0c3h           ;81b0 3e c3
    ld (480ch),a        ;81b2 32 0c 48
    ld hl,l81d5h        ;81b5 21 d5 81
    ld (480dh),hl       ;81b8 22 0d 48
    in a,(74h)          ;81bb db 74
    call 0077h          ;81bd cd 77 00
    ld a,4fh            ;81c0 3e 4f
    out (6bh),a         ;81c2 d3 6b
    in a,(69h)          ;81c4 db 69
    ld a,44h            ;81c6 3e 44
    out (6bh),a         ;81c8 d3 6b
    ld a,83h            ;81ca 3e 83
    out (6bh),a         ;81cc d3 6b
    ld a,0edh           ;81ce 3e ed
    out (68h),a         ;81d0 d3 68
    ei                  ;81d2 fb
l81d3h:
    jr l81d3h           ;81d3 18 fe
l81d5h:
    ld a,0cdh           ;81d5 3e cd
    out (68h),a         ;81d7 d3 68
    ld a,01h            ;81d9 3e 01
    out (7fh),a         ;81db d3 7f
    ld a,03h            ;81dd 3e 03
    out (6bh),a         ;81df d3 6b
    out (6ah),a         ;81e1 d3 6a
    in a,(69h)          ;81e3 db 69
    pop hl              ;81e5 e1
    ei                  ;81e6 fb
    reti                ;81e7 ed 4d

sub_81e9h:
    ld a,0d5h           ;81e9 3e d5
    out (68h),a         ;81eb d3 68
    jp 007dh            ;81ed c3 7d 00

unused:
    db 0,0,0,0,0,0,0,0,0f8h,1,0,0,2

var_1:
    db 0

var_2:
    dw 0101h
