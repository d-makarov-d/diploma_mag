"""script, performing filter training

Trains a filter by user - specified training data

Todo:
    analise different optimizers and models
"""
from optparse import OptionParser
from matplotlib import pyplot as plt
import tensorflow as tf
# disable GPU, because of some complex number issues
tf.config.set_visible_devices([], 'GPU')

from smptool import get_dataset
import models


def get_options():
    """get user defined options

    Returns:
        (options, args): tuple, containing options and arguments
    """
    parser = OptionParser()
    parser.add_option("-f", "--folder",
                      help="folder to parse for education sets")
    parser.add_option("-s", "--sets",
                      help="specify file with training set (repeat to "
                           "specify multiple files)",
                      default=[], action="append")

    (options, args) = parser.parse_args()
    return options


def main():
    """main method, applying all preparations, and performing the training"""
    options = get_options()
    dataset = get_dataset(options)

    layer_len = len(dataset.take(1).as_numpy_iterator().next()[0][0])

    loss = models.SimpleLoss()
    model = models.DefaultModel(layer_len=layer_len, randomize=False)
    model.compile(
        optimizer=tf.keras.optimizers.Adam(learning_rate=0.002),
        loss=loss)
    history = model.fit(x=dataset, epochs=120)

    fig, ax = plt.subplots()
    ax.plot(history.history["loss"])
    fig, ax = plt.subplots()
    ax.plot(model.get_filter().numpy())
    plt.show()


if __name__ == '__main__':
    main()
