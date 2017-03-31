set -e
set -x

cd $LFS/sources

tarball=`ls | grep 'linux-4' | tail -1`
tar -xvf $tarball
packageDir=`ls -d */`
cd $packageDir
make mrproper
make INSTALL_HDR_PATH=dest headers_install
find dest/include \( -name .install -o -name ..install.cmd \) -delete

cp -rv dest/include/* /usr/include
cd $LFS/sources
rm -rf $packageDir

tarball=`ls | grep 'man-pag' | tail -1`
tar -xvf $tarball
packageDir=`ls -d */`
cd $packageDir
make install
cd $LFS/sources
rm -rf $packageDir

tarball=`ls | grep 'glibc-2' | tail -1`
tar -xvf $tarball
packageDir=`ls -d */`
cd $packageDir
patch -Np1 -i ../glibc-2.25-fhs-1.patch
case $(uname -m) in
    x86) ln -s ld-linux.so.2 /lib/ld-lsb.so.3
    ;;
    x86_64) ln -s ../lib/ld-linux-x86-64.so.2 /lib64
            ln -s ../lib/ld-linux-x86-64.so.2 /lib64/ld-lsb-x86-64.so.3
    ;;
esac
mkdir -v build
cd       build
../configure --prefix=/usr                   \
             --enable-kernel=2.6.32          \
             --enable-obsolete-rpc           \
             --enable-stack-protector=strong \
             libc_cv_slibdir=/lib
make
touch /etc/ld.so.conf
make install
cp -v ../nscd/nscd.conf /etc/nscd.conf
mkdir -pv /var/cache/nscd
mkdir -pv /usr/lib/locale
localedef -i cs_CZ -f UTF-8 cs_CZ.UTF-8
localedef -i de_DE -f ISO-8859-1 de_DE
localedef -i de_DE@euro -f ISO-8859-15 de_DE@euro
localedef -i de_DE -f UTF-8 de_DE.UTF-8
localedef -i en_GB -f UTF-8 en_GB.UTF-8
localedef -i en_HK -f ISO-8859-1 en_HK
localedef -i en_PH -f ISO-8859-1 en_PH
localedef -i en_US -f ISO-8859-1 en_US
localedef -i en_US -f UTF-8 en_US.UTF-8
localedef -i es_MX -f ISO-8859-1 es_MX
localedef -i fa_IR -f UTF-8 fa_IR
localedef -i fr_FR -f ISO-8859-1 fr_FR
localedef -i fr_FR@euro -f ISO-8859-15 fr_FR@euro
localedef -i fr_FR -f UTF-8 fr_FR.UTF-8
localedef -i it_IT -f ISO-8859-1 it_IT
localedef -i it_IT -f UTF-8 it_IT.UTF-8
localedef -i ja_JP -f EUC-JP ja_JP
localedef -i ru_RU -f KOI8-R ru_RU.KOI8-R
localedef -i ru_RU -f UTF-8 ru_RU.UTF-8
localedef -i tr_TR -f UTF-8 tr_TR.UTF-8
localedef -i zh_CN -f GB18030 zh_CN.GB18030
make localedata/install-locales

cat > /etc/nsswitch.conf << "EOF"
# Begin /etc/nsswitch.conf

passwd: files
group: files
shadow: files

hosts: files dns
networks: files

protocols: files
services: files
ethers: files
rpc: files

# End /etc/nsswitch.conf

EOF
tar -xf ../../tzdata2016j.tar.gz

ZONEINFO=/usr/share/zoneinfo
mkdir -pv $ZONEINFO/{posix,right}

for tz in etcetera southamerica northamerica europe africa antarctica  \
          asia australasia backward pacificnew systemv; do
    zic -L /dev/null   -d $ZONEINFO       -y "sh yearistype.sh" ${tz}
    zic -L /dev/null   -d $ZONEINFO/posix -y "sh yearistype.sh" ${tz}
    zic -L leapseconds -d $ZONEINFO/right -y "sh yearistype.sh" ${tz}
done

cp -v zone.tab zone1970.tab iso3166.tab $ZONEINFO
zic -d $ZONEINFO -p America/New_York
unset ZONEINFO
tzselect

cat > /etc/ld.so.conf << "EOF"
# Begin /etc/ld.so.conf
/usr/local/lib
/opt/lib


EOF

cat >> /etc/ld.so.conf << "EOF"
# Add an include directory
include /etc/ld.so.conf.d/*.conf


EOF
mkdir -pv /etc/ld.so.conf.d
cd $LFS/sources
rm -rf $packageDir

tarball=`ls | grep 'adjusti' | tail -1`
tar -xvf $tarball
packageDir=`ls -d */`
cd $packageDir
mv -v /tools/bin/{ld,ld-old}
mv -v /tools/$(uname -m)-pc-linux-gnu/bin/{ld,ld-old}
mv -v /tools/bin/{ld-new,ld}
ln -sv /tools/bin/ld /tools/$(uname -m)-pc-linux-gnu/bin/ld
gcc -dumpspecs | sed -e 's@/tools@@g'                   \
    -e '/\*startfile_prefix_spec:/{n;s@.*@/usr/lib/ @}' \
    -e '/\*cpp:/{n;s@$@ -isystem /usr/include@}' >      \
    `dirname $(gcc --print-libgcc-file-name)`/specs
echo 'int main(){}' > dummy.c
cc dummy.c -v -Wl,--verbose &> dummy.log
readelf -l a.out | grep ': /lib'
grep -o '/usr/lib.*/crt[1in].*succeeded' dummy.log
grep -B1 '^ /usr/include' dummy.log
grep 'SEARCH.*/usr/lib' dummy.log |sed 's|; |\n|g'
grep "/lib.*/libc.so.6 " dummy.log
grep found dummy.log
rm -v dummy.c a.out dummy.log
cd $LFS/sources
rm -rf $packageDir

tarball=`ls | grep 'zlib-1.' | tail -1`
tar -xvf $tarball
packageDir=`ls -d */`
cd $packageDir
./configure --prefix=/usr
make
make install
mv -v /usr/lib/libz.so.* /lib
ln -sfv ../../lib/$(readlink /usr/lib/libz.so) /usr/lib/libz.so
cd $LFS/sources
rm -rf $packageDir

tarball=`ls | grep 'file-5.' | tail -1`
tar -xvf $tarball
packageDir=`ls -d */`
cd $packageDir
./configure --prefix=/usr
make
make install
cd $LFS/sources
rm -rf $packageDir

tarball=`ls | grep 'binutil' | tail -1`
tar -xvf $tarball
packageDir=`ls -d */`
cd $packageDir
expect -c "spawn ls"
mkdir -v build
cd       build
../configure --prefix=/usr       \
             --enable-gold       \
             --enable-ld=default \
             --enable-plugins    \
             --enable-shared     \
             --disable-werror    \
             --with-system-zlib
make tooldir=/usr
make tooldir=/usr install
cd $LFS/sources
rm -rf $packageDir

tarball=`ls | grep 'gmp-6.1' | tail -1`
tar -xvf $tarball
packageDir=`ls -d */`
cd $packageDir
./configure --prefix=/usr    \
            --enable-cxx     \
            --disable-static \
            --docdir=/usr/share/doc/gmp-6.1.2
make
make html
awk '/# PASS:/{total+=$3} ; END{print total}' gmp-check-log
make install
make install-html
cd $LFS/sources
rm -rf $packageDir

tarball=`ls | grep 'mpfr-3.' | tail -1`
tar -xvf $tarball
packageDir=`ls -d */`
cd $packageDir
./configure --prefix=/usr        \
            --disable-static     \
            --enable-thread-safe \
            --docdir=/usr/share/doc/mpfr-3.1.5
make
make html
make install
make install-html
cd $LFS/sources
rm -rf $packageDir

tarball=`ls | grep 'mpc-1.0' | tail -1`
tar -xvf $tarball
packageDir=`ls -d */`
cd $packageDir
./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/mpc-1.0.3
make
make html
make install
make install-html
cd $LFS/sources
rm -rf $packageDir

tarball=`ls | grep 'gcc-6.3' | tail -1`
tar -xvf $tarball
packageDir=`ls -d */`
cd $packageDir
case $(uname -m) in
  x86_64)
    sed -e '/m64=/s/lib64/lib/' \
        -i.orig gcc/config/i386/t-linux64
  ;;
esac
mkdir -v build
cd       build
SED=sed                               \
../configure --prefix=/usr            \
             --enable-languages=c,c++ \
             --disable-multilib       \
             --disable-bootstrap      \
             --with-system-zlib
make
ulimit -s 32768
../contrib/test_summary
make install
ln -sv ../usr/bin/cpp /lib
ln -sv gcc /usr/bin/cc
install -v -dm755 /usr/lib/bfd-plugins
ln -sfv ../../libexec/gcc/$(gcc -dumpmachine)/6.3.0/liblto_plugin.so \
        /usr/lib/bfd-plugins/
echo 'int main(){}' > dummy.c
cc dummy.c -v -Wl,--verbose &> dummy.log
readelf -l a.out | grep ': /lib'
grep -o '/usr/lib.*/crt[1in].*succeeded' dummy.log
grep -B4 '^ /usr/include' dummy.log
grep 'SEARCH.*/usr/lib' dummy.log |sed 's|; |\n|g'
grep "/lib.*/libc.so.6 " dummy.log
grep found dummy.log
rm -v dummy.c a.out dummy.log
mkdir -pv /usr/share/gdb/auto-load/usr/lib
mv -v /usr/lib/*gdb.py /usr/share/gdb/auto-load/usr/lib
cd $LFS/sources
rm -rf $packageDir

tarball=`ls | grep 'bzip2-1' | tail -1`
tar -xvf $tarball
packageDir=`ls -d */`
cd $packageDir
patch -Np1 -i ../bzip2-1.0.6-install_docs-1.patch
sed -i 's@\(ln -s -f \)$(PREFIX)/bin/@\1@' Makefile
sed -i "s@(PREFIX)/man@(PREFIX)/share/man@g" Makefile
make -f Makefile-libbz2_so
make clean
make
make PREFIX=/usr install
cp -v bzip2-shared /bin/bzip2
cp -av libbz2.so* /lib
ln -sv ../../lib/libbz2.so.1.0 /usr/lib/libbz2.so
rm -v /usr/bin/{bunzip2,bzcat,bzip2}
ln -sv bzip2 /bin/bunzip2
ln -sv bzip2 /bin/bzcat
cd $LFS/sources
rm -rf $packageDir

tarball=`ls | grep 'pkg-con' | tail -1`
tar -xvf $tarball
packageDir=`ls -d */`
cd $packageDir
./configure --prefix=/usr              \
            --with-internal-glib       \
            --disable-compile-warnings \
            --disable-host-tool        \
            --docdir=/usr/share/doc/pkg-config-0.29.1
make
make install
cd $LFS/sources
rm -rf $packageDir

tarball=`ls | grep 'ncurses' | tail -1`
tar -xvf $tarball
packageDir=`ls -d */`
cd $packageDir
sed -i '/LIBTOOL_INSTALL/d' c++/Makefile.in
./configure --prefix=/usr           \
            --mandir=/usr/share/man \
            --with-shared           \
            --without-debug         \
            --without-normal        \
            --enable-pc-files       \
            --enable-widec
make
make install
mv -v /usr/lib/libncursesw.so.6* /lib
ln -sfv ../../lib/$(readlink /usr/lib/libncursesw.so) /usr/lib/libncursesw.so
for lib in ncurses form panel menu ; do
    rm -vf                    /usr/lib/lib${lib}.so
    echo "INPUT(-l${lib}w)" > /usr/lib/lib${lib}.so
    ln -sfv ${lib}w.pc        /usr/lib/pkgconfig/${lib}.pc
done
rm -vf                     /usr/lib/libcursesw.so
echo "INPUT(-lncursesw)" > /usr/lib/libcursesw.so
ln -sfv libncurses.so      /usr/lib/libcurses.so
mkdir -v       /usr/share/doc/ncurses-6.0
cp -v -R doc/* /usr/share/doc/ncurses-6.0
make distclean
./configure --prefix=/usr    \
            --with-shared    \
            --without-normal \
            --without-debug  \
            --without-cxx-binding \
            --with-abi-version=5 
make sources libs
cp -av lib/lib*.so.5* /usr/lib
cd $LFS/sources
rm -rf $packageDir

tarball=`ls | grep 'attr-2.' | tail -1`
tar -xvf $tarball
packageDir=`ls -d */`
cd $packageDir
sed -i -e 's|/@pkg_name@|&-@pkg_version@|' include/builddefs.in
sed -i -e "/SUBDIRS/s|man[25]||g" man/Makefile
./configure --prefix=/usr \
            --bindir=/bin \
            --disable-static
make
make install install-dev install-lib
chmod -v 755 /usr/lib/libattr.so
mv -v /usr/lib/libattr.so.* /lib
ln -sfv ../../lib/$(readlink /usr/lib/libattr.so) /usr/lib/libattr.so
cd $LFS/sources
rm -rf $packageDir

tarball=`ls | grep 'acl-2.2' | tail -1`
tar -xvf $tarball
packageDir=`ls -d */`
cd $packageDir
sed -i -e 's|/@pkg_name@|&-@pkg_version@|' include/builddefs.in
sed -i "s:| sed.*::g" test/{sbits-restore,cp,misc}.test
sed -i -e "/TABS-1;/a if (x > (TABS-1)) x = (TABS-1);" \
    libacl/__acl_to_any_text.c
./configure --prefix=/usr    \
            --bindir=/bin    \
            --disable-static \
            --libexecdir=/usr/lib
make
make install install-dev install-lib
chmod -v 755 /usr/lib/libacl.so
mv -v /usr/lib/libacl.so.* /lib
ln -sfv ../../lib/$(readlink /usr/lib/libacl.so) /usr/lib/libacl.so
cd $LFS/sources
rm -rf $packageDir

tarball=`ls | grep 'libcap-' | tail -1`
tar -xvf $tarball
packageDir=`ls -d */`
cd $packageDir
sed -i '/install.*STALIBNAME/d' libcap/Makefile
make
make RAISE_SETFCAP=no lib=lib prefix=/usr install
chmod -v 755 /usr/lib/libcap.so
mv -v /usr/lib/libcap.so.* /lib
ln -sfv ../../lib/$(readlink /usr/lib/libcap.so) /usr/lib/libcap.so
cd $LFS/sources
rm -rf $packageDir

tarball=`ls | grep 'sed-4.4' | tail -1`
tar -xvf $tarball
packageDir=`ls -d */`
cd $packageDir
sed -i 's/usr/tools/'       build-aux/help2man
sed -i 's/panic-tests.sh//' Makefile.in
./configure --prefix=/usr --bindir=/bin
make
make html
make install
install -d -m755           /usr/share/doc/sed-4.4
install -m644 doc/sed.html /usr/share/doc/sed-4.4
cd $LFS/sources
rm -rf $packageDir

tarball=`ls | grep 'shadow-' | tail -1`
tar -xvf $tarball
packageDir=`ls -d */`
cd $packageDir
sed -i 's/groups$(EXEEXT) //' src/Makefile.in
find man -name Makefile.in -exec sed -i 's/groups\.1 / /'   {} \;
find man -name Makefile.in -exec sed -i 's/getspnam\.3 / /' {} \;
find man -name Makefile.in -exec sed -i 's/passwd\.5 / /'   {} \;
sed -i -e 's@#ENCRYPT_METHOD DES@ENCRYPT_METHOD SHA512@' \
       -e 's@/var/spool/mail@/var/mail@' etc/login.defs
echo '--- src/useradd.c   (old)
+++ src/useradd.c   (new)
@@ -2027,6 +2027,8 @@
        is_shadow_grp = sgr_file_present ();
 #endif
 
+       get_defaults ();
+
        process_flags (argc, argv);
 
 #ifdef ENABLE_SUBIDS
@@ -2036,8 +2038,6 @@
            (!user_id || (user_id <= uid_max && user_id >= uid_min));
 #endif                         /* ENABLE_SUBIDS */
 
-       get_defaults ();
-
 #ifdef ACCT_TOOLS_SETUID
 #ifdef USE_PAM
        {' | patch -p0 -l
sed -i 's@DICTPATH.*@DICTPATH\t/lib/cracklib/pw_dict@' etc/login.defs
sed -i 's/1000/999/' etc/useradd
sed -i -e '47 d' -e '60,65 d' libmisc/myname.c
./configure --sysconfdir=/etc --with-group-name-max-length=32
make
make install
mv -v /usr/bin/passwd /bin
pwconv
grpconv
sed -i 's/yes/no/' /etc/default/useradd
passwd root
cd $LFS/sources
rm -rf $packageDir

tarball=`ls | grep 'psmisc-' | tail -1`
tar -xvf $tarball
packageDir=`ls -d */`
cd $packageDir
./configure --prefix=/usr
make
make install
mv -v /usr/bin/fuser   /bin
mv -v /usr/bin/killall /bin
cd $LFS/sources
rm -rf $packageDir

tarball=`ls | grep 'iana-et' | tail -1`
tar -xvf $tarball
packageDir=`ls -d */`
cd $packageDir
make
make install
cd $LFS/sources
rm -rf $packageDir

tarball=`ls | grep 'm4-1.4.' | tail -1`
tar -xvf $tarball
packageDir=`ls -d */`
cd $packageDir
./configure --prefix=/usr
make
make install
cd $LFS/sources
rm -rf $packageDir

tarball=`ls | grep 'bison-3' | tail -1`
tar -xvf $tarball
packageDir=`ls -d */`
cd $packageDir
./configure --prefix=/usr --docdir=/usr/share/doc/bison-3.0.4
make
make install
cd $LFS/sources
rm -rf $packageDir

tarball=`ls | grep 'flex-2.' | tail -1`
tar -xvf $tarball
packageDir=`ls -d */`
cd $packageDir
HELP2MAN=/tools/bin/true \
./configure --prefix=/usr --docdir=/usr/share/doc/flex-2.6.3
make
make install
ln -sv flex /usr/bin/lex
cd $LFS/sources
rm -rf $packageDir

tarball=`ls | grep 'grep-3.' | tail -1`
tar -xvf $tarball
packageDir=`ls -d */`
cd $packageDir
./configure --prefix=/usr --bindir=/bin
make
make install
cd $LFS/sources
rm -rf $packageDir

tarball=`ls | grep 'readlin' | tail -1`
tar -xvf $tarball
packageDir=`ls -d */`
cd $packageDir
sed -i '/MV.*old/d' Makefile.in
sed -i '/{OLDSUFF}/c:' support/shlib-install
./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/readline-7.0
make SHLIB_LIBS=-lncurses
make SHLIB_LIBS=-lncurses install
mv -v /usr/lib/lib{readline,history}.so.* /lib
ln -sfv ../../lib/$(readlink /usr/lib/libreadline.so) /usr/lib/libreadline.so
ln -sfv ../../lib/$(readlink /usr/lib/libhistory.so ) /usr/lib/libhistory.so
install -v -m644 doc/*.{ps,pdf,html,dvi} /usr/share/doc/readline-7.0
cd $LFS/sources
rm -rf $packageDir

tarball=`ls | grep 'bash-4.' | tail -1`
tar -xvf $tarball
packageDir=`ls -d */`
cd $packageDir
patch -Np1 -i ../bash-4.4-upstream_fixes-1.patch
./configure --prefix=/usr                       \
            --docdir=/usr/share/doc/bash-4.4 \
            --without-bash-malloc               \
            --with-installed-readline
make
make install
mv -vf /usr/bin/bash /bin
exec /bin/bash --login +h
cd $LFS/sources
rm -rf $packageDir

tarball=`ls | grep 'bc-1.06' | tail -1`
tar -xvf $tarball
packageDir=`ls -d */`
cd $packageDir
patch -Np1 -i ../bc-1.06.95-memory_leak-1.patch
./configure --prefix=/usr           \
            --with-readline         \
            --mandir=/usr/share/man \
            --infodir=/usr/share/info
make
echo "quit" | ./bc/bc -l Test/checklib.b
make install
cd $LFS/sources
rm -rf $packageDir

tarball=`ls | grep 'libtool' | tail -1`
tar -xvf $tarball
packageDir=`ls -d */`
cd $packageDir
./configure --prefix=/usr
make
make install
cd $LFS/sources
rm -rf $packageDir

tarball=`ls | grep 'gdbm-1.' | tail -1`
tar -xvf $tarball
packageDir=`ls -d */`
cd $packageDir
./configure --prefix=/usr \
            --disable-static \
            --enable-libgdbm-compat
make
make install
cd $LFS/sources
rm -rf $packageDir

tarball=`ls | grep 'gperf-3' | tail -1`
tar -xvf $tarball
packageDir=`ls -d */`
cd $packageDir
./configure --prefix=/usr --docdir=/usr/share/doc/gperf-3.0.4
make
make install
cd $LFS/sources
rm -rf $packageDir

tarball=`ls | grep 'expat-2' | tail -1`
tar -xvf $tarball
packageDir=`ls -d */`
cd $packageDir
./configure --prefix=/usr --disable-static
make
make install
install -v -dm755 /usr/share/doc/expat-2.2.0
install -v -m644 doc/*.{html,png,css} /usr/share/doc/expat-2.2.0
cd $LFS/sources
rm -rf $packageDir

tarball=`ls | grep 'inetuti' | tail -1`
tar -xvf $tarball
packageDir=`ls -d */`
cd $packageDir
./configure --prefix=/usr        \
            --localstatedir=/var \
            --disable-logger     \
            --disable-whois      \
            --disable-rcp        \
            --disable-rexec      \
            --disable-rlogin     \
            --disable-rsh        \
            --disable-servers
make
make install
mv -v /usr/bin/{hostname,ping,ping6,traceroute} /bin
mv -v /usr/bin/ifconfig /sbin
cd $LFS/sources
rm -rf $packageDir

tarball=`ls | grep 'perl-5.' | tail -1`
tar -xvf $tarball
packageDir=`ls -d */`
cd $packageDir
echo "127.0.0.1 localhost $(hostname)" > /etc/hosts
export BUILD_ZLIB=False
export BUILD_BZIP2=0
sh Configure -des -Dprefix=/usr                 \
                  -Dvendorprefix=/usr           \
                  -Dman1dir=/usr/share/man/man1 \
                  -Dman3dir=/usr/share/man/man3 \
                  -Dpager="/usr/bin/less -isR"  \
                  -Duseshrplib
make
make install
unset BUILD_ZLIB BUILD_BZIP2
cd $LFS/sources
rm -rf $packageDir

tarball=`ls | grep -i 'xml' | tail -1`
tar -xvf $tarball
packageDir=`ls -d */`
cd $packageDir
perl Makefile.PL
make
make install
cd $LFS/sources
rm -rf $packageDir

tarball=`ls | grep 'intltoo' | tail -1`
tar -xvf $tarball
packageDir=`ls -d */`
cd $packageDir
sed -i 's:\\\${:\\\$\\{:' intltool-update.in
./configure --prefix=/usr
make
make install
install -v -Dm644 doc/I18N-HOWTO /usr/share/doc/intltool-0.51.0/I18N-HOWTO
cd $LFS/sources
rm -rf $packageDir

tarball=`ls | grep 'autocon' | tail -1`
tar -xvf $tarball
packageDir=`ls -d */`
cd $packageDir
./configure --prefix=/usr
make
make install
cd $LFS/sources
rm -rf $packageDir

tarball=`ls | grep 'automak' | tail -1`
tar -xvf $tarball
packageDir=`ls -d */`
cd $packageDir
sed -i 's:/\\\${:/\\\$\\{:' bin/automake.in
./configure --prefix=/usr --docdir=/usr/share/doc/automake-1.15
make
make install
cd $LFS/sources
rm -rf $packageDir

tarball=`ls | grep 'xz-5.2.' | tail -1`
tar -xvf $tarball
packageDir=`ls -d */`
cd $packageDir
./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/xz-5.2.3
make
make install
mv -v   /usr/bin/{lzma,unlzma,lzcat,xz,unxz,xzcat} /bin
mv -v /usr/lib/liblzma.so.* /lib
ln -svf ../../lib/$(readlink /usr/lib/liblzma.so) /usr/lib/liblzma.so
cd $LFS/sources
rm -rf $packageDir

tarball=`ls | grep 'kmod-23' | tail -1`
tar -xvf $tarball
packageDir=`ls -d */`
cd $packageDir
./configure --prefix=/usr          \
            --bindir=/bin          \
            --sysconfdir=/etc      \
            --with-rootlibdir=/lib \
            --with-xz              \
            --with-zlib
make
make install

for target in depmod insmod lsmod modinfo modprobe rmmod; do
  ln -sfv ../bin/kmod /sbin/$target
done

ln -sfv kmod /bin/lsmod
cd $LFS/sources
rm -rf $packageDir

tarball=`ls | grep 'gettext' | tail -1`
tar -xvf $tarball
packageDir=`ls -d */`
cd $packageDir
sed -i '/^TESTS =/d' gettext-runtime/tests/Makefile.in &&
sed -i 's/test-lock..EXEEXT.//' gettext-tools/gnulib-tests/Makefile.in
./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/gettext-0.19.8.1
make
make install
chmod -v 0755 /usr/lib/preloadable_libintl.so
cd $LFS/sources
rm -rf $packageDir

tarball=`ls | grep 'procps-' | tail -1`
tar -xvf $tarball
packageDir=`ls -d */`
cd $packageDir
./configure --prefix=/usr                            \
            --exec-prefix=                           \
            --libdir=/usr/lib                        \
            --docdir=/usr/share/doc/procps-ng-3.3.12 \
            --disable-static                         \
            --disable-kill
make
make install
mv -v /usr/lib/libprocps.so.* /lib
ln -sfv ../../lib/$(readlink /usr/lib/libprocps.so) /usr/lib/libprocps.so
cd $LFS/sources
rm -rf $packageDir

tarball=`ls | grep 'e2fspro' | tail -1`
tar -xvf $tarball
packageDir=`ls -d */`
cd $packageDir
mkdir -v build
cd build
LIBS=-L/tools/lib                    \
CFLAGS=-I/tools/include              \
PKG_CONFIG_PATH=/tools/lib/pkgconfig \
../configure --prefix=/usr           \
             --bindir=/bin           \
             --with-root-prefix=""   \
             --enable-elf-shlibs     \
             --disable-libblkid      \
             --disable-libuuid       \
             --disable-uuidd         \
             --disable-fsck
make
make install
make install-libs
chmod -v u+w /usr/lib/{libcom_err,libe2p,libext2fs,libss}.a
gunzip -v /usr/share/info/libext2fs.info.gz
install-info --dir-file=/usr/share/info/dir /usr/share/info/libext2fs.info
makeinfo -o      doc/com_err.info ../lib/et/com_err.texinfo
install -v -m644 doc/com_err.info /usr/share/info
install-info --dir-file=/usr/share/info/dir /usr/share/info/com_err.info
cd $LFS/sources
rm -rf $packageDir

tarball=`ls | grep 'coreuti' | tail -1`
tar -xvf $tarball
packageDir=`ls -d */`
cd $packageDir
patch -Np1 -i ../coreutils-8.26-i18n-1.patch
sed -i '/test.lock/s/^/#/' gnulib-tests/gnulib.mk
FORCE_UNSAFE_CONFIGURE=1 ./configure \
            --prefix=/usr            \
            --enable-no-install-program=kill,uptime
FORCE_UNSAFE_CONFIGURE=1 make
echo "dummy:x:1000:nobody" >> /etc/group
chown -Rv nobody . 
sed -i '/dummy/d' /etc/group
make install
mv -v /usr/bin/{cat,chgrp,chmod,chown,cp,date,dd,df,echo} /bin
mv -v /usr/bin/{false,ln,ls,mkdir,mknod,mv,pwd,rm} /bin
mv -v /usr/bin/{rmdir,stty,sync,true,uname} /bin
mv -v /usr/bin/chroot /usr/sbin
mv -v /usr/share/man/man1/chroot.1 /usr/share/man/man8/chroot.8
sed -i s/\"1\"/\"8\"/1 /usr/share/man/man8/chroot.8
mv -v /usr/bin/{head,sleep,nice,test,[} /bin
cd $LFS/sources
rm -rf $packageDir

tarball=`ls | grep 'diffuti' | tail -1`
tar -xvf $tarball
packageDir=`ls -d */`
cd $packageDir
sed -i 's:= @mkdir_p@:= /bin/mkdir -p:' po/Makefile.in.in
./configure --prefix=/usr
make
make install
cd $LFS/sources
rm -rf $packageDir

tarball=`ls | grep 'gawk-4.' | tail -1`
tar -xvf $tarball
packageDir=`ls -d */`
cd $packageDir
./configure --prefix=/usr
make
make install
mkdir -v /usr/share/doc/gawk-4.1.4
cp    -v doc/{awkforai.txt,*.{eps,pdf,jpg}} /usr/share/doc/gawk-4.1.4
cd $LFS/sources
rm -rf $packageDir

tarball=`ls | grep 'finduti' | tail -1`
tar -xvf $tarball
packageDir=`ls -d */`
cd $packageDir
sed -i 's/test-lock..EXEEXT.//' tests/Makefile.in
./configure --prefix=/usr --localstatedir=/var/lib/locate
make
make install
mv -v /usr/bin/find /bin
sed -i 's|find:=${BINDIR}|find:=/bin|' /usr/bin/updatedb
cd $LFS/sources
rm -rf $packageDir

tarball=`ls | grep 'groff-1' | tail -1`
tar -xvf $tarball
packageDir=`ls -d */`
cd $packageDir
make
make install
cd $LFS/sources
rm -rf $packageDir

tarball=`ls | grep 'grub-2.' | tail -1`
tar -xvf $tarball
packageDir=`ls -d */`
cd $packageDir
./configure --prefix=/usr          \
            --sbindir=/sbin        \
            --sysconfdir=/etc      \
            --disable-efiemu       \
            --disable-werror
make
make install
cd $LFS/sources
rm -rf $packageDir

tarball=`ls | grep 'less-48' | tail -1`
tar -xvf $tarball
packageDir=`ls -d */`
cd $packageDir
./configure --prefix=/usr --sysconfdir=/etc
make
make install
cd $LFS/sources
rm -rf $packageDir

tarball=`ls | grep 'gzip-1.' | tail -1`
tar -xvf $tarball
packageDir=`ls -d */`
cd $packageDir
./configure --prefix=/usr
make
make install
mv -v /usr/bin/gzip /bin
cd $LFS/sources
rm -rf $packageDir

tarball=`ls | grep 'iproute' | tail -1`
tar -xvf $tarball
packageDir=`ls -d */`
cd $packageDir
sed -i /ARPD/d Makefile
sed -i 's/arpd.8//' man/man8/Makefile
rm -v doc/arpd.sgml
sed -i 's/m_ipt.o//' tc/Makefile
make
make DOCDIR=/usr/share/doc/iproute2-4.9.0 install
cd $LFS/sources
rm -rf $packageDir

tarball=`ls | grep 'kbd-2.0' | tail -1`
tar -xvf $tarball
packageDir=`ls -d */`
cd $packageDir
patch -Np1 -i ../kbd-2.0.4-backspace-1.patch
sed -i 's/\(RESIZECONS_PROGS=\)yes/\1no/g' configure
sed -i 's/resizecons.8 //' docs/man/man8/Makefile.in
PKG_CONFIG_PATH=/tools/lib/pkgconfig ./configure --prefix=/usr --disable-vlock
make
make install
mkdir -v       /usr/share/doc/kbd-2.0.4
cp -R -v docs/doc/* /usr/share/doc/kbd-2.0.4
cd $LFS/sources
rm -rf $packageDir

tarball=`ls | grep 'libpipe' | tail -1`
tar -xvf $tarball
packageDir=`ls -d */`
cd $packageDir
PKG_CONFIG_PATH=/tools/lib/pkgconfig ./configure --prefix=/usr
make
make install
cd $LFS/sources
rm -rf $packageDir

tarball=`ls | grep 'make-4.' | tail -1`
tar -xvf $tarball
packageDir=`ls -d */`
cd $packageDir
./configure --prefix=/usr
make
make install
cd $LFS/sources
rm -rf $packageDir

tarball=`ls | grep 'patch-2' | tail -1`
tar -xvf $tarball
packageDir=`ls -d */`
cd $packageDir
./configure --prefix=/usr
make
make install
cd $LFS/sources
rm -rf $packageDir

tarball=`ls | grep 'sysklog' | tail -1`
tar -xvf $tarball
packageDir=`ls -d */`
cd $packageDir
sed -i '/Error loading kernel symbols/{n;n;d}' ksym_mod.c
sed -i 's/union wait/int/' syslogd.c
make
make BINDIR=/sbin install

cat > /etc/syslog.conf << "EOF"
# Begin /etc/syslog.conf

auth,authpriv.* -/var/log/auth.log
*.*;auth,authpriv.none -/var/log/sys.log
daemon.* -/var/log/daemon.log
kern.* -/var/log/kern.log
mail.* -/var/log/mail.log
user.* -/var/log/user.log
*.emerg *

# End /etc/syslog.conf

EOF
cd $LFS/sources
rm -rf $packageDir

tarball=`ls | grep 'sysvini' | tail -1`
tar -xvf $tarball
packageDir=`ls -d */`
cd $packageDir
patch -Np1 -i ../sysvinit-2.88dsf-consolidated-1.patch
make -C src
make -C src install
cd $LFS/sources
rm -rf $packageDir

tarball=`ls | grep 'eudev-3' | tail -1`
tar -xvf $tarball
packageDir=`ls -d */`
cd $packageDir
sed -r -i 's|/usr(/bin/test)|\1|' test/udev-test.pl
sed -i '/keyboard_lookup_key/d' src/udev/udev-builtin-keyboard.c
cat > config.cache << "EOF"
HAVE_BLKID=1
BLKID_LIBS="-lblkid"
BLKID_CFLAGS="-I/tools/include"
EOF
./configure --prefix=/usr           \
            --bindir=/sbin          \
            --sbindir=/sbin         \
            --libdir=/usr/lib       \
            --sysconfdir=/etc       \
            --libexecdir=/lib       \
            --with-rootprefix=      \
            --with-rootlibdir=/lib  \
            --enable-manpages       \
            --disable-static        \
            --config-cache
LIBRARY_PATH=/tools/lib make
mkdir -pv /lib/udev/rules.d
mkdir -pv /etc/udev/rules.d
make LD_LIBRARY_PATH=/tools/lib install
tar -xvf ../udev-lfs-20140408.tar.bz2
make -f udev-lfs-20140408/Makefile.lfs install
LD_LIBRARY_PATH=/tools/lib udevadm hwdb --update
cd $LFS/sources
rm -rf $packageDir

tarball=`ls | grep 'util-li' | tail -1`
tar -xvf $tarball
packageDir=`ls -d */`
cd $packageDir
mkdir -pv /var/lib/hwclock
./configure ADJTIME_PATH=/var/lib/hwclock/adjtime   \
            --docdir=/usr/share/doc/util-linux-2.29.1 \
            --disable-chfn-chsh  \
            --disable-login      \
            --disable-nologin    \
            --disable-su         \
            --disable-setpriv    \
            --disable-runuser    \
            --disable-pylibmount \
            --disable-static     \
            --without-python     \
            --without-systemd    \
            --without-systemdsystemunitdir
make
make install
cd $LFS/sources
rm -rf $packageDir

tarball=`ls | grep 'man-db-' | tail -1`
tar -xvf $tarball
packageDir=`ls -d */`
cd $packageDir
./configure --prefix=/usr                        \
            --docdir=/usr/share/doc/man-db-2.7.6.1 \
            --sysconfdir=/etc                    \
            --disable-setuid                     \
            --enable-cache-owner=bin             \
            --with-browser=/usr/bin/lynx         \
            --with-vgrind=/usr/bin/vgrind        \
            --with-grap=/usr/bin/grap            \
            --with-systemdtmpfilesdir=
make
make install
cd $LFS/sources
rm -rf $packageDir

tarball=`ls | grep 'tar-1.2' | tail -1`
tar -xvf $tarball
packageDir=`ls -d */`
cd $packageDir
FORCE_UNSAFE_CONFIGURE=1  \
./configure --prefix=/usr \
            --bindir=/bin
make
make install
make -C doc install-html docdir=/usr/share/doc/tar-1.29
cd $LFS/sources
rm -rf $packageDir

tarball=`ls | grep 'texinfo' | tail -1`
tar -xvf $tarball
packageDir=`ls -d */`
cd $packageDir
./configure --prefix=/usr --disable-static
make
make install
make TEXMF=/usr/share/texmf install-tex
pushd /usr/share/info
rm -v dir
for f in *
  do install-info $f dir 2>/dev/null
done
popd
cd $LFS/sources
rm -rf $packageDir

tarball=`ls | grep 'vim-8.0' | tail -1`
tar -xvf $tarball
packageDir=`ls -d */`
cd $packageDir
echo '#define SYS_VIMRC_FILE "/etc/vimrc"' >> src/feature.h
./configure --prefix=/usr
make
make install
ln -sv vim /usr/bin/vi
for L in  /usr/share/man/{,*/}man1/vim.1; do
    ln -sv vim.1 $(dirname $L)/vi.1
done
ln -sv ../vim/vim80/doc /usr/share/doc/vim-8.0.069

cat > /etc/vimrc << "EOF"
" Begin /etc/vimrc

set nocompatible
set backspace=2
set mouse=r
syntax on
if (&term == "xterm") || (&term == "putty")
  set background=dark
endif


" End /etc/vimrc

EOF
vim -c ':options'
cd $LFS/sources
rm -rf $packageDir

