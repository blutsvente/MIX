rem batch for calling MIX from Windows

rem don't know how to tell Win to use relative pathes 8-(
rem set SRC=\\sambam\tools\mix\latest
set SRC=Y:\latest
echo %SRC%

perl %SRC%\mix_1.pl -cfg %SRC%\examples\mix.cfg %SRC%\examples\rs_test.xls 

pause

