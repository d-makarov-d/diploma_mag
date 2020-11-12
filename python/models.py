"""module, containing models for training"""
from abc import ABC, abstractmethod

import tensorflow as tf


class SimpleLayer(tf.keras.layers.Layer):
    """Simple layer, representing filter

    transforms input (signal, shape = [len_sig], dtype = tf.complex128) to
    output (dtype = tf.float64), calculated by formula
    (||ifft(fft(x) * V)|| / ||x||)^2, representing probability, that the
    signal contains train

    """
    def __init__(self, layer_len, randomize):
        super().__init__(layer_len)
        if randomize:
            initial = tf.random.uniform([layer_len], minval=0, maxval=1,
                                        dtype=tf.float64)
        else:
            initial = tf.ones([layer_len], dtype=tf.float64)
        # weights, representing the filter
        self.w = tf.Variable(initial, name="filter")

    def filter(self, inputs):
        v_i = tf.complex(self.w, tf.cast(0, dtype=self.w.dtype))
        in_i = tf.complex(inputs, tf.cast(0, inputs.dtype))
        filtered_i = tf.signal.ifft(tf.signal.fft(in_i) * v_i)
        return tf.reshape(tf.math.real(filtered_i), shape=[self.layer_len])

    # forward pass of the filter
    def call(self, inputs, **kwargs):
        v_i = tf.complex(self.w, tf.cast(0, dtype=self.w.dtype))
        in_i = tf.complex(inputs, tf.cast(0, inputs.dtype))
        filtered_i = tf.signal.ifft(tf.signal.fft(in_i) * v_i)
        # because operation is for whole batch, norm must be computed for each
        # row independently
        norm_filtered = tf.norm(tf.math.real(filtered_i), axis=1)
        norm_signal = tf.norm(inputs, axis=1)
        return (norm_filtered / norm_signal) ** 2


class BiasedLayer(tf.keras.layers.Layer):
    """Layer, representing filter with biases

    transforms input (signal, shape = [len_sig], dtype = tf.complex128) to
    output (dtype = tf.float64), calculated by formula
    (||ifft(fft(x) * V + b)|| / ||x||)^2, representing probability, that the
    signal contains train

    """
    def __init__(self, layer_len, randomize):
        super().__init__(layer_len)
        if randomize:
            initial_w = tf.random.uniform([layer_len], minval=0, maxval=1,
                                          dtype=tf.float64)
            initial_b = tf.random.uniform([layer_len], minval=0, maxval=1,
                                          dtype=tf.float64)
        else:
            initial_w = tf.ones([layer_len], dtype=tf.float64)
            initial_b = tf.ones([layer_len], dtype=tf.float64)
        # weights, representing the filter
        self.w = tf.Variable(initial_w, name="filter")
        # biases
        self.b = tf.Variable(initial_b, name="bias")

    def filter(self, inputs):
        v_i = tf.complex(self.w, tf.cast(0, dtype=self.w.dtype))
        b_i = tf.complex(self.b, tf.cast(0, dtype=self.b.dtype))
        in_i = tf.complex([inputs], tf.cast(0, inputs.dtype))
        filtered_i = tf.signal.ifft(tf.signal.fft(in_i)*v_i + b_i)
        return tf.reshape(tf.math.real(filtered_i), shape=[self.layer_len])

    # forward pass of the filter
    def call(self, inputs, **kwargs):
        v_i = tf.complex(self.w, tf.cast(0, dtype=self.w.dtype))
        b_i = tf.complex(self.b, tf.cast(0, dtype=self.b.dtype))
        in_i = tf.complex(inputs, tf.cast(0, inputs.dtype))
        filtered_i = tf.signal.ifft(tf.signal.fft(in_i) * v_i + b_i)
        # because operation is for whole batch, norm must be computed for each
        # row independently
        norm_filtered = tf.norm(tf.math.real(filtered_i), axis=1)
        norm_signal = tf.norm(inputs, axis=1)
        return (norm_filtered / norm_signal) ** 2


class NeuralLayer(tf.keras.layers.Layer):
    """Simple layer, containing neurons

    Layer of a neural network, as it is usually seen.
    Transforms input (signal, shape = [len_sig], dtype = tf.complex128) to
    output (dtype = tf.float64), calculated by formula
    (||ifft(fft(x) * V + b)|| / ||x||)^2, representing probability, that the
    signal contains train

    """
    def __init__(self, layer_len, randomize):
        super().__init__(layer_len)
        if randomize:
            initial_w = tf.random.uniform([layer_len, layer_len],
                                          minval=0, maxval=1./layer_len,
                                          dtype=tf.float64)
            initial_b = tf.random.uniform([1, layer_len],
                                          minval=0, maxval=1,
                                          dtype=tf.float64)
        else:
            initial_w = \
                tf.ones([layer_len, layer_len], dtype=tf.float64) / layer_len
            initial_b = tf.ones([1, layer_len], dtype=tf.float64)
        # weights, representing the filter
        self.w = tf.Variable(initial_w, name="filter")
        # biases
        self.b = tf.Variable(initial_b, name="bias")

    def filter(self, inputs):
        v_i = tf.complex(self.w, tf.cast(0, dtype=self.w.dtype))
        b_i = tf.complex(self.b, tf.cast(0, dtype=self.b.dtype))
        in_i = tf.complex([inputs], tf.cast(0, inputs.dtype))
        filtered_i = tf.signal.ifft(tf.matmul(tf.signal.fft(in_i), v_i) + b_i)
        return tf.reshape(tf.math.real(filtered_i), shape=[self.layer_len])

    # forward pass of the filter
    def call(self, inputs, **kwargs):
        v_i = tf.complex(self.w, tf.cast(0, dtype=self.w.dtype))
        b_i = tf.complex(self.b, tf.cast(0, dtype=self.b.dtype))
        in_i = tf.complex(inputs, tf.cast(0, inputs.dtype))
        filtered_i = tf.signal.ifft(tf.matmul(tf.signal.fft(in_i), v_i) + b_i)
        # because operation is for whole batch, norm must be computed for each
        # row independently
        norm_filtered = tf.norm(tf.math.real(filtered_i), axis=1)
        norm_signal = tf.norm(inputs, axis=1)
        return (norm_filtered / norm_signal) ** 2


class SimpleLoss(tf.keras.losses.Loss):
    """simple loss, from bachelor diploma

    y_pred = (||ifft(fft(x) * V)|| / ||x||)^2
    L = (y_pred - y_true)^2

    """
    def call(self, y_true, y_pred):
        return tf.reduce_mean((y_true - y_pred) ** 2)


class BaseModel(tf.keras.Model, ABC):
    """Base model to inherit from"""

    @staticmethod
    def train_predict(self, signal, filtered):
        """Predicts if the signal is from train

        Predicts if the signal is from train by comparison of input and
        filtered signals

        Args:
            signal: signal, on the input layer
            filtered: filtered signal on the las network layer
        Returns:
             tf.Tensor: probability, that the signal contains train
        """
        # because operation is for whole batch, norm must be computed for each
        # row independently
        norm_filtered = tf.norm(filtered, axis=1)
        norm_signal = tf.norm(signal, axis=1)
        return (norm_filtered / norm_signal) ** 2

    @staticmethod
    def to_fourier(signal):
        """Transforms input signal to fourier image

        Transforms each row of input tensor to fourier image of same dimension

        Args:
            signal (tf.Tensor): input tensor, real
        Returns:
            tf.Tensor: fourier image of signal, same dimension, complex
        """
        # complex signal, with zero imaginary part
        signal_i = tf.complex(signal, tf.cast(0, signal.dtype))
        return tf.signal.fft(signal_i)

    @staticmethod
    def from_fourier(self, image):
        """Transforms input fourier image to real signal

        Transforms each row of input image to real signal of same dimension

        Args:
            image (tf.Tensor): input tensor, fourier image, complex
        Returns:
            tf.Tensor: signal from inverse transform, real
        """
        return tf.math.real(tf.signal.ifft(image))

    @abstractmethod
    def filter(self, inputs):
        """Abstract method, must return filtered inputs"""
        pass


class DefaultModel(BaseModel):
    """Default model, used in bachelor diploma

    contains one trainable weights layer, and nothing else

    """
    def __init__(self, layer_len, randomize=False, **kwargs):
        super().__init__(kwargs)

        self.layer1 = SimpleLayer(layer_len, randomize)

    def get_config(self):
        pass

    def filter(self, inputs):
        return self.layer1.filter(inputs)

    def call(self, inputs, **kwargs):
        return self.layer1(inputs)


class BiasedModel(BaseModel):
    """Pretty much like DefaultModel, but with biases"""
    def __init__(self, layer_len, randomize=False, **kwargs):
        super().__init__(kwargs, dtype=tf.float64)

        self.layer1 = BiasedLayer(layer_len, randomize)

    def get_config(self):
        pass

    def filter(self, inputs):
        return self.layer1.filter(inputs)

    def call(self, inputs, **kwargs):
        return self.layer1(inputs)


class NeuralModel(BaseModel):
    """Model with 1 neural layer"""
    def __init__(self, layer_len, randomize=False, **kwargs):
        super().__init__(kwargs, dtype=tf.float64)

        self.layer1 = NeuralLayer(layer_len, randomize)

    def get_config(self):
        pass

    def filter(self, inputs):
        return self.layer1.filter(inputs)

    def call(self, inputs, **kwargs):
        return self.layer1(inputs)
