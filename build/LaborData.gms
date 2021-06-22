
* SET wac  /  WA_001, WA_003, WA_005, WA_007, WA_009, WA_011, WA_013, WA_015, 
*             WA_017, WA_019, WA_021, WA_023, WA_025, WA_027, WA_029, WA_031, 
*             WA_033, WA_035, WA_037, WA_039, WA_041, WA_043, WA_045, WA_047, 
*             WA_049, WA_051, WA_053, WA_055, WA_057, WA_059, WA_061, WA_063, 
*             WA_065, WA_067, WA_069, WA_071, WA_073, WA_075, WA_077          / ;
set wac / WA_001, WA_002 /;

$CALL 'csv2gdx ../Data/generation_bytype_labor.csv ID=qcew_gen UseHeader=y index=5' ;
$CALL "csv2gdx '..\IMPLANData\IMPLAN18\WA_001 Industry Detail.csv' ID=WA_001 useheader=y index=1" ;
$exit

loop(wac, 
    $call "csv2gdx ..\IMPLANData\'"wac.tl" Industry Detail.csv' o=..\data\tempdata\labor\"wac.tl"_lab.gdx par=lab rng=NC_lab!A4:C547 ignoreColumns=2 cdim=0 rdim=1";
);



$call "gdxxrw ..\IMPLANData\VA_lab.csv o=..\data\tempdata\labor\VA.gdx par=lab rng=VA_lab!A4:C547 ignoreColumns=2 cdim=0 rdim=1";
$call "gdxxrw ..\IMPLANData\GA_lab.csv o=..\data\tempdata\labor\GA.gdx par=lab rng=GA_lab!A4:C547 ignoreColumns=2 cdim=0 rdim=1";
$call "gdxxrw ..\IMPLANData\TX_lab.csv o=..\data\tempdata\labor\TX.gdx par=lab rng=TX_lab!A4:C547 ignoreColumns=2 cdim=0 rdim=1";
$call "gdxxrw ..\IMPLANData\NM_lab.csv o=..\data\tempdata\labor\NM.gdx par=lab rng=NM_lab!A4:C547 ignoreColumns=2 cdim=0 rdim=1";
$call "gdxxrw ..\IMPLANData\UT_lab.csv o=..\data\tempdata\labor\UT.gdx par=lab rng=UT_lab!A4:C547 ignoreColumns=2 cdim=0 rdim=1";
$call "gdxxrw ..\IMPLANData\TN_lab.csv o=..\data\tempdata\labor\TN.gdx par=lab rng=TN_lab!A4:C547 ignoreColumns=2 cdim=0 rdim=1";
$call "gdxxrw ..\IMPLANData\OH_lab.csv o=..\data\tempdata\labor\OH.gdx par=lab rng=OH_lab!A4:C547 ignoreColumns=2 cdim=0 rdim=1";
$call "gdxxrw ..\IMPLANData\IN_lab.csv o=..\data\tempdata\labor\IN.gdx par=lab rng=IN_lab!A4:C547 ignoreColumns=2 cdim=0 rdim=1";
$call "gdxxrw ..\IMPLANData\IL_lab.csv o=..\data\tempdata\labor\IL.gdx par=lab rng=IL_lab!A4:C547 ignoreColumns=2 cdim=0 rdim=1";
$call "gdxxrw ..\IMPLANData\OR_lab.csv o=..\data\tempdata\labor\OR.gdx par=lab rng=OR_lab!A4:C547 ignoreColumns=2 cdim=0 rdim=1";
$call "gdxxrw ..\IMPLANData\AL_lab.csv o=..\data\tempdata\labor\AL.gdx par=lab rng=AL_lab!A4:C547 ignoreColumns=2 cdim=0 rdim=1";
$call "gdxxrw ..\IMPLANData\MT_lab.csv o=..\data\tempdata\labor\MT.gdx par=lab rng=MT_lab!A4:C547 ignoreColumns=2 cdim=0 rdim=1";
$call "gdxxrw ..\IMPLANData\NE_lab.csv o=..\data\tempdata\labor\NE.gdx par=lab rng=NE_lab!A4:C547 ignoreColumns=2 cdim=0 rdim=1";

$call 'gdxmerge ..\data\tempdata\labor\*.gdx o=..\data\labor.gdx'






