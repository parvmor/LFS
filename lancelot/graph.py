from collections import defaultdict, deque
import json
import sys
import os
import hashlib

if sys.version_info[0]>=3:
    from urllib.request import urlretrieve
else:
    from urllib import urlretrieve

class LanceLot:

    def __init__(self):
        self.adjacencyList = defaultdict(deque)
        packageDict = json.load(open('package.json', 'r'))
        self.packageDict = { key.lower() : packageDict[key] for key in packageDict.keys() }
        packages = self.packageDict.keys()
        for package in packages:
            versionDict = self.packageDict[package]
            versions = versionDict.keys()
            for version in versions:
                self.adjacencyList[(package, version)] = deque()
                dependencies = versionDict[version]['dependencies']
                for dependency in dependencies:
                    self.addEdge((dependency[0], dependency[1]), (package, version))

    def addEdge(self, u, v):
        self.adjacencyList[v].append(u)

    def highestVersion(self, package):
        if package not in self.packageDict:
            raise Exception("%s package could not be found." % (package))
        versions = self.packageDict[package].keys()
        return max(versions)
    
    def removeEdge(self, u, v):
        self.adjacencyList[v].pop()

    def topologicalSort(self, name, version):
        order = deque()
        visited = dict()
        for node in self.adjacencyList.keys():
            visited[node] = -1
        package = (name, version)
        self.visit(order, visited, package)
        return order

    def visit(self, order, visited, package):
        if visited[package] == 1:
            raise Exception("Topological Sort Algorithm was not correct.")
        if visited[package] == 0:
            raise Exception("Dependency graph is not a DAG.")
        visited[package] = 0
        for node in self.adjacencyList[package]:
            if visited[node] != 1:
                self.visit(order, visited, node)
        visited[package] = 1
        order.append(package)

    def install(self, package):
        name, version = package[0], package[1]
        data = self.packageDict[name][version]
        links, md5sum = data['link'], data['md5sum']
        flag = 0
        for link in links.split(','):
            fileName = link.split("/")[-1]
            urlretrieve(link,"./auxilary/" + fileName)
            if flag == 0:
                if md5sum != hashlib.md5(open('./auxilary/' + fileName, 'rb').read()).hexdigest():
                    raise Exception("There was a problem in downloading.")
            flag = 1
        cwd = os.getcwd()
        os.chdir("./auxilary")
        os.system("tar -xf " + fileName)
        for item in os.listdir():
            if os.path.isdir(item):
                os.chdir(item)
                break
        os.system(data['commands'])
        os.chdir(cwd)
        os.chdir('./auxilary')
        for item in os.listdir():
            os.system('rm -rf ' + item)
        os.chdir(cwd)
