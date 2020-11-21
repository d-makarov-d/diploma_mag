# Обучение простых перцептронов на малом наборе данных

Для выявления наиболее подходящей архитектуры нейросети и наилучшего метода
оптимизации, разные архитектуры и оптимизации протестированы на небольшом наборе обучающих данных 
(61 положительных и 65 отрицательных примеров).<br/>

**Без рандомизации начальных значений**

|оптимизатор|фильтр|фильтр со смещениями|слой нейронов|
|-----------|------|--------------------|-------------|
|Adadelta   |![](./pics/simple_nets_test/default_Adadelta_500eph_0.010lrate_nornd.png)	|![](./pics/simple_nets_test/biased_Adadelta_500eph_0.010lrate_nornd.png)	|![](./pics/simple_nets_test/neural_Adadelta_500eph_0.010lrate_nornd.png)	|
|Adagrad    |![](./pics/simple_nets_test/default_Adagrad_120eph_0.002lrate_nornd.png)	|![](./pics/simple_nets_test/biased_Adagrad_120eph_0.002lrate_nornd.png)	|![](./pics/simple_nets_test/neural_Adagrad_120eph_0.002lrate_nornd.png)	|
|Adam       |![](./pics/simple_nets_test/default_Adam_80eph_0.000lrate_nornd.png)		|![](./pics/simple_nets_test/biased_Adam_80eph_0.000lrate_nornd.png)		|![](./pics/simple_nets_test/neural_Adam_80eph_0.000lrate_nornd.png)		|
|Adamax     |![](./pics/simple_nets_test/default_Adamax_150eph_0.001lrate_nornd.png)	|![](./pics/simple_nets_test/biased_Adamax_150eph_0.001lrate_nornd.png)		|![](./pics/simple_nets_test/neural_Adamax_150eph_0.001lrate_nornd.png)		|
|Ftrl       |![](./pics/simple_nets_test/default_Ftrl_300eph_0.002lrate_nornd.png)		|![](./pics/simple_nets_test/biased_Ftrl_300eph_0.002lrate_nornd.png)		|![](./pics/simple_nets_test/neural_Ftrl_300eph_0.002lrate_nornd.png)		|
|Nadam      |![](./pics/simple_nets_test/default_Nadam_60eph_0.001lrate_nornd.png)		|![](./pics/simple_nets_test/biased_Nadam_60eph_0.001lrate_nornd.png)		|![](./pics/simple_nets_test/neural_Nadam_60eph_0.001lrate_nornd.png)		|
|RMSprop    |![](./pics/simple_nets_test/default_RMSprop_100eph_0.001lrate_nornd.png)	|![](./pics/simple_nets_test/biased_RMSprop_100eph_0.001lrate_nornd.png)	|![](./pics/simple_nets_test/neural_RMSprop_100eph_0.001lrate_nornd.png)	|
|SGD        |![](./pics/simple_nets_test/default_SGD_500eph_0.003lrate_nornd.png)		|![](./pics/simple_nets_test/biased_SGD_500eph_0.003lrate_nornd.png)		|![](./pics/simple_nets_test/neural_SGD_500eph_0.003lrate_nornd.png)		|

Как и следовало ожидать, модель "слой нейронов" не обучается, когда начальные веса связей не случайны


**Со случайными начальными значениями**

|оптимизатор|фильтр|фильтр со смещениями|слой нейронов|
|-----------|------|--------------------|-------------|
|Adadelta   |![](./pics/simple_nets_test/default_Adadelta_500eph_0.010lrate_rnd.png)	|![](./pics/simple_nets_test/biased_Adadelta_500eph_0.010lrate_rnd.png)	|![](./pics/simple_nets_test/neural_Adadelta_500eph_0.010lrate_rnd.png)	|
|Adagrad    |![](./pics/simple_nets_test/default_Adagrad_120eph_0.002lrate_rnd.png)		|![](./pics/simple_nets_test/biased_Adagrad_120eph_0.002lrate_rnd.png)	|![](./pics/simple_nets_test/neural_Adagrad_120eph_0.002lrate_rnd.png)	|
|Adam       |![](./pics/simple_nets_test/default_Adam_80eph_0.000lrate_rnd.png)			|![](./pics/simple_nets_test/biased_Adam_80eph_0.000lrate_rnd.png)		|![](./pics/simple_nets_test/neural_Adam_80eph_0.000lrate_rnd.png)		|
|Adamax     |![](./pics/simple_nets_test/default_Adamax_150eph_0.001lrate_rnd.png)		|![](./pics/simple_nets_test/biased_Adamax_150eph_0.001lrate_rnd.png)	|![](./pics/simple_nets_test/neural_Adamax_150eph_0.001lrate_rnd.png)	|
|Ftrl       |![](./pics/simple_nets_test/default_Ftrl_300eph_0.002lrate_rnd.png)		|![](./pics/simple_nets_test/biased_Ftrl_300eph_0.002lrate_rnd.png)		|![](./pics/simple_nets_test/neural_Ftrl_300eph_0.002lrate_rnd.png)		|
|Nadam      |![](./pics/simple_nets_test/default_Nadam_60eph_0.001lrate_rnd.png)		|![](./pics/simple_nets_test/biased_Nadam_60eph_0.001lrate_rnd.png)		|![](./pics/simple_nets_test/neural_Nadam_60eph_0.001lrate_rnd.png)		|
|RMSprop    |![](./pics/simple_nets_test/default_RMSprop_100eph_0.001lrate_rnd.png)		|![](./pics/simple_nets_test/biased_RMSprop_100eph_0.001lrate_rnd.png)	|![](./pics/simple_nets_test/neural_RMSprop_100eph_0.001lrate_rnd.png)	|
|SGD        |![](./pics/simple_nets_test/default_SGD_500eph_0.003lrate_rnd.png)			|![](./pics/simple_nets_test/biased_SGD_500eph_0.003lrate_rnd.png)		|![](./pics/simple_nets_test/neural_SGD_500eph_0.003lrate_rnd.png)		|

Со случайными начальными значениями весов "слой нейронов" обучается, но 126 примеров явно не хватает.


Для обучения более сложных нейросетей нужен больший набор примеров (756 положительных и 763 отрицательных). 
Далее тесты для моделей с большим количеством связей.

|оптимизатор|слой нейронов|слой нейронов STD|1 скрытый слой|
|-----------|-------------|-----------------|--------------|
|Adadelta   |![](./pics/neural_test/neural_Adadelta_15eph_0.00001lrate_rnd.png)	|![](./pics/neural_test/neuralSTD_Adadelta_15eph_0.00001lrate_rnd.png)	|![](./pics/neural_test/deep1h_Adadelta_15eph_0.00003lrate_rnd.png)	|
|Adagrad    |![](./pics/neural_test/neural_Adagrad_15eph_0.00001lrate_rnd.png)	|![](./pics/neural_test/neuralSTD_Adagrad_15eph_0.00001lrate_rnd.png)	|![](./pics/neural_test/deep1h_Adagrad_15eph_0.00003lrate_rnd.png)	|
|Adam       |![](./pics/neural_test/neural_Adam_15eph_0.00001lrate_rnd.png)		|![](./pics/neural_test/neuralSTD_Adam_15eph_0.00001lrate_rnd.png)		|![](./pics/neural_test/deep1h_Adam_15eph_0.00003lrate_rnd.png)		|
|Adamax     |![](./pics/neural_test/neural_Adamax_15eph_0.00001lrate_rnd.png)	|![](./pics/neural_test/neuralSTD_Adamax_15eph_0.00001lrate_rnd.png)	|![](./pics/neural_test/deep1h_Adamax_15eph_0.00003lrate_rnd.png)	|
|Ftrl       |![](./pics/neural_test/neural_Ftrl_15eph_0.00001lrate_rnd.png)		|![](./pics/neural_test/neuralSTD_Ftrl_15eph_0.00001lrate_rnd.png)		|![](./pics/neural_test/deep1h_Ftrl_15eph_0.00003lrate_rnd.png)		|
|Nadam      |![](./pics/neural_test/neural_Nadam_15eph_0.00001lrate_rnd.png)	|![](./pics/neural_test/neuralSTD_Nadam_15eph_0.00001lrate_rnd.png)		|![](./pics/neural_test/deep1h_Nadam_15eph_0.00003lrate_rnd.png)	|
|RMSprop    |![](./pics/neural_test/neural_RMSprop_15eph_0.00001lrate_rnd.png)	|![](./pics/neural_test/neuralSTD_RMSprop_15eph_0.00001lrate_rnd.png)	|![](./pics/neural_test/deep1h_RMSprop_15eph_0.00003lrate_rnd.png)	|
|SGD        |![](./pics/neural_test/neural_SGD_15eph_0.00001lrate_rnd.png)		|![](./pics/neural_test/neuralSTD_SGD_15eph_0.00001lrate_rnd.png)		|![](./pics/neural_test/deep1h_SGD_15eph_0.00003lrate_rnd.png)		|

Видно, что "слой нейронов" и "слой нейронов STD" дают схожие результаты, так что модель "слой нейронов STD"
можно не использовать


Кол-во входных значений: 1562
Время обучения на intel Core i7-4510U 2.0GHz, 8 потоков, 8 Gb ОЗУ:

|модель|кол-во обучаемых значений|кол-во примеров|время|
|------|-------------------------|---------------|-----|
|фильтр			|1562		|126	|33.9 	+- 0.8 мс.|
|фильтр с весами|3124		|126	|37.5 	+- 5.0 мс.|
|слой нейронов	|2441406	|126	|619.1	+- 513.9 мс.|
|слой нейронов	|2441406	|1519	|6639.1 +- 505.5 мс.|
|1 скрытый слой	|3254687	|1519	|9899.2 +- 464.5 мс.|

По рассмотрении результатов тестов, для обучения на большом наборе примеров имеет смысл взять следующие модели 
и оптимизаторы

|модель|оптимизаторы|
|---|---|
|фильтр без рандомизации|Adadelta, Adagrad, SGD|
|слой нейронов|Adam, Adamax, Ftlr, Nadam, RMSprop|
|1 скрытый слой|Adam, Adamax, RMSprop|
