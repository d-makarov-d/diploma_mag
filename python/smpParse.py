# script for getting files with training examples and checking them
import os
import re

# frame length in secinds, needs to be the same in all trining examples
frameDuration = None
# frame length in points, needs to be the same in all trining examples
frameLength = None
# all valid files with training samples
validSets = []

# parse folder for *.smp files
# path - path to the folder
def parseFolder(path):
    setPat = re.compile(r"^.+\.smp$")
    for file in os.listdir(path):
        if setPat.match(file):
            validateSet("%s/%s" % (path, file))

# load set of examples from file to tf.Dataset
# path - path to *.smp file
def validateSet(path):
    global frameDuration, frameLength, totalTrains, totalNoises, validSets
    namePat = re.compile(r"[^/\\]+\.smp$")
    setName = namePat.search(path).group()
    print("{:<80}".format("checking %s ..." % setName), end='')
    allOK = True
    trains = 0
    noises = 0
    # enshure file contains correct data
    with open(path) as file:
        headerPat = re.compile(r"^([0-9.]+)\[([0-9]+)\]$")
        firstLine = file.readline()
        FLmatch = headerPat.match(firstLine)
        if FLmatch:
            frD = float(FLmatch.group(1))
            frL = int(FLmatch.group(2))
            # check frame duration integrity
            if (frameDuration):
                if (not frameDuration == frD):
                    print("files have different frame parameters")
                    allOK = False
                    exit(1)
            else:
                frameDuration = frD
            # check frame length integrity
            if (frameLength):
                if (not frameLength == frL):
                    print("files have different frame parameters")
                    exit(1)
            else:
                frameLength = frL
        else:
            print("incorrect header (%s)" % firstLine)
            return
        linePat = re.compile("^([01]) : ([0-9-.]+,){%i}[0-9-.]+$" % (frameLength-1))
        for line in file:
            Lmatch = linePat.match(line)
            if (Lmatch):
                if (int(Lmatch.group(1)) == 1):
                    trains += 1

                if (int(Lmatch.group(1)) == 0):
                    noises += 1
            else:
                print("incorrect format")
                return
        print("success (t: %d, n: %d)" % (trains, noises))
        validSets.append({"path" : path, "trains" : trains, "noises": noises})

def getFilesList(options):
    # exit if nothing to parse for trining examples
    if (not options.folder and not options.sets):
        print("no files or folder specified")
        exit(1)

    if (options.folder):
        parseFolder(options.folder)

    if (options.sets):
        for s in options.sets:
            validateSet(s)
    return validSets
