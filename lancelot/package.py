class package:

    def __init__(self, name, version=None, link=None, md5sum=None, deps=None, optDeps=None):
        self.name = name
        self.version = version
        self.link = link
        self.md5sum = md5sum
        self.deps = deps
        self.optDeps = optDeps
        self.commands = []

    def addCommand(self, commands):
        self.commands += commands
