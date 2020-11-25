
SET st  / NC, VA, GA, TX, NM, UT, TN, OH, IN, IL, OR, AL, MT, NE / ;

$call "gdxxrw ..\IMPLANData\NC_lab.csv o=..\data\tempdata\labor\NC.gdx par=lab rng=NC_lab!A4:C547 ignoreColumns=2 cdim=0 rdim=1";
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






