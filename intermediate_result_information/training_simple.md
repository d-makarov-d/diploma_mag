# Обучение простых перцептронов на малом наборе данных

Для выявления наиболее подходящей архитектуры нейросети и наилучшего метода
оптимизации, разные архитектуры и оптимизации протестированы на небольшом наборе обучающих данных 
(61 положительный и 65 отрицательных примеров).<br/>

**Без рандомизации начальных значений**

|оптимизатор|фильтр|фильтр со смещениями|слой нейронов|
|-----------|------|---|---|
|Adadelta   |![](./pics/simple_nets_test/default_Adadelta_500eph_0.010lrate_nornd.png)	|![](./pics/simple_nets_test/biased_Adadelta_500eph_0.010lrate_nornd.png)	|![](./pics/simple_nets_test/neural_Adadelta_500eph_0.010lrate_nornd.png)	|
|Adagrad    |![](./pics/simple_nets_test/default_Adagrad_120eph_0.002lrate_nornd.png)	|![](./pics/simple_nets_test/biased_Adagrad_120eph_0.002lrate_nornd.png)	|![](./pics/simple_nets_test/neural_Adagrad_120eph_0.002lrate_nornd.png)	|
|Adam       |![](./pics/simple_nets_test/default_Adam_80eph_0.000lrate_nornd.png)		|![](./pics/simple_nets_test/biased_Adam_80eph_0.000lrate_nornd.png)		|![](./pics/simple_nets_test/neural_Adam_80eph_0.000lrate_nornd.png)		|
|Adamax     |![](./pics/simple_nets_test/default_Adamax_150eph_0.001lrate_nornd.png)	|![](./pics/simple_nets_test/biased_Adamax_150eph_0.001lrate_nornd.png)		|![](./pics/simple_nets_test/neural_Adamax_150eph_0.001lrate_nornd.png)		|
|Ftrl       |![](./pics/simple_nets_test/default_Ftrl_300eph_0.002lrate_nornd.png)		|![](./pics/simple_nets_test/biased_Ftrl_300eph_0.002lrate_nornd.png)		|![](./pics/simple_nets_test/neural_Ftrl_300eph_0.002lrate_nornd.png)		|
|Nadam      |![](./pics/simple_nets_test/default_Nadam_60eph_0.001lrate_nornd.png)		|![](./pics/simple_nets_test/biased_Nadam_60eph_0.001lrate_nornd.png)		|![](./pics/simple_nets_test/neural_Nadam_60eph_0.001lrate_nornd.png)		|
|RMSprop    |![](./pics/simple_nets_test/default_RMSprop_100eph_0.001lrate_nornd.png)	|![](./pics/simple_nets_test/biased_RMSprop_100eph_0.001lrate_nornd.png)	|![](./pics/simple_nets_test/neural_RMSprop_100eph_0.001lrate_nornd.png)	|
|SGD        |![](./pics/simple_nets_test/default_SGD_500eph_0.003lrate_nornd.png)		|![](./pics/simple_nets_test/biased_SGD_500eph_0.003lrate_nornd.png)		|![](./pics/simple_nets_test/neural_SGD_500eph_0.003lrate_nornd.png)		|

**Со случайными начальными значниями начальных значений**

|оптимизатор|фильтр|фильтр со смещениями|слой нейронов|
|-----------|------|---|---|
|Adadelta   |![](./pics/simple_nets_test/default_Adadelta_500eph_0.010lrate_rnd.png)	|![](./pics/simple_nets_test/biased_Adadelta_500eph_0.010lrate_rnd.png)	|![](./pics/simple_nets_test/neural_Adadelta_500eph_0.010lrate_rnd.png)	|
|Adagrad    |![](./pics/simple_nets_test/default_Adagrad_120eph_0.002lrate_rnd.png)		|![](./pics/simple_nets_test/biased_Adagrad_120eph_0.002lrate_rnd.png)	|![](./pics/simple_nets_test/neural_Adagrad_120eph_0.002lrate_rnd.png)	|
|Adam       |![](./pics/simple_nets_test/default_Adam_80eph_0.000lrate_rnd.png)			|![](./pics/simple_nets_test/biased_Adam_80eph_0.000lrate_rnd.png)		|![](./pics/simple_nets_test/neural_Adam_80eph_0.000lrate_rnd.png)		|
|Adamax     |![](./pics/simple_nets_test/default_Adamax_150eph_0.001lrate_rnd.png)		|![](./pics/simple_nets_test/biased_Adamax_150eph_0.001lrate_rnd.png)	|![](./pics/simple_nets_test/neural_Adamax_150eph_0.001lrate_rnd.png)	|
|Ftrl       |![](./pics/simple_nets_test/default_Ftrl_300eph_0.002lrate_rnd.png)		|![](./pics/simple_nets_test/biased_Ftrl_300eph_0.002lrate_rnd.png)		|![](./pics/simple_nets_test/neural_Ftrl_300eph_0.002lrate_rnd.png)		|
|Nadam      |![](./pics/simple_nets_test/default_Nadam_60eph_0.001lrate_rnd.png)		|![](./pics/simple_nets_test/biased_Nadam_60eph_0.001lrate_rnd.png)		|![](./pics/simple_nets_test/neural_Nadam_60eph_0.001lrate_rnd.png)		|
|RMSprop    |![](./pics/simple_nets_test/default_RMSprop_100eph_0.001lrate_rnd.png)		|![](./pics/simple_nets_test/biased_RMSprop_100eph_0.001lrate_rnd.png)	|![](./pics/simple_nets_test/neural_RMSprop_100eph_0.001lrate_rnd.png)	|
|SGD        |![](./pics/simple_nets_test/default_SGD_500eph_0.003lrate_rnd.png)			|![](./pics/simple_nets_test/biased_SGD_500eph_0.003lrate_rnd.png)		|![](./pics/simple_nets_test/neural_SGD_500eph_0.003lrate_rnd.png)		|