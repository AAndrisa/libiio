# https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_preference_variables?view=powershell-7.2#erroractionpreference
$ErrorActionPreference = "Stop"
$ErrorView = "NormalView"

$COMPILER=$Env:COMPILER
$USE_CSHARP=$Env:USE_CSHARP
$src_dir=$pwd

echo "Running cmake for $COMPILER on 64 bit..."
mkdir build-x64
cp .\libiio.iss.cmakein .\build-x64
cd build-x64
C:\msys64\usr\bin\bash.exe -lc "pacman --noconfirm -S mingw-w64-x86_64-libusb mingw-w64-x86_64-libserialport mingw-w64-x86_64-zstd mingw-w64-x86_64-libxml2"
C:\msys64\usr\bin\bash.exe -lc "pacman -Qi mingw-w64-x86_64-libusb"
ls C:\msys64\mingw64\bin
$env:PATH += ";C:\msys64\bin;C:\msys64\mingw64\bin;C:\msys64\usr\bin"
echo $env:PATH
cmake -G "$COMPILER" -DPYTHON_EXECUTABLE:FILEPATH=$(python -c "import os, sys; print(os.path.dirname(sys.executable) + '\python.exe')") -DCMAKE_SYSTEM_PREFIX_PATH="C:" -Werror=dev -DCOMPILE_WARNING_AS_ERROR=ON -DENABLE_IPV6=ON -DWITH_USB_BACKEND=ON -DWITH_SERIAL_BACKEND=ON -DPYTHON_BINDINGS=ON -DCPP_BINDINGS=ON -DCSHARP_BINDINGS:BOOL=$USE_CSHARP  -DLIBXML2_LIBRARIES="C:\\msys64\\mingw64\\lib\\libxml2.dll.a" -DLIBXML2_INCLUDE_DIR="C:\\msys64\\mingw64\\include\\libxml2" -DLIBUSB_LIBRARIES="C:\\msys64\\mingw64\\lib\\libusb-1.0.dll.a" -DLIBUSB_INCLUDE_DIR="C:\\msys64\\mingw64\\include\\libusb-1.0" -DLIBSERIALPORT_INCLUDE_DIR="C:\\msys64\\mingw64\\include" -DLIBSERIALPORT_LIBRARIES="C:\\msys64\\mingw64\\lib\\libserialport.dll.a" -DLIBZSTD_INCLUDE_DIR="C:\\msys64\\mingw64\\include" -DLIBZSTD_LIBRARIES="C:\\msys64\\mingw64\\lib\\libzstd.dll.a" ..
cmake --build . --verbose --config Release
if ( $LASTEXITCODE -ne 0 ) {
		throw "[*] cmake build failure"
	}
cp .\libiio.iss $env:BUILD_ARTIFACTSTAGINGDIRECTORY

cd bindings/python
python.exe setup.py sdist
Get-ChildItem dist\pylibiio-*.tar.gz | Rename-Item -NewName "libiio-py39-amd64.tar.gz"
mv .\dist\*.gz .
rm .\dist\*.gz
