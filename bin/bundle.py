#!/usr/bin/env python
#coding:utf-8

from jinja2 import Environment, FileSystemLoader
import os
import sys

def main():
    outputfile = os.environ['OutputFile']
    rootfile = os.environ['RootFile']
    ARGS = {}
    TARGET = ""

    TARGET, ARGS = parse()

    env = Environment(loader=FileSystemLoader('./src/' + TARGET + "/", encoding='utf8'))
    tmpl = env.get_template(rootfile)
    renderd = tmpl.render(ARGS)

    put(renderd, TARGET, outputfile)

def parse():
    arg = {}
    target = ""
    argvs = sys.argv

    for elm in argvs:
        if elm.find("=") != -1:
            kv = elm.split('=')
            if "target" in kv[0].lower():
                target = kv[1]
            else:
                arg[kv[0]] = kv[1]

    return target, arg

def put(data, TARGET, outputfile):
    pathDir = "./dist/" + TARGET + "/"
    pathFile = pathDir + outputfile

    if os.path.isdir(pathDir) == False:
        os.makedirs(pathDir)

    f = open(pathFile,'w')
    f.write(data)
    f.close()
    print("Bundle is finished, output is there: " + pathFile)

if __name__ == '__main__':
    main()

