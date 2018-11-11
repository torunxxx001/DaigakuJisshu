; edit date in 2010/05/04 20:37

	list P=PIC16F84A
	INCLUDE "P16F84A.INC"

	__CONFIG _HS_OSC & _WDT_ON & _PWRTE_ON & _CP_OFF

	
ARG0 EQU 0x0C       ;引数用変数１
ARG1 EQU 0x0D       ;引数用変数２
ARG2 EQU 0x0E       ;引数用変数３
SELC EQU 0x0F       ;アクション選択カウント変数
FLGS EQU 0x10       ;ＰＩＣリセット用フラグ
WREGTMP EQU 0x11    ;汎用Wレジスタ退避変数
ACMEM1 EQU 0x12     ;ACTION関数用変数１
ACMEM2 EQU 0x13     ;ACTION関数用変数２
ACMEM3 EQU 0x14     ;ACTION関数用変数３
WTMEM1 EQU 0x15     ;WAIT関数用変数１
WTMEM2 EQU 0x16     ;WAIT関数用変数２
WTMEM3 EQU 0x17     ;WAIT関数用変数３
WTMEM4 EQU 0x18     ;WAIT関数用変数４
WTARG0 EQU 0x19     ;WAIT関数用ARG0退避変数
BPMEM1 EQU 0x1A     ;BEEP関数用変数１
BPMEM2 EQU 0x1B     ;BEEP関数用変数２
BPMEM3 EQU 0x1C     ;BEEP関数用変数３
BPMEM4 EQU 0x1D     ;BEEP関数用変数４
BPARG0 EQU 0x1E     ;BEEP関数用ARG0退避変数
BPARG1 EQU 0x1F     ;BEEP関数用ARG1退避変数
PSMEM1 EQU 0x20     ;PLAYSCALE関数用変数１
PSMEM2 EQU 0x21     ;PLAYSCALE関数用変数２
PSMEM3 EQU 0x22     ;PLAYSCALE関数用変数３
PSMEM4 EQU 0x23     ;PLAYSCALE関数用変数４
PSWREG EQU 0x24     ;PLAYSCALE関数用Wレジスタ退避変数
PSARG0 EQU 0x25     ;PLAYSCALE関数用ARG0退避変数
DLWREG EQU 0x26     ;DRAWLED関数用Wレジスタ退避変数
DSMEM1 EQU 0x27     ;DRAWSEG関数用変数１
DSARG0 EQU 0x28     ;DRAWSEG関数用ARG0退避変数
DSWREG EQU 0x29     ;DRAWSEG関数用Wレジスタ退避変数
INTRMEM1 EQU 0x2A   ;割込み用変数１
INTRMEM2 EQU 0x2B   ;割込み用変数２
INTRWREG EQU 0x2C   ;割込み用Wレジスタ退避変数
INTRARG0 EQU 0x2D   ;割込み用ARG0退避変数
SEGNUM EQU 0x2E     ;8セグ表示用変数
BLEDNUM EQU 0x2F    ;8ビットLED表示用変数
RLEDNUM EQU 0x30    ;ルーレットLED表示用変数
DRAWFLG EQU 0x31    ;描画用フラグ変数
                    ;------------------フラグ分布------------------
                    ;0-3 :描画フラグ１，２，３，４
                    ;4-5 :描画選択カウント
                    ;6   :SEGNUM変数の上位4ビットが0でも左側の8セグに表示するか
                    ;7   :描画使用フラグ
                    ;-------------------------------------------
SWFLG EQU 0x32      ;スイッチ用フラグ変数
                    ;------------------フラグ分布------------------
                    ;0-2 :スイッチフラグ１，２，３
                    ;7   :スイッチ使用フラグ
                    ;-------------------------------------------
                    

	ORG 0
	GOTO MAIN
	ORG 0x04
	GOTO INTR
INTR
	BTFSC FLGS, 1           ;リセットフラグが１ならば
	RETFIE                  ;割込み許可で終了
	CLRWDT                  ;ウォッチドックタイマクリア
	BTFSS FLGS, 0           ;リセット許可フラグが０なら
	GOTO C_ESC_SKIP         ;リセットボタンのチャックを飛ばす
	BTFSS PORTA, 4          ;3番目のスイッチが押されていたら
	BSF FLGS, 1             ;リセットフラグを１に
C_ESC_SKIP
	BTFSS SWFLG, 7          ;スイッチ使用フラグが０ならば
	GOTO C_SW_SKIP          ;スイッチチェックを飛ばす
	BTFSS PORTA, 2
	BSF SWFLG, 0
	BTFSS PORTA, 3
	BSF SWFLG, 1
	BTFSS PORTA, 4
	BSF SWFLG, 2
C_SW_SKIP
	MOVWF INTRWREG          ;Wレジスタ退避
	
	BTFSS DRAWFLG, 7        ;描画使用フラグが０ならば
	GOTO D_RET_END          ;描画処理をせずに終了処理へ
	MOVLW B'1111'
	ANDWF DRAWFLG, W        ;DRAWFLGの下位4ビットと論理和をとって
	BTFSC STATUS, Z         ;ゼロならば
	GOTO D_RET_END          ;描画処理をせずに終了処理へ
	GOTO D_RET_SKIP         ;描画処理へ
D_RET_END
	BCF INTCON, T0IF        ;割込みフラグをリセット
	MOVLW 0xFF
	MOVWF PORTB             ;PORTBの全出力をＨＩに
	MOVF INTRWREG, W        ;退避していたWレジスタを復元
	RETFIE                  ;割込み許可で終了
D_RET_SKIP
	MOVF ARG0, W
	MOVWF INTRARG0          ;ARG0変数退避
	
	SWAPF DRAWFLG, W        ;DRAWFLGを入れ替えて、Wレジスタに代入し
	ADDLW B'1'              ;1を加算して
	ANDLW B'11'             ;下位2ビットのみ取り出して
	MOVWF INTRMEM1          ;INTRMEM1とINTMEM2変数に代入
	MOVWF INTRMEM2
	SWAPF INTRMEM1, F       ;加算された描画選択カウントを上下入れ替えて
	MOVF DRAWFLG, W         ;
	ANDLW B'11001111'       ;
	IORWF INTRMEM1, W       ;
	MOVWF DRAWFLG           ;DRAWFLG変数に戻す
	CLRF PCLATH             ;上位プログラムカウンタを０に
	MOVF INTRMEM2, W
	ADDWF PCL, F            ;下位プログラムカウンタに描画選択カウントを加算
	GOTO INTR_DRAW_1        ;描画処理１へ
	GOTO INTR_DRAW_2        ;描画処理２へ
	GOTO INTR_DRAW_3        ;描画処理３へ
	GOTO INTR_DRAW_4        ;描画処理４へ
	
INTR_DRAW_1
	BTFSS DRAWFLG, 0
	GOTO INTR_DRAW_END      ;描画フラグ１が０ならば描画処理終了へ
	MOVLW B'0'
	MOVWF ARG0
	MOVF SEGNUM, W          ;引数１に０を、WレジスタにSEGNUM変数の値を代入し
	CALL DRAWSEG            ;DRAWSEG関数呼び出し
	BCF INTCON, T0IF        ;割込みフラグをリセット
	GOTO INTR_DRAW_END      ;描画処理終了へ
INTR_DRAW_2
	BTFSS DRAWFLG, 1
	GOTO INTR_DRAW_END      ;描画フラグ２が０ならば描画処理終了へ
	BTFSC DRAWFLG, 6        ;SEGNUM変数の上位ビットアンチェックフラグが１ならば
	GOTO INTR_DRAW_2SKIP    ;常に上位ビットも８セグに表示するようにする
	MOVF SEGNUM, W
	ANDLW B'11110000'
	BTFSC STATUS, Z
	GOTO INTR_DRAW_END      ;SEGNUM変数の上位ビットが０ならば何もせずに描画処理終了へ
INTR_DRAW_2SKIP
	MOVLW B'1'
	MOVWF ARG0
	MOVF SEGNUM, W
	CALL DRAWSEG            ;引数１に１を、WレジスタにSEGNUM変数の値を代入し、DRAWSEG関数呼び出し
	BCF INTCON, T0IF        ;割込みフラグをリセット
	GOTO INTR_DRAW_END      ;描画処理終了へ
INTR_DRAW_3
	BTFSS DRAWFLG, 2
	GOTO INTR_DRAW_END      ;描画フラグ３が０ならば描画処理終了へ
	MOVLW B'11'
	MOVWF ARG0              ;引数１に、B'11'を代入して
	COMF BLEDNUM, W         ;BLEDNUM変数を反転してWレジスタに代入し
	CALL DRAWLED            ;DRAWLED関数呼び出し
	BCF INTCON, T0IF        ;割込みフラグをリセット
	GOTO INTR_DRAW_END      ;描画処理終了へ
INTR_DRAW_4
	BTFSS DRAWFLG, 3
	GOTO INTR_DRAW_END      ;描画フラグ４が０ならば描画処理終了へ
	MOVLW B'10'
	MOVWF ARG0              ;引数１に、B'10'を代入して
	COMF RLEDNUM, W         ;RLEDNUM変数を反転してWレジスタに代入し
	CALL DRAWLED            ;DRAWLED関数呼び出し
	BCF INTCON, T0IF        ;割込みフラグをリセット
	
INTR_DRAW_END
	MOVF INTRARG0, W
	MOVWF ARG0              ;退避していたARG0変数を復元
	MOVF INTRWREG, W        ;退避していたWレジスタを復元
	RETFIE                  ;割込み許可で終了
	
MAIN
	BSF STATUS, RP0         ;バンク１を選択
	CLRF TRISB              ;PORTBの入出力設定を、全出力に
	MOVLW B'10000110'       ;プリスケーラをTMR0に使用し
	MOVWF OPTION_REG        ;スケールを1:128に
	BCF STATUS, RP0         ;バンク０を選択
	MOVLW B'10100000'
	MOVWF INTCON            ;TMR0割込み、グローバル割り込みを許可
	MOVLW B'11111111'
	IORWF PORTB, F          ;PORTBの出力をすべてＨＩに
	
	CLRF TMR0
	CLRF SELC
	CLRF FLGS
	CLRF DRAWFLG
	CLRF SEGNUM
	CLRF BLEDNUM
	CLRF RLEDNUM
	
	CALL WAIT400MS
	
	CALL INITSWITCH         ;スイッチ使用設定
	CALL INITLED            ;LED使用設定
	BSF DRAWFLG, 0          ;
	BSF DRAWFLG, 1          ;描画フラグ１，２を１に
MAIN_LOOP
	CALL CLRSW              ;スイッチフラグリセット関数呼び出し
	CALL WAIT400MS          ;スイッチ用ウェイト
	MOVF SELC, W
	MOVWF SEGNUM            ;SEGNUM変数に、SELC変数を代入

	MOVF SELC, W           ;SELC変数の内容をWレジスタに代入
	BTFSC SWFLG, 2         ;スイッチフラグ２が１ならば
	CALL ACTION            ;ACTION関数呼び出し
	BCF FLGS, 0            ;リセット許可フラグを０に
	
	BTFSC SWFLG, 0         ;スイッチフラグ１が１ならば
	GOTO SEL_DEC           ;SELC変数を減算する
	BTFSC SWFLG, 1         ;スイッチフラグ２が１ならば
	GOTO SEL_INC           ;SELC変数を加算する
	GOTO MAIN_LOOP
SEL_INC
	INCF SELC, F
	MOVF SELC, W
	SUBLW D'8'
	BTFSS STATUS, C        ;SELC変数が、８を超えたら
	GOTO INC_OVER
	GOTO MAIN_LOOP
INC_OVER
	CLRF SELC              ;SELC変数を０に
	GOTO MAIN_LOOP
SEL_DEC
	DECF SELC, F
	MOVF SELC, W
	XORLW 0xFF
	BTFSC STATUS, Z        ;SELC変数が0のときに、減算したら
	GOTO DEC_ZERO
	GOTO MAIN_LOOP
DEC_ZERO
	MOVLW D'8'
	MOVWF SELC             ;SELC変数を８に
	GOTO MAIN_LOOP
	
;MAIN ACTION FUNCTION
ACTION
	MOVWF ACMEM1           ;Wレジスタの内容を、ACMEM1変数へ
	CALL WAIT400MS
	MOVF ACMEM1, W
	SUBLW D'8'
	BTFSS STATUS, C        ;ACMEM1変数の値が8を超えていたら
	RETURN                 ;終了
	MOVF ACMEM1, W
	CLRF PCLATH            ;上位プログラムカウンタを０に
	ADDWF PCL, F           ;下位プログラムカウンタの内容に、ACMEM1変数の値を代入
	GOTO ACT0
	GOTO ACT1
	GOTO ACT2
	GOTO ACT3
	GOTO ACT4
	GOTO ACT5
	GOTO ACT6
	GOTO ACT7
	GOTO ACT8

;実験１ 図１のLED 駆動回路１を用いて８ビットの２進数の値を１秒間隔で00000000 から00001111 までの値を順次発光させるプログラムを作れ。	
ACT0
	BSF FLGS, 0            ;リセット許可フラグを１に
	
	CLRF DRAWFLG           ;描画フラグ用変数をリセット
	CALL INITLED           ;LED使用設定
	BSF DRAWFLG, 2         ;描画フラグ３を１に
	CLRF BLEDNUM
ACTION_LOOP0
	CALL WAIT1SEC
	INCF BLEDNUM, F
	MOVF BLEDNUM, W
	XORLW B'00001111'
	BTFSS STATUS, Z
	GOTO ACTION_LOOP0      ;BLEDNUM変数の値がB'00001111'になったらGOTOをスキップ
	CALL WAIT1SEC          ;1秒待って終わる
	GOTO ACTION_END

;実験２ ２つの８ゼグメントLED を制御して異なる２つの１６進数値をあたかも同時に表示されているようするプログラムを作り実行させよ。
ACT1
	BSF FLGS, 0            ;リセット許可フラグを１に
	BSF DRAWFLG, 6         ;SEGHI表示フラグを1に
	
	CLRF SEGNUM
	CLRF DRAWFLG
	CALL INITLED           ;LED使用設定
	BSF DRAWFLG, 0
	BSF DRAWFLG, 1         ;描画フラグ１，２を１に
ACTION_LOOP1
	CALL WAIT100MS
	INCF SEGNUM, F         ;100msごとに、SEGNUM変数の値を加算
	GOTO ACTION_LOOP1
	
	GOTO ACTION_END
	
;実験３ 圧電スピーカ回路を利用して１ KH ｚの信号を鳴らすプログラムを作り実行させよ。  ←1秒間再生します
ACT2

	BSF FLGS, 0            ;リセット許可フラグを１に
	
	BCF DRAWFLG, 7         ;描画使用フラグを０に
	
	CALL INITBEEP          ;ブザー使用設定
	MOVLW D'250'
	MOVWF ARG2
	MOVLW D'4'
	MOVWF ARG1
	MOVLW D'100'
	MOVWF ARG0
	MOVLW D'1'
	CALL BEEP              ;1KHzの音を1秒間鳴らすように設定し、BEEP関数呼び出し
	
	GOTO ACTION_END
	
;実験４ 圧電スピーカ回路を使って１ KH ｚの信号を２秒間発振し４秒間発振を止める無限ループプログラムを作り実行させよ。
ACT3
	BSF FLGS, 0            ;リセット許可フラグを１に
	
	BCF DRAWFLG, 7         ;描画使用フラグを０に
	
	CALL INITBEEP          ;ブザー使用設定
ACTION_LOOP3
	MOVLW D'250'
	MOVWF ARG2
	MOVLW D'8'
	MOVWF ARG1
	MOVLW D'100'
	MOVWF ARG0
	MOVLW D'1'
	CALL BEEP              ;1KHzの音を2秒間鳴らすように設定し、BEEP関数呼び出し
	MOVLW D'250'
	MOVWF ARG1
	MOVLW D'228'
	MOVWF ARG0
	MOVLW D'7'
	CALL WAIT              ;4秒間待つように設定し、WAIT関数呼び出し
	GOTO ACTION_LOOP3
	
	GOTO ACTION_END
	
;実験５ タッチセンサーにタッチすると図３のLED 駆動回路１の出力が点滅を繰り返すプログラムを作り実行させよ。繰り返す周期は１秒にすること。
ACT4
	BSF FLGS, 0            ;リセット許可フラグを１に
	
	CALL INITTOUCHSENSOR   ;タッチセンサー使用設定
ACTION_LOOP4
	BTFSC PORTA, 0
	GOTO ACTION_LOOP4      ;タッチセンサーが触られるまで待つ
	
	CLRF BLEDNUM
	CLRF DRAWFLG
	CALL INITLED           ;LED使用設定
	BSF DRAWFLG, 2         ;描画フラグ３を１に
ACTION_LOOP4_2
	COMF BLEDNUM, F        ;BLEDNUM変数を反転
	CALL WAIT1SEC          ;1秒待つ
	GOTO ACTION_LOOP4_2
	
	GOTO ACTION_END
	
;実験６ ３つのうちの１つのみを用いてスイッチを押した回数を表示回路１に表示するプログラムを作り実行させよ。
ACT5
	BSF FLGS, 0            ;リセット許可フラグを１に
	
	CLRF SEGNUM
	CLRF BLEDNUM
	CLRF DRAWFLG
	CALL INITSWITCH        ;スイッチ使用設定
	CALL INITLED           ;LED使用設定
	BSF DRAWFLG, 0         ;
	BSF DRAWFLG, 1         ;
	BSF DRAWFLG, 2         ;描画フラグ１，２，３を１に
	CLRF ACMEM1
ACTION_LOOP5
	CALL CLRSW             ;スイッチフラグ１，２，３クリア
	CALL WAIT400MS         ;スイッチ用ウェイト
	
	BTFSC SWFLG, 0         ;スイッチフラグ１が１ならば
	INCF BLEDNUM, F        ;BLEDNUM変数を加算する
	BTFSC SWFLG, 1         ;スイッチフラグ２が１ならば
	CLRF BLEDNUM           ;BLEDNUM変数をクリア
	
	MOVF BLEDNUM, W
	MOVWF SEGNUM           ;SEGNUM変数にBLEDNUM変数の値を代入
	GOTO ACTION_LOOP5
	
	GOTO ACTION_END
	
;実験７ LED 駆動回路３を用いて数字の１からF までの数字を１秒間隔で順次表示していくプログラムをつくり実行させよ。 ←少し改造しました
ACT6
	BSF FLGS, 0            ;リセット許可フラグを１に
	
	CALL INITSWITCH        ;スイッチ使用設定
	CLRF DRAWFLG
	CALL INITLED           ;描画使用設定
	BSF DRAWFLG, 0
	BSF DRAWFLG, 1
	BSF DRAWFLG, 2         ;描画フラグ１，２，３を１に
	
	CLRF SEGNUM
	CLRF BLEDNUM
ACTION_LOOP6
	MOVLW D'10'            ;100msを10回繰り返して1秒を作り出す
	MOVWF ACMEM1
ACTION_LOOP6_2
	CALL CLRSW             ;スイッチフラグ１，２，３をクリア
	CALL WAIT100MS
	
	BTFSC SWFLG, 0         ;スイッチフラグ１が１ならば
	CLRF SEGNUM            ;SEGNUM変数をクリア
	BTFSC SWFLG, 0         ;スイッチフラグ１が１ならば
	CLRF BLEDNUM           ;BLEDNUM変数をクリア
	DECFSZ ACMEM1, F       ;ACMEM1変数を減算して
	GOTO ACTION_LOOP6_2    ;０になったらGOTOをスキップ
	
	INCF SEGNUM, F         ;SEGNUM変数を加算して
	BTFSC STATUS, Z        ;一周したら
	INCF BLEDNUM, F        ;BLEDNUM変数を加算
	GOTO ACTION_LOOP6
	
	GOTO ACTION_END
	
;実験８ LED 表示回路２を用いて高速で００００００００ B から１１１１１１１１ B まで変化させながら表示させスイッチキーを押したときに表示している値を
;LED 表示回路１に表示するプログラムを作り実行させよ。
ACT7
	BSF FLGS, 0            ;リセット許可フラグを１に
	
	CALL INITSWITCH        ;スイッチ使用設定
	CLRF DRAWFLG
	CALL INITLED           ;LED使用設定
	BSF DRAWFLG, 0
	BSF DRAWFLG, 1
	BSF DRAWFLG, 2         ;描画フラグ１，２，３を１に
	
	CLRF SEGNUM
	CLRF BLEDNUM
	
	CLRF ACMEM1
ACTION_LOOP7
	CALL CLRSW            ;スイッチフラグ１，２，３をクリア
	CALL WAIT400MS        ;スイッチ用ウェイト
	INCF BLEDNUM, F       ;BLEDNUMを加算
	BTFSS SWFLG, 0        ;スイッチフラグ１が１ならば
	GOTO ACTION_LOOP7     ;ループを抜ける
	
	MOVF BLEDNUM, W
	MOVWF SEGNUM          ;SEGNUM変数に、BLEDNUM変数をコピー
	CALL WAIT1SEC
	
	GOTO ACTION_END
	
;オリジナル（３オクターブの音階再生プログラム）
ACT8
	BSF FLGS, 0            ;リセット許可フラグを１に
	
	CLRF DRAWFLG
	CALL INITSWITCH        ;スイッチ使用設定
	CALL INITLED           ;LED使用設定
	BSF DRAWFLG, 0
	BSF DRAWFLG, 1         ;描画フラグ１，２を１に
	BSF DRAWFLG, 6
	
	CLRF ACMEM1
	CLRF ACMEM2
ACTION_LOOP8
	CALL CLRSW             ;スイッチ使用設定
	CALL WAIT400MS         ;スイッチ用ウェイト
	CLRF SEGNUM            ;SEGNUM変数をクリアして
	MOVF ACMEM2, W         ;
	IORWF SEGNUM, F        ;
	SWAPF ACMEM1, W        ;
	ANDLW B'11110000'      ;上位4ビットにACMEM1変数の下位4ビットの内容を
	IORWF SEGNUM, F        ;下位4ビットにACMEM2変数の下位4ビットの内容を代入する
	
	BTFSC SWFLG, 0         ;スイッチフラグ１が１ならば
	INCF ACMEM1, F         ;ACMEM1変数を加算する
	MOVF ACMEM1, W
	SUBLW D'10'
	BTFSC STATUS, C        ;ACMEM1変数の内容が、10以内ならば
	GOTO ACTION_SKIP8      ;通常処理へジャンプ
	CLRF ACMEM1            ;10を超えていたら、ACMEM1の内容をクリアして
	INCF ACMEM2, F         ;ACMEM2の内容を加算
	MOVF ACMEM2, W
	SUBLW D'3'             ;ACMEM2が3を超えていなければ
	BTFSC STATUS, C
	GOTO ACTION_SKIP8      ;通常処理へ戻る
	CLRF ACMEM2            ;超えていれば、ACMEM2をクリア
ACTION_SKIP8
	BTFSS SWFLG, 1         ;スイッチフラグ２が１ならば
	GOTO ACTION_SKIP8_2    ;GOTO文を飛ばして、音階を再生する
	
	BCF DRAWFLG, 7	       ;描画使用フラグを０に
	CALL INITBEEP          ;ビープ使用設定
	MOVLW D'20'
	MOVWF ARG0
	MOVF SEGNUM, W         ;SEGNUM変数の上位4ビットを半音に、下位4ビットをオクターブに設定して
	CALL PLAYSCALE         ;PLAYSCALE関数呼び出し
	BSF DRAWFLG, 7         ;描画使用フラグを１に
	
	CALL INITSWITCH        ;スイッチ使用設定
ACTION_SKIP8_2
	GOTO ACTION_LOOP8
	GOTO ACTION_END
	
ACTION_END
	CALL INITLED           ;LED使用設定
	CALL INITSWITCH        ;スイッチ使用設定
	CALL CLRSW             ;スイッチフラグ１，２，３をクリア
	MOVF DRAWFLG, W
	ANDLW B'11110000'      ;DRAWFLG変数の下位4ビットを０にして
	ADDLW B'11'            ;B'11'を加算する
	MOVWF DRAWFLG
	BCF DRAWFLG, 6         ;SEGHI表示フラグを０に
	RETURN
	
;1秒待つ関数
;250*200*2 *10 = 1,000,000 us
WAIT1SEC
	MOVLW D'250'
	MOVWF ARG1
	MOVLW D'200'
	MOVWF ARG0
	MOVLW D'2'
	CALL WAIT
	RETURN
	
;400ミリ秒待つ関数
;250*160*1 *10 = 400,000 us
WAIT400MS
	MOVLW D'250'
	MOVWF ARG1
	MOVLW D'160'
	MOVWF ARG0
	MOVLW D'1'
	CALL WAIT
	RETURN

;100ミリ秒待つ関数
;250*40*1 *10 = 100,000 us
WAIT100MS
	MOVLW D'250'
	MOVWF ARG1
	MOVLW D'40'
	MOVWF ARG0
	MOVLW D'1'
	CALL WAIT
	RETURN

;音階再生関数
; 使用引数 : Wレジスタ = 音階(上位4ビット：半音、下位4ビット：オクターブ)
;                    半音は０～１０まで、オクターブは０～３まで可能
;         : ARG0   = 再生時間 (* 50ms)
; 例：　Wレジスタ=0 && ARG0=20 （130Hzの音階を１秒間再生する）
PLAYSCALE
	MOVWF PSWREG            ;Wレジスタ退避
	MOVWF PSMEM1            ;Wレジスタの下位4ビットを
	MOVWF PSMEM2            ;
	MOVLW B'1111'           ;
	ANDWF PSMEM1, F         ;PSMEM1に
	SWAPF PSMEM2, F         ;
	ANDWF PSMEM2, W         ;上位4ビットを
	MOVWF PSMEM2            ;PSMEM2とPSMEM3に代入する
	MOVWF PSMEM3            ;
	MOVF PSMEM1, W          ;PSMEM1が
	SUBLW D'3'              ;３を超えていたら
	BTFSS STATUS, C         ;
	RETURN                  ;終了する
	MOVF PSMEM2, W          ;PSMEM2が
	SUBLW D'10'             ;１０を超えていたら
	BTFSS STATUS, C         ;
	RETURN                  ;終了する
	MOVF PSMEM2, W          ;PSMEM2の半音を引数に
	CALL GETTONETIME        ;半音の定数を取得し
	MOVWF PSMEM2            ;PSMEM2に代入
	MOVF PSMEM3, W          ;PSMEM3の半音を引数に
	CALL GETTONECOUNT       ;半音の定数を取得し
	MOVWF PSMEM3            ;PSMEM3に代入
	MOVF PSMEM1, F          ;PSMEM1のオクターブが
	BTFSC STATUS, Z         ;0ならば
	GOTO SKIP_2MUL          ;オクターブ上げ処理を飛ばす
LOOP_2MUL
	RRF PSMEM2, F           ;オクターブの数の分だけ
	BCF PSMEM2, 7           ;PSMEM2を2割する
	RLF PSMEM3, F           ;オクターブの数の分だけ
	BCF PSMEM3, 0           ;PSMEM3を2倍する
	DECFSZ PSMEM1, F        ;オクターブの数だけ繰り返したら
	GOTO LOOP_2MUL          ;ループを抜ける
SKIP_2MUL
	MOVF ARG0, W            ;ARG0を
	MOVWF PSARG0            ;退避する
	MOVWF PSMEM4            ;ARG0にある再生時間をPSMEM4へ
PLAY_LOOP
	MOVF PSMEM3, W          ;50msになるように回数計算した
	MOVWF ARG2              ;PSMEM3をARG2へ
	MOVLW D'1'
	MOVWF ARG1
	MOVF PSMEM2, W          ;周波数を求めた
	MOVWF ARG0              ;PSMEM2をARG0へ
	MOVLW D'3'
	CALL BEEP               ;ビープを鳴らす
	DECFSZ PSMEM4, F        ;再生時間の数だけ50msを繰り返す
	GOTO PLAY_LOOP
	
	MOVF PSARG0, W
	MOVWF ARG0              ;ARG0復元
	MOVF PSWREG, W          ;Wレジスタ復元
	RETURN

;ビープ再生関数
;　使用引数 : Wレジスタ,ARG0 ＝　特殊周波数指定（求め方： X = ((1/Hz)*1000*100)/Y ;(X <= 255):: ARG0 = X, Wレジスタ = Y）
;         : ARG1,ARG2   ＝　内部のループを何回するか（時間の求め方： ARG2*ARG1*ARG0*Wレジスタ*10us)
;         : 推奨設定：　ARG2 > ARG1
BEEP
	BCF PORTA, 3            ;ブザーを使用するためにRA3をLOWに
	MOVWF BPMEM1            ;Wレジスタの内容をBPMEM1に
	MOVF ARG0, W            ;
	MOVWF BPARG0            ;ARG0の内容を退避
	RRF ARG0, W             ;ARG0の内容を２割して
	ANDLW B'1111111'        ;
	MOVWF BPMEM2            ;BPMEM2に代入する
	MOVF ARG1, W            ;ARG1の内容を退避
	MOVWF BPARG1            ;
	MOVWF BPMEM3            ;ARG1の内容をBPMEM3に代入する
BEEP_LOOP2
	MOVF ARG2, W            ;
	MOVWF BPMEM4            ;ARG2の内容をBPMEM4に代入する
	
	MOVF BPMEM2, W          ;２割したARG0の内容を
	MOVWF ARG1              ;ARG1に代入
	MOVF BPMEM1, W
	MOVWF ARG0
	MOVLW D'1'
BEEP_LOOP1
	BCF PORTA, 2            ;ブザー系統の出力をLOWに
	CALL WAIT               ;上で指定した時間だけウェイト
	BSF PORTA, 2            ;ブザー系統の出力をHIに
	CALL WAIT               ;上で指定した時間だけウェイト
	DECFSZ BPMEM4, F        ;BPMEM4が０になったら
	GOTO BEEP_LOOP1         ;ループを抜ける
	DECFSZ BPMEM3, F        ;BPMEM3が０になったら
	GOTO BEEP_LOOP2         ;ブザーのループ終了
	
	MOVF BPARG1, W
	MOVWF ARG1              ;退避したARG1を復元
	MOVF BPARG0, W
	MOVWF ARG0              ;退避したARG0を復元
	MOVF BPMEM1, W          ;退避したWレジスタを復元
	RETURN
	
;８セグ表示用関数
; 使用引数　:　Wレジスタ　＝　表示データ
;         : ARG0　　　＝　セグメント選択（１：HighSeg, ０：LowSeg)
DRAWSEG
	MOVWF DSWREG            ;Wレジスタ退避
	MOVWF DSMEM1            ;Wレジスタの内容をDSMEM1に
	MOVF ARG0, W
	MOVWF DSARG0            ;ARG0の内容を退避
	
	BTFSC ARG0, 0           ;ARG0が１ならば
	GOTO DRAW_HIGHSEG       ;HISEG描画処理へ
	
	MOVLW 0x0F              ;下位４ビットを取り出し
	ANDWF DSMEM1, W         ;Wレジスタに代入し
	CALL CONVSEG            ;CONVSEG関数呼び出し
	MOVWF DSMEM1            ;結果をDSMEM1に代入
	
	MOVLW B'01'             ;LEDセレクト番号を指定
	MOVWF ARG0
	MOVF DSMEM1, W          ;描画データをWレジスタに
	CALL DRAWLED            ;DRAWLED関数呼び出し
	
	GOTO DRAWSEG_END        ;終了処理へ
DRAW_HIGHSEG
	SWAPF DSMEM1, F         ;DSMEM1の上下入れ替え
	MOVLW 0x0F              ;下位４ビット取り出し
	ANDWF DSMEM1, W         ;Wレジスタへ代入し
	CALL CONVSEG            ;CONVSEG関数呼び出し
	MOVWF DSMEM1            ;結果をDSMEM1に
	
	MOVLW B'00'             ;LEDセレクト番号指定
	MOVWF ARG0
	MOVF DSMEM1, W          ;描画データをWレジスタに代入し
	CALL DRAWLED            ;DRAWLED関数呼び出し
DRAWSEG_END
	MOVF DSARG0, W
	MOVWF ARG0              ;退避していたARG0の内容を復元
	MOVF DSWREG, W          ;退避していたWレジスタの内容を復元
	RETURN


;LED表示関数
; 使用引数 : Wレジスタ = 表示データ
;         : ARG0   = LEDセレクト番号
DRAWLED
	MOVWF DLWREG            ;Wレジスタの内容を退避
	MOVF PORTA, W           ;PORTAの状態を取り出し
	ANDLW B'11111100'       ;下位２ビットを０にして
	IORWF ARG0, W           ;ARG0のセレクト番号を書き込み
	MOVWF PORTA             ;PORTAに代入
	MOVF DLWREG, W          ;表示データを
	MOVWF PORTB             ;PORTBに出力
	
	MOVF DLWREG, W          ;退避していたWレジスタの内容を復元
	RETURN
	
;ウェイト関数
; 使用引数 : WREG, ARG0, ARG1 = 待ち時間（ WREG*ARG0*ARG1*10(us) )
; 推奨設定 : WREG < ARG0 < ARG1
WAIT
	MOVWF WREGTMP           ;Wレジスタの内容を退避
	MOVWF WTMEM1            ;Wレジスタの内容をWTMEM1に代入
	MOVF ARG1, W            ;ARG1の内容を
	MOVWF WTARG0            ;退避する
	MOVWF WTMEM2            ;さらにWTMEM2に代入する
	RRF WTMEM2, F           ;ここでWTMEM2の内容を
	RRF WTMEM2, F           ;
	RRF WTMEM2, F           ;８割する
	MOVF WTMEM2, W          ;WTMEM2の内容をWレジスタに書き込み
	RRF WTMEM2, F           ;さらにWTMEM2の内容を2割して
	RRF WTMEM2, F           ;擬似的に１０割を作り出す
	ANDLW B'11111'          ;Wレジスタに保存していた８割を
	MOVWF WTMEM3            ;余分なものを除いてWTMEM3へ代入
	MOVF WTMEM2, W          ;１０割したWTMEM2をWレジスタに代入し
	ANDLW B'111'            ;余分なものを取り除いて
	SUBWF WTMEM3, W         ;WTMEM3からその数を引きWレジスタに代入
	SUBWF ARG1, F           ;さらにARG1からその数を引く
	                        ;以上の処理で長時間の待ち時間で誤差が
	                        ;大きくなりすぎないように調整している
	                        
	MOVF ARG1, W            ;計算結果が
	SUBLW D'100'            ;１００を超えていたら
	BTFSS STATUS, C
	INCF ARG1, F            ;補正として１引く
WAIT_LOOP4
	MOVF ARG0, W
	MOVWF WTMEM2            ;ARG0の内容をWTMEM2に代入
WAIT_LOOP3
	MOVF ARG1, W
	MOVWF WTMEM3            ;ARG1の内容をWTMEM3に代入
WAIT_LOOP2 
	MOVLW D'10'
	MOVWF WTMEM4            ;WTMEM4に10を代入
WAIT_LOOP1
	NOP
	NOP
	DECFSZ WTMEM4, F        ;WTMEM4が０になったら
	GOTO WAIT_LOOP1         ;ループを抜ける
	DECFSZ WTMEM3, F        ;WTMEM3が０になったら
	GOTO WAIT_LOOP2         ;ループを抜ける
	DECFSZ WTMEM2, F        ;WTMEM2が０になったら
	GOTO WAIT_LOOP3         ;ループを抜ける
	DECFSZ WTMEM1, F        ;WTMEM1が０になったら
	GOTO WAIT_LOOP4         ;ウェイトループ終了
	MOVF WTARG0, W          ;退避していたARG1の内容を
	MOVWF ARG1              ;復元する
	MOVF WREGTMP, W         ;退避していたWレジスタの内容を復元
	RETURN

; スイッチフラグクリア用関数
CLRSW
	MOVLW B'10000000'
	ANDWF SWFLG, F
	RETURN


; 初期化関数群
INITTOUCHSENSOR
	BSF STATUS, RP0
	BSF TRISA, 0
	BCF STATUS, RP0
	
	BCF DRAWFLG, 7
	RETURN
INITCDS
	BSF STATUS, RP0
	BSF TRISA, 1
	BCF STATUS, RP0
	
	BSF PORTA, 1
	BCF DRAWFLG, 7
	RETURN
	
INITSWITCH
	BSF STATUS, RP0
	BSF TRISA, 2
	BSF TRISA, 3
	BCF STATUS, RP0
	
	CLRF SWFLG
	BSF SWFLG, 7
	RETURN
	
INITBEEP
	BSF STATUS, RP0
	BCF TRISA, 2
	BCF TRISA, 3
	BCF STATUS, RP0	
	
	BCF SWFLG, 7
	RETURN
INITLED
	BSF STATUS, RP0
	BCF TRISA, 0
	BCF TRISA, 1
	CLRF TRISB
	BCF STATUS, RP0
	
	BSF DRAWFLG, 7
	RETURN

;----------------定数用テーブル----------------
	ORG 0x3C8
	
;セグメント用表示定数テーブル
CONVSEG
	MOVWF WREGTMP
	MOVLW 0x3
	MOVWF PCLATH
	MOVF WREGTMP, W
	ADDWF PCL, F
	RETLW B'1000000' 
	RETLW B'1111001' 
	RETLW B'0100100' 
	RETLW B'0110000' 
	RETLW B'0011001'
	RETLW B'0010010' 
	RETLW B'0000010' 
	RETLW B'1011000' 
	RETLW B'0000000' 
	RETLW B'0010000' 
	RETLW B'0001000'
	RETLW B'0000011'
	RETLW B'1000110'
	RETLW B'0100001'
	RETLW B'0000110'
	RETLW B'0001110'

;音階表示プログラム用定数テーブル
GETTONETIME
	MOVWF WREGTMP
	MOVLW 0x3
	MOVWF PCLATH
	MOVF WREGTMP, W
	ADDWF PCL, F
	RETLW D'255'
	RETLW D'241'
	RETLW D'227'
	RETLW D'214'
	RETLW D'202'
	RETLW D'191'
	RETLW D'180'
	RETLW D'170'
	RETLW D'161'
	RETLW D'152'
	RETLW D'143'
	RETLW D'135'
	
;音階表示プログラム用定数テーブル
GETTONECOUNT
	MOVWF WREGTMP
	MOVLW 0x3
	MOVWF PCLATH
	MOVF WREGTMP, W
	ADDWF PCL, F
	RETLW D'7'
	RETLW D'7'
	RETLW D'7'
	RETLW D'8'
	RETLW D'8'
	RETLW D'9'
	RETLW D'9'
	RETLW D'10'
	RETLW D'10'
	RETLW D'11'
	RETLW D'12'
	RETLW D'12'
	
	END