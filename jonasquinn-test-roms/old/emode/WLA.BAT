@echo off

echo [objects] > temp.prj
echo emode.obj >> temp.prj

..\wla-65816 -o emode.asm emode.obj
..\wlalink -vr temp.prj emode.swc
..\smc2swc emode.swc emode.smc

del emode.swc
del emode.obj
del temp.prj

pause
