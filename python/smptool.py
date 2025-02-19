"""module for parsing .smp files

This module provides function to parse user - specified files of training
examples and check data integrity. Then the tf.Dataset is made of this data

Todo:
    handle exceptions raised by validateSet

"""
import os
import re
import tensorflow as tf


def parse_smp_line(line):
    """function, parsing a line of .smp file to values

    Args:
        line (str): line from file
    Returns:
        features ((tf.Tensor[tf.float64]), tf.int32): list of variables

    """
    ln_len = tf.strings.length(line)                        # line length
    label = tf.strings.substr(line, 0, 1)                   # get label as str
    label = tf.strings.to_number(label, out_type=tf.float32)

    # get the substring with values
    features = tf.strings.substr(line, 4, ln_len - 4)
    features = tf.strings.split(features, ",")
    features = tf.strings.to_number(features, out_type=tf.float64)
    features = features / tf.reduce_max(features)           # norm to 1
    # should be exactly this order (inputs, targets) for tf.keras.fit()
    return [features, label]


def get_files_list(options):
    """get files, according to options, specified bu user, and check, that all
    data is valid

    Args:
        options: user - specified options
    Returns:
        valid_sets (List[str]): list of files with validated sets of examples
        test_set (str): path to file with test set
        fs (float): sampling frequency of all signals

    """

    frame_duration = None
    """frame length in seconds, needs to be the same in all training examples"""
    frame_length = None
    """frame length in points, needs to be the same in all training examples"""
    valid_sets = []
    """all valid files with training samples"""

    def validate_set(path):
        """validates a set of examples from specified file, and checks frame
        parameters intrgrity

        Args:
            path (str): path to .smp file with examples for training
        Returns:
            valid_sets (Dict[str, Any]): info about examples in file

        Raises:
            FrameException: If frame integrity for set is broken (frames should
                have same length in points and time for proper training)
            FormatException: If format of some row is incorrect

        """
        nonlocal frame_duration, frame_length
        name_pat = re.compile(r"[^/\\]+\.smp$")
        set_name = name_pat.search(path).group()
        print("{:<80}".format("checking %s ..." % set_name), end='')
        trains = 0
        noises = 0
        # ensure file contains correct data
        with open(path) as file:
            header_pat = re.compile(r"^([0-9.]+)\[([0-9]+)\]$")
            first_line = file.readline()
            fl_match = header_pat.match(first_line)
            if fl_match:
                fr_dur = float(fl_match.group(1))
                fr_len = int(fl_match.group(2))
                # check frame duration integrity
                if frame_duration:
                    if not frame_duration == fr_dur:
                        raise FrameException(
                            "files have different frame parameters")
                else:
                    frame_duration = fr_dur
                # check frame length integrity
                if frame_length:
                    if not frame_length == fr_len:
                        raise FrameException(
                            "files have different frame parameters")
                else:
                    frame_length = fr_len
            else:
                raise FormatException("incorrect header (%s)" % first_line)

            line_pat = re.compile(
                "^([01]) : ([0-9-.]+,){%i}[0-9-.]+$" % (frame_length - 1))
            for line in file:
                l_match = line_pat.match(line)
                if l_match:
                    if int(l_match.group(1)) == 1:
                        trains += 1

                    if int(l_match.group(1)) == 0:
                        noises += 1
                else:
                    raise FormatException("incorrect format")
            print("success (t: %d, n: %d)" % (trains, noises))
        return {"path": path, "trains": trains, "noises": noises}

    def parse_folder(path):
        """parse specified folder for .smp files

        Args:
            path (str): path to a folder to parse

        """
        set_pat = re.compile(r"^.+\.smp$")
        for file in os.listdir(path):
            if set_pat.match(file):
                candidate = validate_set("%s/%s" % (path, file))
                if candidate: valid_sets.append(candidate)

    # exit if nothing to parse for training examples
    if not options.folder and not options.set:
        print("no files or folder specified")
        exit(0)

    if options.folder:
        parse_folder(options.folder)

    if options.set:
        for s in options.set:
            candidate = validate_set(s)
            if candidate: valid_sets.append(candidate)

    test_set = None
    if options.test:
        test_set = validate_set(options.test)

    fs = frame_length / frame_duration      # sampling frequency
    return valid_sets, test_set, fs


def disp_examples_info(sets):
    """function, displaying info about found training examples, and asking
    user to proceed

    Args:
        sets (Dict[str,Any]): dictionary, containing path to each .smp file,
            and number of train and noise examples

    """
    print("found %d train and %d noise examples." %
          (sum(map(lambda el: el["trains"], sets)),
           sum(map(lambda el: el["noises"], sets))),
          end='')

    # ask if proceed
    inp = input(" Proceed [Y/n]?") or "Y"
    while not (inp == "Y" or inp == "y" or inp == "n"):
        inp = input("Proceed [Y/n]?") or "Y"
    if inp == "n":
        exit(0)


def get_dataset(options):
    """ function, that should be called from outside. Defines tf.Dataset
    on list of files, parsed according to user parameters

    Returns:
        acc, test_set (tf.Dataset, tf.Dataset): dataset, accumulating data from
            all files, and test dataset
        fs (float): sampling frequency of all signals
    """

    # parse files
    sets, test, fs = get_files_list(options)
    # ask to proceed
    disp_examples_info(sets)

    file_names = list(map(lambda el: el["path"], sets))
    n_examples = sum(map(lambda el: el["trains"] + el["noises"], sets))

    # build dataset
    acc = None
    for file in file_names:
        dataset = tf.data.TextLineDataset(file)
        dataset = dataset.skip(1)  # skip first, header, line
        dataset = dataset.map(parse_smp_line)  # parse values
        if (acc):
            acc = acc.concatenate(dataset)
        else:
            acc = dataset
    acc = acc.shuffle(n_examples)  # if n_examples is not too big!!!
    if not test:
        # if no test dataset provided, take examples from main dataset
        print("No test dataset found, taking test examples from main dateset")
        test_set = acc.take(10)
    else:
        # make test dataset from file
        test_set = tf.data.TextLineDataset(test["path"])
        test_set = test_set.skip(1)     # skip first, header, line
        test_set = test_set.map(parse_smp_line)
        test_set.shuffle(test["trains"] + test["noises"])
    acc = acc.batch(32)
    return acc, test_set, fs


class FrameException(Exception):
    """exception, raised when frame integrity in data set is broken"""
    pass


class FormatException(Exception):
    """exception, raised when format of data in a file does not match
    format, expected from .smp"""
    pass
