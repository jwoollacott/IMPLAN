set target=%1
set subdir=\WA_county
echo Target is set to %target%

@echo off

:: goto merge
:: goto aggregation
:: goto tradeadj
:: goto translate
:: goto census_agg
:: goto state_agg

: Whenever possible, skip the reading of individual state data files --
: it takes a while...

:run_all
if exist errors.txt del errors.txt
echo About to read the data sets...

call ./build/1_readstate WA_001 WA_003 WA_005 WA_007 WA_009 WA_011 WA_013 WA_015 WA_017 WA_019 WA_021 WA_023 WA_025 WA_027 
call ./build/1_readstate WA_029 WA_031 WA_033 WA_035 WA_037 WA_039 WA_041 WA_043 WA_045 WA_047 WA_049 WA_051 WA_053 WA_055 
call ./build/1_readstate WA_057 WA_059 WA_061 WA_063 WA_065 WA_067 WA_069 WA_071 WA_073 WA_075 WA_077
:: call ./build/1_readstate AK AL AR AZ CA CO CT DC DE FL GA HI IA ID IL IN KS KY LA MA MD ME MI MN MO MS 
:: call ./build/1_readstate MT NC ND NE NH NJ NM NV NY OH OK OR PA RI SC SD TN TX UT VA VT WA WI WV WY   

if exist errors.txt type errors.txt

:merge
title Merge single data state files and check consistency:
call gams build\2_merge o=.\listings\merge.lst --ds1=WA_001 --subdir=\WA_county

goto end

:aggregation
call gams build\3_aggregation o=.\listings\3_aggregation.lst --target=%target% --subdir=\WA_county --ds1=WA_001

:tradeadj
call gams build\4_tradeadj o=.\listings\4_tradeadj.lst --target=%target%

:translate
call gams build\5_translate o=.\listings\5_translate.lst --target=%target%

goto end
goto state_agg
:census_agg
call gams build\6_census_agg o=.\listings\6_census_agg.lst 

:state_agg
call gams build\6_StateOut.gms o=.\listings\6_StateOut.lst --target=%target% --ST=WRIA7
call gams build\6_StateOut.gms o=.\listings\6_StateOut.lst --target=%target% --ST=BLUES
call gams build\6_StateOut.gms o=.\listings\6_StateOut.lst --target=%target% --ST=NEWA
call gams build\6_StateOut.gms o=.\listings\6_StateOut.lst --target=%target% --ST=NCENT
call gams build\6_StateOut.gms o=.\listings\6_StateOut.lst --target=%target% --ST=SCENT
call gams build\6_StateOut.gms o=.\listings\6_StateOut.lst --target=%target% --ST=ROWWA

:end
