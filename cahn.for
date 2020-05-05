	EXTERNAL WAIT
	DIMENSION TH(10), W(100), T(100)
	COMMON T, HT, DCOAL
	WRITE(5,1)
1	FORMAT(1X, '  INPUT DATA FILE:  '$)
	READ(5,2)DNAME
	FORMAT(A5)
2	OPEN(UNIT=1, FILE=DNAME)
	WRITE(5,6)
6	FORMAT(1X,'HEIGHT='$)
	READ(5,5)HT
5	FORMAT(F)
	WRITE(5,7)
7	FORMAT(1X,'COAL DENSITY='$)
	READ(5,8)DCOAL
8	FORMAT(F)
CCC
CCC
	NP=4
	READ(1,10)(TH(1), I=1, NP)
10	FORMAT(10F)
	I=1
15	READ(1,10,END=19) T(I), W(I)
	I=I+1
	GO TO 15
19	NOB=I-1
	MODNAM='WAIT'
CCC
CCC
	CALL TGQUIK(MODNAM, DNAME, WAIT, NOB, W, NP, TH)
CCC
CCC
	AMEAN=EXP(TH(1)+TH(2)*TH(2)/2)
	STDEV=EXP(2*TH(1)+TH(2)*TH(2))*
	1(EXP(TH(2)*TH(2)-1.))
	STDEV=SQRT(STDEV)
	WRITE(5,3)AMEAN
3	FORMAT(1X,'MEAN=',F10.4)
	WRITE(5,4)STDEV
4	FORMAT(1X,'STANDARD DEVIATION=',F10.4)
	WRITE(5,24)GMEAN
24	FORMAT(1X,'GMEAN=',F10.4)
	GSTD=EXP(TH(2))
	WRITE(5,25)GSTD
25	FORMAT(1X,'G STADARD DEVIATION=',F10.4) ! ed. note: sic
	CALL AREA(TH)
	CALL EXIT
	END
CCC
CCC
	SUBROUTINE WAIT (TH,F,NOB,NP)
	DIMENSION TH(10),F(100),T(100)
	COMMON T, HT, DCOAL
	C=423.*HT/(DCOAL-.78)
	DMIN=1.
	DMAX=1000.
	FCNST=SQRT(2.*3.1415926)
	DO 400 I=1,NOB
	DI=SQRT(C/((T(I)-TH(4)))) ! ed note: written by this line "dc cutoff diameter"
	IF(DI.LT.DMIN)GO TO 400
	DD=(DMAX-DMIN)/300.
	NMAX=(NMAX/2)*2+1
	NMIN=(NMIN/2)*2+1
	AMAX=NMAX-1
	HMIN=(DI-DMIN)/AMIN
	SUMFD=0.
	SUMXFD=0.
	XP=2.*TH(2)*TH(2)
	IF(I.GT.1)GO TO 702
	SUMAD=0
	DZ=1000./500.
	D=0
	DO 701 K=1,500
	D=D+DZ
	J=K/2
	J=J*2
	IF(J.EQ.K)GO TO 70
	CF=4.
	GO TO 80
70	CF=2.
80	CONTINUE
	RD=ALOG(D)-TH(1)
	RDT=RD*RD
	FD=1./(FCNST*TH(2)*D*EXP(RDT/XP))
	WD=FD*D
	SUMAD=SUMAD+WD*CF
701	CONTINUE
	SUMAD=SUMAD*DZ/3.
702	CONTINUE
	D=DI
	DO 500 K=1,NMAX
	IF(K.EQ.1)CF=1
	IF(K.EQ.NMAX)CF=1
	IF(K.EQ.1.OR.K.EQ.NMAX)GO TO 40
	J=K/2
	J=J*2
	IF(J.EQ.K)GO TO 30
	CF=2.
	GO TO 40
30	CF=4.
40	CONTINUE
	RD=ALOG(D)-TH(1)
	RDT=RD*RD
	FD=1./(FCNST*TH(2)*D*EXP(RDT/XP))
	FD=D*D/SUMAD
	SUMFD=SUMFD+FD*CF
	D=D+HMAX
500	CONTINUE
	GCONST=(3.945*.00001*(DCOAL-.78)*60.*(T(I)-TH(4)))/HT
	D=DMIN
	DO 600 K=1,NMIN
	IF(K.EQ.1)CF=1.
	IF(K.EQ.NMIN)CF=1.
	IF(K.EQ.1.OR.K.EQ.NMIN)GO TO 60
	J=K/2
	J=J*2
	IF(K.EQ.J)GO TO 50
	CF=2.
	GO TO 60
50	CF=4.
60	CONTINUE
	RD=ALOG(D)-TH(1)
	FD=FD*D/SUMAD
	SUMXFD=SUMXFD+(FD*CF*(D*D)*GCONST)
	D=D+HMIN
600	CONTINUE
	F(I)=TH(3)*(SUMFD*HMAX/3+SUMXFD*HMIN/3)
400 CONTINUE
	RETURN
	END
ccc
ccc
	SUBROUTINE AREA (TH)
	DIMENSION TH(10)
	HT=15./20.
	D=0.
	SUM=00.
	FCNST=SQRT(2*3.14159)
	XP=2.*TH(2)*TH(2)
	DO 100 K=2,21
	D=D+HT
	IF(K.EQ.21)CF=1.
	IF(K.EQ.21)GO TO 111
	J=K/2
	J=J*2
	IF(J.EQ.K)GO TO 110
	CF=2
	GO TO 111
110	CF = 4
111	CONTINUE
	RD=ALOG(D)-TH(1)
	RDT=RD*RD
	FD=1./(FCNST*TH(2)*D*EXP(RDT/XP))
	SUM=SUM+FD*CF
100	CONTINUE
	SUM=SUM*HT/.03
	WRITE(5,10)SUM
10	FORMAT(1X,'SURFACE % LESS THAN 15 MICRONS=',F10.2)
	RETURN
	END
702	CONTINUE
