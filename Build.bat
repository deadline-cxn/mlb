@echo off
echo Build Script: Building %1
call genkickass-script.bat -t C64 -o prg_files -m false -s false -l "RETRO_DEV_LIB"
call KickAss.bat mlb.asm
copy prg_files\\cxn.spr x:\\www\\html\\m64\\in\\_in.spr
copy prg_files\\mlb.prg x:\\www\\html\\m64\\mlb.prg
copy prg_files\\mlb.prg E:\\dev\\github\\cityxen\\meatloaf-specialty\\data\\BUILD_CBM\\mlb-cxn.prg