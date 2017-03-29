set -e
set -x

cd $LFS/sources

tarball=`ls | grep 'tcl-co' | tail -1`
tar -xvf $tarball
packageDir=`ls -d */`
cd $packageDir
cd unix
./configure --prefix=/tools
make
make install
chmod -v u+w /tools/lib/libtcl8.6.so
make install-private-headers
ln -sv tclsh8.6 /tools/bin/tclsh
cd $LFS/sources
rm -rf $packageDir

tarball=`ls | grep 'expect' | tail -1`
tar -xvf $tarball
packageDir=`ls -d */`
cd $packageDir
cp -v configure{,.orig}
sed 's:/usr/local/bin:/bin:' configure.orig > configure
./configure --prefix=/tools       \
            --with-tcl=/tools/lib \
            --with-tclinclude=/tools/include
make
make SCRIPTS="" install
cd $LFS/sources
rm -rf $packageDir

tarball=`ls | grep 'dejagn' | tail -1`
tar -xvf $tarball
packageDir=`ls -d */`
cd $packageDir
./configure --prefix=/tools
make install
cd $LFS/sources
rm -rf $packageDir

tarball=`ls | grep 'check-' | tail -1`
tar -xvf $tarball
packageDir=`ls -d */`
cd $packageDir
PKG_CONFIG= ./configure --prefix=/tools
make
make install
cd $LFS/sources
rm -rf $packageDir

tarball=`ls | grep 'ncurse' | tail -1`
tar -xvf $tarball
packageDir=`ls -d */`
cd $packageDir
sed -i s/mawk// configure
./configure --prefix=/tools \
            --with-shared   \
            --without-debug \
            --without-ada   \
            --enable-widec  \
            --enable-overwrite
make
make install
cd $LFS/sources
rm -rf $packageDir

tarball=`ls | grep 'bash-4' | tail -1`
tar -xvf $tarball
packageDir=`ls -d */`
cd $packageDir
./configure --prefix=/tools --without-bash-malloc
make
make install
ln -sv bash /tools/bin/sh
cd $LFS/sources
rm -rf $packageDir

tarball=`ls | grep 'bison-' | tail -1`
tar -xvf $tarball
packageDir=`ls -d */`
cd $packageDir
./configure --prefix=/tools
make
make install
cd $LFS/sources
rm -rf $packageDir

tarball=`ls | grep 'bzip2-' | tail -1`
tar -xvf $tarball
packageDir=`ls -d */`
cd $packageDir
make
make PREFIX=/tools install
cd $LFS/sources
rm -rf $packageDir

tarball=`ls | grep 'coreut' | tail -1`
tar -xvf $tarball
packageDir=`ls -d */`
cd $packageDir
./configure --prefix=/tools --enable-install-program=hostname
make
make install
cd $LFS/sources
rm -rf $packageDir

tarball=`ls | grep 'diffut' | tail -1`
tar -xvf $tarball
packageDir=`ls -d */`
cd $packageDir
./configure --prefix=/tools
make
make install
cd $LFS/sources
rm -rf $packageDir

tarball=`ls | grep 'file-5' | tail -1`
tar -xvf $tarball
packageDir=`ls -d */`
cd $packageDir
./configure --prefix=/tools
make
make install
cd $LFS/sources
rm -rf $packageDir

tarball=`ls | grep 'findut' | tail -1`
tar -xvf $tarball
packageDir=`ls -d */`
cd $packageDir
./configure --prefix=/tools
make
make install
cd $LFS/sources
rm -rf $packageDir

tarball=`ls | grep 'gawk-4' | tail -1`
tar -xvf $tarball
packageDir=`ls -d */`
cd $packageDir
./configure --prefix=/tools
make
make install
cd $LFS/sources
rm -rf $packageDir

tarball=`ls | grep 'gettex' | tail -1`
tar -xvf $tarball
packageDir=`ls -d */`
cd $packageDir
cd gettext-tools
EMACS="no" ./configure --prefix=/tools --disable-shared
make -C gnulib-lib
make -C intl pluralx.c
make -C src msgfmt
make -C src msgmerge
make -C src xgettext
cp -v src/{msgfmt,msgmerge,xgettext} /tools/bin
cd $LFS/sources
rm -rf $packageDir

tarball=`ls | grep 'grep-3' | tail -1`
tar -xvf $tarball
packageDir=`ls -d */`
cd $packageDir
./configure --prefix=/tools
make
make install
cd $LFS/sources
rm -rf $packageDir

tarball=`ls | grep 'gzip-1' | tail -1`
tar -xvf $tarball
packageDir=`ls -d */`
cd $packageDir
./configure --prefix=/tools
make
make install
cd $LFS/sources
rm -rf $packageDir

tarball=`ls | grep 'm4-1.4' | tail -1`
tar -xvf $tarball
packageDir=`ls -d */`
cd $packageDir
./configure --prefix=/tools
make
make install
cd $LFS/sources
rm -rf $packageDir

tarball=`ls | grep 'make-4' | tail -1`
tar -xvf $tarball
packageDir=`ls -d */`
cd $packageDir
./configure --prefix=/tools --without-guile
make
make install
cd $LFS/sources
rm -rf $packageDir

tarball=`ls | grep 'patch-' | tail -1`
tar -xvf $tarball
packageDir=`ls -d */`
cd $packageDir
./configure --prefix=/tools
make
make install
cd $LFS/sources
rm -rf $packageDir

tarball=`ls | grep 'perl-5' | tail -1`
tar -xvf $tarball
packageDir=`ls -d */`
cd $packageDir
sh Configure -des -Dprefix=/tools -Dlibs=-lm
make
cp -v perl cpan/podlators/scripts/pod2man /tools/bin
mkdir -pv /tools/lib/perl5/5.24.1
cp -Rv lib/* /tools/lib/perl5/5.24.1
cd $LFS/sources
rm -rf $packageDir

tarball=`ls | grep 'sed-4.' | tail -1`
tar -xvf $tarball
packageDir=`ls -d */`
cd $packageDir
./configure --prefix=/tools
make
make install
cd $LFS/sources
rm -rf $packageDir

tarball=`ls | grep 'tar-1.' | tail -1`
tar -xvf $tarball
packageDir=`ls -d */`
cd $packageDir
./configure --prefix=/tools
make
make install
cd $LFS/sources
rm -rf $packageDir

tarball=`ls | grep 'texinf' | tail -1`
tar -xvf $tarball
packageDir=`ls -d */`
cd $packageDir
./configure --prefix=/tools
make
make install
cd $LFS/sources
rm -rf $packageDir

tarball=`ls | grep 'util-l' | tail -1`
tar -xvf $tarball
packageDir=`ls -d */`
cd $packageDir
./configure --prefix=/tools                \
            --without-python               \
            --disable-makeinstall-chown    \
            --without-systemdsystemunitdir \
            PKG_CONFIG=""
make
make install
cd $LFS/sources
rm -rf $packageDir

tarball=`ls | grep 'xz-5.2' | tail -1`
tar -xvf $tarball
packageDir=`ls -d */`
cd $packageDir
./configure --prefix=/tools
make
make install
cd $LFS/sources
rm -rf $packageDir

