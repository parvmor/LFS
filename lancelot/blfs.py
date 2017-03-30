from bs4 import BeautifulSoup as htmlParser
from urllib.request import urlopen
from package import package
from parser import *
import re
import json

blfs = "http://www.linuxfromscratch.org/blfs/view/stable/"

def security(chapter):
    """
    param:
        chapter : list of sections in security chapter
    return:
        None
    """
    sections = chapter.find_all('li', 'sect1')[1:]
    for section in sections:
        link = blfs + section.contents[1]['href']
        src = urlopen(link)
        parsedHtml = htmlParser(src, 'lxml')
        name = parsedHtml.title.string.strip()
        if name == 'Certificate Authority Certificates' :
            version = 'none'
            link, md5sum, deps, optDeps, commands = parser(parsedHtml)
            temp = package(name, version, link, md5sum, deps, optDeps)
            temp.addCommand(commands)
        elif name == 'Setting Up a Network Firewall':
            commands = commandParser(parsedHtml)
            packageDict = json.load(open('package.json', 'r'))
            for command in commands:
                packageDict['iptables']['1.6.1']['commands'] = packageDict['iptables']['1.6.1']['commands'] + command
            open('package.json', 'w').write(json.dumps(packageDict, sort_keys=True, indent=4) + '\n')
        else:
            pattern = re.compile('(.*)-(\d[^\s]*)')
            name, version = re.findall(pattern,name)[0]
            link, md5sum, deps, optDeps, commands = parser(parsedHtml)
            temp = package(name, version, link, md5sum, deps, optDeps)
            temp.addCommand(commands)

def main():
    src = urlopen(blfs)
    parsedHtml = htmlParser(src, 'lxml')
    chapters = parsedHtml.find_all('li', 'chapter')
    security(chapters[3])

if __name__=='__main__':
    main()
