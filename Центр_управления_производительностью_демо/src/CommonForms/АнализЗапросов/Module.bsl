&НаСервере
Перем мВременныеТаблицы;

&НаСервере
Перем мЗапросыБлокировки;


///////////////////////////////////////////////////////////////////////////////
// ПРОЦЕДУРЫ ОБРАБОТКИ СОБЫТИЙ ФОРМЫ

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	ИнформационнаяБаза = Параметры.ИнформационнаяБаза;
	НачалоИнтервала = Параметры.НачалоИнтервала;
	КонецИнтервала = Параметры.КонецИнтервала;
	ПроблемнаяСтрокаКонтекста = Параметры.ПроблемнаяСтрокаКонтекста;
	ПроблемныйРесурс = Параметры.ПроблемныйРесурс;
	ПроблемныйПользователь = Параметры.ПроблемныйПользователь;
	Если ЗначениеЗаполнено(ПроблемныйРесурс) Или ЗначениеЗаполнено(ПроблемныйПользователь) Тогда
		ОтключитьОтборПоКонтексту = Истина;
		Элементы.ОтключитьОтборПоКонтексту.Видимость = Ложь;
	КонецЕсли;
	СпособГруппировки = Параметры.СпособГруппировки;
	ТипРесурса = ПроблемныйРесурс.Тип;
	
	Если НЕ ЗначениеЗаполнено(НачалоИнтервала) Тогда
		Сообщить("Не указано начало интервала!");
		Отказ = Истина;
	ИначеЕсли НЕ ЗначениеЗаполнено(КонецИнтервала) Тогда
		Сообщить("Не указан конец интервала!");
		Отказ = Истина;
	ИначеЕсли НЕ ЗначениеЗаполнено(ИнформационнаяБаза) Тогда
		Сообщить("Не указана информационная база!");
		Отказ = Истина;
	КонецЕсли;
	
	Если Отказ Тогда
		Возврат
	КонецЕсли;
	
	// Получить коэффицент ожидания на блокировках
	КоэффицентВыполнения = ПоказателиПроизводительности.ПолучитьВесовойКоэффициент(Справочники.Показатели.АнализЗапросов);
	КоэффицентВыполнения = ?(КоэффицентВыполнения = 0, 1, КоэффицентВыполнения);
	
	УстановитьВидимостьКолонкамЗапросов();
	ЗаполнитьТаблицуЗапросов();
	
КонецПроцедуры

&НаКлиенте
Процедура ЗапросыВыбор(Элемент, ВыбраннаяСтрока, Поле, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	Если ВыбраннаяСтрока <> Неопределено Тогда
		ДанныеСтроки = Запросы.НайтиПоИдентификатору(ВыбраннаяСтрока);
		
		// Открыть форму запроса
		ИнтерфейсыКлиент.ОткрытьВыполнениеЗапроса(ДанныеСтроки.ВыполнениеСсылка);
	КонецЕсли;
	
КонецПроцедуры


///////////////////////////////////////////////////////////////////////////////
// ПРОЦЕДУРЫ И ФУНКЦИИ ОБЩЕГО НАЗНАЧЕНИЯ

&НаСервере
// Процедура устанавляет видемость некоторым колонкам таблицы Запросы.
//
Процедура УстановитьВидимостьКолонкамЗапросов()
	
	ВключенаГруппировка = (СпособГруппировки <> "БезГруппировки");
	Элементы.ЗапросыДатаВремяВыполнения.Видимость = НЕ ВключенаГруппировка;
	Элементы.ЗапросыПользователь.Видимость        = НЕ ВключенаГруппировка;
	Элементы.ФункцияГруппировки.Доступность       = ВключенаГруппировка;
	
	Элементы.ЗапросыКонтекст.Высота = ?(СпособГруппировки = "Контекст", 3, 1);
	
КонецПроцедуры // УстановитьВидимостьКолонкамЗапросов()


///////////////////////////////////////////////////////////////////////////////
// ПРОЦЕДУРЫ И ФУНКЦИИ ВЫБОРА ДАННЫХ

&НаСервере
// Функция возвращает текст запроса выбора проблемных запросов в случае анализа запросов по контекстам.
//
// Возвращаемое значение:
//  Строка - текст запроса.
//
Функция ТекстЗапросаВыполненияПоКонтексту(ИмяРеквизитаКонтекста)
	
	ВключенаГруппировка = (СпособГруппировки <> "БезГруппировки");
	Если НЕ ВключенаГруппировка Тогда
		
		ТекстЗапроса = "ВЫБРАТЬ
		               |	1 КАК ИндексКартинки,
		               |	&ПоказательВеса / 1000 КАК ВремяВыполнения,
		               |	(&ПоказательВеса / 1000) * &КоэффицентВыполнения КАК Вес,
		               |	Выполнение.Дата КАК ДатаВремяВыполнения,
		               |	Выполнение.ПользовательИБ КАК Пользователь,
		               |	Выполнение.КонтекстСсылка.ПоследняяСтрока КАК Контекст,
		               |	Выполнение.ТекстЗапроса КАК Запрос,
		               |	Выполнение.Ссылка КАК ВыполнениеСсылка
		               |ИЗ
		               |	Документ.ВыполнениеЗапроса КАК Выполнение
		               |ГДЕ
		               |	Выполнение.Дата МЕЖДУ &НачалоИнтервала И &КонецИнтервала
		               |	И &ПоказательВеса > 0
		               |	И (&ПоказательВеса / 1000) * &КоэффицентВыполнения > 0
		               |	И Выполнение.ИнформационнаяБаза = &ИБ
		               |	И (Выполнение.КонтекстСсылка.ПоследняяСтрока = &СтрокаКонтекста ИЛИ &БезОтбораПоКонтексту)
		               |	И (Выполнение.ПользовательИБ = &Пользователь ИЛИ &БезОтбораПоПользователю)
		               |УПОРЯДОЧИТЬ ПО
		               |	ВремяВыполнения УБЫВ
		               |	";
		
	Иначе
		
		ТекстЗапроса = "ВЫБРАТЬ
		               |	1 КАК ИндексКартинки,
		               |	Выполнение.Запрос,
		               |	СУММА(&ПоказательВеса / 1000) КАК ВремяВыполнения,
		               |	СУММА((&ПоказательВеса / 1000) * &КоэффицентВыполнения) КАК Вес,
		               |	Выполнение.КонтекстСсылка.ПоследняяСтрока КАК Контекст,
		               |	Выполнение.ТекстЗапроса КАК Запрос,
		               |	Выполнение.Ссылка КАК ВыполнениеСсылка
		               |ИЗ
		               |	Документ.ВыполнениеЗапроса КАК Выполнение
		               |ГДЕ
		               |	Выполнение.Дата МЕЖДУ &НачалоИнтервала И &КонецИнтервала
		               |	И &ПоказательВеса > 0
		               |	И (&ПоказательВеса / 1000) * &КоэффицентВыполнения > 0
		               |	И Выполнение.ИнформационнаяБаза = &ИБ
		               |	И (Выполнение.КонтекстСсылка.ПоследняяСтрока = &СтрокаКонтекста ИЛИ &БезОтбораПоКонтексту)
		               |	И (Выполнение.ПользовательИБ = &Пользователь ИЛИ &БезОтбораПоПользователю)
		               |СГРУППИРОВАТЬ ПО
		               |	
		               |	Выполнение.Запрос,
		               |	Выполнение.КонтекстСсылка.ПоследняяСтрока,
		               |	Выполнение.ТекстЗапроса,
		               |	Выполнение.Ссылка
		               |ИТОГИ ПО Выполнение.КонтекстСсылка.ПоследняяСтрока ИЕРАРХИЯ
		               |	";
		
		Если ФункцияГруппировки = 1 Тогда
			ТекстЗапроса = СтрЗаменить(ТекстЗапроса, "СУММА(", "СРЕДНЕЕ(");
		ИначеЕсли ФункцияГруппировки = 2 Тогда
			ТекстЗапроса = СтрЗаменить(ТекстЗапроса, "СУММА(", "МАКСИМУМ(");
		КонецЕсли;
	КонецЕсли;
	
	Если ПоказательВеса = 0 Тогда
		ИмяРеквизита = "ВремяВыполненияМс";
	Иначе
		ИмяРеквизита = "ВесПланаЗапроса";
	КонецЕсли;
	ТекстЗапроса = СтрЗаменить(ТекстЗапроса, "&ПоказательВеса", "Выполнение." + ИмяРеквизита);
	
	// Результат
	Если ИмяРеквизитаКонтекста = "Ссылка" Тогда
		ИмяРеквизитаКонтекстаРезультат = "Контекст";
	Иначе
		ИмяРеквизитаКонтекстаРезультат = ИмяРеквизитаКонтекста;
	КонецЕсли;
	
	ТекстЗапроса = СтрЗаменить(ТекстЗапроса, 
		"Выполнение.КонтекстСсылка.ПоследняяСтрока КАК Контекст", 
		"Выполнение.КонтекстСсылка." + ИмяРеквизитаКонтекстаРезультат + " КАК Контекст");
	
	ТекстЗапроса = СтрЗаменить(ТекстЗапроса, 
		"ИТОГИ ПО Выполнение.КонтекстСсылка.ПоследняяСтрока", 
		"ИТОГИ ПО Выполнение.КонтекстСсылка." + ИмяРеквизитаКонтекстаРезультат);
	
	Возврат ТекстЗапроса;
	
КонецФункции //ТекстЗапросаВыполненияПоКонтексту()

&НаСервере
// Функция возвращает текст запроса выбора проблемных запросов в случае анализа запросов по ресурсам.
//
// Возвращаемое значение:
//  Строка - текст запроса.
//
Функция ТекстЗапросаВыполненияПоРесурсу(ИмяРеквизитаКонтекста)
	
	ВключенаГруппировка = (СпособГруппировки <> "БезГруппировки");
	Если НЕ ВключенаГруппировка Тогда
		
		ТекстЗапроса = "ВЫБРАТЬ
		               |	1 КАК ИндексКартинки,
		               |	&ПоказательВеса / 1000 КАК ВремяВыполнения,
		               |	(&ПоказательВеса / К.Количество / 1000) * &КоэффицентВыполнения КАК Вес,
		               |	Б.ВыполнениеЗапроса.Дата КАК ДатаВремяВыполнения,
		               |	Б.ВыполнениеЗапроса.ПользовательИБ КАК Пользователь,
		               |	Б.ВыполнениеЗапроса.КонтекстСсылка.ПоследняяСтрока КАК Контекст,
		               |	Б.ВыполнениеЗапроса.ТекстЗапроса КАК Запрос,
		               |	Б.ВыполнениеЗапроса.Ссылка КАК ВыполнениеСсылка
		               |	ИЗ
		               |		Документ.Блокировка КАК Б
		               |			ЛЕВОЕ СОЕДИНЕНИЕ БлокировкиВыполненийЗапросов КАК К
		               |			ПО (К.ВыполнениеЗапроса = Б.ВыполнениеЗапроса)
		               |	ГДЕ
		               |		Б.Дата МЕЖДУ &НачалоИнтервала И &КонецИнтервала
		               |		И ВЫРАЗИТЬ (Б.ВыполнениеЗапроса КАК Документ.ВыполнениеЗапроса) <> ЗНАЧЕНИЕ(Документ.ВыполнениеЗапроса.ПустаяСсылка)
		               |		И &ПоказательВеса > 0
		               |		И (&ПоказательВеса / К.Количество / 1000) * &КоэффицентВыполнения > 0
		               |		И Б.ИнформационнаяБаза = &ИБ
		               |		И Б.Ресурс = &Ресурс
		               |		И Б.Ресурс.Тип = &ТипРесурса
		               |УПОРЯДОЧИТЬ ПО
		               |	ВремяВыполнения УБЫВ";
	
	Иначе
		
		ТекстЗапроса = "ВЫБРАТЬ
		               |	1 КАК ИндексКартинки,
		               |	Б.ВыполнениеЗапроса.Запрос,
		               |	СУММА(&ПоказательВеса / 1000) КАК ВремяВыполнения,
		               |	СУММА ((&ПоказательВеса / К.Количество / 1000) * &КоэффицентВыполнения) КАК Вес,
		               |	Б.ВыполнениеЗапроса.КонтекстСсылка.ПоследняяСтрока КАК Контекст,
		               |	Б.ВыполнениеЗапроса.ТекстЗапроса КАК Запрос,
		               |	Б.ВыполнениеЗапроса.Ссылка КАК ВыполнениеСсылка
		               |	ИЗ
		               |		Документ.Блокировка КАК Б
		               |			ЛЕВОЕ СОЕДИНЕНИЕ БлокировкиВыполненийЗапросов КАК К
		               |			ПО (К.ВыполнениеЗапроса = Б.ВыполнениеЗапроса)
		               |	ГДЕ
		               |		Б.Дата МЕЖДУ &НачалоИнтервала И &КонецИнтервала
		               |		И ВЫРАЗИТЬ (Б.ВыполнениеЗапроса КАК Документ.ВыполнениеЗапроса) <> ЗНАЧЕНИЕ(Документ.ВыполнениеЗапроса.ПустаяСсылка)
		               |		И &ПоказательВеса > 0
		               |		И (&ПоказательВеса / К.Количество / 1000) * &КоэффицентВыполнения > 0
		               |		И Б.ИнформационнаяБаза = &ИБ
		               |		И Б.Ресурс = &Ресурс
		               |		И Б.Ресурс.Тип = &ТипРесурса
		               |СГРУППИРОВАТЬ ПО
		               |	
		               |	Б.ВыполнениеЗапроса.Запрос,
		               |	Б.ВыполнениеЗапроса.КонтекстСсылка.ПоследняяСтрока,
		               |	Б.ВыполнениеЗапроса.ТекстЗапроса,
		               |	Б.ВыполнениеЗапроса.Ссылка
		               |	
		               |	ИТОГИ ПО Б.ВыполнениеЗапроса.КонтекстСсылка.ПоследняяСтрока ИЕРАРХИЯ";
		
		Если ФункцияГруппировки = 1 Тогда
			ТекстЗапроса = СтрЗаменить(ТекстЗапроса, "СУММА(", "СРЕДНЕЕ(");
		ИначеЕсли ФункцияГруппировки = 2 Тогда
			ТекстЗапроса = СтрЗаменить(ТекстЗапроса, "СУММА(", "МАКСИМУМ(");
		КонецЕсли;
		
	КонецЕсли;
	
	Если ПоказательВеса = 0 Тогда
		ИмяРеквизита = "ВремяВыполненияМс";
	Иначе
		ИмяРеквизита = "ВесПланаЗапроса";
	КонецЕсли;
	ТекстЗапроса = СтрЗаменить(ТекстЗапроса, "&ПоказательВеса", "Б.ВыполнениеЗапроса." + ИмяРеквизита);
	
	// Результат
	Если ИмяРеквизитаКонтекста = "Ссылка" Тогда
		ИмяРеквизитаКонтекстаРезультат = "Контекст";
	Иначе
		ИмяРеквизитаКонтекстаРезультат = ИмяРеквизитаКонтекста;
	КонецЕсли;
	
	ТекстЗапроса = СтрЗаменить(ТекстЗапроса, 
		"ВыполнениеЗапроса.КонтекстСсылка.ПоследняяСтрока", 
		"ВыполнениеЗапроса.КонтекстСсылка." + ИмяРеквизитаКонтекстаРезультат);
	
	Возврат ТекстЗапроса;
	
КонецФункции // ТекстЗапросаВыполненияПоРесурсу()

&НаСервере
// Процедура заполняет временную таблицу БлокировкиВыполненийЗапросов.
// Используется в остальных запросах для вычисления веса.
//
Процедура ЗаполнитьВТБлокировкиВыполненийЗапросов()
	
	Запрос = Новый Запрос;
	Запрос.МенеджерВременныхТаблиц = мВременныеТаблицы;
	
	Запрос.Текст = "ВЫБРАТЬ
	               |	Б.ВыполнениеЗапроса КАК ВыполнениеЗапроса,
	               |	КОЛИЧЕСТВО(*) КАК Количество
	               |ПОМЕСТИТЬ БлокировкиВыполненийЗапросов
	               |ИЗ
	               |	Документ.Блокировка КАК Б
	               |ГДЕ
	               |	Б.Дата МЕЖДУ &НачалоИнтервала И &КонецИнтервала
	               |	И Б.ИнформационнаяБаза = &ИБ
	               |	И ВЫРАЗИТЬ (Б.ВыполнениеЗапроса КАК Документ.ВыполнениеЗапроса) <> ЗНАЧЕНИЕ(Документ.ВыполнениеЗапроса.ПустаяСсылка)
	               |	И Б.ВыполнениеЗапроса.ВремяВыполненияМс > 0
	               |СГРУППИРОВАТЬ ПО
	               |	Б.ВыполнениеЗапроса
	               |ИНДЕКСИРОВАТЬ ПО
	               |	ВыполнениеЗапроса;
	               |";
	
	Запрос.УстановитьПараметр("НачалоИнтервала", НачалоИнтервала);
	Запрос.УстановитьПараметр("КонецИнтервала",  КонецИнтервала);
	Запрос.УстановитьПараметр("ИБ",              ИнформационнаяБаза);
	
	Запрос.Выполнить();
	
КонецПроцедуры // ЗаполнитьВТБлокировкиВыполненийЗапросов()

&НаСервере
// Процедура заполняет таблицу Запросы.
// Выполняет запрос выбора проблемных запросов.
//
// Параметры:
//  ЗаблокированныйКонтекст - СправочникСсылка.Контекст
//  БлокирующийКонтекст     - СправочникСсылка.Контекст
//  ЗаблокированныйРесурс   - СправочникСсылка.Ресурс
//
Процедура ЗаполнитьТаблицуЗапросов()
	
	// Сформировать запрос выбора
	Если мЗапросыБлокировки = Неопределено Тогда
		
		мЗапросыБлокировки = Новый Запрос;
		
		Если СпособГруппировки = "БезГруппировки" Тогда
			ИмяРеквизитаКонтекста = "ПоследняяСтрока";
		ИначеЕсли СпособГруппировки = "Контекст" Тогда
			ИмяРеквизитаКонтекста = "Ссылка";
		Иначе
			ИмяРеквизитаКонтекста = СпособГруппировки;
		КонецЕсли;
		
		Если ЗначениеЗаполнено(ПроблемнаяСтрокаКонтекста) Или ЗначениеЗаполнено(ПроблемныйПользователь) Тогда
			
			// Получить текст запроса выбора проблемных запросов по заданному контексту
			мЗапросыБлокировки.Текст = ТекстЗапросаВыполненияПоКонтексту(ИмяРеквизитаКонтекста);
			мЗапросыБлокировки.УстановитьПараметр("СтрокаКонтекста", ПроблемнаяСтрокаКонтекста);
			мЗапросыБлокировки.УстановитьПараметр("БезОтбораПоКонтексту", ОтключитьОтборПоКонтексту);
			
			мЗапросыБлокировки.УстановитьПараметр("Пользователь",         ПроблемныйПользователь);
			мЗапросыБлокировки.УстановитьПараметр("БезОтбораПоПользователю", НЕ ЗначениеЗаполнено(ПроблемныйПользователь));
			
		Иначе
			
			// Создать временные таблицы для вычисления веса проблем.
			мВременныеТаблицы = Новый МенеджерВременныхТаблиц;
			
			ЗаполнитьВТБлокировкиВыполненийЗапросов();
			
			мЗапросыБлокировки.МенеджерВременныхТаблиц = мВременныеТаблицы;
			
			// Получить текст запроса выбора проблемных запросов по заданному ресурсу
			мЗапросыБлокировки.Текст = ТекстЗапросаВыполненияПоРесурсу(ИмяРеквизитаКонтекста);
			
			мЗапросыБлокировки.УстановитьПараметр("ТипРесурса", ТипРесурса);
			мЗапросыБлокировки.УстановитьПараметр("Ресурс",     ПроблемныйРесурс);
			
		КонецЕсли;
		
		// Установить общие параметры запроса
		мЗапросыБлокировки.УстановитьПараметр("КоэффицентВыполнения", КоэффицентВыполнения);
		мЗапросыБлокировки.УстановитьПараметр("НачалоИнтервала",      НачалоИнтервала);
		мЗапросыБлокировки.УстановитьПараметр("КонецИнтервала",       КонецИнтервала);
		мЗапросыБлокировки.УстановитьПараметр("ИБ",                   ИнформационнаяБаза);
		
	КонецЕсли;
	
	// Заполнить таблицу
	ВключенаГруппировка = (СпособГруппировки <> "БезГруппировки");
	Если НЕ ВключенаГруппировка Тогда
		
		// Выгрузить список всех запросов
		ТаблицаЗапросы = мЗапросыБлокировки.Выполнить().Выгрузить();
		ЗначениеВДанныеФормы(ТаблицаЗапросы, Запросы);
		
	Иначе
		
		Запросы.Очистить();
		
		// Выгрузить запросы и сгруппировать по типу запроса
		Выборка1 = мЗапросыБлокировки.Выполнить().Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
		
		Пока Выборка1.Следующий() Цикл
			
			Стр = Запросы.Добавить();
			
			Стр.ИндексКартинки  = 1;
			Стр.Вес             = Выборка1.Вес;
			Стр.ВремяВыполнения = Выборка1.ВремяВыполнения;
			Стр.Контекст         = Выборка1.Контекст;
			
			Выборка2 = Выборка1.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
			
			Пока Выборка2.Следующий() Цикл
				
				Стр.Запрос           = Выборка2.Запрос;
				Стр.ВыполнениеСсылка = Выборка2.ВыполнениеСсылка;
				
				//Прервать;
				
			КонецЦикла;
			
		КонецЦикла;
		
		Запросы.Сортировать("ВремяВыполнения УБЫВ");
		
	КонецЕсли;
	
	// Заполнить копию таблицы (используется при установке отбора)
	ВсеЗапросы = Новый ХранилищеЗначения(РеквизитФормыВЗначение("Запросы").Скопировать());
	
	мФильтрЗапросы = Неопределено;
	
КонецПроцедуры // ЗаполнитьТаблицуЗапросов()

&НаКлиенте
Процедура ПоказательВесаПриИзменении(Элемент)
	
	ЗаполнитьТаблицуЗапросов();
	
	Если ПоказательВеса = 0 Тогда
		Элементы.ЗапросыВремяВыполнения.Заголовок = "Длительность (сек)";
		Элементы.ЗапросыВремяВыполнения.Подсказка = "Время выполнения запроса в секундах";
	Иначе
		Элементы.ЗапросыВремяВыполнения.Заголовок = "Вес плана запроса";
		Элементы.ЗапросыВремяВыполнения.Подсказка = "Оценка качества плана запроса, определенная как отношение числа возвращенных строк к числу считанных строк, деленное на 1000";
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура СпособГруппировкиПриИзменении(Элемент)
	
	УстановитьВидимостьКолонкамЗапросов();
	ЗаполнитьТаблицуЗапросов();
	
КонецПроцедуры

&НаКлиенте
Процедура ФункцияГруппировкиПриИзменении(Элемент)
	
	ЗаполнитьТаблицуЗапросов();
	
КонецПроцедуры

&НаКлиенте
Процедура ОтключитьОтборПоКонтекстуПриИзменении(Элемент)
	
	ЗаполнитьТаблицуЗапросов();
	
КонецПроцедуры
