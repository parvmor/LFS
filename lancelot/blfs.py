from bs4 import BeautifulSoup as htmlParser
from urllib.request import urlopen
from package import package
from parser import *
import re
import json

blfs = "http://www.linuxfromscratch.org/blfs/view/stable/"
pattern = re.compile('(.*)-(\d[^\s]*)')

def general(chapter):
    """
    param:
        chapter: bs4 tag object of chapter
    return:
        None
    """
    sections = chapter.find_all('li', 'sect1')
    for section in sections:
        if section.find_all('a') == []:
            continue
        print(section)
        link = blfs + section.a['href']
        src = urlopen(link)
        parsedHtml = htmlParser(src, 'lxml')
        name = parsedHtml.title.string.strip()
        if re.search('[xX]org', name) is not None:
            continue
        elif name == "Certificate Authority Certificates" :
            version = 'none'
            link, md5sum, deps, optDeps, commands = parser(parsedHtml)
            temp = package(name, version, link, md5sum, deps, optDeps)
            temp.addCommand(commands)
        elif re.search(pattern, name) is None:
            continue
        else:
            name, version = re.findall(pattern,name)[0]
            if parsedHtml.find_all('div', 'itemizedlist') == []:
                continue
            link, md5sum, deps, optDeps, commands = parser(parsedHtml)
            temp = package(name, version, link, md5sum, deps, optDeps)
            temp.addCommand(commands)

def main():
    src = urlopen(blfs)
    parsedHtml = htmlParser(src, 'lxml')
    chapters = parsedHtml.find_all('li', 'chapter')
    for chapter in (chapters[3:53]):
        general(chapter)

if __name__=='__main__':
    main()
