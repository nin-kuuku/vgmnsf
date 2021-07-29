;       VGM NSF player by nin-kuuku 2015
;-----------------------------------------------------------------------------
;Byte10: 03= channel setup
;            0 = automatic
;            1 = psg0=triangle, psg1=pulse0,   psg2=pulse1
;            2 = psg0=pulse0,   psg1=triangle, psg2=pulse1
;            3 = psg0=pulse0,   psg1=pulse1,   psg2=triangle
;        04= drop triangle by octave
;        08= drop pulse 0 by octave
;        10= drop pulse 1 by octave
;        60= unused for now
;        80= drop whole song 5 semitones
;
;Byte11: 0F= triangle gate
;        F0= dac amp
;
;Byte12: 0F= pulse0_amp
;        F0= pulse0_duty
;
;Byte13: 0F= pulse1_amp
;        F0= pulse1_duty
;
;Byte14: 0F= noise_h
;        F0= noise_m
;
;Byte15: 0F= noise_l
;        F0= noise_amp
;
;Byte16: 0F= genpulse0
;        F0= genpulse1
;
;Byte17: 0F= gentriangle
;        F0= gendrums
;
;Byte18: 0F= genpulse3
;        F0= genpulse2
;
;Byte19: 0F= backpulse0ampredu
;        F0= backpulse0duty
;
;Byte1A: 0F= backpulse1ampredu
;        F0= backpulse1duty
;
;Byte1B: 0F= kickfrq
;
;Byte1C: F0= snarefrq
;
;Byte1D: 0F= htomfrq
;
;Byte1E: F0= ltomfrq
;
;Byte1F: unused for now
;
postpone {
        if $ > $108000                                  
        display       "too large is the nsf file"
        display 13,10,"1024k is the limit"
        err
        end if
}

macro makenes {
        .pad $107ff2
        lda!    7
        sta     5fffh
        jmp     $f000
.dw $fff2,$fff2,$fff2
}

macro vgmset    op0=0, op1=0, op2=8, op3=2, op4=2, op5=0, op6=0, op7=0,\
                op8=$d, op9=$b, op10=$9, op11=0, op12=0, op13=0, op14=0,\
                op15=2, op16=4, op17=1, op18=0, op19=3, op20=5 ,\
                op21=1, op22=1, op23=3 , op24=3,\
                op25=$2b , op26=$17 , op27=$dd, op28=$8c  {

psg_drop= #op0

triangle_psg= #op1
triangle_gate= #op2

pulse0_duty= #op3
pulse1_duty= #op4

triangle_oct= #op5
pulse0_oct= #op6
pulse1_oct= #op7

noise_l= #op8
noise_m= #op9
noise_h= #op10

pulse0_amp= #op11
pulse1_amp= #op12
noise_amp= #op13
dac_amp= #op14

genpulse0= #op15
genpulse1= #op16
gentriangle= #op17
gendrums= #op18
genpulse2= #op19
genpulse3= #op20

backpulse0duty = #op21
backpulse1duty = #op22
backpulse0ampredu = #op23
backpulse1ampredu = #op24

kickfrq= #op25
snarefrq=#op26
htomfrq= #op27
ltomfrq= #op28

}

vgmset
if defined sunsoftMSX
        stb     $20, nsfheader:+$7b
else if defined vrc6audio
        stb     $01, nsfheader:+$7b
else if defined vrc7audio
        stb     $02, nsfheader:+$7b
end if

macro vgm vgm, op0 {
        lddw    mag, vgm,$00
if mag <> "Vgm "
        display       "not vgm: ", vgm
if (mag and $ffff) = $8b1f
        display 13,10, "zipped vgm (vgz): ", vgm
end if
end if
align $100
        stb ((($-$8000) shr 12) and $fe),     songbanks+songcounter
        stb ((($-$8000) shr 8) and $1f) + $a0,     songpages+songcounter

        songcounter = songcounter + 1
if defined nsfheader
        stb     songcounter, nsfheader:+$06
else
        stb     songcounter, nessongnumber
end if
;vgm version
        ldw     ver, vgm,$08
if ver > $0161
        hea = $100
else if ver > $0160
        hea = $c0
else if ver > $0150
        hea = $80
else
        hea = $40
end if
        nessyheader = $20
;entry
        lddw    a, vgm,$34
        o = ($ + nessyheader + a + $34) - ($8000 + hea)
        stb     o and $ff
        stb     ((o shr 8) and $1f) + $a0
        stb     (o shr 12) and $fe
     ;   stb     0
;loop address
        lddw    a, vgm,$1c
if a > 0
        o = ($ + nessyheader + a + $1c) - ($8000 + hea)
else
        o = 0
end if
        stb     o and $ff
        stb     ((o shr 8) and $1f) + $a0
        stb     (o shr 12) and $fe
     ;   stb     0
; system
if hea > $80
        lddw    gen, vgm,$2c
        lddw    msx, vgm,$74
        lddw    dmg, vgm,$80
        lddw    nes, vgm,$84
        lddw    pce, vgm,$a4
else if hea > $40
        lddw    gen, vgm,$2c
        lddw    msx, vgm,$74
        dmg = 0
        nes = 0
        pce = 0
else
        msx = 0
        dmg = 0
        nes = 0
        pce = 0
end if
        lddw    gen, vgm,$2c
;        lddw    ym2, vgm,$10
        lddw    sms, vgm,$0c

if gen > 0
        stb     5
else if sms > 0
        stb     1
else if msx > 0
        stb     2
else if dmg > 0
        stb     3
else if nes > 0
        stb     4
else if pce > 0
        stb     6
;else if ym2 > 0
;        stb     7
else
        stb     0
        display "unsupported:",vgm
end if
;pad $09-$0f
db                0, 0,0,0,0, 0,0,0,0
;pad
if op0 eq
db (triangle_psg)\
   or (triangle_oct shl 2)\
   or (pulse0_oct shl 3)\
   or (pulse1_oct shl 4)\
   or (psg_drop shl 7)
else
db op0
end if

db (dac_amp shl 4) or (triangle_gate)
db (pulse0_duty shl 4) or (pulse0_amp )
db (pulse1_duty shl 4) or (pulse1_amp )

db (noise_m shl 4) or (noise_h)
db (noise_amp shl 4) or (noise_l)
db (genpulse1 shl 4) or (genpulse0)
db (gendrums shl 4) or (gentriangle)

db (genpulse2 shl 4) or (genpulse3)
db (backpulse0duty shl 4) or (backpulse0ampredu)
db (backpulse1duty shl 4) or (backpulse1ampredu)
db kickfrq

db snarefrq
db htomfrq
db ltomfrq
db 0

file `vgm : hea
}
;=============================================================================
;       MEMMAP

psgmem = $70
vgmsetup = $c0
genesis0 = $600
genesis1 = $700
genesis0trig = $6f0
genesis1trig = $7f0
genesismem = $400
msxmem= $50
gameboymem= $400
pcemem= $400

tmp0 = 0
tmp1 = 1
tmp2 = 2
tmp3 = 3
tmp4 = 4
tmp5 = 5
tmp6 = 6
tmp7 = 7
tmpw = 8
l_tmpw = 8
h_tmpw = 9

vgmptr = 10
songbank= 12
vgmtim = 13

nsfbank= 17

songnumber=19

nmi_inc = $ff

apumem  = $60
apu00   = apumem+0
apu02   = apumem+1
apu03   = apumem+2
apu03l  = apumem+3
apu10   = apumem+4
apu12   = apumem+5
apu13   = apumem+6
apu13l  = apumem+7
aput0   = apumem+8
aput2   = apumem+9
aput3   = apumem+10
aput3l  = apumem+11
apun0   = apumem+12
apun2   = apumem+13

virtual at gameboymem
        nr1len  db ?
        nr2len  db ?
        nr3len  db ?
        nr4len  db ?

        nr1env  db ?
        nr2env  db ?
        nr4env  db ?

        nr1envc db ?
        nr2envc db ?
        nr4envc db ?

        nr1amp  db ?
        nr2amp  db ?
        nr4amp  db ?

        nr1envl db ?
        nr2envl db ?

end virtual




virtual at psgmem
        psg0f   dw ?
        psg0v   dw ?
        psg1f   dw ?
        psg1v   dw ?
        psg2f   dw ?
        psg2v   dw ?
        psg3f   dw ?
        psg3v   dw ?
        psg0fbuf        dw ?
        psg0vbuf        dw ?
        psg1fbuf        dw ?
        psg1vbuf        dw ?
        psg2fbuf        dw ?
        psg2vbuf        dw ?
        psg3fbuf        dw ?
        psg3vbuf        dw ?
        psgptr          dw ?
end virtual


virtual at vgmsetup
        vgmentry        rb 3
        vgmloop         rb 3
        vgmsystem       db ?
                        db ?

                        db ?
                        db ?
        samplecount     dw ?

                        db ?
                        db ?
                        db ?
                        db ?

        psgdrop         db ?
        trich           db ?
        trigate         db ?
        apuoctt         db ?

        apuam0          db ?
        apudt0          db ?
        apu0fl          db ?
        apuoct0         db ?

        apuam1          db ?
        apudt1          db ?
        apu1fl          db ?
        apuoct1         db ?

        apuamn          db ?
                        db ?
                        db ?
                        db ?

        genp0           db ?
        genp1           db ?
        gentri          db ?
        gendmc          db ?

        backp0          db ?
        backp1          db ?
        backpdt0        db ?
        backpdt1        db ?

        backamp0        db ?
        backamp1        db ?
        gendmcfrq       rb 4

        noisetfrq       db $84,$86,$89,$0, $09,$0b,$0d,$0
end virtual

virtual at genesismem
        genesisfrq0l    db ?
        genesisfrq1l    db ?
        genesisfrq2l    db ?
        genesisfrq3l    db ?
        genesisfrq4l    db ?
        genesisfrq5l    db ?
        genesisfrq0h    db ?
        genesisfrq1h    db ?
        genesisfrq2h    db ?
        genesisfrq3h    db ?
        genesisfrq4h    db ?
        genesisfrq5h    db ?
        genesistrig0    db ?
        genesistrig1    db ?
        genesistrig2    db ?
        genesistrig3    db ?
        genesistrig4    db ?
        genesistrig5    db ?
        genesistl0      db ?
        genesistl1      db ?
        genesistl2      db ?
        genesistl3      db ?
        genesistl4      db ?
        genesistl5      db ?
        genpcm          rb 4
end virtual

;=============================================================================
;       ROM
.org $8000

init_nsf:     ;  incne   apu1fl
              ;  lda     songnumber
                sta     songnumber
       .td:
             ;   movw!   vgmptr, $a040
                mov     psgptr, !0
                ld      <4001h, 4005h>, !08
                mov     4015h, !0f
                if defined vrc6audio
;                        mov     5015h, !01
                         mov     9003h, !00
                end if
                ldy     songnumber
                lda     songbanks+y
                sta     5ffah, nsfbank
                or      !1
                sta     5ffbh
                lda     !00
                sta     l_tmpw
                lda     songpages+y
                sta     h_tmpw

                ldy     !06
              @ mov     vgmsetup+zy, (tmpw)+y
                dey
                bpl @b

                ldy     !10
                lda     (tmpw)+y
                sta     x
                and     !03
                stanz   trich
                ld      apuoctt, x, and !04, shl4
                ld      apuoct0, x, and !08, shl3
                ld      apuoct1, x, and !10, shl2
                ld      psgdrop, x, and !80

                iny
                ld      trigate, (tmpw)+y, and !0f
                ld      4011h, (tmpw)+y, and !f0, shr
                iny
                ld      apudt0, (tmpw)+y, and !f0
                ld      apuam0, (tmpw)+y, and !0f
                iny
                ld      apudt1, (tmpw)+y, and !f0
                ld      apuam1, (tmpw)+y, and !0f
                iny
                mov     noisetfrq+0, !84
                mov     noisetfrq+1, !86
                mov     noisetfrq+2, !89
                ld      noisetfrq+4, (tmpw)+y, and !0f
                ld      noisetfrq+5, (tmpw)+y, shr4
                iny
                ld      noisetfrq+6, (tmpw)+y, and !0f
                ld      apuamn,      (tmpw)+y, shr4
                iny
                ld      genp1, (tmpw)+y, shr4
                ld      genp0, (tmpw)+y, and !0f
                iny
                ld      gendmc, (tmpw)+y, shr4
                ld      gentri, (tmpw)+y, and !0f
                iny
                ld      backp1, (tmpw)+y, shr4
                ld      backp0, (tmpw)+y, and !0f
                iny
                ld      backpdt0, (tmpw)+y, and !f0
                ld      backamp0, (tmpw)+y, and !0f
                iny
                ld      backpdt1, (tmpw)+y, and !f0
                ld      backamp1, (tmpw)+y, and !0f
                iny
                mov     gendmcfrq+0, (tmpw)+y, iny
                mov     gendmcfrq+1, (tmpw)+y, iny
                mov     gendmcfrq+2, (tmpw)+y, iny
                mov     gendmcfrq+3, (tmpw)+y


                mov     vgmptr,   vgmentry+0
                mov     1+vgmptr, vgmentry+1
                lda     vgmentry+2
                sta     5ffah, nsfbank
                or      !1
                sta     5ffbh

                mov     <psg0v,psg1v,psg2v,psg3v>, !0f

               ;jsr     initvrc7

                ldy     vgmptr
                ld      <vgmptr, vgmtim>,  !0

                lda     vgmsystem
                cmp     !02
                beq @f
                cmp     !01
                bne .skp
              @ dec     trich
                jmpmi   test_vgm

          .skp: jsr     readvgm
                rts
;------------------------------------------------------------------------------
;       main loop

play_nsf:       if defined blastprosessing
                jsr .h
                end if
.h:             lda     vgmsystem
                ;rtseq

                cmp     !01
                beq     .mastersystem
                cmp     !02
                beq     .spectrum
                cmp     !03
                beq     .gameboy
                cmp     !04
                beq     frame
                cmp     !05
                beq     .genesis
                cmp     !06
                beq     .pcengine
           ;     cmp     !07 ;vrc7
           ;     beq     frame
                jmp     frame


.gameboy:       jsr     gameboy
                jmp     frame

.spectrum:      jsr     spectrum
                jmp     frame

.mastersystem:  jsr     psgapu
                jmp     frame

.genesis:       jsr     nintendoes_what_genesis_does
                jmp     frame

.pcengine:      jsr     turbografx16
                jmp     frame

frame:          dec     vgmtim
                bpl     .done

                ldy     vgmptr
                lda     !0
                sta     vgmptr, vgmtim
                jsr     readvgm
.done:          rts
;------------------------------------------------------------------------------
test_vgm:       movw!   $30c, 666
        .loop:  jsr     readvgm
                lda     vgmsystem
                cmp     !01
                beq .sms
                jsr     msxadd
                jmp @f
        .sms:   jsr     smsadd
              @ decw    $30c
                bnz     .loop
                mov!    $311,2
                ldx!    $2
                ldy!    $6
                jsr     cmpfrq
                bze .skp
                ldx!    $2
                ldy!    $a
                jsr     cmpfrq
                bze @f
                mov!    trich,1
                jmp     init_nsf.td
              @ mov!    trich,3
                jmp     init_nsf.td
          .skp: ldx!    $6
                ldy!    $a
                jsr     cmpfrq
                bze @f
                mov!    trich,2
                jmp     init_nsf.td
              @ mov!    trich,3
                jmp     init_nsf.td

cmpfrq:         lda     $300+x
                cmp     $300+y
                blo     .done1
                bne     .done2
                dex
                dey
                lda     $300+x
                cmp     $300+y
                blo     .done1
                bne     .done2
                dex
                dey
                lda     $300+x
                cmp     $300+y
                blo     .done1
.done2:         lda!    1
                rts
.done1:         lda!    0
                rts

msxadd:         addw    $300, msxmem+0
                inccs   $302
                addw    $304, msxmem+2
                inccs   $306
                addw    $308, msxmem+4
                inccs   $30a
                rts

smsadd:         addw    $300, psg0f
                inccs   $302
                addw    $304, psg1f
                inccs   $306
                addw    $308, psg2f
                inccs   $30a
                rts

;------------------------------------------------------------------------------
endofdata:    ;  ldx     songnumber
              ;  mov     5ffah, songbanks+x
              ;  lda     $a006
                lda     vgmloop+2
                bnz     .loopysong

.end_song:      sta     4015h, vgmsystem
                if defined vrc6audio
                        ;sta     5015h
                        mov     9003h,!01
                end if
                pla2
                rts

.loopysong:  ;  and     !fe
                sta     5ffah, nsfbank
                or      !1
                sta     5ffbh

                ld      vgmptr,   vgmloop+0
                ld      1+vgmptr, vgmloop+1

                ldy     vgmptr
                st      !0, vgmptr, vgmtim
                jmp     readvgm

;#############################################################################
;       vgm reader

@wy equ (vgmptr)+y
macro   incptr                  {
        iny
        jsrze   incptrpage      }
macro   readend                 {
        sty     vgmptr
        rts                     }
macro   readnext                {
        jmp     readvgm         }
conditional 0, incptr, readend, readnext
macro   unused [lab] {#lab:     }

align 256
.lohi tbl_vgm_commands\
,_opc_wtf!      ,_opc_wtf!      ,_opc_wtf!      ,_opc_wtf!      \
,_opc_wtf!      ,_opc_wtf!      ,_opc_wtf!      ,_opc_wtf!      \
,_opc_wtf!      ,_opc_wtf!      ,_opc_wtf!      ,_opc_wtf!      \
,_opc_wtf!      ,_opc_wtf!      ,_opc_wtf!      ,_opc_wtf!      \
,_opc_wtf!      ,_opc_wtf!      ,_opc_wtf!      ,_opc_wtf!      \
,_opc_wtf!      ,_opc_wtf!      ,_opc_wtf!      ,_opc_wtf!      \
,_opc_wtf!      ,_opc_wtf!      ,_opc_wtf!      ,_opc_wtf!      \
,_opc_wtf!      ,_opc_wtf!      ,_opc_wtf!      ,_opc_wtf!      \
,_opc_wtf!      ,_opc_wtf!      ,_opc_wtf!      ,_opc_wtf!      \
,_opc_wtf!      ,_opc_wtf!      ,_opc_wtf!      ,_opc_wtf!      \
,_opc_wtf!      ,_opc_wtf!      ,_opc_wtf!      ,_opc_wtf!      \
,_opc_wtf!      ,_opc_wtf!      ,_opc_wtf!      ,_opc_wtf!      \
,opc30_3f       ,opc30_3f       ,opc30_3f       ,opc30_3f       \
,opc30_3f       ,opc30_3f       ,opc30_3f       ,opc30_3f       \
,opc30_3f       ,opc30_3f       ,opc30_3f       ,opc30_3f       \
,opc30_3f       ,opc30_3f       ,opc30_3f       ,opc30_3f       \
,opc40_4e       ,opc40_4e       ,opc40_4e       ,opc40_4e       \
,opc40_4e       ,opc40_4e       ,opc40_4e       ,opc40_4e       \
,opc40_4e       ,opc40_4e       ,opc40_4e       ,opc40_4e       \
,opc40_4e       ,opc40_4e       ,opc40_4e       ,opc4f_gg       \
,opc50_psg      ,opc51_ym2413   ,opc52_ym2612_0 ,opc53_ym2612_1 \
,opc54_ym2151   ,opc55_ym2203   ,opc56_ym2608_0 ,opc57_ym2608_1 \
,opc58_ym2610_0 ,opc59_ym2610_1 ,opc5a_ym3812   ,opc5b_ym3526   \
,opc5c_y8950    ,opc5d_ymz280b  ,opc5e_ymf262_0 ,opc5f_ymf262_1 \
,_opc_wtf!      ,opc61_wait     ,opc62_wait_ntsc,opc63_wait_pal \
,opc64_not_sure ,_opc_wtf!      ,opc66_end_data ,opc67_datablock\
,opc68_pcmram   ,_opc_wtf!      ,_opc_wtf!      ,_opc_wtf!      \
,_opc_wtf!      ,_opc_wtf!      ,_opc_wtf!      ,_opc_wtf!      \
,opc70_7f       ,opc70_7f       ,opc70_7f       ,opc70_7f       \
,opc70_7f       ,opc70_7f       ,opc70_7f       ,opc70_7f       \
,opc70_7f       ,opc70_7f       ,opc70_7f       ,opc70_7f       \
,opc70_7f       ,opc70_7f       ,opc70_7f       ,opc70_7f       \
,opc80_8f       ,opc80_8f       ,opc80_8f       ,opc80_8f       \
,opc80_8f       ,opc80_8f       ,opc80_8f       ,opc80_8f       \
,opc80_8f       ,opc80_8f       ,opc80_8f       ,opc80_8f       \
,opc80_8f       ,opc80_8f       ,opc80_8f       ,opc80_8f       \
,opc90_95       ,opc90_95       ,opc90_95       ,opc90_95       \
,opc90_95       ,opc90_95       ,_opc_wtf!      ,_opc_wtf!      \
,_opc_wtf!      ,_opc_wtf!      ,_opc_wtf!      ,_opc_wtf!      \
,_opc_wtf!      ,_opc_wtf!      ,_opc_wtf!      ,_opc_wtf!      \
,opca0_ay8910   ,opca1_af       ,opca1_af       ,opca1_af       \
,opca1_af       ,opca1_af       ,opca1_af       ,opca1_af       \
,opca1_af       ,opca1_af       ,opca1_af       ,opca1_af       \
,opca1_af       ,opca1_af       ,opca1_af       ,opca1_af       \
,opcb0_rf5c68   ,opcb1_rf5c164  ,opcb2_pwm      ,opcb3_dmg      \
,opcb4_nes      ,opcb5_multipcm ,opcb6_upd7759  ,opcb7_okim6258 \
,opcb8_okim6295 ,opcb9_huc6280  ,opcba_ko53260  ,opcbb_pokey    \
,opcbc_bf       ,opcbc_bf       ,opcbc_bf       ,opcbc_bf       \
,opcc0_segapcm  ,opcc1_rf5c68   ,opcc2_rf5c164  ,opcc3_multipcm \
,opcc4_qsound   ,opcc5_scsp     ,opcc6_wswan    ,opcc7_vsu      \
,opcc8_cf       ,opcc8_cf       ,opcc8_cf       ,opcc8_cf       \
,opcc8_cf       ,opcc8_cf       ,opcc8_cf       ,opcc8_cf       \
,opcd0_ymf278b  ,opcd1_ymf271   ,opcd2_scc1     ,opcd3_ko54539  \
,opcd4_c140     ,opcd5_df       ,opcd5_df       ,opcd5_df       \
,opcd5_df       ,opcd5_df       ,opcd5_df       ,opcd5_df       \
,opcd5_df       ,opcd5_df       ,opcd5_df       ,opcd5_df       \
,opce0_seek     ,opce1_ff       ,opce1_ff       ,opce1_ff       \
,opce1_ff       ,opce1_ff       ,opce1_ff       ,opce1_ff       \
,opce1_ff       ,opce1_ff       ,opce1_ff       ,opce1_ff       \
,opce1_ff       ,opce1_ff       ,opce1_ff       ,opce1_ff       \
,opce1_ff       ,opce1_ff       ,opce1_ff       ,opce1_ff       \
,opce1_ff       ,opce1_ff       ,opce1_ff       ,opce1_ff       \
,opce1_ff       ,opce1_ff       ,opce1_ff       ,opce1_ff       \
,opce1_ff       ,opce1_ff       ,opce1_ff       ,opce1_ff
;------------------------------------------------------------------------------
readvgm:        mov     x, @wy
                incptr
                movlh   tmpw, tbl_vgm_commands+x
                ijmp    (tmpw)

incptrpage:     inc     1+vgmptr
                bit     1+vgmptr
                bvc     .done

                pha
                add     a, nsfbank,!2
                sta     nsfbank, 5ffah
                or      5ffbh, a,!01
                mov     1+vgmptr, !a0
                pla
.done:          rts
;------------------------------------------------------------------------------
;       Thanks to "vgm_facc.exe", most of this timing mess is useless.
opc61_wait:     mov     tmpw, @wy
                incptr
                lda     @wy
                bnz @f

                incptr
                readnext

              @ sta     1+tmpw
                incptr
                sec
                ldx     !ff
.loop:          inx
                sbcb    tmpw, !33       ;$2df=ntsc / $372=pal
                sbcb    1+tmpw,!03
                bcs     .loop

                stx     vgmtim
                readend

opc70_7f:     ;  lda     x
              ;  and     !0f
                 readnext
                incw    samplecount
opc80_8f:       lda     x
                and     !0f
                add     samplecount
                sta     samplecount
                inccs   samplecount+1
                lda     samplecount+1
                cmp     !03
                bhs     .done

                readnext

.done:          lda     !0
                sta     samplecount, samplecount+1, vgmtim
                readend

opc62_wait_ntsc:
opc63_wait_pal: and     a, @wy,!f0
                cmp     !70
                incptreq        ; skip mini-wait
                readend

opc66_end_data: jmp     endofdata

opce0_seek:     incptr
                incptr
                incptr
                incptr
                readnext
;------------------------------------------------------------------------------
opc50_psg:      lda     @wy
                bpl     .data

                and     !70
                shr3
                sta     x, psgptr
                lda     psgmem+x
                and     !f0
                sta     tmp0
                lda     @wy
                and     !0f
                or      tmp0
                sta     psgmem+x
                jmp     .done

.data:          ldx     psgptr
                and     !30
                shr4
                sta     1+psgmem+x
                lda     @wy
                cpx     !0a
                bhs     .clone

                cpx     !06
                beq     .clone

                cpx     !02
                beq     .clone

                shl4
                sta     tmp0
                lda     psgmem+x
                and     !0f
                or      tmp0
.clone:         sta     psgmem+x
.done:          incptr
                readnext
;---------------------------------------
opcb4_nes:      mov     x, @wy
                incptr
                lda     @wy
                cpx     !12
                beq     .dmca
                cpx     !13
                stane   4000h+x
.done:          incptr
                readnext
;       batman experiment
.dmca:          cmp!    $c0
                beq .k
                cmp!    $c4
                beq .s
                mov!    4000h+x, adr_tom.dmc
                inx
                mov!    4000h+x, len_tom.dmc
                jmp     .done
             .s:mov!    4000h+x, adr_snare.dmc
                inx
                mov!    4000h+x, len_snare.dmc
                jmp     .done
             .k:mov!    4000h+x, adr_kick.dmc
                inx
                mov!    4000h+x, len_kick.dmc
                jmp     .done

;---------------------------------------

opc52_ym2612_0: incw    samplecount
                lda     @wy
                cmp     !28
                bne     .reg

                incptr
                lda     @wy
                and     !07
                sta     x
                or      !f0
                sta     x
                lda     @wy
                sta     tmp0
                lda     genesis0+x
                xor     tmp0
                and     tmp0
                sta     genesis0+x+8    ; re-trigger
                lda     tmp0
                jmp @f

.reg:           sta     x
                incptr
                lda     @wy
              @ sta     genesis0+x
                incptr
                readnext


opc53_ym2612_1: incw    samplecount
                lda     @wy
                sta     x
                incptr
                lda     @wy
                sta     genesis1+x
                incptr
                readnext
;---------------------------------------
opcb3_dmg:      and     x, @wy, !3f
                incptr
                lda     @wy
                cpx     !1a
                bhs     .done

.trig:          sta     gameboymem+x+$40    ; re-trigger

.done:          sta     gameboymem+$10+x

                incptr
                readnext

;---------------------------------------
opca0_ay8910:   and     x, @wy, !0f
                incptr
                mov     msxmem+x, @wy
                incptr
                readnext

;---------------------------------------
opcb9_huc6280:  and     x, @wy, !0f
                incptr
                lda     @wy
                cpx     !00
                beq     .channelselect
                cpx     !08
                bhs     .other

                pha
                add     x, x, pcemem+$30
                pla

                sta     pcemem+x

              @ incptr
                readnext

.channelselect: shl3

.other:         sta     pcemem+$30+x
                jmp @b

;------------------------------------------------------------------------------
opc51_ym2413:   mov     9010h, @wy
                ;incptr
                ;mov     9030h, @wy
                ;incptr
                ;readnext

                pha
                incptr

                ldx     !08
.wailoop:       dex
                bnz     .wailoop

                pla

                ; cmp     !0e
                ; beq     .drum

                cmp     !30
                blo @f
                cmp     !36
                bhs @f
                lda     @wy
.getinstru:     sta     tmp0
                shr4
                sta     x
                lda     tmp0
                and     !0f
                ora     .ym2413instrutable+x
                sta     9030h
                jmp .done

              @ mov     9030h, @wy
.done:          incptr
                readnext

.drum:



        lda      @wy
        and     !10
        bze     .snare
        mov!     4010h,$f
        mov!    4011h, $0
        mov!     4012h,adr_kick.dmc
        mov!     4013h,len_kick.dmc
        mov!    4015h, $f
        mov!    4015h, $1f
        jmp opc51_ym2413.done

.snare:
        mov!     4010h,$f
        mov!    4011h, $0
        mov!     4012h,adr_snare.dmc
        mov!     4013h,len_snare.dmc
        mov!    4015h, $f
        mov!    4015h, $1f
        jmp opc51_ym2413.done



.ym2413instrutable:
        ; vrc7                ym2413
hx 00   ; 0
hx 10   ; 1 Buzzy Bell        Violin
hx 20   ; 2 Guitar            Guitar
hx 30   ; 3 Wurly             Piano
hx 40   ; 4 Flute             Flute
hx 50   ; 5 Clarinet          Clarinet
hx 60   ; 6 Synth             Oboe
hx 70   ; 7 Trumpet           Trumpet
hx 80   ; 8 Organ             Organ
hx 90   ; 9 Bells             Horn
hx A0   ; A Vibes             Synthesizer
hx B0   ; B Vibraphone        Harpsichord
hx C0   ; C Tutti             Vibraphone
hx D0   ; D Fretless          Synthesizer Bass
hx E0   ; E Synth Bass        Acoustic Bass
hx F0   ; F Sweep             Electric Guitar

;==============================================================================
;               DUBSTEP GENERATOR (TM)

; 3 byte
opcd1_ymf271:
                incptr
; 2 byte
opc5a_ym3812:
opc5b_ym3526:
opc5c_y8950:
opc5e_ymf262_0:
opc5f_ymf262_1:
                lda     @wy
                sta     x
                mov     9010h, adlib_remap+x
                sta     x
                incptr
                lda     @wy
                sta     pcemem+x
                cpx     !20
                blo     .done
                cpx     !30
                bhs     .done
                shr
.done:          sta     9030h
                incptr
                readnext

adlib_remap:
hx 00,01,02,03,04,05,06,07,08,09,0A,0B,0C,0D,0E,0F
hx 00,01,02,03,04,05,06,07,08,09,0A,0B,0C,0D,0E,0F
hx 00,01,02,03,04,05,06,07,08,09,0A,0B,0C,0D,0E,0F
hx 00,01,02,03,04,05,06,07,08,09,0A,0B,0C,0D,0E,0F

hx 30,31,32,33,34,35,36,37,38,39,3A,3B,3C,3D,3E,3F
hx 50,51,52,53,54,55,56,57,58,59,5A,5B,5C,5D,5E,5F
hx 60,61,62,63,64,65,66,67,68,69,6A,6B,6C,6D,6E,6F
hx 70,71,72,73,74,75,76,77,78,79,7A,7B,7C,7D,7E,7F

hx 80,81,82,83,84,85,86,87,88,89,8A,8B,8C,8D,8E,8F
hx 90,91,92,93,94,95,96,97,98,99,9A,9B,9C,9D,9E,9F
hx 10,11,12,13,14,15,16,17,18,19,1A,1B,1C,1D,1E,1F
hx 20,21,22,23,24,25,26,27,28,29,2A,2B,2C,2D,2E,2F

hx C0,C1,C2,C3,C4,C5,C6,C7,C8,C9,CA,CB,CC,CD,CE,CF
hx D0,D1,D2,D3,D4,D5,D6,D7,D8,D9,DA,DB,DC,DD,DE,DF
hx E0,E1,E2,E3,E4,E5,E6,E7,E8,E9,EA,EB,EC,ED,EE,EF
hx F0,F1,F2,F3,F4,F5,F6,F7,F8,F9,FA,FB,FC,FD,FE,FF

;==============================================================================
; 4 byte
unused  opce1_ff
        incptr
; 3 byte
unused  opc64_not_sure, opcc0_segapcm, opcc1_rf5c68, opcc2_rf5c164
unused  opcc3_multipcm, opcc4_qsound, opcc5_scsp, opcc6_wswan, opcc7_vsu
unused  opcc8_cf, opcd0_ymf278b
unused  opcd2_scc1, opcd3_ko54539, opcd4_c140, opcd5_df
        incptr
; 2 byte
unused  opc40_4e
unused  opc54_ym2151, opc55_ym2203, opc56_ym2608_0, opc57_ym2608_1
unused  opc58_ym2610_0, opc59_ym2610_1
unused  opc5d_ymz280b
unused  opca1_af, opcb0_rf5c68, opcb1_rf5c164, opcb2_pwm
unused  opcb5_multipcm, opcb6_upd7759, opcb7_okim6258
unused  opcb8_okim6295, opcba_ko53260, opcbb_pokey, opcbc_bf
        incptr
; 1 byte
unused  opc30_3f, opc4f_gg
        incptr
; ignore
unused  _opc_wtf!
        readnext
; other
unused  opc67_datablock, opc68_pcmram, opc90_95
        readnext
;==============================================================================
;       master system / msx player

macro psg_vrc6 {
   ;     mov     tmp0, apuoct0+x
        sty     tmp1
        ld      y, psg0v+zy,and !0f
        ld      tmp2, voltable+y,and !0f
;        ldy     !20
;        lda     voltable+y, and !f0
        lda!    vrc6audio shl 4
        or      tmp2
        sta     9000h;5000h

    ;    bit     tmp0
        ldy     tmp1
        lda     psg0fbuf+zy
    ;    shlvs
        sta     9001h;5002h
        lda     1+psg0fbuf+zy
    ;    rolvs
        or      !80;!18
        cmp     aput3l
        stane   9002h, aput3l;5003h, aput3l

        rts    }

macro psg3wacky_vrc6 {
        mov     400ch, !30
        ld      y, psg3v,and !0f
        ld      tmp2, voltable+y, and !0f
;        ldy     !00
;        lda     voltable+y, and !f0
         lda    !00
        or      tmp2
        sta     9000h;5000h

        lda     1+psg2fbuf
        shl     psg2fbuf
        rol
        shl     psg2fbuf
        rol
        shl     psg2fbuf
        rol

         shl     psg2fbuf
         rol


        cmp     !10;!08
        ldahs   !0f;!07
        or      !80;!18
        cmp     aput3l
        stane   9002h, aput3l  ;5003h, aput3l
        ld      9001h, psg2fbuf;5002h, psg2fbuf

        rts      }


noisespecial:
hx 01,02,02,03,04,04,05,05,06,06,07,07,08,08,08,09
hx 09,0a,0a,0a,0b,0b,0c,0c,0c,0d,0d,0d,0d,0e,0e,0e

;duty/volume table for pulse#_duty setting
;3# = 12,5%
;7# = 25%
;b# = 50%
;f# = 75%
voltable:
hx 3f,3c,39,37, 35,34,33,33, 32,32,32,31, 31,31,31,30
hx 7f,7c,79,77, 75,74,73,73, 72,72,72,71, 71,71,71,70
hx bf,bc,b9,b7, b5,b4,b3,b3, b2,b2,b2,b1, b1,b1,b1,b0
hx ff,fc,f9,f7, f5,f4,f3,f3, f2,f2,f2,f1, f1,f1,f1,f0

hx 3f,3c,39,37, 75,74,73,73, b2,b2,b2,b1, b1,b1,b1,b0
hx bf,bc,b9,b7, 75,74,73,73, 32,32,32,31, 31,31,31,30
hx bf,bc,b9,b7, b5,b4,b3,b2, b2,b2,b2,b1, b1,b1,b1,b0
hx ff,fc,f9,f7, f5,f4,f3,f2, f2,f2,f2,f1, f1,f1,f1,f0

hx 3f,3c,39,37, 36,35,34,33, 32,32,32,31, 31,31,31,30
hx 7f,7c,79,77, 76,75,74,73, 72,72,72,71, 71,71,71,70
hx bf,bc,b9,b7, b6,b5,b4,b3, b2,b2,b2,b1, b1,b1,b1,b0
hx ff,fc,f9,f7, f6,f5,f4,f3, f2,f2,f2,f1, f1,f1,f1,f0

hx bf,bc,b9,b7, b6,75,74,73, 72,72,32,31, 31,31,31,30
hx 3f,3c,39,37, 36,75,74,73, 72,72,b2,b1, b1,b1,b1,70
hx bf,bc,b9,b7, b6,b5,b4,b3, b2,b2,b2,b1, b1,b1,b1,b0
hx ff,fc,f9,f7, f6,f5,f4,f3, f2,f2,f2,f1, f1,f1,f1,f0

spectrum:
        ldy     !0
        ldx     !0
.floop :mov     tmp0, msxmem+x
        inx
        lda     msxmem+x
if defined sunsoftMSX
else
        shr
        ror     tmp0
end if

;       shr
;       ror     tmp0

        sta     psg0f+zy+1
        mov     psg0f+zy, tmp0
        iny4
        inx
        cpx     !06
        bne     .floop

        lda     !0f
        sta     psg0v,psg1v,psg2v

        mov     tmp0, msxmem+$7
        shr     tmp0
        bcs @f
        xor     psg0v, msxmem+$8, !0f
      @ shr     tmp0
        bcs @f
        xor     psg1v, msxmem+$9, !0f
      @ shr     tmp0
        bcs @f
        xor     psg2v, msxmem+$a, !0f
      @ lda     !00
        shr     tmp0
        ldacc   msxmem+$8
        shr     tmp0
        ldacc   msxmem+$9
        shr     tmp0
        ldacc   msxmem+$a
        xor     !0f
        sta     x
        mov     400ch, voltable+x
        and     x, msxmem+$6, !1f
        dex
        ldxmi   !0
        mov     400eh, noisespecial+x
        mov     400fh, !18

psgapu:
if defined sunsoftMSX

        lda     psg0f+1
        shr
        sta     psg0fbuf+1
        lda     psg0f
        ror
        sta     psg0fbuf
        lda     psg1f+1
        shr
        sta     psg1fbuf+1
        lda     psg1f
        ror
        sta     psg1fbuf
        lda     psg2f+1
        shr
        sta     psg2fbuf+1
        lda     psg2f
        ror
        sta     psg2fbuf

        ldx     !00
        lda     psg0fbuf
        stx     0c000h
        sta     0e000h
        inx
        lda     psg0fbuf+1
        stx     0c000h
        sta     0e000h
        inx
        lda     psg1fbuf
        stx     0c000h
        sta     0e000h
        inx
        lda     psg1fbuf+1
        stx     0c000h
        sta     0e000h
        inx
        lda     psg2fbuf
        stx     0c000h
        sta     0e000h
        inx
        lda     psg2fbuf+1
        stx     0c000h
        sta     0e000h
        inx

        inx
        lda     !f8
        stx     0c000h
        sta     0e000h
        inx
        lda     psg0v
        and     !0f
        xor     !0f
        stx     0c000h
        sta     0e000h
        inx
        lda     psg1v
        and     !0f
        xor     !0f
        stx     0c000h
        sta     0e000h
        inx
        lda     psg2v
        and     !0f
        xor     !0f
        stx     0c000h
        sta     0e000h

        jsr     psg3_noise
        rts
end if

        bit     psgdrop
        bmi     .drop

        movw    psg0fbuf,psg0f
        movw    psg1fbuf,psg1f
        movw    psg2fbuf,psg2f
        jmp     .bufdone

.drop:  ldx     !08
      @ ld      tmp1,   1+psg0f+x, shr
        ld      tmp0,   psg0f+x, ror
        addw    psg0fbuf+x, psg0f+x, tmp0
        sub     x, x,!04
        bpl @b
.bufdone:

        lda     psg3f,and !07
        ldx     trich
        jmpze   triangle_mode0
        cpx     !01
        jmpeq   triangle_mode1
;--------------------------------------
triangle_mode2:
        cmp     !03
        beq     .wacky
        cmp     !07
        bne     .normal

        mov     4008h, !00
        jsr     psg3hd_noise
        jmp @f
.normal:
        ldy     !08
        jsr     psg_triangle
        jsr     psg3_noise
        jmp @f
.wacky:
        jsr     psg3wacky_triangle
      @ ldx     !04
        ldy     !04
        jsr     psg_pulse
        ldx     !00
        ldy     !00
        jmp     psg_pulse
;--------------------------------------
triangle_mode1:
        cmp     !03
        beq     .wacky
        cmp     !07
        bne     .normal

        mov     4004h, !30
        jsr     psg3hd_noise
        jmp @f
.normal:
        ldx     !04
        ldy     !08
        jsr     psg_pulse
        jsr     psg3_noise
        jmp @f
.wacky:
        jsr     psg3wacky_pulse1
      @ ldy     !04
        jsr     psg_triangle
        ldx     !00
        ldy     !00
        jmp     psg_pulse
;--------------------------------------
triangle_mode0:
        cmp     !03
        beq     .wacky
        cmp     !07
        bne     .normal

        mov     4004h, !30
        jsr     psg3hd_noise
        jmp @f
.normal:
        ldx     !04
        ldy     !08
        jsr     psg_pulse
        jsr     psg3_noise
        jmp @f
.wacky:
        jsr     psg3wacky_pulse1
      @ ldy     !00
        jsr     psg_triangle
        ldx     !00
        ldy     !04
        jmp     psg_pulse
;--------------------------------------
;a:  40=octave drop
;y:  0=psg0 / 4=psg1 / 8=psg2
;x:  0=pulse0 / 4=pulse1
psg_pulse:
        mov     tmp0, apuoct0+x
        sty     tmp1
      ; ld      y, psg0v+zy,and !0f,or apuam0+x
      ; ld      tmp2, voltable+y,and !0f
      ; ldy     apudt0+x
      ; lda     voltable+y, and !f0
      ; ld      4000h+x, a,or tmp2
        lda     psg0v+zy
        and     !0f
        or      apudt0+x
        sta     y
        ;mov     4000h+x, voltable+y
         and     tmp2, voltable+y, !f0
         and     a, voltable+y, !0f
         sub     apuam0+x
         ldami   !0
         or      4000h+x, a, tmp2

        bit     tmp0
        ldy     tmp1
        lda     psg0fbuf+zy
        shlvs
        sta     4002h+x

        lda     1+psg0fbuf+zy
        rolvs
        or      !18
        cmp     apu0fl+x
        stane   4003h+x, apu0fl+x

        rts
;--------------------------------------
;a:  40=octave drop
;y:  0=psg0 / 4=psg1 / 8=psg2
psg_triangle:
if defined vrc6audio
psg_vrc6
else
        ldx     !81
        and     a, psg0v+zy,!0f
        xor     !0f
        cmp     trigate
        ldxlo   !00
        stx     4008h

        bit     apuoctt
        lda     1+psg0fbuf+zy
        shrvc
        ld      400bh, a,or !18
        lda     psg0fbuf+zy
        rorvc
        sta     400ah

        rts
end if
;--------------------------------------
psg3_noise:
        lda     vgmsystem
        cmp     !02 ;msx/spectrum
        beq     .igno

        ld      x, psg3v,and !0f,or apuamn
        ld      400ch, voltable+x
        ld      x, psg3f,and !07
        ld      400eh, noisetfrq+x
        ld      400fh, !18

.igno:  rts
;--------------------------------------
psg3hd_noise:
        lda     vgmsystem
        cmp     !02 ;msx/spectrum
        beq     .igno

        ld      x, psg3v,and !0f,or apuamn
        ld      tmp0, !30

        ldy     !0f
        lda     1+psg2f
        and     !03
        bnz     .str

        ld      tmp0, voltable+x
        lda     psg2f
        bmi     .str

        cmp     !10
        blo @f

        shr3
        or      !10

      @ sta     x
        ldy     noisespecial+x
.str:   sty     400eh
        ld      400fh, !18
        ld      400ch, tmp0
.igno:  rts
;--------------------------------------
psg3wacky_triangle:
if defined vrc6audio
psg3wacky_vrc6
else
        mov     400ch, !30
        ldx     !81
        lda     psg3v,and !0f
        xor     !0f
        cmp     trigate
        ldxlo   !00
        stx     4008h

        lda     1+psg2fbuf
        shl     psg2fbuf
        rol
        shl     psg2fbuf
        rol
    ;   shl     psg2fbuf
    ;   rol


        cmp     !08
        ldahs   !07
        ld      400bh, a, or !18
        ld      400ah, psg2fbuf

        rts
end if
;--------------------------------------
psg3wacky_pulse1:
        mov     400ch, !30
        ld      y, psg3v,and !0f,or apuam1
        ld      tmp2, voltable+y, and !0f
        ldy     apudt1
        lda     voltable+y, and !f0
        ld      4004h, a, or tmp2

        lda     1+psg2fbuf
rept 3 {shl     psg2fbuf
        rol
}
        cmp     !08
        ldahs   !07
        or      !18
        cmp     apu1fl
        stane   4007h, apu1fl
        ld      4006h, psg2fbuf

        rts
;------------------------------------------------------------------------------
;       game boy player


gbnoisetable:
;  0  1  2  3  4  5  6  7  8  9  a  b  c  d  e  f
hx 0d,0d,0d,0d,0c,0a,08,04,02,01,00,00,00,00,00,00
hx 0d,0d,0d,0c,0a,08,04,02,01,00,00,00,00,00,00,00
hx 0d,0d,0c,0a,08,04,02,01,00,00,00,00,00,00,00,00
hx 0d,0c,0b,09,06,03,01,00,00,00,00,00,00,00,00,00
hx 0d,0c,0a,08,04,03,01,00,00,00,00,00,00,00,00,00
hx 0d,0b,09,06,04,02,01,00,00,00,00,00,00,00,00,00
hx 0d,0b,08,05,03,01,00,00,00,00,00,00,00,00,00,00
hx 0c,0a,07,05,03,01,00,00,00,00,00,00,00,00,00,00

gameboy:
if defined noisygameboy
        lda     gameboymem+$12
        cmp     nr1envl
        rolne   apu0fl
        sta     nr1envl
        lda     gameboymem+$17
        cmp     nr2envl
        rolne   apu1fl
        sta     nr2envl
end if


gb_pulse0:
        ldx     !30
        lda     gameboymem+$12
        and     !f0
        bze     .amp

        bit     gameboymem+$30+$14
        bpl     .env

        and     nr1env, gameboymem+$12, !07
         sta     nr1envc
        lda     gameboymem+$12
        shr4
if defined playitloud
else
         shr
         sta     tmp0
         shr
         add     tmp0
end if
         sub     apuam0
         ldami   !0
        sta     nr1amp
        mov     gameboymem+$30+$14, !0
.env:   ldx     nr1env
        bze     .init

        dex
         bnz @f



         mov     nr1env, nr1envc
         jmp     .ts
      @ stx     nr1env
         jmp     .envdon
        jmp     .ts

.init:  and     nr1env, gameboymem+$12, !07
        jmp     .envdon

.ts:    lda     gameboymem+$12
        and     !08
        bze     .decay

.attac: ldx     nr1amp
        inx
        cpx     !10
        stxlo   nr1amp
        jmp     .envdon

.decay: ldx     nr1amp
        bze     .envdon
        dex
        bnz @f
      ;  andbze  gameboymem+$14, !7f
      @ stx     nr1amp
.envdon:
        lda     gameboymem+$11
        and     !c0
        or      !30
      ;  bit     gameboymem+$14
      ;  ormi    nr1amp
        or      nr1amp
        sta     x
.amp:   stx     4000h

        xor     4002h, gameboymem+$13, !ff
        lda     gameboymem+$14
        xor     !07
        or      !18
       and !1f
        cmp     apu0fl
        stane   4003h, apu0fl

gb_pulse1:
        ldx     !30
        lda     gameboymem+$17
        and     !f0
        bze     .amp

        bit     gameboymem+$30+$19
        bpl     .env

        and     nr2env, gameboymem+$17, !07
         sta     nr2envc
        lda     gameboymem+$17
        shr4
if defined playitloud
else
         shr
         sta     tmp0
         shr
         add     tmp0
end if
         sub    apuam1
         ldami  !0
        sta     nr2amp
        mov     gameboymem+$30+$19, !0
.env:   ldx     nr2env
        bze     .init

        dex
         bnz @f



         mov     nr2env, nr2envc
         jmp     .ts
      @ stx     nr2env
         jmp     .envdon
        jmp     .ts



.init:  and     nr2env, gameboymem+$17, !07
        jmp     .envdon

.ts:    lda     gameboymem+$17
        and     !08
        bze     .decay

.attac: ldx     nr2amp
        inx
        cpx     !10
        stxlo   nr2amp
        jmp     .envdon

.decay: ldx     nr2amp
        bze     .envdon
        dex
        bnz @f
    ;    andbze  gameboymem+$19, !7f
      @ stx     nr2amp
.envdon:
        lda     gameboymem+$16
        and     !c0
        or      !30
      ;  bit     gameboymem+$19
      ;  ormi    nr2amp
        or      nr2amp
        sta     x
.amp:   stx     4004h

        xor     4006h, gameboymem+$18, !ff
        lda     gameboymem+$19
        xor     !07
        or      !18
       and !1f
        cmp     apu1fl
        stane   4007h, apu1fl
gbwav:
        ldx     !81
        bit     gameboymem+$1a
        ldxpl   !00
        lda     gameboymem+$1c

        if defined vrc6audio
                shr5
                and     !3
                sta     y
                lda     .frq+y
                jmp @f
                .frq: hx 00,08,04,02
              @ cpx     !0
                ldaze   x
                or!     (vrc6audio and 7) shl 4
                sta     09000h
        else

        and     !60
        bze .ze
        cmp     !20
        beq .s
        cmp     !40
        ifeq    lda !08, lda !04

        cmp     trigate;!40
        bhs .s
    .ze:ldx     !00
    .s: bit     gameboymem+$1e
       ;ldxpl   !00
        stx     4008h
end if

        lda     gameboymem+$1d
        xor     !ff
         sta     tmp0
;        sta     400ah
        lda     gameboymem+$1e
         and     !07
        xor     !07

        if defined vrc6audio
                and     !07
                or      !80
                sta     09002h
                mov     09001h, tmp0
        else

         shr
         ror     tmp0
        or      !18
        sta     400bh
         mov     400ah, tmp0
end if

gbnoise:
        ldx     !30
        lda     gameboymem+$21
        and     !f0
        bze     .amp

        bit     gameboymem+$30+$23
        bpl     .env

        and     nr4env, gameboymem+$21, !07
         sta     nr4envc
        lda     gameboymem+$21
        shr4
if defined playitloud
else
         shr
         sta     tmp0
         shr
         add     tmp0
end if
         sub     apuamn
         ldami   !0

        sta     nr4amp
        mov     gameboymem+$30+$23, !0
.env:   ldx     nr4env
        bze     .init

        dex
         bnz @f

         mov     nr4env, nr4envc
         jmp     .ts
      @ stx     nr4env
         jmp     .envdon
        jmp     .ts

.init:  and     nr4env, gameboymem+$21, !07
        jmp     .envdon

.ts:    lda     gameboymem+$21
        and     !08
        bze     .decay

.attac: ldx     nr4amp
        inx
        cpx     !10
        stxlo   nr4amp
        jmp     .envdon

.decay: ldx     nr4amp
        bze     .envdon
        dex
        bnz @f
    ;    andbze  gameboymem+$23, !7f
      @ stx     nr4amp
.envdon:
        lda     gameboymem+$20
        and     !c0
        or      !30
      ;  bit     gameboymem+$23
      ;  ormi    nr4amp
        or      nr4amp
        sta     x
.amp:   stx     400ch

       ;  shr4
        lda     gameboymem+$22
        and     !07
        shl4
        sta     tmp0
        lda     gameboymem+$22
        shr4
        or      tmp0
        sta     x
        lda     gbnoisetable+x
        xor     !0f
        sta     400eh

        lda     gameboymem+$23
        xor     !07
        or      !18
       and !1f

        sta     400fh

        rts

;------------------------------------------------------------------------------
;       megadrive player

lohihx yamafnote,\
,7F1,7D4,7B7,79B,77F,763,748,72D\
,713,6FE,6EA,6D5,6C1,6AD,695,67D\
,665,64D,63B,628,616,604,5F3,5E1\
,5D0,5BF,5AE,59D,58F,582,574,567\
,55A,54C,53D,52D,51E,50F,500,4F6\
,4EB,4E1,4D7,4CC,4C2,4B8,4AD,4A1\
,496,48B,47F,474,46B,462,459,44F\
,446,43D,434,42C,423,41A,411,409\
,400,3F8,3F1,3E9,3E2,3DB,3D4,3CD\
,3C6,3BF,3B8,3B1,3AA,3A4,39D,396\
,390,389,383,37D,378,372,36C,367\
,361,35C,356,351,34B,346,340,33B\
,336,331,32B,326,321,31D,318,314\
,30F,30B,306,302,2FD,2F9,2F4,2F0\
,2EC,2E7,2E3,2DF,2DB,2D6,2D2,2CE

nintendoes_what_genesis_does:
        ;jsr psgapu
        mov     genesisfrq0l, genesis0+$a0
        mov     genesisfrq1l, genesis0+$a1
        mov     genesisfrq2l, genesis0+$a2
        mov     genesisfrq3l, genesis1+$a0
        mov     genesisfrq4l, genesis1+$a1
        mov     genesisfrq5l, genesis1+$a2
        mov     genesisfrq0h, genesis0+$a4
        mov     genesisfrq1h, genesis0+$a5
        mov     genesisfrq2h, genesis0+$a6
        mov     genesisfrq3h, genesis1+$a4
        mov     genesisfrq4h, genesis1+$a5
        mov     genesisfrq5h, genesis1+$a6
        mov     genesistrig0, genesis0+$f0
        mov     genesistrig1, genesis0+$f1
        mov     genesistrig2, genesis0+$f2
        mov     genesistrig3, genesis0+$f4
        mov     genesistrig4, genesis0+$f5
        mov     genesistrig5, genesis0+$f6
        mov     genesistl0, genesis0+$4c
        mov     genesistl1, genesis0+$4d
        mov     genesistl2, genesis0+$4e
        mov     genesistl3, genesis1+$4c
        mov     genesistl4, genesis1+$4d
        mov     genesistl5, genesis1+$4e

    ;   movw    psg0fbuf,psg0f
    ;   ldx     !04
    ;   ldy     !00
    ;   jsr     psg_pulse

        lda     psg3f,and !07
        cmp     !07
        ifeq    jsr psg3hd_noise, jsr psg3_noise

    ;   jsr     genevrc7
        ldx     genp0
        lda     genesistrig0+x
        and     !f0
        bnz .p0
        mov     tmp5, backamp0
        mov     tmp4, backpdt0
        mov     tmp3, backp0
        mov     tmp2, !0
        jsr     genepulse
        jmp @f

.p0:    mov     tmp5, apuam0
        mov     tmp4, apudt0
        mov     tmp3, genp0
        mov!    tmp2, 0
        jsr     genepulse

      @ ldx     genp1
        lda     genesistrig0+x
        and     !f0
        bnz .p1
        mov     tmp5, backamp1
        mov     tmp4, backpdt1
        mov     tmp3, backp1
        mov     tmp2, !4
        jsr     genepulse
        jmp @f

.p1:    mov     tmp5, apuam1
        mov     tmp4, apudt1
        mov     tmp3, genp1
        mov!    tmp2, 4
        jsr     genepulse

      @ ldx     gentri
        jsr     genetriangle

;dmc------
if defined pcmdrums
        lda     genesis0+$ff
        rtsze
        mov     genesis0+$ff, !0
        mov!    4010h, $f
        mov!    4011h, $0
        mov     4012h, genpcm
        mov     4013h, genpcm+1
        mov!    4015h, $f
        mov!    4015h, $1f
        rts
end if

        ;rts
        ldx     gendmc
        cpx     !3
        inxhs
        lda     genesis0+$f8+x
        and     !f0
        bnz @f
        mov     genesis0+$ff, !1
        rts
      @

if defined testmode
        ldy     !0
        sty     0c000h
        ldx     gendmc
        mov     0e000h, genesisfrq0h+x
        iny
        sty     0c000h
        mov     0e000h, genesisfrq0l+x

        rts
end if
        ldx     gendmc
        lda     genesisfrq0l+x

        cmp     genesis0+$ff
        rtseq
        sta     $a0



        ldx     !7
.l1:    cmp     $a0+x
        beq .d
        dex
        bnz .l1
        ldx     $af
        jmp @f
.l2:    inx
        ldy     $a0+x
        bnz @f
        sta     $a0+x
        bze .d
      @ cpx     !8
        blo .l2
        stx     $af

.d:     cmp     gendmcfrq+0
        bne @f
        ldx!    adr_kick.dmc
        ldy!    len_kick.dmc
        lda!    $f
        jmp     .shoot

      @ cmp     gendmcfrq+1
        bne @f
        ldx!    adr_snare.dmc
        ldy!    len_snare.dmc
        lda!    $f
        jmp     .shoot

      @ cmp     gendmcfrq+2
        bne @f
        ldx!    adr_tom.dmc
        ldy!    len_tom.dmc
        lda!    $f
        jmp     .shoot

      @ cmp     gendmcfrq+3
        bne .done
        ldx!    adr_tom.dmc
        ldy!    len_tom.dmc
        lda!    $e
.shoot: sta     4010h
        mov!    4011h, $0
        stx     4012h
        sty     4013h
        mov!    4015h, $f
        mov!    4015h, $1f
        mov     genesis0+$ff, $a0
.done:  rts


;pul0
genepulse:
        ldx     tmp3
        lda     genesistl0+x
        shr3
        and     !0f

        add     tmp5
        cmp     !10
        ldahs   !f
        or      tmp4

        sta     y
        lda     genesistrig0+x
        and     !f0
        ifze    lda !30, lda voltable+y


        ldx     tmp2
        sta     4000h+x
        ldx     tmp3
        lda     genesisfrq0h+x
        sta     tmp0
        lda     genesisfrq0l+x

        shr     tmp0
        ror
        shr     tmp0
        ror
        shr     tmp0
        ror

        sub     !40
        sta     y
        movlh   tmpw, yamafnote+y

        lda     genesisfrq0h+x
        shr3
        and     !07
        sta     y

        jmp     @f

.octav0:shrw    tmpw
      @ dey
        bnz     .octav0

        clc
        ldx     tmp2
        secze
        lda     l_tmpw
        rol
        sta     4002h+x
        lda     h_tmpw
        rol
        or      !18
        cmp     apu0fl+x
        stane   4003h+x , apu0fl+x
        rts
;tri
genetriangle:
        lda     genesistrig0+x
        and     !f0
        ifze    lda !00, lda !ff
        sta     4008h
        lda     genesisfrq0h+x
        sta     tmp0
        lda     genesisfrq0l+x

        shr     tmp0
        ror
        shr     tmp0
        ror
        shr     tmp0
        ror

        sub     !40
        sta     y
        movlh   tmpw, yamafnote+y

        lda     genesisfrq0h+x
        shr3
        and     !07
        sta     y

        jmp     @f

.octav2:shrw    tmpw
      @ dey
        bpl     .octav2

        lda     l_tmpw
        shl
        sta     400ah
        lda     h_tmpw
        rol
        or      !18
        sta     400bh
        rts
;------------------------------------------------------------------------------
;       pc engine player

turbografx16:
.pul0:  lda     genp0
        shl3
        and     x,a,!38
        lda     pcemem+x+5 ;pan
        shr
        and     !07
        sta     tmp0
        lda     pcemem+x+5 ;pan
        shr5
        add     tmp0
        xor     !0f
        sta     tmp0

        lda     pcemem+x+4 ;vol
         ldapl   !00
         cmp     !c0
         ldahs   !00

        shr
        and     !0f
        xor     !0f
        add     tmp0
        shr
        sta     y
;        or      !30
;        sta     4000h
;        and     x, a, !0f
        mov     4000h, voltable+y

        lda     pcemem+x+3
        ;shr
        and     !07
        pha
        lda     pcemem+x+2
        ;ror
        sta     4002h
        pla
        or      !18
        and     !1f
        cmp     apu0fl
        stane   4003h, apu0fl

.pul1:  lda     genp1
        shl3
        and     x,a,!38
        lda     pcemem+x+5 ;pan
        shr
        and     !07
        sta     tmp0
        lda     pcemem+x+5 ;pan
        shr5
        add     tmp0
        xor     !0f
        sta     tmp0

        lda     pcemem+x+4
         ldapl   !00
         cmp     !c0
         ldahs   !00


        shr
        and     !0f
        xor     !0f
        add     tmp0
        shr
        sta     y
;        or      !30
;        sta     4004h
    ;    and     x, a, !0f
        mov     4004h, voltable+y

        lda     pcemem+x+3
;        shr
        and     !07
        pha
        lda     pcemem+x+2
;        ror
        sta     4006h
        pla
        or      !18
     ;   and     !1f
        cmp     apu1fl
        stane   4007h, apu1fl

.tri:   lda     gentri
        shl3
        and     x,a,!38
        ldy     !81
        lda     pcemem+x+4
        ldypl   !00
        cmp     !c0
        ldyhs   !00
        and     !1f
        ldyze   !00
        sty     4008h

        mov     tmp0, pcemem+x+2
        lda     pcemem+x+3
        shr
        ror     tmp0
        shr
        ror     tmp0
        or      !18
        sta     400bh
        mov     400ah, tmp0

        rts

;==============================================================================
address "player 8000-"
.pad $c000
;dmcfile kick.dmc, snare.dmc, tom.dmc

align 64
dmc_startkick.dmc:
hx E9,E1,01,96,96,2A,FE,BD,2F,05,20,A4,4A,B7,77,EF,BE,BE,28,2E,80,02,04,00,50,04,F0,58,BF,FF,F6,FF
hx F7,DF,FD,FF,AD,DA,A3,5B,40,8B,40,08,00,00,11,40,01,90,02,52,05,00,00,A8,AB,7B,F7,EF,FF,FF,FE,DD
hx DD,EF,AE,BB,FB,FF,FF,FF,FF,44,89,08,08,11,01,21,22,02,22,22,A2,8A,A8,4A,54,E1,74,55,95,6E,ED,AE
hx DA,AB,AF,BB,75,BF,BB,F5,6B,77,B7,56,55,D5,52,A5,5A,24,A5,A4,8A,44,55,49,55,A9,96,56,D5,55,D5,52
dmc_endkick.dmc:
adr_kick.dmc = (dmc_startkick.dmc shr 6) and $00ff
len_kick.dmc = (((dmc_endkick.dmc - dmc_startkick.dmc) shr 4 )-1) and $00ff

align 64
dmc_startsnare.dmc:
hx F5,FF,7F,00,00,00,00,00,FE,E3,FF,FF,FF,FF,88,73,1C,3E,FC,1F,00,00,00,00,00,38,FF,FF,02,00,F0,FF
hx FF,FF,FF,FF,5F,00,20,1C,1C,00,00,00,00,00,F8,E7,FF,FF,FF,FF,FF,07,84,3F,F8,07,00,00,00,00,06,BE
hx FF,CF,7F,00,7E,8E,17,FF,FF,FD,07,A0,17,00,00,28,00,8A,EF,C6,0B,E0,DF,FF,7F,FF,FF,00,D0,01,EC,01
hx 80,22,5A,4B,D0,F5,7F,A0,FF,7E,80,F0,81,FD,1F,40,F3,F7,00,5C,31,01,20,FF,3F,F0,A8,91,47,8B,FE,F7
hx 5F,A0,47,0E,40,51,11,BE,03,38,F5,0D,F8,FF,1C,7C,F0,1D,3F,0E,02,B8,85,C1,3C,77,94,DE,1E,38,1A,EC
hx F5,30,A1,97,A5,B1,5F,7B,80,1F,10,31,FD,81,6D,40,DA,6F,1C,65,47,5F,D5,BF,03,B0,68,4C,E0,BE,50,D0
hx DA,67,C1,BB,A1,58,FD,AE,68,03,A5,4F,84,67,3A,A5,AA,97,4E,52,55,78,18,C7,19,5D,B5,CB,7A,4B,47,05
hx DA,D6,23,54,45,30,CB,E7,1A,47,75,7C,DE,34,24,D5,36,54,5A,A9,55,C1,57,75,51,15,67,65,4B,EB,50,94
hx B5,5C,75,51,A5,6A,7F,29,A4,52,55,A9,29,B1,A4,65,DB,AD,95,2D,79,2C,CA,53,29,A9,52,AB,55,55,05,DD
hx D9,34,2F,51,19,57,55,AD,04,D7,C5,DA,56,9D,54,4A,55,55,A9,96,52,55,57,95,56,29,5B,D5,F5,22,31,55
hx D5,1A,95,A4,AA,EA,D6,3C,2A,55,57,49,55,4B,29,65,9B,D5,34,55,95,6A,AD,9B,44,A9,55,D5,54,55,A1,B8
hx 6D,B5,A9,B2,5A,29,CD,4A,A5,52,55,57,55,4B,4D,AA,D6,B4,AA,64,55,55,75,A5,94,50,B7,5A,75,A9,2A,55
hx AB,4A,55,55,A8,B6,A5,55,55,4D,55,AB,6A,16,55,A5,35,2B,55,A5,52,55,57,6B,49,55,D5,AA,AA,54,29,55
hx 5D,55,55,55,4D,D5,D2,2A,55,A5,56,55,53,55,A5,D4,AA,D5,2A,55,55,B5,56,29,55,AA,AC,6A,55,55,55,55
hx D5,AA,52,55,55,55,55,55,55,55,5A,56,2B,53,55,55,AD,AA,54,95,52,AD,5A,55,55,55,B5,AA,54,55,55,55
hx 55,55,55,55,55,65,55,55,55,55,55,B5,96,52,95,AA,6A,55,55,55,55,D5,AA,52,55,55,5A,55,55,55,55,63
dmc_endsnare.dmc:
adr_snare.dmc = (dmc_startsnare.dmc shr 6) and $00ff
len_snare.dmc = (((dmc_endsnare.dmc - dmc_startsnare.dmc) shr 4 )-1) and $00ff

align 64
dmc_starttom.dmc:
hx A9,AA,FA,FF,3F,00,40,06,00,E3,03,00,FD,8D,C8,FF,FF,7F,FE,F9,FF,BF,00,00,10,1F,C0,80,1C,C7,71,8E
hx 1E,00,00,00,F8,03,07,FC,3F,87,FD,FF,FF,FF,FF,FF,45,F2,38,7C,01,00,02,30,00,70,20,07,08,BE,BF,99
hx 17,0A,78,D6,C3,5F,FE,FD,3F,BF,F8,FF,EC,CF,A8,10,08,01,01,38,00,04,44,F9,41,4E,FA,EB,2D,65,A8,F0
hx 57,FD,47,FF,9F,FF,B3,DE,11,B0,2E,4B,D4,84,00,00,90,3E,00,08,D4,7B,45,A7,5A,BB,EF,1F,74,ED,F6,EB
hx 35,A5,B5,6B,5D,75,25,F5,6A,07,00,00,00,00,B5,8F,12,80,FF,7B,55,D5,D4,BF,A3,46,F5,FA,B5,F7,DA,85
hx 5E,A8,AC,2E,A5,42,92,94,08,40,54,68,09,85,9A,6A,F7,5E,ED,56,A9,F7,7E,A5,5B,77,45,49,EA,AD,6B,25
hx B4,7B,04,08,68,29,58,00,62,6A,92,54,57,5D,EB,D6,EE,BD,DB,AD,5B,55,25,AA,36,93,55,DB,56,51,55,92
hx A2,14,0A,A8,2A,52,52,95,AA,14,55,B7,5E,BB,DB,AB,DE,7D,57,B6,AA,2A,54,56,15,4A,D6,2A,55,51,A8,42
hx 55,91,AA,12,29,53,AB,92,AA,AA,FB,DE,AB,5B,B7,AA,DF,2A,A9,4A,95,6C,4A,A9,A4,54,95,A8,2A,24,AA,9A
hx A4,52,55,45,AA,5D,B7,DA,D6,AD,6A,5B,55,BB,D6,75,4A,75,AD,94,54,44,94,A4,2A,52,A9,2A,55,12,B5,29
hx 55,6B,55,AB,AA,AD,DA,AD,AA,6D,B7,AD,56,A5,AA,55,55,49,AA,8A,84,AA,AA,44,91,AA,CA,AA,54,AA,AD,AA
hx 92,B6,DA,56,B7,6A,5B,57,B5,AA,AD,A4,AA,DA,4A,4A,AA,B5,14,25,2A,51,52,AA,52,AA,AA,AA,D5,AA,AD,AA
hx 55,B7,AA,AA,5A,6B,6D,AB,AD,AA,4A,AA,AA,52,25,25,55,AA,2A,51,2A,55,55,AA,AA,AA,AA,AA,55,AD,56,B5
hx AD,DA,56,AD,D5,AA,A5,AA,AA,54,55,AA,AA,54,92,AA,4A,52,A5,6A,25,A5,6A,AA,6A,55,55,6B,55,6D,AB,56
hx B5,5A,DB,AA,AA,4A,95,AA,AA,AA,AA,52,95,A4,4A,52,A5,4A,55,55,A6,AA,D5,5A,55,AB,AA,55,AB,AA,6A,B5
hx 56,AD,55,A5,AA,5A,A5,AA,4A,55,52,AA,AA,4A,52,4A,55,55,55,56,6B,55,A9,55,AD,D5,AA,DA,6A,55,55,55
hx 55,55,55,55,55,55,55,A9,AA,52,AA,AA,54,52,95,55,55,AA,AA,AA,AA,5A,55,6B,AB,AA,D5,AA,55,55,55,55
hx 55,55,55,55,55,55,2A,A5,AA,AA,92,52,55,55,55,55,55,55,55,AD,AA,55,55,AD,AA,6A,D5,5A,55,55,55,55
hx 55,55,55,A5,4A,A5,AA,AA,54,55,29,55,55,55,D5,54,55,AB,AA,AA,DA,AA,AA,AA,5A,B5,AA,AA,6A,55,55,55
hx 55,55,A9,54,A9,AA,AA,52,AA,AA,AA,52,55,55,55,55,AB,56,AB,AA,AA,AA,AA,56,55,55,55,AB,AA,AA,5A,55
hx AA,2A,95,AA,AA,AA,AA,54,A9,2A,55,55,AD,AA,AA,6A,55,D5,AA,AA,AA,6A,55,55,AB,AA,AA,AA,AA,2A,55,95
hx AA,AA,AA,AA,AA,AA,4A,55,55,A9,AA,AA,AA,AA,AA,56,B5,AA,AA,AA,AA,AA,5A,55,55,55,95,AA,AA,AA,AA,AA
dmc_endtom.dmc:
adr_tom.dmc = (dmc_starttom.dmc shr 6) and $00ff
len_tom.dmc = (((dmc_endtom.dmc - dmc_starttom.dmc) shr 4 )-1) and $00ff

songbanks:
.pad songbanks+$80
songpages:
.pad songpages+$80
nessongnumber:  db 0

address
nmi:            inc     nmi_inc
                rti
irq:            lda!    $29
                sta     2000h
              @ sta     2001h, 2005h, 2005h
                xor!    $01
                jnz @b
.pad $f000
                mov     5ff8h, !0
                mov     5ff9h, !1
                mov     5ffah, !2
                mov     5ffbh, !3
                mov     5ffch, !4
                mov     5ffdh, !5
                mov     5ffeh, !6
                mov     5fffh, !7

rst:            sei
                cld
                ldx     !ff
                txs
                inx
                stx     4010h, 4015h, 2000h, 2001h      ; disable all
                mov     4017h, !c0
.wait_ppu:      bit     2002h
                bpl     .wait_ppu
                shl
                bcs     .wait_ppu

                ldy     !07
                sty     1
                lda     x
                sta     0, y
.set_wram:      sta     (0)+y
                dey
                bnz     .set_wram
                dec     1
                bpl     .set_wram

nesnsf_init:    lda     songnumber
                cmp     nessongnumber
                ldahi   !0
                jsr     init_nsf

                mov     2000h, !a8

eternal:        lda     nmi_inc
              @ cmp     nmi_inc
                beq @b
                jsr     play_nsf
                jmp     eternal

.pad $fff2
                mov     5fffh, !7
                jmp     $f000
.dw nmi,rst,irq
;==============================================================================
songcounter = 0

