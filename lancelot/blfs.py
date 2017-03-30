from bs4 import BeautifulSoup as htmlParser
from urllib.request import urlopen
import re

from package import package as pac
"""
param of pac:
    name
    version=None
    link=None
    md5sum=None
    deps=None
    optDeps=None
methods:
    addCommand:
        param:
            commands to be added as a list
"""

blfs = "http://www.linuxfromscratch.org/blfs/view/stable/"

def security(chapter):
    """
    param:
        chapter : list of sections in security chapter

    return:
        an instance of pac class
    """
    sections = chapter.find_all('li', 'sect1')[1:]
    for section in sections:
        link = blfs + section.contents[1]['href']
        src = urlopen(link)
        parsedHtml = htmlParser(src, 'lxml')
        name = parsedHtml.title.string.strip()
        if name == 'Certificate Authority Certificates' :
            version = 'none'
        elif name == 'Setting Up a Network Firewall':
            # TODO : add the commands to iptables, 1.6.1
        else:
            pattern = re.compile('(.*)-(\d[^\s]*)')
            name, version = re.findall(pattern,name)[0]

def main():
    src = urlopen(blfs)
    parsedHtml = htmlParser(src, 'lxml')
    chapters = parsedHtml.find_all('li', 'chapter')
    security(chapters[3])

if __name__=='__main__':
    main()
