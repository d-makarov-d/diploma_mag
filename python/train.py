# script for training a filter, using tensorflow
from optparse import OptionParser
from smpParse import getFilesList
import tensorflow as tf
import numpy as np

# get user defined options
def getOptions():
    parser = OptionParser()
    parser.add_option("-f", "--folder",
        help = "folder to parse for education sets")
    parser.add_option("-s", "--sets",
        help = "specify file with training set (repeat to specifi multiple files)",
        default=[], action = "append")

    (options, args) = parser.parse_args()
    return options

# display info about found training examples and ask user to proceed
def dispExamplesInfo(validSets):
    print("found %d train and %d noise examples." %
        (sum(map(lambda el: el["trains"], validSets)), sum(map(lambda el: el["noises"], validSets))),
        end = '')

    # ask if proceed
    inp = input(" Proceed [Y/n]?") or "Y"
    while (not (inp == "Y" or inp == "y" or inp == "n")):
        inp = input("Proceed [Y/n]?") or "Y"
    if (inp == "n"):
        exit(0)

def parseSMPLine(line):
    """function, parsing a line of .smp file to values

    Args:
        line (str): line from file
    Returns:
        vals ([tf.float64]): list of variables

    """
    lnLen = tf.strings.length(line)                         # line length
    label = tf.strings.substr(line, 0, 1)                   # get label as str
    label = tf.strings.to_number(label, out_type=tf.int32)
    label = tf.cast(label, tf.bool)                         # convert label to bool
    vals = tf.strings.substr(line, 4, lnLen - 4)            # get the substring with values
    vals = tf.strings.split(vals, ",")
    vals = tf.strings.to_number(vals, out_type=tf.float64)  # transform string value to floats
    return tf.tuple([label, vals])

# create tf.data.Dataset from files list
# fileNames - list of pathes to files
# acc - accumulator tf.data.Dataset to return
def createDataset(fileNames, NEx):
    acc = None
    for file in fileNames:
        dataset = tf.data.TextLineDataset(file)
        dataset = dataset.skip(1)                 # skip first, header, line
        dataset = dataset.map(parseSMPLine)       # parse values
        if (acc):
            acc = acc.concatenate(dataset)
        else:
            acc = dataset
    acc = acc.shuffle(NEx)       # if NEx is not too big!!!
    """for big datasets batches must be applied, and may be shuffle with smaller
    buffer size"""

def main():
    options = getOptions()
    validSets = getFilesList(options)

    dispExamplesInfo(validSets);

    fileNames = map(lambda el: el["path"], validSets)                    # extract pathes to files
    NEx = sum(map(lambda el: el["trains"] + el["noises"], validSets))    # all examples count

    # create dataset from files
    dataset = createDataset(fileNames, NEx)

if __name__ == '__main__':
    main()
