# Input version name
read -p 'Enter kernel upstreamed version: ' VERSION

echo ''
echo Starting kernel build.
echo ''

# set toolchains directory
TOP=$(realpath ../)

# export aosp gcc toolchains path 
export PATH="$TOP/tools/gcc/linux-x86/aarch64/aarch64-linux-android-4.9/bin:$PATH"
export PATH="$TOP/tools/gcc/linux-x86/arm/arm-linux-androideabi-4.9/bin:$PATH"
export PATH="$TOP/tools/clang/host/linux-x86/clang-r416183b/bin:$PATH"
export LD_LIBRARY_PATH="$TOP/tools/clang/host/linux-x86/clang-r416183b/lib64:$LD_LIBRARY_PATH"

# export configs
export ARCH=arm64
export CLANG_TRIPLE=aarch64-linux-gnu-
export CROSS_COMPILE=aarch64-linux-android-
export CROSS_COMPILE_ARM32=arm-linux-androideabi-

# Clean old builds
rm -rf "$TOP/ZIPS/stock/Image.gz-dtb"
rm -rf "$TOP/ZIPS/Kernel_ZIP/*.zip"

# start make builds
# start make builds
make	O=out \
	CC=clang \
	AR=llvm-ar \
	NM=llvm-nm \
	LD=ld.lld \
	STRIP=llvm-strip \
	OBJDUMP=llvm-objdump \
	OBJCOPY=llvm-objcopy \
	X00T_defconfig


time	make \
	O=out \
	CC=clang \
	AR=llvm-ar \
	NM=llvm-nm \
	LD=ld.lld \
	STRIP=llvm-strip \
	OBJDUMP=llvm-objdump \
	OBJCOPY=llvm-objcopy \
	--jobs=5

# Zipping kernel build
FILE='out/arch/arm64/boot/Image.gz-dtb'
DIR="$TOP/ZIPS"
if [[ -f "$FILE" ]] 
   then
   if [[ ! -d "$DIR" ]] 
      then
      echo ZIPS Folder not found !
      exit 1
   else
   cp out/arch/arm64/boot/Image.gz-dtb "$TOP/ZIPS/stock"
   cd "$TOP/ZIPS/stock"
   zip -r "$TOP/ZIPS/Kernel_ZIP/ProjectInfinity_EAS-v$VERSION.zip" *
   echo 'Signing Kernel ZIP'
   curl -sLo zipsigner-4.0.jar https://github.com/baalajimaestro/AnyKernel3/raw/master/zipsigner-4.0.jar
   java -jar zipsigner-4.0.jar "$TOP/ZIPS/Kernel_ZIP/ProjectInfinity_EAS-v$VERSION.zip" "$TOP/ZIPS/Kernel_ZIP/ProjectInfinity_EAS-v$VERSION-signed.zip"
   rm -rf "$TOP/ZIPS/Kernel_ZIP/ProjectInfinity_EAS-v$VERSION.zip"
   rm -rf zipsigner-4.0.jar
   echo ''
   echo 'Kernel Build Successful !!!!'
   fi
else
echo ''
echo 'Kernel build Unsuccessfull !!!!'
echo ''
fi
