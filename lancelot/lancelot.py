#!/usr/bin/env python

import argparse
import re
import json
import csv
import os
from graph import LanceLot

lancelot = LanceLot()

def parseArgs():
    parser = argparse.ArgumentParser()
    parser.add_argument('install', nargs='+', help="Packages to be installed (specify in form of name-version or name)")
    args = parser.parse_args()
    return args

def resolve(name, version, alreadyInstalled):
    # Display optional dependencies
    optDeps = lancelot.packageDict[name][version]["optional dependencies"]
    if len(optDeps) != 0:
        print("Please choose the optional dependencies you want for this program:")
        idx = 1
        for optDep in optDeps:
            print("%d) %s-%s" % (idx, optDep[0], optDep[1]))
            idx += 1
        print("%d) None" % idx)
        print("Values(comma separated):")
        required = input().split(',')
        for i in range(len(required)):
            try:
                required[i] = int(required[i])
                if required[i] == idx:
                    break
            except:
                raise Exception("integers(>=0) were required with comma separated values")
            lancelot.addEdge((optDeps[required[i]-1][0], optDeps[required[i]-1][1]), (name, version))
    #Top Sort
    order = lancelot.topologicalSort(name, version)
    for package in order:
        if package in alreadyInstalled:
            continue
        lancelot.install(package)
        alreadyInstalled.append(package)
        with open('installedPackages.csv', 'w') as f:
            writer = csv.writer(f, quotechar='"', quoting=csv.QUOTE_ALL)
            for tbw in alreadyInstalled:
                writer.writerow([tbw[0], tbw[1]])
    #Remove optional edges
    if len(optDeps) != 0:
        for i in range(len(required[i])):
            if required[i] == idx:
                break
            lancelot.removeEdge((optDeps[required[i]-1][0], optDeps[required[i]-1][1]), (name, version))

def main():
    args = parseArgs()
    pattern = re.compile('(.*)-(\d[^\s]*)')
    packages = args.install
    alreadyInstalled = []
    with open('installedPackages.csv', 'r') as f:
        reader = csv.reader(f)
        for row in reader:
            alreadyInstalled.append((row[0], row[1]))
    for package in packages:
        if re.search(pattern, package) is None:
            name = package.strip().lower()
            version = lancelot.highestVersion(name).lower().strip()
        else:
            name, version = re.findall(pattern, package)[0]
            name = name.lower().strip()
            version = version.lower().strip()
        if (name, version) in alreadyInstalled:
            print("Package is already installed")
        else:
            if name not in lancelot.packageDict:
                raise Exception("%s could not be found." % (name + '-' + version))
            if version not in lancelot.packageDict[name]:
                raise Exception("%s could not be found with the specified version." % name)
            resolve(name, version, alreadyInstalled)
    
if __name__ == '__main__':
    cwd = os.getcwd()
    os.chdir(cwd + '/auxilary')
    for item in os.listdir():
        os.system('rm -rf ' + item)
    os.chdir(cwd)
    main()
