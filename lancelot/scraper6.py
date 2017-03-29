from urllib.request import urlopen
from bs4 import BeautifulSoup as htmlParser
import re

from package import package as pac

pattern = [re.compile('([^\s]*)\s.*\((.*)\)'),re.compile('(.*)-(\d[^\s]*)')]
lfs = "http://www.linuxfromscratch.org/lfs/view/stable/"
src = urlopen(lfs)
parsedHtml = htmlParser(src, 'lxml')
chapters = parsedHtml.find_all('li', 'chapter')
packageDict = {}

sections = chapters[2].find_all('li', 'sect1')
section = sections[1]
link = lfs + section.contents[1]['href']
linkSrc = urlopen(link)
parsedLink = htmlParser(linkSrc, 'lxml')
variableList = parsedLink.find_all('dl', 'variablelist')
dtList = variableList[0].find_all('dt')
ddList = variableList[0].find_all('dd')
for dd,dt in zip(ddList,dtList):
    package = dt.contents[1].contents[0][:-3].lower()
    if package == "time zone data (2016j)":
        name, version = "time zone data", "2016j"
    else:
        name, version = re.findall(pattern[0],package)[0]
        name = name.lower()
        version = version.lower()
        if(name == 'procps'):
            name += '-ng'
    dd = dd.find_all('p')
    idx = 0
    if re.search('[H|h]ome', dd[0].contents[0]) is not None:
        idx = idx + 1
    if package == "file (5.30)":
        link = "http://ftp.lfs-matrix.net/pub/lfs/lfs-packages/8.0-rc1/file-5.30.tar.gz"
    else:
        link = dd[idx].contents[1]['href']
    md5sum = dd[idx+1].contents[1].string
    packageDict[(name, version)] = pac(name, version, link, md5sum)
    print(packageDict[(name, version)])

sections = chapters[5].find_all('li', 'sect1')
sections = sections[6:-3]
for section in sections:
    link = lfs + section.contents[1]['href']
    packageSrc = urlopen(link)
    parsedPackageSrc = htmlParser(packageSrc, 'lxml')
    commands = parsedPackageSrc.find_all('kbd', 'command')
    for i in range(len(commands)):
        commands[i] = commands[i].string
    package = section.contents[1].string.lower()
    match = re.findall(pattern[1], package)
    if match == []:
        packageDict[('glibc','2.25')].addCommand(commands)
    else:
        name, version = match[0]
        name = name.lower()
        version = version.lower()
        packageDict[(name, version)].addCommand(commands)
