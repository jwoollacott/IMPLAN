@echo off

if "%year%"=="" set year=18

if not exist ..\listings\nul mkdir listings
if not exist ..\data\nul mkdir data
if not exist ..\data\tempdata\nul mkdir data\tempdata
if not exist .\listings\State_Listings\ mkdir .\listings\State_Listings\

:start

title   Reading dataset for %1 -- job started at %time%
if not exist .\data\noaggr%SD%\nul mkdir data\noaggr%2
echo CALLING DATA ... ... ... %1
call gams .\Build\1a_readall --ds=%1 --year=%year% o=.\listings\State_Listings\%1_read.lst 
::call ..\26.1\gams.exe .\Build\1a_readall --ds=%1 --year=%year% o=.\listings\State_Listings\%1_read.lst 


if not errorlevel 1 goto model

echo	GAMS error encountered reading IMPLAN data for %1  >>errors.txt
echo	See .\listings\%1_read.lst for details.           >>errors.txt
echo.

:model
title	Translating data into a GTAP style namespace:
call gams .\Build\1b_trnsl8 --ds=%1 --subdir=%SD% --year=%year% o=.\listings\State_Listings\%1_transl8.lst
::call ..\26.1\gams.exe .\Build\1b_trnsl8 --ds=%1 --subdir=%SD% --year=%year% o=.\listings\State_Listings\%1_transl8.lst


:title	Checking state-level IMPLAN model for %1 -- job started at %time%
::call   ..\26.1\gams.exe ..\models\implan_acc --ds=%1
::call   gams ..\models\implan_acc --ds=%1

if not errorlevel 1 goto next

echo	GAMS error encountered in static model for %1 >>errors.txt
echo	See .\listings\%1_static.lst for details.     >>errors.txt
echo.

:next
shift
if not "%1"=="" goto start
:end
