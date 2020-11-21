"""script, performing filter training

Trains a filter by user - specified training data

Todo:
    analise different optimizers and models
"""
from optparse import OptionParser
from matplotlib import pyplot as plt
import tensorflow as tf
import numpy as np

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
    parser.add_option("-t", "--test",
                      help="file with test set")
    parser.add_option("-s", "--set",
                      help="specify file with training set (repeat to "
                           "specify multiple files)",
                      default=[], action="append")
    (options, args) = parser.parse_args()
    return options


def main():
    """main method, applying all preparations, and performing the training"""
    options = get_options()
    dataset, test, fs = get_dataset(options)

    def eval_all(folder):
        """evaluates all optimizers and all models on given dataset, and saves
        info pictures to folder

        Args:
            folder: folder to save results
        """
        optimizers = [
            tf.keras.optimizers.Adadelta(learning_rate=0.01),
            tf.keras.optimizers.Adagrad(learning_rate=0.002),
            tf.keras.optimizers.Adam(learning_rate=0.0001),
            tf.keras.optimizers.Adamax(learning_rate=0.0005),
            tf.keras.optimizers.Ftrl(learning_rate=0.002),
            tf.keras.optimizers.Nadam(learning_rate=0.001),
            tf.keras.optimizers.RMSprop(learning_rate=0.0005),
            tf.keras.optimizers.SGD(learning_rate=0.003),
        ]

        epochs = [
            500, 120, 80, 150, 300, 60, 100, 500
        ]

        biased_randomized = [
            (models.DefaultModel, False),
            (models.BiasedModel, False),
            (models.NeuralModel, False),
            (models.DefaultModel, True),
            (models.BiasedModel, True),
            (models.NeuralModel, True),
        ]

        for optimizer, n_epochs in zip(optimizers, epochs):
            for model, rndmz in biased_randomized:
                eval_optimizer(folder,
                               model,
                               optimizer,
                               n_epochs,
                               rndmz)

    def eval_complecated(folder):
        optimizers = [
            tf.keras.optimizers.Adadelta,
            tf.keras.optimizers.Adagrad,
            tf.keras.optimizers.Adam,
            tf.keras.optimizers.Adamax,
            tf.keras.optimizers.Ftrl,
            tf.keras.optimizers.Nadam,
            tf.keras.optimizers.RMSprop,
            tf.keras.optimizers.SGD,
        ]

        type_eph_lrate = [
            (models.Deep2Hidden, 15, 0.00003),
            (models.Deep11Hidden, 15, 0.00003)
        ]

        for opt in optimizers:
            for model, epochs, lrate in type_eph_lrate:
                eval_optimizer(folder,
                               model,
                               opt(learning_rate=lrate),
                               epochs,
                               True)

    def eval_optimizer(folder,
                       model, optimizer, epochs, randomize):
        """Evaluates given model on given dataset

        Evaluates model on given dataset, optimizes result by optimizer, and saves
        info image to given folder

        Args:
            folder: folder to save info images
            model: tf.keras.Model model for evaluation
            optimizer: tf.keras optimizer
            epochs (int): epochs of training
            randomize (bool): tandomize initial weights and biases


        """
        class2name = {
            models.DefaultModel: "default",
            models.BiasedModel: "biased",
            models.NeuralModel: "neural",
            models.NeuralSTD: "neuralSTD",
            models.Deep1Hidden: "deep1h",
            models.Deep2Hidden: "deep2h",
            models.Deep11Hidden: "deep1_1"
        }

        # prepare for training
        layer_len = len(dataset.take(1).as_numpy_iterator().next()[0][0])
        optimizer_conf = optimizer.get_config()
        fname = "/%s_%s_%deph_%.5flrate_%s" % \
                (class2name[model],
                 optimizer_conf["name"],
                 epochs,
                 optimizer_conf["learning_rate"],
                 "rnd" if randomize else "nornd")

        pic_name = folder + fname + ".png"
        file_name = folder + "/models" + fname + ".model"
        model_obj = model(layer_len, randomize)
        model_obj.compile(optimizer=optimizer, loss=models.SimpleLoss())

        # prepare data from test dataset for result visualization
        train_sample = None
        no_train_sample = None
        samples = []
        labels = []
        for features, label in test.as_numpy_iterator():
            samples.append(features)
            labels.append(label)
            if train_sample is None and label == 1:
                train_sample = features
            if no_train_sample is None and label == 0:
                no_train_sample = features
        samples = np.array(samples)
        labels = np.array(labels, dtype=np.bool)
        # save untrained classification, for result visualization
        untrained_predicted_labels = model_obj(samples).numpy()
        # train model
        history = model_obj.fit(x=dataset, epochs=epochs)
        train_filtered = model_obj.filter_single(train_sample)
        no_train_filtered = model_obj.filter_single(no_train_sample)
        predicted_labels = model_obj(samples).numpy()

        # result visualization and saving
        fig = plt.figure(figsize=(15., 7.))
        loss_ax = fig.add_subplot(3, 1, 1)
        loss_ax.set_title("ход обучения")
        loss_ax.set_xlabel("эпоха")
        loss_ax.set_ylabel("ф-я потерь")
        sig_untrained_ax = fig.add_subplot(3, 2, 3)
        sig_untrained_ax.set_title("примеры сигналов")
        sig_untrained_ax.set_xlabel("время, сек")
        sig_untrained_ax.set_ylabel("ускорение, мкм/сек")
        sig_trained_ax = fig.add_subplot(3, 2, 4)
        sig_trained_ax.set_title("отфильтрованные сигналы")
        sig_trained_ax.set_xlabel("время, сек")
        sig_trained_ax.set_ylabel("ускорение, мкм/сек")
        # sig_trained_ax.set_ylim(-1, 1)
        label_untrained_ax = fig.add_subplot(3, 2, 5)
        label_untrained_ax.set_title("классификация необученной моделью")
        label_untrained_ax.set_xlabel("вероятность, что сигнал от поезда")
        label_trained_ax = fig.add_subplot(3, 2, 6)
        label_trained_ax.set_title("классификация обученной моделью")
        label_trained_ax.set_xlabel("вероятность, что сигнал от поезда")

        loss_ax.plot(history.history["loss"])
        train_ax_label, = sig_untrained_ax.plot(
            np.linspace(0, len(train_sample)/fs, len(train_sample)),
            train_sample,
            "g", label="сигнал с поездом")
        no_train_ax_label, = sig_untrained_ax.plot(
            np.linspace(0, len(no_train_sample)/fs, len(no_train_sample)),
            no_train_sample,
            "r", label="сигнал без поезда")
        sig_untrained_ax.legend(handles=[train_ax_label, no_train_ax_label])
        train_ax_label, = sig_trained_ax.plot(
            np.linspace(0, len(train_filtered)/fs, len(train_filtered)-1),
            train_filtered[1:],
            "g", label="сигнал с поездом")
        no_train_ax_label, = sig_trained_ax.plot(
            np.linspace(0, len(no_train_filtered)/fs, len(no_train_filtered)-1),
            no_train_filtered[1:],
            "r", label="сигнал без поезда")
        sig_trained_ax.legend(handles=[train_ax_label, no_train_ax_label])
        train_ax_label = label_untrained_ax.scatter(
            untrained_predicted_labels[labels],
            np.array(range(0, len(labels)))[labels],
            color='green', marker='.', label="сигнал с поездом")
        no_train_ax_label = label_untrained_ax.scatter(
            untrained_predicted_labels[np.invert(labels)],
            np.array(range(0, len(labels)))[np.invert(labels)],
            color='red', marker='.', label="сигнал без поезда")
        label_untrained_ax.legend(handles=[train_ax_label, no_train_ax_label])
        train_ax_label = label_trained_ax.scatter(
            predicted_labels[labels],
            np.ma.array(range(0, len(labels)))[labels],
            color='green', marker='.', label="сигнал с поездом")
        no_train_ax_label = label_trained_ax.scatter(
            predicted_labels[np.invert(labels)],
            np.array(range(0, len(labels)))[np.invert(labels)],
            color='red', marker='.', label="сигнал без поезда")
        label_trained_ax.legend(handles=[train_ax_label, no_train_ax_label])
        fig.tight_layout(w_pad=3, h_pad=2,
                         rect=[0.0225, 0.0225, 0.95, 0.95])
        plt.savefig(pic_name)
        #with open(file_name, "w") as f:
            #f.write(str(model_obj))

    eval_optimizer("training_res",
                   models.Deep2Hidden,
                   tf.keras.optimizers.Adamax(learning_rate=0.00003),
                   15,
                   True)
    eval_optimizer("training_res",
                   models.Deep11Hidden,
                   tf.keras.optimizers.Adamax(learning_rate=0.00003),
                   15,
                   True)



if __name__ == '__main__':
    main()
