rem SETUP Visual C 6.0 (SP5) environment for command line
@rem Fix directory name if incorrect!
call "C:\Program Files (x86)\Microsoft Visual Studio 9.0\VC\bin\vcvars32.bat"

@rem SETUP DirectX 8.x environment for command line
@rem Fix directory name if incorrect!
set include=C:\Program Files (x86)\Microsoft DirectX SDK (June 2007)\Include;%include%
set lib=C:\Program Files (x86)\Microsoft DirectX SDK (June 2007)\Lib\x86;%lib%

cd ..\src\voxlap
nmake foguan.c

@rem Copy result
move foguan.exe ..\..\bin\voxbattles.exe
move foguan.exe.manifest ..\..\bin\voxbattles.exe.manifest

@rem Save v5.obj
ren v5.obj v5.obj.back

@rem Cleanup
del *.obj

@rem Restore v5.obj
ren v5.obj.back v5.obj