///////////////////////////////////////////////////////////////////////////////
// АНАЛИЗ ВЗАИМОБЛОКИРОВОК

// Включить сбор информации для анализа взаимоблокировок
//
Функция ВключитьСборВзаимоблокировок(ИБ, Показатели) Экспорт
	
	ОтладкаКлиентСервер.Действие("ВключитьСборВзаимоблокировок");
	
	Если ИБ.ТипСУБД <> Перечисления.ТипыСУБД.MSSQLServer Тогда
		ВызватьИсключение СловарьКлиентСервер.Получить("ОшибкаОграничениеАнализаВзаимоблокировокПоСУБД");
	КонецЕсли;
	
	ОписателиСбораДанных = ВключитьСборВзаимоблокировокMSSQL(ИБ, Показатели);
	
	ОтладкаКлиентСервер.Результат("ВключитьСборВзаимоблокировок");
	
	Возврат ОписателиСбораДанных;
	
КонецФункции // ВключитьСборВзаимоблокировок

// Отключить сбор информации для анализа взаимоблокировок
//
Процедура ОтключитьСборВзаимоблокировок(ИБ, Показатели, ОписательТЖ, ОписательТрассировки, АнализНеобходим) Экспорт
	
	ОтладкаКлиентСервер.Действие("ОтключитьСборВзаимоблокировок");
	
	ОстановитьСборВзаимоблокировокMSSQL(ИБ, Показатели, ОписательТЖ, ОписательТрассировки, АнализНеобходим);
	
	ОтладкаКлиентСервер.Результат("ОтключитьСборВзаимоблокировок");
	
КонецПроцедуры // ОтключитьСборВзаимоблокировок

// Провести анализ ожиданий на блокировках
//
Процедура ПроанализироватьВзаимоблокировки(КонтекстАнализа) Экспорт
	
	ОтладкаКлиентСервер.Действие("ПроанализироватьВзаимоблокировки");
	
	ПроанализироватьВзаимоблокировкиMSSQL(КонтекстАнализа);
	
	ОтладкаКлиентСервер.Результат("ПроанализироватьВзаимоблокировки");
	
КонецПроцедуры // ПроанализироватьВзаимоблокировки


///////////////////////////////////////////////////////////////////////////////
// АНАЛИЗ ВЗАИМОБЛОКИРОВОК MSSQL Server

// Включить сбор информации для анализа взаимоблокировок
//
Функция ВключитьСборВзаимоблокировокMSSQL(ИБ, Показатели) Экспорт
	
	ОтладкаКлиентСервер.Действие("ВключитьСборВзаимоблокировокMSSQL");
	
	АнализВзаимоблокировокОбъект = Справочники.Показатели.АнализВзаимоблокировок.ПолучитьОбъект();
	ПолучатьПланы = АнализВзаимоблокировокОбъект.ПолучатьПланыЗапросов();
	
	// Включить технологический журнал
	ОписательТЖВзаимоблокировок = ТехнологическийЖурнал.ВключитьТехнологическийЖурнал(
		ТехнологическийЖурнал.КонфигурацияАнализаВзаимоблокировок(
			ИБ.ИмяИБ,
			ИБ.ТипСУБД,
			ПолучатьПланы),
		ИБ.ИменаКаталоговТЖ);
		
	// Зафиксировать каталоги ТЖ
	СтрокаПоказателя = ОбщегоНазначенияКлиентСервер.НайтиЭлементМассиваСтруктур(Показатели, "Показатель", Справочники.Показатели.АнализВзаимоблокировок);
	СтрокаПоказателя.ЗамерАнализЗапросов = Замер.СоздатьЗамер(
		ИБ,
		СтрокаПоказателя.Показатель,
		СтрокаПоказателя.Экземпляр,
		ИБ.ТипСУБД,
		ИБ.СерверСУБД,,
		ИБ.ИмяБД);
	Замер.УстановитьКаталогиТЖ(СтрокаПоказателя.ЗамерАнализЗапросов, ОписательТЖВзаимоблокировок.КаталогиТЖ);
	
	// Создать трассировку
	ОписательТрассировки = MSSQL.СоздатьТрассировку(
		ИБ,
		ИБ.ТипОССервераСУБД,
		ИБ.КаталогТрассировкиЛокальный);
	
	// Добавить события трассировки
	ИдентификаторыСобытий = MSSQL.ПолучитьИдентификаторыСобытий();
	
	MSSQL.ДобавитьСобытиеТрассировки(
		ИдентификаторыСобытий["Deadlock graph"],
		"SPID, StartTime, TextData, EventSequence",
		ОписательТрассировки);
	
	// Включить трассировку
	MSSQL.ВключитьТрассировку(ОписательТрассировки);
	
	ФайлыТрассировок = Новый Массив;
	Пути = Новый Структура;
	Пути.Вставить("Локальный", ОписательТрассировки.ПолноеИмяФайла);
	ФайлыТрассировок.Добавить(Пути);
	Замер.УстановитьФайлыТрассировок(СтрокаПоказателя.ЗамерАнализЗапросов, ФайлыТрассировок);
	
	ОтладкаКлиентСервер.Результат("ВключитьСборВзаимоблокировокMSSQL");
	
	ОписателиСбораДанных = Новый Структура("ОписательТЖ,ОписательТрассировки",
		ОписательТЖВзаимоблокировок,
		ОписательТрассировки
	);
	
	Возврат ОписателиСбораДанных;
	
КонецФункции // ВключитьСборВзаимоблокировокMSSQL

// Остановить сбор информации для анализа взаимоблокировок
//
Процедура ОстановитьСборВзаимоблокировокMSSQL(ИБ, Показатели, ОписательТЖ, ОписательТрассировки, АнализНеобходим) Экспорт
	
	ОтладкаКлиентСервер.Действие("ОстановитьСборВзаимоблокировокMSSQL");
	
	// Остановить трассировку
	MSSQL.ОстановитьТрассировку(ОписательТрассировки);
	MSSQL.ВыключитьТрассировку(ОписательТрассировки);
	
	// Остановить технологический журнал
	ТехнологическийЖурнал.ОтключитьТехнологическийЖурнал(
		ОписательТЖ,
		ИБ.ИменаКаталоговТЖ);
		
	СтрокаПоказателя = ОбщегоНазначенияКлиентСервер.НайтиЭлементМассиваСтруктур(Показатели, "Показатель", Справочники.Показатели.АнализВзаимоблокировок);
	
	Замер.ЗавершитьЗамер(СтрокаПоказателя.ЗамерАнализЗапросов);
	
	Если Не АнализНеобходим Тогда
		Замер.Отменить(СтрокаПоказателя.ЗамерАнализЗапросов);
	КонецЕсли;
	
	ОтладкаКлиентСервер.Результат("ОстановитьСборВзаимоблокировокMSSQL");
	
КонецПроцедуры // ОстановитьСборВзаимоблокировокMSSQL

// Отключить сбор информации для анализа взаимоблокировок
//
Процедура ОтключитьСборВзаимоблокировокMSSQL() Экспорт
	
	ОтладкаКлиентСервер.Действие("ОтключитьСборВзаимоблокировокMSSQL");
	
	ОтладкаКлиентСервер.Результат("ОтключитьСборВзаимоблокировокMSSQL");
	
КонецПроцедуры // ОтключитьСборВзаимоблокировокMSSQL

// Провести анализ ожиданий на блокировках
//
Процедура ПроанализироватьВзаимоблокировкиMSSQL(КонтекстАнализа) Экспорт
	
	Перем НомерПоследнегоСобытия;
	Перем РезультатРазбора;
	Перем Взаимоблокировка;
	
	ОтладкаКлиентСервер.Действие("ПроанализироватьВзаимоблокировкиMSSQL");
	
	ТаблицаСовместимостиБлокировок = СУБД.СоздатьТаблицуСовместимостиБлокировок();
	СтруктураБазы = КонтекстАнализа.СтруктураБазы.СУБД;
	СловарьШаблонов = КонтекстАнализа.СловарьШаблонов;
	
	КоличествоВзаимоблокировок = 0;
	
	Инструменты = КипВнешнийКомпонент.ПолучитьИнструменты();
	
	// Получить все записи трассировки
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("Замер", КонтекстАнализа.Замер);
	Запрос.УстановитьПараметр("Период", КонтекстАнализа.Замер.Дата);
	Запрос.Текст = "
		|ВЫБРАТЬ
		|	Графы.Граф,
		|	Графы.ДатаСобытия,
		|	Графы.МоментВремениСобытия
		|ИЗ
		|	РегистрСведений.ГрафыВзаимоблокировок КАК Графы
		|ГДЕ
		|	Графы.Период = &Период И
		|	Графы.Регистратор = &Замер";
	ПорцияСобытий = Запрос.Выполнить().Выбрать();
	
	Результаты = Новый Массив;
	
	// Анализ графов взаимоблокировок
	Пока ПорцияСобытий.Следующий() Цикл
		РезультатРазбора = РазобратьГрафВзаимоблокировкиMSSQL(
			СтруктураБазы,
			СловарьШаблонов,
			ПорцияСобытий.ДатаСобытия,
			ПорцияСобытий.Граф,
			КонтекстАнализа.Замер.ИнформационнаяБаза,
			КонтекстАнализа.Замер.ИмяБазыДанных,
			ПорцияСобытий.МоментВремениСобытия,
			КонтекстАнализа.Замер.ТипСУБД);
		
		Если РезультатРазбора <> Неопределено Тогда
			Результаты.Добавить(РезультатРазбора);
		КонецЕсли;
	КонецЦикла;
	
	// Анализ технологического журнала
	ПроанализироватьТехнологическийЖурнал(Результаты, КонтекстАнализа.Замер.ТипСУБД, КонтекстАнализа.Замер, ТаблицаСовместимостиБлокировок);
	
	// Зафиксировать взаимоблокировки
	Для Каждого РезультатРазбора Из Результаты Цикл
		Если РезультатРазбора.Проанализирована Тогда
			НачатьТранзакцию();
			
			Попытка
				Взаимоблокировка = СтруктураДанных.ЗафиксироватьВзаимоблокировку(РезультатРазбора, КонтекстАнализа, Инструменты);
				КоличествоВзаимоблокировок = КоличествоВзаимоблокировок + 1;
			Исключение
				ОтменитьТранзакцию();
				ВызватьИсключение;
			КонецПопытки;
			
			ЗафиксироватьТранзакцию();
		Иначе
			Продолжить;
		КонецЕсли;
	КонецЦикла;
	
	ОтладкаКлиентСервер.Результат("ПроанализироватьВзаимоблокировкиMSSQL", КоличествоВзаимоблокировок);
	
КонецПроцедуры // ПроанализироватьВзаимоблокировкиMSSQL

// Разобрать взаимоблокировку Microsoft SQL Server
//
// Параметры:
//  СтруктураБазы - ТаблицаЗначений, структура хранения базы данных
//  СловарьШаблонов - ТаблицаЗначений, словарь шаблонов метаданных
//  ВремяВозникновения - Дата, время возникновения взаимоблокировки
//  Граф - Строка, XML представление взаимоблокировки
//  ИсследуемаяИнформационнаяБаза - СправочникСсылка.ИнформационнаяБаза
//  ИБ - COMОбъект, текущая информационная база
//  МоментВремени - Число, момент времени в тиках
//
// Возвращаемое значение:
//  Результат - Структура, результат разбора взаимоблокировки
//
Функция РазобратьГрафВзаимоблокировкиMSSQL(СтруктураБазы,
                                           СловарьШаблонов,
                                           ВремяВозникновения,
                                           Граф,
                                           ИсследуемаяИнформационнаяБаза,
                                           ИмяБазыДанных,
                                           МоментВремени,
                                           ТипСУБД)
	
	ОтладкаКлиентСервер.Действие("РазобратьГрафВзаимоблокировкиMSSQL");
	
	ТаблицаСовместимостиБлокировок = СУБД.СоздатьТаблицуСовместимостиБлокировок();
	
	// Подготовиться к чтению XML
	ЧтениеXmlГрафа = Новый ЧтениеXML;
	ЧтениеXmlГрафа.УстановитьСтроку(Граф);
	Построитель = Новый ПостроительDOM;
	DomГраф = Неопределено;
	Результат = Неопределено;
	
	// Если граф с ошибками, пропустить его
	Попытка
		DomГраф = Построитель.Прочитать(ЧтениеXmlГрафа);
	Исключение
		ОтладкаКлиентСервер.Результат("РазобратьГрафВзаимоблокировкиMSSQLГрафСОшибками", Граф);
		Возврат Неопределено;
	КонецПопытки;
	
	Результат = Анализ.ПолучитьШаблонОписанияВзаимоблокировки();
	Результат.Дата = ВремяВозникновения;
	Результат.ИнформационнаяБаза = ИсследуемаяИнформационнаяБаза;
	Результат.Граф = Граф;
	Результат.МоментВремени = МоментВремени;
	Результат.ТипБлокировки = Перечисления.ТипыБлокировок.БлокировкаСУБД;
	
	// Получить узел процессов
	Процессы = MSSQL.ПолучитьУзелПроцессов(DomГраф);
	
	// Получить таблицу идентификаторов процессов
	ИдентификаторыПроцессов = MSSQL.ПолучитьИдентификаторыПроцессов(DomГраф, Процессы);
	НомерПроцесса = 1;
	
	// Получить описание процессов
	Для Каждого ИдентификаторПроцесса Из ИдентификаторыПроцессов Цикл
		
		// Получить свойства процесса
		СвойстваПроцесса = MSSQL.ПолучитьСвойстваПроцесса(DomГраф, Процессы, ИдентификаторПроцесса.Процесс);
		СтрокаПроцесса = Результат.Процесс.Добавить();
		СтрокаПроцесса.Имя = ИдентификаторПроцесса.Процесс;
		СтрокаПроцесса.Номер = НомерПроцесса;
		
		Для Каждого СтрокаСвойства Из СвойстваПроцесса Цикл 
			СтрокаСвойствПроцесса = Результат.СвойствоПроцесса.Добавить();
			СтрокаСвойствПроцесса.НомерПроцесса = СтрокаПроцесса.Номер;
			СтрокаСвойствПроцесса.Свойство = СтрокаСвойства.Свойство;
			СтрокаСвойствПроцесса.Значение = СтрокаСвойства.Значение;
		КонецЦикла;
		
		// Получить запросы процессов
		СтрокаЗапросаПроцесса = Результат.ЗапросПроцесса.Добавить();
		СтрокаЗапросаПроцесса.НомерПроцесса = НомерПроцесса;
		ОригинальныйФрагмент = СокрЛП(MSSQL.ПолучитьЗапросПроцесса(DomГраф, Процессы, ИдентификаторПроцесса.Процесс));
		СтрокаЗапросаПроцесса.ФрагментЗапроса = "%" + ОригинальныйФрагмент + "%";
		СтрокаЗапросаПроцесса.ФрагментЗапросаМодифицированный = "%" + MSSQL.ПолучитьТекстЗапросаСПараметрамиВопросами(ОригинальныйФрагмент) + "%";
		СтрокаЗапросаПроцесса.ФрагментЗапросаГрафа = СтрЗаменить(СтрокаЗапросаПроцесса.ФрагментЗапроса, "'", "''");
		
		НомерПроцесса = НомерПроцесса + 1;
	КонецЦикла;
	
	// Получить узел ресурсов
	Ресурсы = MSSQL.ПолучитьУзелРесурсов(DomГраф);
	
	// Получить идентификаторы блокировок ресурсов
	ИдентификаторыБлокировокРесурсов = MSSQL.ПолучитьИдентификаторыБлокировокРесурсов(DomГраф, Ресурсы);
	НомерРесурса = 1;
	Виновники = Новый Массив;
	Жертвы = Новый Массив;
	
	// Получить описание блокировок ресурсов
	УзелБлокировки = Ресурсы.ПервыйДочерний;
	Пока УзелБлокировки <> Неопределено Цикл
		
		// Добавить описание ресурса
		ОписаниеБлокировкиРесурса = MSSQL.ПолучитьОписаниеБлокировкиРесурса(DomГраф, УзелБлокировки);
		
		// Если ресурс не от исследуемой базы, пропустить разбор графа
		Если ВРег(ОписаниеБлокировкиРесурса.ИмяБД) <> ВРег(ИмяБазыДанных) Тогда
			ОтладкаКлиентСервер.Результат("РазобратьГрафВзаимоблокировкиMSSQLИнородныйРесурс", Граф);
			Возврат Неопределено;
		КонецЕсли;
		
		// Добавить описание ресурса в терминах метаданных
		ОписаниеТаблицы = СтруктураМетаданных.ПолучитьОписаниеТаблицыМетаданных(СтруктураБазы, СтруктураМетаданных.ПолучитьКороткоеИмяТаблицы(ОписаниеБлокировкиРесурса.Имя));
		МетаИмяРесурса = ?(ОписаниеТаблицы = Неопределено, ОписаниеБлокировкиРесурса.Имя, ОписаниеТаблицы.ИмяТаблицы);
		МетаИдентификаторРесурса = "Ресурс " + НомерРесурса;
		НомерРесурса = НомерРесурса + 1;
		
		// Получить список ожидающих на блокировке
		ИдентификаторыОжидающихНаБлокировке = MSSQL.ПолучитьИдентификаторыОжидающихНаБлокировке(DomГраф, УзелБлокировки);
		
		Для Каждого ИдентификаторОжидающегоНаБлокировке Из ИдентификаторыОжидающихНаБлокировке Цикл
			
			// Добавить описание ожидающего на блокировке
			ОписаниеОжидающегоНаБлокировке = MSSQL.ПолучитьОписаниеОжидающегоНаБлокировке(DomГраф, УзелБлокировки, ИдентификаторОжидающегоНаБлокировке);
			
			СтрокаБлокировок = Результат.Блокировки.Добавить();
			Жертвы.Добавить(СтрокаБлокировок);
			ОписаниеПроцесса = Результат.Процесс.Найти(ИдентификаторОжидающегоНаБлокировке, "Имя");
			СтрокаБлокировок.Процесс = ОписаниеПроцесса.Номер;
			Блокировка = Анализ.СоздатьОписаниеБлокировки();
			СтрокаБлокировок.Блокировка = Блокировка;
			СтрокаБлокировок.Временная = Ложь;
			
			Блокировка.НачалоВыполненияЗапроса = MSSQL.ВремяMSSQLВТики(НайтиСвойствоПроцесса(ОписаниеПроцесса.Номер, "lastbatchstarted", Результат.СвойствоПроцесса));
			Блокировка.ИдентификаторПроцессаСУБД = НайтиСвойствоПроцесса(ОписаниеПроцесса.Номер, "spid", Результат.СвойствоПроцесса);
			
			Блокировка.Ресурс = СтруктураДанных.ПолучитьСтруктуруРесурса(
				МетаИмяРесурса, 
				ОписаниеБлокировкиРесурса.Имя, 
				ОписаниеБлокировкиРесурса.Индекс);
			Блокировка.ИдентификаторРесурса = ОписаниеБлокировкиРесурса.Идентификатор;
			Блокировка.Состояние = ОписаниеОжидающегоНаБлокировке.СостояниеБлокировки;
			Блокировка.Режим = ОписаниеОжидающегоНаБлокировке.РежимБлокировки;
			Блокировка.Гранулярность = ОписаниеБлокировкиРесурса.Гранулярность;
			Блокировка.ТипВыполнения = Перечисления.ТипыВыполненийКода.УстановкаБлокировки;
			
		КонецЦикла;
		
		// Получить список владельцев блокировки
		ИдентификаторыВладельцевБлокировки = MSSQL.ПолучитьИдентификаторыВладельцевБлокировки(DomГраф, УзелБлокировки);
		
		Для Каждого ИдентификаторВладельцаБлокировки Из ИдентификаторыВладельцевБлокировки Цикл
			
			// Добавить описание владельца блокировки
			ОписаниеВладельцаБлокировки = MSSQL.ПолучитьОписаниеВладельцаБлокировки(DomГраф, УзелБлокировки, ИдентификаторВладельцаБлокировки);
			
			СтрокаБлокировок = Результат.Блокировки.Добавить();
			Виновники.Добавить(СтрокаБлокировок);
			СтрокаБлокировок.Процесс = Результат.Процесс.Найти(ИдентификаторВладельцаБлокировки, "Имя").Номер;
			Блокировка = Анализ.СоздатьОписаниеБлокировки();
			СтрокаБлокировок.Блокировка = Блокировка;
			СтрокаБлокировок.Временная = Истина;
			
			Блокировка.Ресурс = СтруктураДанных.ПолучитьСтруктуруРесурса(
				МетаИмяРесурса, 
				ОписаниеБлокировкиРесурса.Имя, 
				ОписаниеБлокировкиРесурса.Индекс);
			Блокировка.ИдентификаторРесурса = ОписаниеБлокировкиРесурса.Идентификатор;
			Блокировка.Состояние = ОписаниеВладельцаБлокировки.СостояниеБлокировки;
			Блокировка.Режим = ОписаниеВладельцаБлокировки.РежимБлокировки;
			Блокировка.Гранулярность = ОписаниеБлокировкиРесурса.Гранулярность;
			Блокировка.ТипВыполнения = Перечисления.ТипыВыполненийКода.УстановкаБлокировки;
			
		КонецЦикла;
		
		УзелБлокировки = УзелБлокировки.СледующийСоседний;
	КонецЦикла;
	
	// Определить DBPID виновника для жертвы
	Для Каждого СтрокаЖертвы Из Жертвы Цикл
		БлокировкаЖертвы = СтрокаЖертвы.Блокировка;
		ВиновникНайден = Ложь;
		
		// Поиск виновника среди владельцев ресурса
		Для Каждого СтрокаВиновника Из Виновники Цикл
			БлокировкаВиновника = СтрокаВиновника.Блокировка;
			
			Если СтрокаВиновника.Процесс <> СтрокаЖертвы.Процесс Тогда
				Если СУБД.БлокировкиСовместимы(ТаблицаСовместимостиБлокировок, ТипСУБД, БлокировкаВиновника.Режим, БлокировкаЖертвы.Режим) = Перечисления.ВидыСовместимостиБлокировок.Несовместима Тогда
					БлокировкаЖертвы.БлокирующийПроцесс = НайтиСвойствоПроцесса(СтрокаВиновника.Процесс, "spid", Результат.СвойствоПроцесса);
					ВиновникНайден = Истина;
					Прервать;
				КонецЕсли;
			КонецЕсли;
		КонецЦикла;
		
		// Поиск виновника среди ожидающих ресурс
		Если Не ВиновникНайден Тогда
			Для Каждого СтрокаВиновникаЖертвы Из Жертвы Цикл
				БлокировкаВиновника = СтрокаВиновникаЖертвы.Блокировка;
				
				Если СтрокаВиновникаЖертвы.Процесс <> СтрокаЖертвы.Процесс Тогда
					Если СУБД.БлокировкиСовместимы(ТипСУБД, БлокировкаВиновника.Режим, БлокировкаЖертвы.Режим) = Перечисления.ВидыСовместимостиБлокировок.Несовместима Тогда
						БлокировкаЖертвы.БлокирующийПроцесс = НайтиСвойствоПроцесса(СтрокаВиновникаЖертвы.Процесс, "spid", Результат.СвойствоПроцесса);
						Прервать;
					КонецЕсли;
				КонецЕсли;
			КонецЦикла;
		КонецЕсли;
	КонецЦикла;
	
	ОтладкаКлиентСервер.Результат("РазобратьГрафВзаимоблокировкиMSSQL");
	
	Возврат Результат;
	
КонецФункции // РазобратьГрафВзаимоблокировкиMSSQL()

// Дополнить анализ графа взаимоблокировки результатами анализа
// технологического журнала
//
// Параметры:
//  Результаты - Массив, структуры описывающие блокировки
//  ТипСУБД - Перечисление.ТипСУБД, тип СУБД исследуемой базы
//
Процедура ПроанализироватьТехнологическийЖурнал(Результаты, ТипСУБД, ДокументЗамер, ТаблицаСовместимостиБлокировок)
	
	Перем Блокировки;
	
	ОтладкаКлиентСервер.Действие("ПроанализироватьТехнологическийЖурналДляВзаимоблокировок");
	
	ТехнологическийЖурнал.ОчиститьИсходныеДанныеДляАнализа(ДокументЗамер);
	
	ИсходныеДанные = Новый ТаблицаЗначений;
	ИсходныеДанные.Колонки.Добавить("МоментВремениЖертвы", Новый ОписаниеТипов("Число", Новый КвалификаторыЧисла(20, 0)));
	ИсходныеДанные.Колонки.Добавить("СоединениеЖертвы", Новый ОписаниеТипов("Число", Новый КвалификаторыЧисла(10, 0)));
	ИсходныеДанные.Колонки.Добавить("НомерВзаимоблокировки", Новый ОписаниеТипов("Число", Новый КвалификаторыЧисла(10, 0)));
	ИсходныеДанные.Колонки.Добавить("НомерБлокировки", Новый ОписаниеТипов("Число", Новый КвалификаторыЧисла(10, 0)));
	ИсходныеДанные.Колонки.Добавить("БлокирующийПроцесс", Новый ОписаниеТипов("Число", Новый КвалификаторыЧисла(10, 0)));
	ИсходныеДанные.Колонки.Добавить("ФрагментЗапроса", Новый ОписаниеТипов("Строка"));
	ИсходныеДанные.Колонки.Добавить("ФрагментЗапросаМодифицированный", Новый ОписаниеТипов("Строка"));
	ИсходныеДанные.Колонки.Добавить("ФрагментЗапросаГрафа", Новый ОписаниеТипов("Строка"));
	ИсходныеДанные.Колонки.Добавить("Длительность", Новый ОписаниеТипов("Число", Новый КвалификаторыЧисла(10, 0)));
	НомерВзаимоблокировки = 0;
	
	// Подготовка исходных данных
	Для Каждого РезультатРазбора Из Результаты Цикл
		
		Блокировки = РезультатРазбора.Блокировки;
		ЗапросПроцесса = РезультатРазбора.ЗапросПроцесса;
		НомерБлокировки = 0;
		
		Для Каждого СтрокаБлокировки Из Блокировки Цикл
			
			Блокировка = СтрокаБлокировки.Блокировка;
			
			Если Блокировка.Состояние <> Перечисления.СостоянияБлокировок.Установлена Тогда
				
				СтрокаИсходныхДанных = ИсходныеДанные.Добавить();
				//СтрокаИсходныхДанных.МоментВремениЖертвы = Блокировка.НачалоВыполненияЗапроса;
				//Приводим к моменту времени на сервере 1С:Предприятия (в случае если время сервера 1С:Предприятия и СУБД не совпадают
				СтрокаИсходныхДанных.МоментВремениЖертвы = Блокировка.НачалоВыполненияЗапроса + (ДокументЗамер.Дата-ДокументЗамер.ДатаНаСервереСУБД) * 10000000;
				СтрокаИсходныхДанных.СоединениеЖертвы = Блокировка.ИдентификаторПроцессаСУБД;
				СтрокаИсходныхДанных.НомерВзаимоблокировки = НомерВзаимоблокировки;
				СтрокаИсходныхДанных.НомерБлокировки = НомерБлокировки;
				СтрокаИсходныхДанных.БлокирующийПроцесс = Блокировка.БлокирующийПроцесс;
				СтрокаИсходныхДанных.ФрагментЗапроса = НайтиЗапросПроцесса(СтрокаБлокировки.Процесс, ЗапросПроцесса);
				СтрокаИсходныхДанных.ФрагментЗапросаМодифицированный = НайтиМодифицированныйЗапросПроцесса(СтрокаБлокировки.Процесс, ЗапросПроцесса);
				СтрокаИсходныхДанных.ФрагментЗапросаГрафа = НайтиЗапросГрафаПроцесса(СтрокаБлокировки.Процесс, ЗапросПроцесса);
				
				Отбор = Новый Структура;
				Отбор.Вставить("НомерПроцесса", СтрокаБлокировки.Процесс);
				Отбор.Вставить("Свойство", "waittime");
				НайденыеСтроки = РезультатРазбора.СвойствоПроцесса.НайтиСтроки(Отбор);
				СтрокаИсходныхДанных.Длительность = ?(НайденыеСтроки.Количество() = 0, 0, Число(НайденыеСтроки[0].Значение));
			КонецЕсли;
			
			НомерБлокировки = НомерБлокировки + 1;
			
		КонецЦикла;
		
		РезультатРазбора.НомерВзаимоблокировки = НомерВзаимоблокировки;
		НомерВзаимоблокировки = НомерВзаимоблокировки + 1;
		
	КонецЦикла;
	
	// Подготовить таблицу для получения точных соответствий запросов графа и ТЖ
	Запрос = Новый Запрос;
	Запрос.МенеджерВременныхТаблиц = Новый МенеджерВременныхТаблиц;
	Запрос.Текст = "
		|ВЫБРАТЬ
		|	Таблица.МоментВремениЖертвы КАК МоментВремениЖертвы,
		|	Таблица.СоединениеЖертвы КАК СоединениеЖертвы,
		|	Таблица.НомерВзаимоблокировки КАК НомерВзаимоблокировки,
		|	Таблица.НомерБлокировки КАК НомерБлокировки,
		|	Таблица.БлокирующийПроцесс КАК БлокирующийПроцесс,
		|	Таблица.Длительность КАК Длительность,
		|	Таблица.ФрагментЗапроса КАК ФрагментЗапроса,
		|	Таблица.ФрагментЗапросаМодифицированный КАК ФрагментЗапросаМодифицированный,
		|	Таблица.ФрагментЗапросаГрафа КАК ФрагментЗапросаГрафа
		|
		|ПОМЕСТИТЬ ИсходныеДанные
		|
		|ИЗ
		|	&Таблица КАК Таблица
		|
		|ИНДЕКСИРОВАТЬ ПО
		|	МоментВремениЖертвы,
		|	СоединениеЖертвы,
		|	НомерВзаимоблокировки,
		|	НомерБлокировки";
	Запрос.УстановитьПараметр("Таблица", ИсходныеДанные);
	Запрос.УстановитьПараметр("ДокументЗамер", ДокументЗамер);
	Запрос.УстановитьПараметр("Период", ДокументЗамер.Дата);
	Запрос.Выполнить();
	
	Запрос.УстановитьПараметр("СобытиеСУБД", ТехнологическийЖурнал.ПолучитьИмяСобытияСУБД(ТипСУБД));
	
	// Найти точные соответствия запросов графов и ТЖ
	Запрос.Текст = "
		|ВЫБРАТЬ
		|	РезультатПоискаСоответствий.МоментВремениЖертвы КАК МоментВремениЖертвы,
		|	РезультатПоискаСоответствий.НомерВзаимоблокировки КАК НомерВзаимоблокировки,
		|	РезультатПоискаСоответствий.НомерБлокировки КАК НомерБлокировки,
		|	РезультатПоискаСоответствий.СоединениеЖертвы КАК dbpidЖертвы,
		|	ТехнологическийЖурнал.connectID КАК СоединениеЖертвы,
		|	РезультатПоискаСоответствий.БлокирующийПроцесс КАК БлокирующийПроцесс
		|ПОМЕСТИТЬ
		|	СоответствияЗапросов
		|ИЗ
		|	(ВЫБРАТЬ
		|		ВЫБОР
		|			КОГДА Предыдущие.Количество > 0
		|				ТОГДА МАКСИМУМ(ТехнологическийЖурнал.МоментВремени)
		|			ИНАЧЕ Null
		|		КОНЕЦ КАК МоментВремениЖертвы,
		|		ТехнологическийЖурнал.dbpid КАК СоединениеЖертвы,
		|		ИсходныеДанные.НомерВзаимоблокировки,
		|		ИсходныеДанные.НомерБлокировки,
		|		ИсходныеДанные.БлокирующийПроцесс КАК БлокирующийПроцесс
		|
		|	ИЗ
		|		ИсходныеДанные
		|			ЛЕВОЕ СОЕДИНЕНИЕ (
		|				ВЫБРАТЬ
		|					ИсходныеДанные.МоментВремениЖертвы КАК МоментВремениЖертвы,
		|					ИсходныеДанные.СоединениеЖертвы КАК СоединениеЖертвы,
		|					ИсходныеДанные.НомерВзаимоблокировки КАК НомерВзаимоблокировки,
		|					ИсходныеДанные.НомерБлокировки КАК НомерБлокировки,
		|					КОЛИЧЕСТВО(ТехнологическийЖурнал.МоментВремени) КАК Количество
		|				ИЗ
		|					ИсходныеДанные
		|						ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.ТехнологическийЖурнал КАК ТехнологическийЖурнал
		|						ПО ИсходныеДанные.МоментВремениЖертвы + ИсходныеДанные.Длительность * 10000 >= ТехнологическийЖурнал.МоментВремени - ТехнологическийЖурнал.Продолжительность * 10
		|							И ИсходныеДанные.МоментВремениЖертвы <= ТехнологическийЖурнал.МоментВремени
		|							И ИсходныеДанные.СоединениеЖертвы = ТехнологическийЖурнал.dbpid
		|							И ТехнологическийЖурнал.Регистратор = &ДокументЗамер
		|							И ТехнологическийЖурнал.Период = &Период
		|				СГРУППИРОВАТЬ ПО
		|					ИсходныеДанные.МоментВремениЖертвы,
		|					ИсходныеДанные.СоединениеЖертвы,
		|					ИсходныеДанные.НомерВзаимоблокировки,
		|					ИсходныеДанные.НомерБлокировки
		|				) КАК Предыдущие
		|			ПО ИсходныеДанные.МоментВремениЖертвы = Предыдущие.МоментВремениЖертвы
		|				И ИсходныеДанные.СоединениеЖертвы = Предыдущие.СоединениеЖертвы
		|				И ИсходныеДанные.НомерВзаимоблокировки = Предыдущие.НомерВзаимоблокировки
		|				И ИсходныеДанные.НомерБлокировки = Предыдущие.НомерБлокировки
		|			
		|			ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.ТехнологическийЖурнал КАК ТехнологическийЖурнал
		|			ПО ИсходныеДанные.СоединениеЖертвы = ТехнологическийЖурнал.dbpid
		|				И ИсходныеДанные.МоментВремениЖертвы + ИсходныеДанные.Длительность * 10000 >= ТехнологическийЖурнал.МоментВремени - ТехнологическийЖурнал.Продолжительность * 10
		|				И ИсходныеДанные.МоментВремениЖертвы <= ТехнологическийЖурнал.МоментВремени
		|				И ТехнологическийЖурнал.Событие = &СобытиеСУБД
		|				И ТехнологическийЖурнал.Период = &Период
		|				И ТехнологическийЖурнал.Регистратор = &ДокументЗамер
		|				И (ТехнологическийЖурнал.Sql ПОДОБНО ИсходныеДанные.ФрагментЗапроса
		|					ИЛИ ТехнологическийЖурнал.Sql ПОДОБНО ИсходныеДанные.ФрагментЗапросаМодифицированный
		|					ИЛИ ТехнологическийЖурнал.Sql ПОДОБНО ИсходныеДанные.ФрагментЗапросаГрафа)
		|
		|	СГРУППИРОВАТЬ ПО
		|		ТехнологическийЖурнал.dbpid,
		|		ИсходныеДанные.НомерВзаимоблокировки,
		|		ИсходныеДанные.НомерБлокировки,
		|		Предыдущие.Количество,
		|		БлокирующийПроцесс) КАК РезультатПоискаСоответствий
		|		
		|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.ТехнологическийЖурнал КАК ТехнологическийЖурнал
		|		ПО ТехнологическийЖурнал.МоментВремени = РезультатПоискаСоответствий.МоментВремениЖертвы
		|			И ТехнологическийЖурнал.dbpid = РезультатПоискаСоответствий.СоединениеЖертвы
		|			И ТехнологическийЖурнал.Период = &Период
		|			И ТехнологическийЖурнал.Регистратор = &ДокументЗамер";
		
	УточненныеИсходныеДанные = Запрос.Выполнить();
	
	Запрос.Текст = "
		|ВЫБРАТЬ
		|	Соответствия.МоментВремениЖертвы КАК МоментВремениЖертвы,
		|	Соответствия.НомерВзаимоблокировки КАК НомерВзаимоблокировки,
		|	Соответствия.НомерБлокировки КАК НомерБлокировки,
		|	Соответствия.СоединениеЖертвы КАК СоединениеЖертвы,
		|	Поиск.СоединениеЖертвы КАК БлокирующийПроцесс
		|ИЗ
		|	СоответствияЗапросов КАК Соответствия
		|		ЛЕВОЕ СОЕДИНЕНИЕ СоответствияЗапросов КАК Поиск ПО
		|			Соответствия.НомерВзаимоблокировки = Поиск.НомерВзаимоблокировки И
		|			Соответствия.БлокирующийПроцесс = Поиск.dbpidЖертвы";
	
	УточненныеИсходныеДанные = Запрос.Выполнить().Выбрать();
	
	НаборЗаписейИсточника = РегистрыСведений.ИсточникиАнализаТЖ.СоздатьНаборЗаписей();
	НаборЗаписейИсточника.Отбор.Регистратор.Установить(ДокументЗамер);
	НаборЗаписейРесурса = РегистрыСведений.РесурсыАнализаТЖ.СоздатьНаборЗаписей();
	НаборЗаписейРесурса.Отбор.Регистратор.Установить(ДокументЗамер);
	
	КоличествоНезаполненныхВзаимоблокировок = 0;
	
	// Поиск незаполненных взаимоблокировок
	Пока УточненныеИсходныеДанные.Следующий() Цикл
		
		// Если найдена незаполненная взаимоблокировка
		Если УточненныеИсходныеДанные.МоментВремениЖертвы = Null Тогда
			Результаты[УточненныеИсходныеДанные.НомерВзаимоблокировки].НедостаточноДанных = Истина;
			КоличествоНезаполненныхВзаимоблокировок = КоличествоНезаполненныхВзаимоблокировок + 1;
			Продолжить;
		КонецЕсли;
		
	КонецЦикла;
	
	УточненныеИсходныеДанные.Сбросить();
	
	// Подготовка исходных данных для анализа
	Пока УточненныеИсходныеДанные.Следующий() Цикл
		
		// Если найдена незаполненная взаимоблокировка
		Если Результаты[УточненныеИсходныеДанные.НомерВзаимоблокировки].НедостаточноДанных Тогда
			Продолжить;
		КонецЕсли;
		
		Источник = НаборЗаписейИсточника.Добавить();
		Источник.Период = ДокументЗамер.Дата;
		Источник.МоментВремениЖертвы = УточненныеИсходныеДанные.МоментВремениЖертвы;
		Источник.СоединениеЖертвы = УточненныеИсходныеДанные.СоединениеЖертвы;
		Источник.НомерВзаимоблокировки = УточненныеИсходныеДанные.НомерВзаимоблокировки;
		Источник.НомерБлокировки = УточненныеИсходныеДанные.НомерБлокировки;
		Источник.БлокирующийПроцесс = УточненныеИсходныеДанные.БлокирующийПроцесс;
		Источник.Владелец = ДокументЗамер;
		
		ОписаниеБлокировки = Результаты[УточненныеИсходныеДанные.НомерВзаимоблокировки].Блокировки[УточненныеИсходныеДанные.НомерБлокировки].Блокировка;
		
		Ресурс = НаборЗаписейРесурса.Добавить();
		Ресурс.Период = ДокументЗамер.Дата;
		Ресурс.МоментВремениЖертвы = УточненныеИсходныеДанные.МоментВремениЖертвы;
		Ресурс.СоединениеЖертвы = УточненныеИсходныеДанные.СоединениеЖертвы;
		Ресурс.ИмяРесурса = ОписаниеБлокировки.Ресурс.Таблица;
		Ресурс.НомерВзаимоблокировки = УточненныеИсходныеДанные.НомерВзаимоблокировки;
		Ресурс.НомерБлокировки = УточненныеИсходныеДанные.НомерБлокировки;
		Ресурс.Владелец = ДокументЗамер;
		
	КонецЦикла;
	
	НачатьТранзакцию();
	Блокировка = Новый БлокировкаДанных;
	СтрокаБлокировки = Блокировка.Добавить("РегистрСведений.ИсточникиАнализаТЖ");
	СтрокаБлокировки.УстановитьЗначение("Владелец", ДокументЗамер);
	СтрокаБлокировки.Режим = РежимБлокировкиДанных.Исключительный;
	СтрокаБлокировки = Блокировка.Добавить("РегистрСведений.РесурсыАнализаТЖ");
	СтрокаБлокировки.УстановитьЗначение("Владелец", ДокументЗамер);
	СтрокаБлокировки.Режим = РежимБлокировкиДанных.Исключительный;
	//Блокировка.Заблокировать();
	
	НаборЗаписейИсточника.Записать();
	НаборЗаписейРесурса.Записать();
	
	ЗафиксироватьТранзакцию();
	
	// Анализ
	РезультатАнализа = ТехнологическийЖурнал.ПроанализироватьОжиданияДляВзаимоблокировок(ТипСУБД, ДокументЗамер);
	ВыборкаПоВзаимоблокировке = РезультатАнализа.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
	
	Пока ВыборкаПоВзаимоблокировке.Следующий() Цикл
		
		ВыборкаПоБлокировке = ВыборкаПоВзаимоблокировке.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
		Взаимоблокировка = Результаты[ВыборкаПоВзаимоблокировке.НомерВзаимоблокировки];
		Блокировки = Взаимоблокировка.Блокировки;
		НастоящееКоличествоЖертв = 0;
		
		Для Каждого СтрокаБлокировки Из Блокировки Цикл
			Если СтрокаБлокировки.Блокировка.Состояние <> Перечисления.СостоянияБлокировок.Установлена Тогда
				НастоящееКоличествоЖертв = НастоящееКоличествоЖертв + 1;
			КонецЕсли;
		КонецЦикла;
		
		ПроцессыЖертв = Новый Соответствие;
		НомераБлокировокЖертв = Новый Соответствие;
		
		Пока ВыборкаПоБлокировке.Следующий() Цикл
			НомераБлокировокЖертв.Вставить(ВыборкаПоБлокировке.НомерБлокировки);
			
			СтрокаЖертвы = Блокировки[ВыборкаПоБлокировке.НомерБлокировки];
			Если СтрокаЖертвы.Блокировка.Состояние <> Перечисления.СостоянияБлокировок.Установлена Тогда
				ПроцессыЖертв.Вставить(ВыборкаПоБлокировке.СоединениеЖертвы, СтрокаЖертвы.Процесс);
			КонецЕсли;
		КонецЦикла;
		
		ВыборкаПоБлокировке.Сбросить();
		
		Если НастоящееКоличествоЖертв <> НомераБлокировокЖертв.Количество() Тогда
			Взаимоблокировка.НедостаточноДанных = Истина;
			КоличествоНезаполненныхВзаимоблокировок = КоличествоНезаполненныхВзаимоблокировок + 1;
			Продолжить;
		КонецЕсли;
		
		Владельцы = Новый Массив;
		Для Каждого СтрокаВладельца Из Блокировки Цикл
			Если СтрокаВладельца.Временная Тогда
				Если СтрокаВладельца.Блокировка.Состояние = Перечисления.СостоянияБлокировок.Установлена Тогда
					Владельцы.Добавить(СтрокаВладельца);
				КонецЕсли;
			КонецЕсли;
		КонецЦикла;
		
		// Сохранение результатов анализа
		Пока ВыборкаПоБлокировке.Следующий() Цикл
			
			// Жертва
			СтрокаЖертвы = Блокировки[ВыборкаПоБлокировке.НомерБлокировки];
			БлокировкаЖертвы = СтрокаЖертвы.Блокировка;
			БлокировкаЖертвы.Запрос = ВыборкаПоБлокировке.ЗапросЖертвы;
			БлокировкаЖертвы.План = ВыборкаПоБлокировке.ПланЖертвы;
			БлокировкаЖертвы.ТекстSdbl = Строка(ВыборкаПоБлокировке.SdblЗапросЖертвы) + Строка(ВыборкаПоБлокировке.SdblФункцияЖертвы) + Строка(ВыборкаПоБлокировке.SdblИмяТаблицыЖертвы);
			БлокировкаЖертвы.ВремяВыполненияМс = ВыборкаПоБлокировке.ПродолжительностьЖертвы / 1000;
			БлокировкаЖертвы.МоментВремениОкончания = ВыборкаПоБлокировке.МоментВремениЖертвы;
			БлокировкаЖертвы.ДатаВремяСобытия = ВыборкаПоБлокировке.ДатаВремяСобытияЖертвы;
			БлокировкаЖертвы.Компьютер = ВыборкаПоБлокировке.КомпьютерЖертвы;
			БлокировкаЖертвы.Пользователь = ВыборкаПоБлокировке.ИмяПользователяЖертвы;
			БлокировкаЖертвы.НомерСоединения = ВыборкаПоБлокировке.СоединениеЖертвы;
			БлокировкаЖертвы.КонтекстЗапроса = Строка(ВыборкаПоБлокировке.КонтекстКлиентаЖертвы) + Строка(ВыборкаПоБлокировке.КонтекстСервераЖертвы);
			
			// Виновник
			ПроцессВиновника = ПроцессыЖертв[ВыборкаПоБлокировке.СоединениеВиновника];
			Для Каждого СтрокаВладельца Из Владельцы Цикл
				БлокировкаВладельца = СтрокаВладельца.Блокировка;
				
				Если СтрокаВладельца.Процесс = ПроцессВиновника
				   И ВыборкаПоБлокировке.ИмяРесурса = БлокировкаВладельца.Ресурс.Таблица
				   И СУБД.БлокировкиСовместимы(ТаблицаСовместимостиБлокировок, ТипСУБД, БлокировкаВладельца.Режим, БлокировкаЖертвы.Режим) = Перечисления.ВидыСовместимостиБлокировок.Несовместима Тогда
						
					СтрокаБлокировкиПодозреваемого = Блокировки.Добавить();
					СтрокаБлокировкиПодозреваемого.Процесс = ПроцессВиновника;
					БлокировкаПодозреваемого = Анализ.СоздатьОписаниеБлокировки();
					СтрокаБлокировкиПодозреваемого.Блокировка = БлокировкаПодозреваемого;
					СтрокаБлокировкиПодозреваемого.Временная = Ложь;
					
					БлокировкаПодозреваемого.Ресурс = СтруктураДанных.ПолучитьСтруктуруРесурса(
						БлокировкаВладельца.Ресурс.ОбъектМетаданных,
						БлокировкаВладельца.Ресурс.Таблица,
						БлокировкаВладельца.Ресурс.Индекс);
					
					БлокировкаПодозреваемого.ИдентификаторРесурса = БлокировкаВладельца.ИдентификаторРесурса;
					БлокировкаПодозреваемого.Состояние = БлокировкаВладельца.Состояние;
					БлокировкаПодозреваемого.Режим = БлокировкаВладельца.Режим;
					БлокировкаПодозреваемого.Гранулярность = БлокировкаВладельца.Гранулярность;
					БлокировкаПодозреваемого.Запрос = ВыборкаПоБлокировке.ЗапросВиновника;
					БлокировкаПодозреваемого.План = ВыборкаПоБлокировке.ПланВиновника;
					БлокировкаПодозреваемого.ТекстSdbl = Строка(ВыборкаПоБлокировке.SdblЗапросВиновника) + Строка(ВыборкаПоБлокировке.SdblФункцияВиновника) + Строка(ВыборкаПоБлокировке.SdblИмяТаблицыВиновника);
					БлокировкаПодозреваемого.ВремяВыполненияМс = ВыборкаПоБлокировке.ПродолжительностьВиновника / 1000;
					БлокировкаПодозреваемого.МоментВремениОкончания = ВыборкаПоБлокировке.МоментВремениВиновника;
					БлокировкаПодозреваемого.ДатаВремяСобытия = ВыборкаПоБлокировке.ДатаВремяСобытияВиновника;
					БлокировкаПодозреваемого.Компьютер = ВыборкаПоБлокировке.КомпьютерВиновника;
					БлокировкаПодозреваемого.Пользователь = ВыборкаПоБлокировке.ИмяПользователяВиновника;
					БлокировкаПодозреваемого.НомерСоединения = ВыборкаПоБлокировке.СоединениеВиновника;
					БлокировкаПодозреваемого.КонтекстЗапроса = Строка(ВыборкаПоБлокировке.КонтекстКлиентаВиновника) + Строка(ВыборкаПоБлокировке.КонтекстСервераВиновника);
					БлокировкаПодозреваемого.ТипВыполнения = Перечисления.ТипыВыполненийКода.УстановкаБлокировки;
				КонецЕсли;
			КонецЦикла;
		КонецЦикла;
		
		// Удаление дубликатов
		Для Каждого СтрокаБлокировки Из Блокировки Цикл
			Блокировка = СтрокаБлокировки.Блокировка;
			
			Для Каждого СтрокаПроверяемойБлокировки Из Блокировки Цикл
				ПроверяемаяБлокировка = СтрокаПроверяемойБлокировки.Блокировка;
				
				Если Блокировка <> ПроверяемаяБлокировка
				   И Блокировка.МоментВремениОкончания <> Неопределено
				   И ПроверяемаяБлокировка.МоментВремениОкончания <> Неопределено
				   И ПроверяемаяБлокировка.Состояние = Перечисления.СостоянияБлокировок.Установлена
				   И Блокировка.НомерСоединения = ПроверяемаяБлокировка.НомерСоединения
				   И СтрокаБлокировки.Временная = Ложь Тогда
				
					Если Блокировка.Состояние <> Перечисления.СостоянияБлокировок.Установлена
					   И Блокировка.МоментВремениОкончания < ПроверяемаяБлокировка.МоментВремениОкончания Тогда
						СтрокаПроверяемойБлокировки.Временная = Истина;
					КонецЕсли;
					
					Если Блокировка.МоментВремениОкончания = ПроверяемаяБлокировка.МоментВремениОкончания Тогда
						СтрокаПроверяемойБлокировки.Временная = Истина;
					КонецЕсли;
				КонецЕсли;
			КонецЦикла;
		КонецЦикла;
		
		ПараметрыПоискаЛишнихБлокировок = Новый Структура;
		ПараметрыПоискаЛишнихБлокировок.Вставить("Временная", Истина);
		ВременныеБлокировки = Блокировки.НайтиСтроки(ПараметрыПоискаЛишнихБлокировок);
		
		Для Каждого ВременнаяБлокировка Из ВременныеБлокировки Цикл
			Блокировки.Удалить(ВременнаяБлокировка);
		КонецЦикла;
		
		Взаимоблокировка.Проанализирована = Истина;
		
	КонецЦикла;
	
	ОтладкаКлиентСервер.Результат("ПроанализироватьТехнологическийЖурналДляВзаимоблокировок",
	                  КоличествоНезаполненныхВзаимоблокировок);
	
КонецПроцедуры // ПроанализироватьТехнологическийЖурнал()

// Найти значение свойства процесса
//
// Прааметры:
//  Процесс - Строка, идентификатор процесса
//  ИмяСвойства - Строка, имя искомого свойства
//  ТаблицаСвойств - ТаблицаЗначений, свойства процессов
//
// Возвращаемое значение:
//  Строка - значение свойства
//
Функция НайтиСвойствоПроцесса(Процесс, ИмяСвойства, ТаблицаСвойств)
	
	ПараметрыПоиска = Новый Структура;
	ПараметрыПоиска.Вставить("НомерПроцесса", Процесс);
	ПараметрыПоиска.Вставить("Свойство", ИмяСвойства);
	Возврат ТаблицаСвойств.НайтиСтроки(ПараметрыПоиска)[0].Значение;
	
КонецФункции // НайтиСвойствоПроцесса()

// Найти фрагмент запроса процесса
//
// Прааметры:
//  Процесс - Строка, идентификатор процесса
//  ТаблицаЗапросов - ТаблицаЗначений, запросы процессов
//
// Возвращаемое значение:
//  Строка - значение свойства
//
Функция НайтиЗапросПроцесса(Процесс, ТаблицаЗапросов)
	
	ПараметрыПоиска = Новый Структура;
	ПараметрыПоиска.Вставить("НомерПроцесса", Процесс);
	Возврат ТаблицаЗапросов.НайтиСтроки(ПараметрыПоиска)[0].ФрагментЗапроса;
	
КонецФункции // НайтиЗапросПроцесса()

// Найти фрагмент запроса процесса с параметрами типа ?
//
// Прааметры:
//  Процесс - Строка, идентификатор процесса
//  ТаблицаЗапросов - ТаблицаЗначений, запросы процессов
//
// Возвращаемое значение:
//  Строка - значение свойства
//
Функция НайтиМодифицированныйЗапросПроцесса(Процесс, ТаблицаЗапросов)
	
	ПараметрыПоиска = Новый Структура;
	ПараметрыПоиска.Вставить("НомерПроцесса", Процесс);
	Возврат ТаблицаЗапросов.НайтиСтроки(ПараметрыПоиска)[0].ФрагментЗапросаМодифицированный;
	
КонецФункции // НайтиМодифицированныйЗапросПроцесса()

// Найти фрагмент запроса графа
//
// Прааметры:
//  Процесс - Строка, идентификатор процесса
//  ТаблицаЗапросов - ТаблицаЗначений, запросы процессов
//
// Возвращаемое значение:
//  Строка - значение свойства
//
Функция НайтиЗапросГрафаПроцесса(Процесс, ТаблицаЗапросов)
	
	ПараметрыПоиска = Новый Структура;
	ПараметрыПоиска.Вставить("НомерПроцесса", Процесс);
	Возврат ТаблицаЗапросов.НайтиСтроки(ПараметрыПоиска)[0].ФрагментЗапросаГрафа;
	
КонецФункции // НайтиЗапросГрафаПроцесса()
