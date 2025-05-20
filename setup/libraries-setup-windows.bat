@echo off
color 0a
cd ..
echo Installing basic libraries...
echo (Make sure you have Haxe 4.3.6 installed for this to work properly!)
echo (URL -> https://haxe.org/download/4.3.6)
haxelib install lime 8.2.2
haxelib install openfl 9.4.1
haxelib install flixel 6.0.0
haxelib install flixel-addons 3.3.2
haxelib install flixel-tools 1.5.1
echo Installing Microsoft Visual Studio Community...
echo This is used for converting the game to become an exe program!
curl -# -O https://download.visualstudio.microsoft.com/download/pr/3105fcfe-e771-41d6-9a1c-fc971e7d03a7/8eb13958dc429a6e6f7e0d6704d43a55f18d02a253608351b6bf6723ffdaf24e/vs_Community.exe
vs_Community.exe --add Microsoft.VisualStudio.Component.VC.Tools.x86.x64 --add Microsoft.VisualStudio.Component.Windows10SDK.19041 -p
del vs_Community.exe
echo Libraries and dependencies download complete!
echo Running setup commands...
haxelib run lime setup
haxelib run lime setup flixel
haxelib run flixel-tools setup
echo HaxeFlixel Windows setup finished!
pause
