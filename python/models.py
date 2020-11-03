"""module, containing models for training"""
import tensorflow as tf


class SimpleLayer(tf.keras.layers.Layer):
    """Simple layer, representing filter

    transforms input (signal, shape = [len_sig], dtype = tf.complex128) to
    output (dtype = tf.float64), calculated by formula
    (||ifft(fft(x) * V)|| / ||x||)^2, representing probability, that the
    signal contains train

    """

    def __init__(self, layer_len, randomize):
        super().__init__()
        if randomize:
            initial = tf.random.uniform([layer_len], minval=0, maxval=1,
                                        dtype=tf.float64)
        else:
            initial = tf.ones([layer_len])
        # weights, representing the filter
        self.w = tf.Variable(initial, name="filter")

    def get_filter(self):
        return self.w

    # forward pass of the filter
    def call(self, inputs, **kwargs):
        v_i = tf.complex(self.w, tf.zeros(self.w.shape, dtype=self.w.dtype))
        in_i = tf.complex(inputs, tf.zeros(1562, dtype=inputs.dtype))
        filtered_i = tf.signal.ifft(tf.signal.fft(in_i) * v_i)
        norm_filtered = tf.norm(tf.math.real(filtered_i))
        norm_signal = tf.norm(inputs)
        return (norm_filtered / norm_signal) ** 2


class BiasedLayer(tf.keras.layers.Layer):
    """Layer, representing filter with biases

    transforms input (signal, shape = [len_sig], dtype = tf.complex128) to
    output (dtype = tf.float64), calculated by formula
    (||ifft(fft(x) * V + b)|| / ||x||)^2, representing probability, that the
    signal contains train

    """

    def __init__(self, layer_len, randomize):
        super().__init__()
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

    def get_wb(self):
        return self.w, self.b

    # forward pass of the filter
    def call(self, inputs, **kwargs):
        v_i = tf.complex(self.w, tf.zeros(self.w.shape, dtype=self.w.dtype))
        b_i = tf.complex(self.b, tf.zeros(self.b.shape, dtype=self.b.dtype))
        in_i = tf.complex(inputs, tf.zeros(1562, dtype=inputs.dtype))
        filtered_i = tf.signal.ifft(tf.signal.fft(in_i) * v_i + b_i)
        norm_filtered = tf.norm(tf.math.real(filtered_i))
        norm_signal = tf.norm(inputs)
        return (norm_filtered / norm_signal) ** 2


class SimpleLoss(tf.keras.losses.Loss):
    """simple loss, from bachelor diploma

    y_pred = (||ifft(fft(x) * V)|| / ||x||)^2
    L = (y_pred - y_true)^2

    """

    def call(self, y_true, y_pred):
        return (y_true - y_pred) ** 2


class DefaultModel(tf.keras.Model):
    """Default model, used in bachelor diploma

    contains one trainable weights layer, and nothing else

    """

    def __init__(self, layer_len, randomize=False, **kwargs):
        super().__init__(kwargs, dtype=tf.float64)

        self.layer1 = SimpleLayer(layer_len, randomize)

    def get_filter(self):
        return self.layer1.get_filter()

    def call(self, inputs, **kwargs):
        return self.layer1(inputs)


class BiasedModel(tf.keras.Model):
    """Pretty much like DefaultModel, but with biases"""
    def __init__(self, layer_len, randomize=False, **kwargs):
        super().__init__(kwargs, dtype=tf.float64)

        self.layer1 = BiasedLayer(layer_len, randomize)

    def get_wb(self):
        return self.layer1.get_wb()

    def call(self, inputs, **kwargs):
        return self.layer1(inputs)
