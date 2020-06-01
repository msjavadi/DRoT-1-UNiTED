sets

         j    Line Number/1*6/
         ucc    Unit Cost Coefficient /Pmax,Pmin,Price/
         ug       /1*2/
         Lim /Line/
         i   /1*5/

          alias(j,jj)
;

variable
PG Net Injection;
Table GENDATA(i,ug,ucc) Generation Unit data
     Pmax Pmin Price
1.1  110  0    14
1.2  100  0    15
3.1  520  0    30
4.1  200  0    35
5.1  600  0    10   ;

Table Demand(i,*)
     Pd
2    300
3    300
4    300        ;

Table A(i,j)    A Matrix
     1    2    3    4    5    6
1    1    1    1    0    0    0
2    -1   0    0    1    0    0
3    0    0    0    -1   1    0
4    0    -1   0    0    -1   1
5    0    0    -1   0    0    -1;


Table X(jj,j)
     1      2      3      4      5      6
1    0.0281 0      0      0      0      0
2    0      0.0304 0      0      0      0
3    0      0      0.0064 0      0      0
4    0      0      0      0.0108 0      0
5    0      0      0      0      0.0297 0
6    0      0      0      0      0      0.0297 ;
Table Max_Lines(j,Lim) Lines
          Line
1         999
2         999
3         999
4         999
5         999
6         240;


Variables
  Z         Objective Function
***** Power Flow Variables
  P(i,ug)    Real Power Produced
  Delta(i)  Angel of bus
  PLine(j) Flow of Lines
*  VQ(j)
;

Positive VARIABLE
P(i,ug)
;
*display
P.up(i,ug)=GENDATA(i,ug,'Pmax');
P.lo(i,ug)=GENDATA(i,ug,'Pmin');

Delta.fx('1')=0;

EQUATIONS
  COST_FUNC             Cost function of the system
  DC(i)                 DC Function
  Lines_Flow(j)         Flow of lines
  Congestion_Check1(j)  Congestion Check
  Congestion_Check2(j)  Congestion Check
  PCON(i)               Aggregated production
;

** Calculated Cost Function
   COST_FUNC .. Z =e= SUM((i,ug),P(i,ug)*GENDATA(i,ug,'Price'));
   PCON(i)   .. PG(i)=e=sum(ug,P(i,ug)) ;

****************************** DC Power Flow Equation  *************************
  Congestion_Check1(j) .. PLine(j) =l=  1*Max_Lines(j,'Line');
  Congestion_Check2(j) .. PLine(j) =g= -1*Max_Lines(j,'Line');
  DC(i) .. PG(i)-Demand(i,'Pd') =e= sum(j, A(i,j)*PLine(j)) ;
  Lines_Flow(j).. sum(i, A(i,j)*Delta(i))=e=sum(jj,X(jj,j)*PLine(j));



MODEL Run_Market /all/;
option optca  = 1e-10;
option optcr  = 1e-10;
option reslim = 100000;
option mip=cplex;

SOLVE Run_Market USING MIP minimizing Z;
display     PLine.l, PG.l,Delta.l;

Parameter
        LMP(i);
LMP(i)=DC.m(i);
display LMP;