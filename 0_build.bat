set target=%1
echo Target is set to %target%

@echo off

:: goto merge
:: goto aggregation
:: goto tradeadj
:: goto translate
:: goto census_agg
:: goto state_agg

:	Whenever possible, skip the reading of individual state data files --
:	it takes a while...

:run_all
if exist errors.txt del errors.txt
echo	About to read the data sets...

call ./build/1_readstate AK AL AR AZ CA CO CT DC DE FL GA HI IA ID IL IN KS KY LA MA MD ME MI MN MO MS 
call ./build/1_readstate MT NC ND NE NH NJ NM NV NY OH OK OR PA RI SC SD TN TX UT VA VT WA WI WV WY   

if exist errors.txt type errors.txt

:merge
title Merge single data state files and check consistency:
call gams build\2_merge o=.\listings\merge.lst 

:aggregation
call gams build\3_aggregation o=.\listings\3_aggregation.lst --target=%target%

:tradeadj
call gams build\4_tradeadj o=.\listings\4_tradeadj.lst --target=%target%

:translate
call gams build\5_translate o=.\listings\5_translate.lst --target=%target%

goto end
goto state_agg
:census_agg
call gams build\6_census_agg o=.\listings\6_census_agg.lst 

:state_agg
call gams build\6_StateOut.gms o=.\listings\6_StateOut.lst --target=%target% --ST=NC
call gams build\6_StateOut.gms o=.\listings\6_StateOut.lst --target=%target% --ST=VA
call gams build\6_StateOut.gms o=.\listings\6_StateOut.lst --target=%target% --ST=GA
call gams build\6_StateOut.gms o=.\listings\6_StateOut.lst --target=%target% --ST=TX
call gams build\6_StateOut.gms o=.\listings\6_StateOut.lst --target=%target% --ST=NM
call gams build\6_StateOut.gms o=.\listings\6_StateOut.lst --target=%target% --ST=UT
call gams build\6_StateOut.gms o=.\listings\6_StateOut.lst --target=%target% --ST=TN
call gams build\6_StateOut.gms o=.\listings\6_StateOut.lst --target=%target% --ST=OH
call gams build\6_StateOut.gms o=.\listings\6_StateOut.lst --target=%target% --ST=IN
call gams build\6_StateOut.gms o=.\listings\6_StateOut.lst --target=%target% --ST=IL
call gams build\6_StateOut.gms o=.\listings\6_StateOut.lst --target=%target% --ST=OR
call gams build\6_StateOut.gms o=.\listings\6_StateOut.lst --target=%target% --ST=AL
call gams build\6_StateOut.gms o=.\listings\6_StateOut.lst --target=%target% --ST=MT
call gams build\6_StateOut.gms o=.\listings\6_StateOut.lst --target=%target% --ST=NE

:end
