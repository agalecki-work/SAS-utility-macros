*#4b. Macro to check the distribution of first digit, Benfords Law;
%macro FirstDigitDist(InpSet= /*Input dataset*/
,Var=/*Variable to check*/
,Whr=/*Optional filter*/
,OutSet= /*Output dataset*/
,Plot=/*Set to Y for plot of theroretical
versus emprical distribution*/
);
*#Derive d (digit) and filter data;
data _tmp01 (where=(d>0));
set &InpSet. %if %length(&whr.)>0 %then (where=(&Whr.));;
d=input(substr(compress(&Var.,'-'),1,1),best.);
run;
*#Count digits;
proc freq data=_tmp01 noprint;
tables d / out=_tmp02(rename=(percent=e));
run;
*#Compare against Benfords first digit distribution;
data &OutSet.;
set _tmp02 end=last;
t=log10(1+1/d)*100;
Dif=(e-t)**2/t;
sum+dif;
if last then do;
 p=1-probchi(sum,8);
 call symputx('Chi2e',putn(sum,'5.3'));
 call symputx('p',putn(p,'5.3'));
end;
run;

%if %upcase(&Plot.)=Y %then %do;
*#Plot empricial and theoretical distributions;
%let _Chi2=(*ESC*){unicode '03C7'x '00B2'x};
%let _ge = (*ESC*){unicode '2265'x};
%let _sube = (*ESC*){unicode '2091'x};
proc sgplot data=&OutSet.;
 vbar d / response=t name='t'
legendlabel='Theoretical distribution';
 vbar d / response=e transparency=.5 name='e' legendlabel='Empirical distribution';
 yaxis label='Percantage';
 xaxis label='Digit';
 keylegend 't' 'e' / down=1;
 inset
 ("&_Chi2.&_sube."="&chi2e." "P(&_Chi2. &_ge. &_Chi2.&_sube.)"="&p.") / position=ne;
run;
%end;
%mend FirstDigitDist;
