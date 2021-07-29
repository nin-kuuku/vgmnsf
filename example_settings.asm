include "flatnes.inc"
nsfheader "example", "VGMNSF", "-"
include "vgmnsf.asm"

;sunsoftMSX=1   ; enable 5B
;vrc6audio=3    ; enable VRC6 0-7=pulse duty

;playitloud=1    ;disable gameboy volume reduce
;noisygameboy=1 ;emulate gameboy clicks
;blastprosessing=1 ;double speed

psg_drop=1      ; drop song 5 semitones (default=0)

triangle_psg=2  ; channel setup
                ; 0 = automatic (default)
                ; 1 = psg0=triangle, psg1=pulse0,   psg2=pulse1
                ; 2 = psg0=pulse0,   psg1=triangle, psg2=pulse1
                ; 3 = psg0=pulse0,   psg1=pulse1,   psg2=triangle

triangle_gate=8 ; 0-15 triangle volume threshold (default=8)
dac_amp=0       ; 0-15 triangle/noise "volume" using DMC channel (default=0)

pulse0_duty=0
pulse1_duty=2   ; 0-15 pulse duty or really "voltable" pointer (default=2)

pulse0_oct=0
pulse1_oct=0
triangle_oct=0  ; drop channel by octave (default=0)

noise_l= 14
noise_m= 10
noise_h= 7      ; 0-15 SMS noise frqs (default= 13,11,9)

vgm "vgm/03 Forest Path_frame.vgm"

triangle_psg=3
pulse0_duty=4
pulse1_duty=5
vgm "vgm/Alien 3 SMS-Title Screen.vgm"

psg_drop=0
pulse0_oct=1
triangle_gate=6
triangle_psg=2
dac_amp=10
vgm "vgm/Asterix SMS-Gaul.vgm"

dac_amp=4
triangle_gate=12
vgm "vgm/Kirbys Dream Land GB-Float Islands_frame.vgm"

triangle_gate=8
vgm "vgm/Pinball Gator GB-Title Screen_frame.vgm"

