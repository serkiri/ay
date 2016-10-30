
/*
 * ayisr.S
 *
 * Created: 10/23/2016 10:53:25 PM
 *  Author: Sergiy_Kyrylenko
 */ 

#include <avr/io.h>

toneCountAL = 13
toneCountAH = 14
toneCountBL = 2
toneCountBH = 3
toneCountCL = 4
toneCountCH = 5
ntVal = 6
noiseSeedL = 7
noiseSeedH = 8
noiseCount = 9
envelopeCountL = 10
envelopeCountH = 11
envelopeAmpl = 12

bit16lsbreg = 27
tmpL = 28
tmpH = 29
temp = 30
temp2 = 31
                
.global TIMER1_COMPA_vect
TIMER1_COMPA_vect:
    push bit16lsbreg  
    push tmpL
    push tmpH
    push temp
    push temp2
    in   temp, _SFR_IO_ADDR(SREG)
    push temp    
    
    ldi  temp,0x04
    ldi  temp2,0x00  
    sub  toneCountAL,temp
    sbc  toneCountAH,temp2
    brmi lbltcAsk
    breq lbltcAsk
    rjmp lbltcA
lbltcAsk:  
    ldi  temp,0x02 
    eor  ntVal,temp         
    bst  ntVal,0x01
    brtc lbltcAper 
    clr  toneCountAL
    clr  toneCountAH
lbltcAper:      
    lds  temp,toneA
    lds  temp2,toneA+1
    add  toneCountAL,temp         
    adc  toneCountAH,temp2
lbltcA:
    ldi  temp,0x04
    ldi  temp2,0x00  
    sub  toneCountBL,temp
    sbc  toneCountBH,temp2
    brmi lbltcBsk
    breq lbltcBsk
    rjmp lbltcB
lbltcBsk:  
    ldi  temp,0x04 
    eor  ntVal,temp 
    bst  ntVal,0x02
    brtc lbltcBper 
    clr  toneCountBL
    clr  toneCountBH
lbltcBper:      
    lds  temp,toneB
    lds  temp2,toneB+1
    add  toneCountBL,temp         
    adc  toneCountBH,temp2
lbltcB:
    ldi  temp,0x04
    ldi  temp2,0x00  
    sub  toneCountCL,temp
    sbc  toneCountCH,temp2
    brmi lbltcCsk
    breq lbltcCsk
    rjmp lbltcC
lbltcCsk:  
    ldi  temp,0x08 
    eor  ntVal,temp 
    bst  ntVal,0x03
    brtc lbltcCper 
    clr  toneCountCL
    clr  toneCountCH
lbltcCper:      
    lds  temp,toneC
    lds  temp2,toneC+1
    add  toneCountCL,temp         
    adc  toneCountCH,temp2
lbltcC:
    ;noise generator 
;    lds  temp,_noisePeriod
;    cpi  temp,0x02
;    brcs lblncsk
    ldi  temp,0x02   
    sub  noiseCount,temp
    brcs lblncsk
    breq lblncsk
    rjmp lblnoise
lblncsk:       
    bst  noiseSeedH,5
    bld  temp,0   
    eor  temp,ntVal
    ror  ntVal
    com  temp
    ror  temp
    rol  noiseSeedL
    rol  noiseSeedH
    rol  ntVal     
    lds  temp,noisePeriod
    add  noiseCount,temp      
lblnoise:
    ;envelope generator        
;    lds  temp,_envelopePeriod
;    cpi  temp,0x02
;    lds  temp,_envelopePeriod+1
;    ldi  temp2,0x00
;    cpc  temp,temp2
;    brcs lblensk  
;lblenmi:      
    ldi  temp,0x02
    sub  envelopeCountL,temp
    ldi  temp2,0x00
    sbc  envelopeCountH,temp2
    brcs lblensk
    breq lblensk
    rjmp lblenvelopeSkip
lblensk: 
    lds  temp,envelopePeriod
    lds  temp2,envelopePeriod+1
    add  envelopeCountL,temp
    adc  envelopeCountH,temp2
    ;calc _envelopeAmpl
    lds  temp2,envelopeType
    mov  temp,temp2
    andi temp,0x0C
    breq lblenv01239
    cpi  temp,0x04
    breq lblenv4567F
    mov  temp,temp2
    cpi  temp,0x08
    breq lblenv8
    cpi  temp,0x09
    breq lblenv01239
    cpi  temp,0x0A
    breq lblenvA
    cpi  temp,0x0B
    breq lblenvB
    cpi  temp,0x0C
    breq lblenvC
    cpi  temp,0x0D
    breq lblenvD
    cpi temp,0x0E
    breq lblenvE
    cpi temp,0x0F
    breq lblenv4567F
lblenvelopeSkip:
    rjmp lblenvelope
lblenv4567F:
    tst  envelopeAmpl
    brmi lblenvelopeSkip
    inc  envelopeAmpl
    ldi  temp,0x10
    cp   temp,envelopeAmpl
    brne lblenvelope
    ldi  temp,0x80
    mov  envelopeAmpl,temp    
    rjmp lblenvelope
lblenv01239:
    tst  envelopeAmpl
    brmi lblenvelope
    dec  envelopeAmpl
    brpl lblenvelope
    ldi  temp,0x80
    mov  envelopeAmpl,temp    
    rjmp lblenvelope
lblenv8:
    dec  envelopeAmpl
    ldi  temp,0x0F
    and  envelopeAmpl,temp
    rjmp lblenvelope
lblenvA:
    tst  envelopeAmpl
    brmi lblenvAsp
    dec  envelopeAmpl
    brpl lblenvelope
    ldi  temp,0x80
    mov  envelopeAmpl,temp
    rjmp lblenvelope
lblenvAsp:
    inc  envelopeAmpl 
    ldi  temp,0x90
    cp   temp,envelopeAmpl 
    brne lblenvelope
    ldi  temp,0x0F
    mov  envelopeAmpl,temp 
    rjmp lblenvelope
lblenvB:
    tst  envelopeAmpl
    brmi lblenvelope
    dec  envelopeAmpl
    brpl lblenvelope
    ldi  temp,0x8F
    mov  envelopeAmpl,temp    
    rjmp lblenvelope
lblenvC:
    inc  envelopeAmpl
    ldi  temp,0x0F
    and  envelopeAmpl,temp
    rjmp lblenvelope
lblenvD:
    tst  envelopeAmpl
    brmi lblenvelope
    inc  envelopeAmpl
    ldi  temp,0x10
    cp   temp,envelopeAmpl
    brne lblenvelope
    ldi  temp,0x8F
    mov  envelopeAmpl,temp    
    rjmp lblenvelope
lblenvE:
    tst  envelopeAmpl
    brmi lblenvEsp
    inc  envelopeAmpl
    ldi  temp,0x10
    cp  temp,envelopeAmpl
    brne lblenvelope
    ldi  temp,0x8F
    mov  envelopeAmpl,temp
    rjmp lblenvelope
lblenvEsp:
    dec  envelopeAmpl
    brmi lblenvelope
    clr  envelopeAmpl
lblenvelope: 
    
    cbi  _SFR_IO_ADDR(PORTB),3;WS=0
    lds  bit16lsbreg,bit16lsb
    lsr  bit16lsbreg
    lds  temp,bit16LeftH
    ror  temp
    rol  bit16lsbreg      
    out  _SFR_IO_ADDR(SPDR),temp  

    ;syntheserA                  
    ldi  temp2,0x01                       
    lds  temp,mixer
    andi temp,0x01
    brne lblmixertoneA
    mov  temp,ntVal
    andi temp,0x02;AAA
    brne lblmixertoneA 
    clr  temp2
lblmixertoneA:          
    lds  temp,mixer
    andi temp,0x08
    brne lblmixernoiseA
    mov  temp,ntVal
    andi temp,0x01
    brne lblmixernoiseA 
    clr  temp2
lblmixernoiseA:
    tst  temp2
    breq lblmixerstatA
    lds  temp2,amplA
    bst  temp2,4
    brtc lblmixerstatA 
    mov  temp2,envelopeAmpl  
    andi temp2,0x0F  
lblmixerstatA:
    sts  dacA,temp2

    lsr  bit16lsbreg
    lds  temp,bit16LeftL
    ror  temp
    rol  bit16lsbreg
    out  _SFR_IO_ADDR(SPDR),temp  

    ;syntheserB                
    ldi  temp2,0x01                       
    lds  temp,mixer
    andi temp,0x02
    brne lblmixertoneB
    mov  temp,ntVal
    andi temp,0x04
    brne lblmixertoneB 
    clr  temp2
lblmixertoneB:          
    lds  temp,mixer
    andi temp,0x10
    brne lblmixernoiseB
    mov  temp,ntVal
    andi temp,0x01
    brne lblmixernoiseB 
    clr  temp2
lblmixernoiseB:
    tst  temp2
    breq lblmixerstatB
    lds  temp2,amplB
    bst  temp2,4
    brtc lblmixerstatB 
    mov  temp2,envelopeAmpl  
    andi temp2,0x0F  
lblmixerstatB:
    sts  dacB,temp2     
    
    sbi  _SFR_IO_ADDR(PORTB),3;WS=1
    lsr  bit16lsbreg
    lds  temp,bit16RightH
    ror  temp
    rol  bit16lsbreg
    out  _SFR_IO_ADDR(SPDR),temp  

    ;syntheserC                  
    ldi  temp2,0x01                       
    lds  temp,mixer
    andi temp,0x04
    brne lblmixertoneC
    mov  temp,ntVal
    andi temp,0x08
    brne lblmixertoneC 
    clr  temp2
lblmixertoneC:          
    lds  temp,mixer
    andi temp,0x20
    brne lblmixernoiseC
    mov  temp,ntVal
    andi temp,0x01
    brne lblmixernoiseC 
    clr  temp2
lblmixernoiseC:
    tst  temp2
    breq lblmixerstatC
    lds  temp2,amplC
    bst  temp2,4
    brtc lblmixerstatC 
    mov  temp2,envelopeAmpl  
    andi temp2,0x0F  
lblmixerstatC:
    sts  dacC,temp2      
    
    lsr  bit16lsbreg
    lds  temp,bit16RightL
    ror  temp
    rol  bit16lsbreg
    out  _SFR_IO_ADDR(SPDR),temp  
    sts  bit16lsb,bit16lsbreg
    
//bit16
    lds  temp2,dacA
    lsl  temp2 
    ldi  temp,lo8(dactableAC)  
    add  temp,temp2 
    ldi  temp2,hi8(dactableAC) 
    brcc lbllpmA
    inc  temp2
lbllpmA:
    lpm  tmpL,Z+
    sts  bit16LeftL,tmpL     
    lpm  tmpL,Z
    sts  bit16LeftH,tmpL     

    lds  temp2,dacC
    lsl  temp2 
    ldi  temp,lo8(dactableAC) 
    add  temp,temp2 
    ldi  temp2,hi8(dactableAC)
    brcc lbllpmC
    inc  temp2
lbllpmC:
    lpm  tmpL,Z+
    sts  bit16RightL,tmpL     
    lpm  tmpL,Z
    sts  bit16RightH,tmpL     

    lds  temp2,dacB
    lsl  temp2 
    ldi  temp,lo8(dactableB)  
    add  temp,temp2 
    ldi  temp2,hi8(dactableB) 
    brcc lbllpmB
    inc  temp2
lbllpmB:
    lpm  tmpL,Z+     
    lpm  tmpH,Z
        
    ;mix B to A and C and output
    lds  temp,bit16LeftL
    lds  temp2,bit16LeftH
    add  temp,tmpL
    adc  temp2,tmpH
    sts  bit16LeftL,temp
    sts  bit16LeftH,temp2
    lds  temp,bit16RightL
    lds  temp2,bit16RightH
    add  temp,tmpL
    adc  temp2,tmpH
    sts  bit16RightL,temp
    sts  bit16RightH,temp2
        
    pop  temp
    out  _SFR_IO_ADDR(SREG),temp
    pop  temp2
    pop  temp
    pop  tmpH
    pop  tmpL 
    pop  bit16lsbreg
    reti