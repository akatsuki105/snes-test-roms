@echo off

echo [objects] > temp.prj
echo cx4test.obj >> temp.prj

..\wla-65816 -o cx4test.x65 cx4test.obj
..\wlalink -vr temp.prj cx4test.sfc
..\fixcheck cx4test.sfc
..\smc2swc cx4test.sfc cx4test.swc

del cx4test.obj
del temp.prj

pause