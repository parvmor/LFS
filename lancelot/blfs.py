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
        paras = parsedHtml.find_all('div', 'itemizedlist')[0].find_all('p')
        linkFlag = 1
        for para in paras:
            anchors = para.find_all('a')
            if anchors == []:
                content = para.string.strip()
                if re.search('MD5 Sum',content) is not None:
                    md5sum = re.findall(':(.*)',content)[0].strip()
                else:
                    continue
            elif linkFlag:
                content = para.contents[0].strip()
                if re.search('Download.*(([Hh][tT])|[fF])[tT][pP]',content) is not None:
                    link = para.a['href']
                    linkFlag = 0
        if re.search(re.compile('[Aa]dditional\s+[Dd]ownload'),parsedHtml) is not None:
            additionals = parsedHtml.find_all('div', 'itemizedlist')[1].find_all('a', 'ulink')
            for additional in additionals:
                link+=' , '
                link += additional['href']
        optParas = parsedHtml.find_all('p', 'optional')
        requiredParas = parsedHtml.find_all('p', 'required') + parsedHtml.find_all('p','recommended')
        optDeps = []
        deps=[]
        for opt in optParas:
            anchors = opt.find_all('a', 'xref')
            for anchor in anchors:
                if re.search(pattern,anchor['title'].strip()) is None:
                    depName = anchor['title'].strip()
                    depVersion = 'none'
                else:
                    depName,depVersion = re.findall(pattern,anchor['title'].strip())[0]
                optDeps.append((depName,depVersion))
        for required in requiredParas:
            anchors = required.find_all('a', 'xref')
            for anchor in anchors:
                if re.search(pattern,anchor['title'].strip()) is None:
                    depName = anchor['title'].strip()
                    depVersion = 'none'
                else:
                    depName,depVersion = re.findall(pattern,anchor['title'].strip())[0]
                deps.append((depName,depVersion))
        commands = parsedHtml.find_all('kbd', 'command')
        for i in range(len(commands)):
            if commands[i].string==None:
                command = commands[i].string
                if commands[i].find_all('em') != []:
                    # TODO : handle em
                    commands[i] = '\n'
                    continue
                commands[i] = command.contents[0]
                commands[i] = commands[i] + command.contents[1].string
                commands[i] = commands[i] + command.contents[2]
            else:
                commands[i] = commands[i].string

def main():
    src = urlopen(blfs)
    parsedHtml = htmlParser(src, 'lxml')
    chapters = parsedHtml.find_all('li', 'chapter')
    security(chapters[3])

if __name__=='__main__':
    main()
