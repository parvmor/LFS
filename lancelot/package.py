import json

class package:

    def __init__(self, name, version=None, link=None, md5sum=None, deps=None, optDeps=None):
        self.name = name
        self.version = version
        self.link = link
        self.md5sum = md5sum
        self.deps = deps
        self.optDeps = optDeps
        self.commands = " "

    def addCommand(self, commands):
        for command in commands:
            self.commands = self.commands + '\n' + command
        self.jsonify()
    
    def jsonify(self):
        rep = {
                self.name : {
                    self.version : {
                        "link" : self.link,
                        "md5sum" : self.md5sum,
                        "dependencies" : self.deps,
                        "optional dependencies" : self.optDeps,
                        "commands" : self.commands
                        }
                    }
                }
        alreadyInstalled = json.load(open('package.json','r'))
        if self.name in alreadyInstalled:
            alreadyInstalled[self.name].update(rep[self.name])
        else:
            alreadyInstalled.update(rep)
        jsoned = json.dumps(alreadyInstalled, sort_keys=True, indent=4)
        open('package.json', 'w').write(jsoned+'\n')

