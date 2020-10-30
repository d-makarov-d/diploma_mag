"""module for parsing .smp files

This module provides function to parse user - specified files of training
examples and check data integrity.

Todo:
    handle exceptions raised by validateSet

"""
import os
import re

frameDuration = None
"""frame length in secinds, needs to be the same in all trining examples"""
frameLength = None
"""frame length in points, needs to be the same in all trining examples"""
validSets = []
"""all valid files with training samples"""

def parseFolder(path):
    """parse specified folder for .smp files

    Args:
        path (str): path to a folder to parse

    """
    setPat = re.compile(r"^.+\.smp$")
    for file in os.listdir(path):
        if setPat.match(file):
            validateSet("%s/%s" % (path, file))

def validateSet(path):
    """validates a set of examples from specified file, and checks frame
    parameters intrgrity

    Args:
        path (str): path to .smp file with examples for trining

    Raises:
        FrameExeption: If frame integrity for set is broken (frames should have
        same length in points and time for proper training)
        FormatExeption: If format of some row is incorrect

    """
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
                    raise FrameExeption("files have different frame parameters")
            else:
                frameDuration = frD
            # check frame length integrity
            if (frameLength):
                if (not frameLength == frL):
                    raise FrameExeption("files have different frame parameters")
            else:
                frameLength = frL
        else:
            raise FormatExeption("incorrect header (%s)" % firstLine)

        linePat = re.compile("^([01]) : ([0-9-.]+,){%i}[0-9-.]+$" % (frameLength-1))
        for line in file:
            Lmatch = linePat.match(line)
            if (Lmatch):
                if (int(Lmatch.group(1)) == 1):
                    trains += 1

                if (int(Lmatch.group(1)) == 0):
                    noises += 1
            else:
                raise FormatExeption("incorrect format")
                return
        print("success (t: %d, n: %d)" % (trains, noises))
        validSets.append({"path" : path, "trains" : trains, "noises": noises})

def getFilesList(options):
    """get files, according to options, specified bu user, and check, that all
    data is valid

    Args:
        options: user - specified options

    """
    # exit if nothing to parse for trining examples
    if (not options.folder and not options.sets):
        print("no files or folder specified")
        exit(0)

    if (options.folder):
        parseFolder(options.folder)

    if (options.sets):
        for s in options.sets:
            validateSet(s)
    return validSets

    class FrameExeption(Exception):
        """exception, raised when frame intgrity in dataset is broken"""
        pass
    class FormatExeption(Exception):
        """exception, raised when format of data in a file does not match
        format, expected from .smp"""
        pass
