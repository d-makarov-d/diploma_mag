"""module, containing models for training"""
from abc import ABC, abstractmethod

import tensorflow as tf
import numpy as np


class BaseLayer(tf.keras.layers.Layer):
    def __str__(self):
        out = ""
        for w in self.get_weights():
            out += np.array2string(w,
                                   threshold=np.inf,
                                   max_line_width=np.Inf,
                                   floatmode='maxprec')
            out += '\n'
        out = out[:-1]
        return out


class SimpleLayer(BaseLayer):
    """Simple layer, representing filter"""
    def __init__(self, layer_len, randomize):
        super().__init__(dtype=tf.float64)
        if randomize:
            initial = tf.random.uniform([layer_len], minval=0, maxval=1,
                                        dtype=tf.float64)
        else:
            initial = tf.ones([layer_len], dtype=tf.float64)
        # weights, representing the filter
        self.w = tf.Variable(initial, name="filter")

    # forward pass of the filter
    def call(self, inputs, **kwargs):
        w_i = tf.complex(self.w, tf.cast(0, self.w.dtype))
        return inputs * w_i


class BiasedLayer(BaseLayer):
    """Layer, representing filter with biases"""
    def __init__(self, layer_len, randomize):
        super().__init__(dtype=tf.float64)
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

    # forward pass of the filter
    def call(self, inputs, **kwargs):
        w_i = tf.complex(self.w, tf.cast(0, self.w.dtype))
        v_i = tf.complex(self.b, tf.cast(0, self.b.dtype))
        return inputs * w_i + v_i


class NeuralLayer(BaseLayer):
    """Simple layer, containing neurons"""
    def __init__(self, input_len, out_len, randomize):
        super().__init__(dtype=tf.float64)
        if randomize:
            initial_w = tf.random.uniform([input_len, out_len],
                                          minval=0, maxval=1. / out_len,
                                          dtype=tf.float64)
            initial_b = tf.random.uniform([1, out_len],
                                          minval=0, maxval=1.,
                                          dtype=tf.float64)
        else:
            initial_w = \
                tf.ones([input_len, out_len], dtype=tf.float64) / out_len
            initial_b = tf.ones([1, out_len], dtype=tf.float64)
        self.w = tf.Variable(initial_w, name="filter")
        self.b = tf.Variable(initial_b, name="bias")

    # forward pass of the filter
    def call(self, inputs, **kwargs):
        w_i = tf.complex(self.w, tf.cast(0, self.w.dtype))
        v_i = tf.complex(self.b, tf.cast(0, self.b.dtype))
        return tf.matmul(inputs, w_i) + v_i


class DeepNeuralLayer(BaseLayer):
    """Just like NeuralLayer, but supports real inputs and initial biases
    are zeros"""
    def __init__(self, input_len, out_len, randomize):
        super().__init__(dtype=tf.float64)
        if randomize:
            initial_w = tf.random.uniform([input_len, out_len],
                                          minval=0, maxval=1. / out_len,
                                          dtype=tf.float64)

        else:
            initial_w = \
                tf.ones([input_len, out_len], dtype=tf.float64) / out_len
        initial_b = tf.zeros([1, out_len], dtype=tf.float64)
        self.w = tf.Variable(initial_w, name="filter")
        self.b = tf.Variable(initial_b, name="bias")

    # forward pass of the filter
    def call(self, inputs, **kwargs):
        if inputs.dtype == tf.complex128 or inputs.dtype == tf.complex64:
            w_i = tf.complex(self.w, tf.cast(0, self.w.dtype))
            b_i = tf.complex(self.b, tf.cast(0, self.b.dtype))
        else:
            w_i = self.w
            b_i = self.b
        return tf.keras.backend.dot(inputs, w_i) + b_i


class SimpleLoss(tf.keras.losses.Loss):
    """simple loss, from bachelor diploma

    y_pred = (||ifft(fft(x) * V)|| / ||x||)^2
    L = (y_pred - y_true)^2

    """
    def call(self, y_true, y_pred):
        return tf.reduce_mean((y_true - y_pred) ** 2)


class BaseModel(tf.keras.Model, ABC):
    """Base model to inherit from"""

    def __init__(self, **kwargs):
        super().__init__(kwargs, dtype=tf.float64)

    def __str__(self):
        out = ""
        ind = 0
        while True:
            try:
                layer = self.get_layer(index=ind)
                out += layer.name + "\n"
                out += str(layer) + "\n"
                ind += 1
            except ValueError:
                break
        out = out[:-1]
        return out

    @staticmethod
    def train_predict(signal, filtered):
        """Predicts if the signal is from train

        Predicts if the signal is from train by comparison of input and
        filtered signals

        Args:
            signal: signal, on the input layer
            filtered: filtered signal on the las network layer
        Returns:
             tf.Tensor: probability, that the signal contains train
        """
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
    def from_fourier(image):
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

    def filter_single(self, signal):
        """Filter single row signal

        Because model works with batches when training, it must strip some
        dimensions, when working with single input
        """
        batch_like = tf.transpose(tf.expand_dims(signal, 1))
        filtered = self.filter(batch_like)
        return tf.squeeze(filtered)


class DefaultModel(BaseModel):
    """Default model, used in bachelor diploma

    contains one trainable weights layer, and nothing else

    """
    def __init__(self, layer_len, randomize=False, **kwargs):
        super().__init__(kwargs=kwargs)

        self.layer1 = SimpleLayer(layer_len, randomize)

    def get_config(self):
        pass

    def filter(self, inputs):
        fourier_image = self.to_fourier(inputs)         # complex
        filtered_image = self.layer1(fourier_image)     # complex
        filtered = self.from_fourier(filtered_image)    # real
        return filtered

    def call(self, inputs, **kwargs):
        filtered = self.filter(inputs)
        return self.train_predict(inputs, filtered)


class BiasedModel(BaseModel):
    """Pretty much like DefaultModel, but with biases"""
    def __init__(self, layer_len, randomize=False, **kwargs):
        super().__init__(kwargs=kwargs)

        self.layer1 = BiasedLayer(layer_len, randomize)

    def get_config(self):
        pass

    def filter(self, inputs):
        fourier_image = self.to_fourier(inputs)         # complex
        filtered_image = self.layer1(fourier_image)     # complex
        filtered = self.from_fourier(filtered_image)    # real
        return filtered

    def call(self, inputs, **kwargs):
        filtered = self.filter(inputs)
        return self.train_predict(inputs, filtered)


class NeuralModel(BaseModel):
    """Model with 1 neural layer"""
    def __init__(self, layer_len, randomize=False, **kwargs):
        super().__init__(kwargs=kwargs)

        self.layer1 = NeuralLayer(layer_len, layer_len, randomize)

    def get_config(self):
        pass

    def filter(self, inputs):
        fourier_image = self.to_fourier(inputs)         # complex
        filtered_image = self.layer1(fourier_image)     # complex
        filtered = self.from_fourier(filtered_image)    # real
        return filtered

    def call(self, inputs, **kwargs):
        filtered = self.filter(inputs)
        return self.train_predict(inputs, filtered)


class NeuralSTD(NeuralModel):
    """Just like Neural model, but with different prediction schema"""

    @staticmethod
    def train_predict(signal, filtered):
        x = tf.math.reduce_std(filtered, axis=1)
        return tf.math.tanh(x)


class Deep1Hidden(BaseModel):
    """Model with 1 hidden layer.

    Hidden layer is thought of, like classifying fourier images

    """
    def __init__(self, layer_len, randomize=True, **kwargs):
        super().__init__(kwargs=kwargs)

        hidden_len = int(layer_len*2/3)
        self.hidden1 = DeepNeuralLayer(layer_len, hidden_len,
                                       randomize)
        self.outer_right = DeepNeuralLayer(hidden_len, layer_len,
                                           randomize)
        self.layer_len = layer_len

    def get_config(self):
        pass

    def filter(self, inputs):
        x = self.to_fourier(inputs)
        x = self.hidden1(x)
        x = self.outer_right(x)
        min_x = tf.reduce_min(tf.math.real(x), axis=1)
        min_x = tf.cast(min_x, tf.complex128)
        min_x = tf.expand_dims(min_x, 1)
        min_x = tf.repeat(min_x, self.layer_len, axis=1)
        x = x - min_x
        x = self.from_fourier(x)
        return x

    @staticmethod
    def train_predict(signal, filtered):
        x = tf.math.reduce_std(filtered, axis=1)
        return tf.math.tanh(x)

    def call(self, inputs, **kwargs):
        filtered = self.filter(inputs)
        return self.train_predict(inputs, filtered)


class Deep2Hidden(BaseModel):
    """Deep model with 2 hidden layers, both operating in fourier dimension"""
    def __init__(self, layer_len, randomize=True, **kwargs):
        super().__init__(kwargs=kwargs)

        hidden_len = int(layer_len*2/3)
        self.hidden1 = DeepNeuralLayer(layer_len, hidden_len,
                                       randomize)
        self.hidden2 = DeepNeuralLayer(hidden_len, hidden_len,
                                       randomize)
        self.outer_right = DeepNeuralLayer(hidden_len, layer_len,
                                           randomize)
        self.layer_len = layer_len

    def get_config(self):
        pass

    def filter(self, inputs):
        x = self.to_fourier(inputs)
        x = self.hidden1(x)
        x = self.hidden2(x)
        x = self.outer_right(x)
        x = self.from_fourier(x)
        return x

    @staticmethod
    def train_predict(signal, filtered):
        x = tf.math.reduce_std(filtered, axis=1)
        return tf.math.tanh(x)

    def call(self, inputs, **kwargs):
        filtered = self.filter(inputs)
        return self.train_predict(inputs, filtered)


class Deep11Hidden(BaseModel):
    """Deep model with 2 hidden layers, one operating in fourier dimension,
    other in real"""
    def __init__(self, layer_len, randomize=True, **kwargs):
        super().__init__(kwargs=kwargs)

        hidden_len = int(layer_len*2/3)
        self.hidden1 = DeepNeuralLayer(layer_len, hidden_len,
                                       randomize)
        self.hidden2 = DeepNeuralLayer(hidden_len, hidden_len,
                                       randomize)
        self.outer_right = DeepNeuralLayer(hidden_len, layer_len,
                                           randomize)
        self.layer_len = layer_len

    def get_config(self):
        pass

    def filter(self, inputs):
        x = self.to_fourier(inputs)
        x = self.hidden1(x)
        x = self.from_fourier(x)
        x = self.hidden2(x)
        x = self.outer_right(x)
        return x

    @staticmethod
    def train_predict(signal, filtered):
        x = tf.math.reduce_std(filtered, axis=1)
        return tf.math.tanh(x)

    def call(self, inputs, **kwargs):
        filtered = self.filter(inputs)
        return self.train_predict(inputs, filtered)
