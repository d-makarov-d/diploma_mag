# Сохраненные промежуточные резултаты, используемые на промежуточных этапах работы и обучения программы

- **classified.mat**:
выбранные экспертом участки, содержащие сигнал от поезда. Формат структуры:
  - data: "вырезанный" участок сигнала
  - time: "вырезанный" участок времени
  - type: "тип" сигнала
    - 1: тип 1, наиболее распространенный и ярковыраженный
    - 2: тип 2, менее распространенный, чем 1-й
    - 3: тип 3, встречается часто, выглядит как суперпозиция или зашумление первых 2-х типов
  - interval: временной интервал выделенного участка
- **test/***
  - тестовая выборка
- **\*.smp**
	- обучающие выборки
- **mob_acc.mat** 
запись на акселерометр телефона из вагона метро