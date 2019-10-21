#!/usr/bin/env python
#coding:utf-8
from jinja2 import Environment, FileSystemLoader
from dotenv import dotenv_values

import os
import sys

def main():
    outputFile = os.environ['OutputFile'] if os.environ['OutputFile'] else "bundle.yaml"
    rootFile = os.environ['RootFile'] if os.environ['RootFile'] else "root.yaml.j2"
    makefileFisrtDict = {}
    makefileOtherDicts = {}
    mergedDicts = {}

    makefileFisrtDict, makefileOtherDicts = parse_makefile_args()

    dotenvData = inmemory_load_env()

    mergedDicts = merge_args(dotenvData, makefileOtherDicts) # makefileOtherDicts > dotenvData

    renderedData = render_jinja_template(rootFile, makefileFisrtDict, mergedDicts)

    put_bundled_file(renderedData, makefileFisrtDict, outputFile)

def inmemory_load_env():
    path = "./.env"
    if os.path.isfile(path) == True:
        return dotenv_values(path)
    return {}

def parse_makefile_args():
    args = {}
    target = ""
    argvs = sys.argv
    for elm in argvs:
        if elm.find("=") != -1:
            kv = elm.split('=', 1)
            if "target" == kv[0].lower():
                target = kv[1]
            else:
                args[kv[0]] = kv[1]
    return target, args

def merge_args(d1, d2):
    newdict = dict(d1)
    newdict.update(d2)
    return newdict

def render_jinja_template(rootFile, makefileFisrtDict, mergedDicts):
    path = './src/'
    root = makefileFisrtDict + '/' + rootFile
    reMergedDicts = merge_args({'dirname':makefileFisrtDict}, mergedDicts)
    env = Environment(loader=FileSystemLoader(path, encoding='utf8'))
    tmpl = env.get_template(root)
    rendered = tmpl.render(reMergedDicts)
    return rendered

def put_bundled_file(data, TARGET, outputfile):
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

