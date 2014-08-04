; z80dasm 1.1.3
; command line: z80dasm --origin=256 --address --labels --output=prep-corvus-diag.asm prep-corvus-diag.bin

pio2:       equ 68h     ;Z80 PIO #2 (U44)
pio2_dra:   equ pio2+0  ;  Data Register A
pio2_drb:   equ pio2+1  ;  Data Register B
pio2_cra:   equ pio2+2  ;  Control Register A
pio2_crb:   equ pio2+3  ;  Control Register B

hsxclr:     equ 74h     ;/HSXCLR

ctc:        equ 7ch     ;Z80 CTC
ctc_ch0:    equ ctc+0   ;  Channel 0 Register
ctc_ch1:    equ ctc+1   ;  Channel 1 Register
ctc_ch2:    equ ctc+2   ;  Channel 2 Register
ctc_ch3:    equ ctc+3   ;  Channel 3 Register

format:          equ 003dh  ;ROM Format the drive
hostread:        equ 007dh  ;ROM Read BC bytes from the host

cmd_reset:       equ 00h  ;Reset drive (exit prep mode)
cmd_format_drv:  equ 01h  ;Format drive
cmd_verify_drv:  equ 07h  ;Verify drive
cmd_read_firm:   equ 32h  ;Read a firmware block
cmd_writ_firm:   equ 33h  ;Write a firmare block

    org 8000h

    nop                 ;8000 00
    nop                 ;8001 00

    ld a,03h            ;8002 3e 03
    out (pio2_cra),a    ;8004 d3 6a
    out (pio2_crb),a    ;8006 d3 6b

                        ;The host is still waiting for a response
                        ;to the "enter prep mode" command.  Send
                        ;the "OK" result byte to the host to
                        ;finish the "enter prep mode" command.

    xor a               ;A = 0 ("OK" result byte)
    ld (6011h),a        ;8009 32 11 60
    ld hl,0000h         ;800c 21 00 00
    ld (6012h),hl       ;800f 22 12 60
    call 0074h          ;8012 cd 74 00

cmd_loop:
    ld a,03h            ;8015 3e 03
    out (ctc_ch2),a     ;8017 d3 7e

    call _read_byte     ;A = read 1 byte from the host

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

                        ;The command is not recognized.  Send the
                        ;"illegal command" result byte and then
                        ;loop to wait for another command.

    ld a,8fh            ;A = 8Fh ("Illegal Command" result byte)
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
    ld bc,0200h         ;BC = 512 bytes to read
    call _read_buf      ;Read BC bytes from the host
    ld de,l8200h        ;8052 11 00 82
    ldir                ;Copy BC bytes from (HL) to (DE)
    ld hl,0000h         ;8057 21 00 00
    ld (l81feh),hl      ;805a 22 fe 81
    call format         ;805d cd 3d 00
    ld hl,0000h         ;8060 21 00 00
    ld (6012h),hl       ;8063 22 12 60
    jp finish_cmd       ;8066 c3 a0 81

read_firm_blk:
;Read a block of Corvus firmware
;
;Command byte (0x32) has already been read
;1 byte left to read: head/sector: head (bits 7-5), sector (bits 4-0)
;
    call _read_byte     ;A = read 1 byte from the host
    ld (head_sec),a     ;806c 32 fd 81
    ld hl,0000h         ;806f 21 00 00
    ld (l81feh),hl      ;8072 22 fe 81
    rst 10h             ;8075 d7
    ld hl,7600h         ;8076 21 00 76
    ld (6012h),hl       ;8079 22 12 60
    jp finish_cmd       ;807c c3 a0 81

writ_firm_blk:
;Write a block of Corvus firmware
;
;Command byte (0x33) has already been read
;513 bytes left to read:
;  1 byte head/sector: head (bits 7-5), sector (bits 4-0)
;  512 bytes data
;
    ld bc,0201h         ;BC = 513 bytes to read
    call _read_buf      ;Read BC bytes from the host
    ld a,(hl)           ;8085 7e
    ld (head_sec),a     ;8086 32 fd 81
    ld hl,0000h         ;8089 21 00 00
    ld (l81feh),hl      ;808c 22 fe 81
    rst 20h             ;808f e7
    jp nz,finish_cmd    ;8090 c2 a0 81
    ld hl,0001h         ;8093 21 01 00
    ld (l81feh),hl      ;8096 22 fe 81
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
    ld (head_sec),a     ;80ad 32 fd 81
    ld hl,0000h         ;80b0 21 00 00
    ld (l81feh),hl      ;80b3 22 fe 81
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
    ld a,(head_sec)     ;80e4 3a fd 81
    and 0e0h            ;80e7 e6 e0
    call sub_813bh      ;80e9 cd 3b 81
    ld a,(head_sec)     ;80ec 3a fd 81
    and 0e0h            ;80ef e6 e0
    add a,01h           ;80f1 c6 01
    call sub_813bh      ;80f3 cd 3b 81
    ld a,(head_sec)     ;80f6 3a fd 81
    and 0e0h            ;80f9 e6 e0
    add a,02h           ;80fb c6 02
    call sub_813bh      ;80fd cd 3b 81
    ld a,(head_sec)     ;8100 3a fd 81
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
    ld a,(head_sec)     ;8114 3a fd 81
    and 0e0h            ;8117 e6 e0
    add a,20h           ;8119 c6 20
    ld (head_sec),a     ;811b 32 fd 81
    cp b                ;811e b8
    jr c,l8138h         ;811f 38 17
    xor a               ;8121 af
    ld (head_sec),a     ;8122 32 fd 81
    ld hl,(l81feh)      ;8125 2a fe 81
    inc hl              ;8128 23
    ld (l81feh),hl      ;8129 22 fe 81
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
    ld (head_sec),a     ;8147 32 fd 81
    rst 30h             ;814a f7
    call 0013h          ;814b cd 13 00
    jr nc,l8193h        ;814e 30 43
    rst 10h             ;8150 d7
    ld hl,(6012h)       ;8151 2a 12 60
    ld a,(head_sec)     ;8154 3a fd 81
    rlc a               ;8157 cb 07
    rlc a               ;8159 cb 07
    rlc a               ;815b cb 07
    and 07h             ;815d e6 07
    ld (hl),a           ;815f 77
    inc hl              ;8160 23
    ld bc,(l81feh)      ;8161 ed 4b fe 81
    ld (hl),c           ;8165 71
    inc hl              ;8166 23
    ld (hl),b           ;8167 70
    inc hl              ;8168 23
    ld a,(head_sec)     ;8169 3a fd 81
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
    ld de,l8200h        ;8187 11 00 82
    ld bc,0200h         ;818a 01 00 02
    ldir                ;Copy BC bytes from (HL) to (DE)
    rst 18h             ;818f df
    call 00a7h          ;8190 cd a7 00
l8193h:
    ld a,(head_sec)     ;8193 3a fd 81
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

_read_byte:
;Read 1 byte from the host, return it in A.
;
    di                  ;81af f3
    ld a,0c3h           ;81b0 3e c3
    ld (480ch),a        ;81b2 32 0c 48
    ld hl,l81d5h        ;81b5 21 d5 81
    ld (480dh),hl       ;81b8 22 0d 48
    in a,(hsxclr)       ;81bb db 74
    call 0077h          ;81bd cd 77 00
    ld a,4fh            ;81c0 3e 4f
    out (pio2_crb),a    ;81c2 d3 6b
    in a,(pio2_drb)     ;81c4 db 69
    ld a,44h            ;81c6 3e 44
    out (pio2_crb),a    ;81c8 d3 6b
    ld a,83h            ;81ca 3e 83
    out (pio2_crb),a    ;81cc d3 6b
    ld a,0edh           ;81ce 3e ed
    out (pio2_dra),a    ;81d0 d3 68
    ei                  ;81d2 fb
l81d3h:
    jr l81d3h           ;81d3 18 fe
l81d5h:
    ld a,0cdh           ;81d5 3e cd
    out (pio2_dra),a    ;81d7 d3 68
    ld a,01h            ;81d9 3e 01
    out (ctc_ch3),a     ;81db d3 7f
    ld a,03h            ;81dd 3e 03
    out (pio2_crb),a    ;81df d3 6b
    out (pio2_cra),a    ;81e1 d3 6a
    in a,(pio2_drb)     ;81e3 db 69
    pop hl              ;81e5 e1
    ei                  ;81e6 fb
    reti                ;81e7 ed 4d

_read_buf:
;Read BC bytes from the host
;
    ld a,0d5h           ;81e9 3e d5
    out (pio2_dra),a    ;81eb d3 68
    jp hostread         ;81ed c3 7d 00

unused:
    db 0,0,0,0,0,0,0

;The locations below are accessed by the ROM and can't be moved.

l81f7h:
    db 0                ;used by ROM at 046eh
l81f8h:
    db 0f8h
l81f9h:
    db 1
l81fah:
    dw 0                ;used by ROM at 0c69h
l81fch:
    db 2                ;used by ROM at 0847h
head_sec:
    db 0                ;head/sector: head (bits 7-5), sector (bits 4-0)
                        ;used by ROM at 0afbh, 0b68h, 0b81h, ...
l81feh:
    dw 0101h            ;used by ROM at 01f4h, 0711h, 0719h, ...

l8200h:
    ;512-byte buffer used to store the format pattern
    ;and for an unknown purpose in the verify command

