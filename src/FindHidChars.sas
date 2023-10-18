*# 4a. Macro to find hidden characters in a variable;
%macro FindHidChars(InpSet= /*Input dataset*/
,Var=/*Variable to check*/
,Whr=/*Optional filter*/
,OutSet= /*Output dataset*/);
data &OutSet. (where=(sum > 0));
set &InpSet.;
array _tmpsc {*} _tmpsc1-_tmpsc31;
 do i=1 to dim(_tmpsc);
_tmpsc{i} = index(&Var.,byte(i));
 end;
 sum=sum(of _tmpsc1-_tmpsc31);
 %if %length(&whr.)>0 %then where &Whr.;;
run;
%mend FindHidChars;
