from urllib.request import urlopen
from bs4 import BeautifulSoup
import re

ignore=[re.compile('make\s.*check'), re.compile('make\s.*test')]
scraper = open('scrape.sh', 'w')
scraper.write('set -e\n')
scraper.write('set -x\n\n')
scraper.write('cd $LFS/sources\n\n')
lfs = "http://www.linuxfromscratch.org/lfs/view/stable/"
src = urlopen(lfs)
parsedHtml = BeautifulSoup(src, 'lxml')
chapter5 = parsedHtml.find_all('li', 'chapter')[4]
sections = chapter5.find_all('li', 'sect1')
sections = sections[10:-2]
for section in sections:
    link = lfs + section.contents[1]['href']
    packageSrc = urlopen(link)
    package = section.contents[1].string[:6].lower()
    scraper.write('tarball=`ls | grep \'' + package + '\' | tail -1`\n')
    scraper.write('tar -xvf $tarball\n')
    scraper.write('packageDir=`ls -d */`\n')
    scraper.write('cd $packageDir\n')
    packageBS = BeautifulSoup(packageSrc, 'lxml')
    commands = packageBS.find_all('kbd', 'command')
    for command in commands:
        command = command.string
        flag = 1
        for pattern in ignore:
            if re.search(pattern,command) is not None:
                flag = 0
                break
        if flag:
            scraper.write(command + '\n')
    scraper.write('cd $LFS/sources\n')
    scraper.write('rm -rf $packageDir\n\n')
