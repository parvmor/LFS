from bs4 import BeautifulSoup as htmlParser
import re

def parser(parsedHtml):
    itemizedList = parsedHtml.find_all('div', 'itemizedlist')
    # Download link
    paras = itemizedList[0].find_all('p')
    linkFlag = 1
    link = ""
    pattern = re.compile('(.*)-(\d[^\s]*)')
    for para in paras:
        anchors = para.find_all('a')
        if anchors == []:
            content = para.string.strip()
            if re.search('[Mm][Dd]5 [Ss][uU][Mm]', content) is not None:
                md5sum = re.findall(':(.*)', content)[0].strip()
            else:
                continue
        elif linkFlag:
            content = para.contents[0].strip()
            if re.search('[Dd]ownload.* (([Hh][Tt])|[Ff])[tT][pP]', content) is not None:
                link = para.a['href']
                linkFlag = 0
    if re.search(re.compile('[Aa]dditional\s+[Dd]ownload'), str(parsedHtml)) is not None:
        additionals = itemizedList[1].find_all('a', 'ulink')
        for additional in additionals:
            link += ' , '
            link += additional['href']
    optParas = parsedHtml.find_all('p', 'optional')
    requiredParas = parsedHtml.find_all('p', 'required') + parsedHtml.find_all('p', 'recommended')
    optDeps = []
    deps = []
    for opt in optParas:
        anchors = opt.find_all('a', 'xref')
        for anchor in anchors:
            if re.search(pattern, anchor['title'].strip()) is None:
                depName = anchor['title'].strip()
                depVersion = 'none'
            else:
                depName, depVersion = re.findall(pattern, anchor['title'].strip())[0]
            optDeps.append((depName, depVersion))
    for required in requiredParas:
        anchors = required.find_all('a', 'xref')
        for anchor in anchors:
            if re.search(pattern, anchor['title'].strip()) is None:
                depName = anchor['title'].strip()
                depVersion = 'none'
            else:
                depName, depVersion = re.findall(pattern, anchor['title'].strip())[0]
            deps.append((depName, depVersion))
    commands = commandParser(parsedHtml)
    return (link, md5sum, deps, optDeps, commands)

def commandParser(parsedHtml):
    commands = parsedHtml.find_all('kbd', 'command')
    for i in range(len(commands)):
        if commands[i].string is None:
            command = commands[i]
            if commands[i].find_all('em') != []:
                # TODO  : handle em
                commands[i] ='\n'
                continue
            commands[i] = command.contents[0]
            commands[i] = commands[i] + command.contents[1].string
            commands[i] = commands[i] + command.contents[2]
        else:
            commands[i] = commands[i].string
    return commands
