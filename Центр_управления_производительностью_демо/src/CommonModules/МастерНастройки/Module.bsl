// Выполнить указанное действие в каждом рабочем процессе
//
// Параметры:
//  АгентСервера - IServerAgentConnection, соединение с центральным сервером
//  ОписаниеКластера - IClusterInfo, который следует проверить
//  Действие - Строка, имя функции, которую необходимо выполнить
//  Параметры - Массив, параметры выполняемой функции
//
Процедура ДляКаждогоРабочегоПроцесса(Действие, Параметры) Экспорт
	ОбщегоНазначения.ВыполнитьНаСервере(Действие, Параметры);
КонецПроцедуры // ДляКаждогоРабочегоПроцесса()

// Аутентифицироваться в укзанном кластере
//
// Параметры:
//  АдресСервера - Строка, соединения с агентом сервера
//  ПортКластера - Число, номер порта кластера
//  Администратор - Строка, имя администратора кластера
//  Пароль - Строка, пароль администратора кластера
//
Процедура АутентифицироватьсяВКластере(АдресСервера, ПортКластера, Администратор, Пароль) Экспорт
	
	ComСоединитель = ОбщегоНазначения.ПолучитьComСоединитель();
	АгентСервера = ИнформационнаяБаза.ПолучитьАгентаСервера(ComСоединитель, АдресСервера);
	Кластер = ИнформационнаяБаза.НайтиКластерПоПорту(АгентСервера, ПортКластера);
	АгентСервера.Authenticate(Кластер, Администратор, Пароль);
	
КонецПроцедуры // АутентифицироватьсяВКластере()

// Сформировать полный адрес сервера из его имени и порта
//
// Параметры:
//  ИмяСервера - Строка, имя сервера
//  Порт - Число, номер порта
//
// Возвращаемое значение:
//  Строка - полная строка соединения с сервером
//
Функция СформироватьАдресСервера(ИмяСервера, Порт) Экспорт
	
	Возврат ОбщегоНазначенияКлиентСервер.УдалитьКавычки(ИмяСервера) + ":" + Формат(Порт, "ЧН=0; ЧГ=0");
	
КонецФункции // СформироватьАдресСервера()

// Подключиться к центральному серверу
//
// Адрес - Строка, адрес центрального сервера
//
// Возвращаемое значение:
//  IServerAgentConnection - соединение с центральным сервером
//
Функция ПодключитьсяКЦентральномуСерверу(Адрес) Экспорт
	
	ComСоединитель = ОбщегоНазначения.ПолучитьComСоединитель();
	Возврат ИнформационнаяБаза.ПолучитьАгентаСервера(ComСоединитель, Адрес);
	
КонецФункции // ПодключитьсяКЦентральномуСерверу()

// Подключится к исследуемой информационной базе
//
// Параметры:
//  СтрокаСоединения - Строка соединения с информационной базой
//
Функция ПодключитьсяКИБ(СтрокаСоединения) Экспорт
	
	ComСоединитель = ОбщегоНазначения.ПолучитьComСоединитель();
	СоединениеИБ = Неопределено;
	Попытка
		СоединениеИБ = ComСоединитель.Connect(СтрокаСоединения);
	Исключение
		ОписаниеОшибки = ИнформацияОбОшибке().Описание;
		ВызватьИсключение "Возможные причины ошибки:
		                  |  - имя или пароль пользователя исследуемой информационной базы указаны неверно;
		                  |  - указанный пользователь не имеет права установки внешних соединений.
		                  |
		                  |Полние описание ошибки:
		                  |" + ОписаниеОшибки;
	КонецПопытки;
	
	//Если Не СоединениеИБ.ПравоДоступа("Администрирование", СоединениеИБ.Метаданные) Тогда
	//	ВызватьИсключение "У пользователя информационной базы нет административных прав";
	//КонецЕсли;
	
	Если Не СоединениеИБ.ПравоДоступа("ВнешнееСоединение", СоединениеИБ.Метаданные) Тогда
		ВызватьИсключение "У пользователя информационной базы нет права установки внешнего соединения";
	КонецЕсли;
	
	Возврат СоединениеИБ;
	
КонецФункции // ПодключитьсяКИБ()

// Проверить доступность технологического журнала
//
// Параметры:
//  НастройкиТЖ - ТаблицаЗначений, настройки ТЖ
//  НеПроверятьНастройки - Булево, Истина - если проверять настройки ТЖ не нужно
//
Процедура ПроверитьДоступностьТЖ(НастройкиТЖ, НеПроверятьНастройки = Ложь) Экспорт
	
	Для Каждого СтрокаНастройкиТЖ Из НастройкиТЖ Цикл
		Если Не НеПроверятьНастройки Тогда
			// Проверка файла настройки ТЖ
			Попытка
				ИмяФайлаНастройкиТЖ = ОбщегоНазначенияКлиентСервер.ПолучитьИмяФайлаНастройкиТЖ(СтрокаНастройкиТЖ.Конфигурация);
				ПроверитьДоступностьФайла(ИмяФайлаНастройкиТЖ);
			Исключение
				ОписаниеОшибки = "Возможные причины ошибки:
				                 |  - имя каталога, файла настройки технологического журнала, указано неверно;
				                 |  - нет прав на чтение и запись файла настройки технологического журнала;
				                 |
				                 |Полное описание ошибки:
				                 |"
				               + ИнформацияОбОшибке().Описание;
				ВызватьИсключение ОписаниеОшибки;
			КонецПопытки;
		КонецЕсли;
		
		// Проверка доступности сетевого каталога ТЖ
		Попытка
			ПроверитьДоступностьКаталога(СтрокаНастройкиТЖ.Сетевой);
		Исключение
			ОписаниеОшибки = "Возможные причины ошибки:
			                 |  - имя каталога технологического журнала указано неверно;
			                 |  - нет прав на чтение,запись или удаление для каталога технологического журнала;
			                 |
			                 |Полное описание ошибки:
			                 |"
			               + ИнформацияОбОшибке().Описание;
			ВызватьИсключение ОписаниеОшибки;
		КонецПопытки;
	КонецЦикла;
	
КонецПроцедуры // ПроверитьДоступностьТЖ()

// Проверить доступность указанного файла
// В случае неудачной проверки вызывается исключение
//
// Параметры:
//  ИмяФайла - Строка, имя проверяемого файла
//
Процедура ПроверитьДоступностьФайла(ИмяФайла)
	
	Файл = Новый Файл(ИмяФайла);
	Существует = Файл.Существует();
	
	Если Существует Тогда
		Чтение = Новый ЧтениеТекста(ИмяФайла);
		Чтение.Закрыть();
	КонецЕсли;
	
	Запись = Новый ЗаписьТекста(ИмяФайла,,, Истина);
	Запись.Закрыть();
	
	Если Не Существует Тогда
		УдалитьФайлы(ИмяФайла);
	КонецЕсли;
	
КонецПроцедуры // ПроверитьДоступностьФайла()

// Проверить доступность указанного каталога
// В случае неудачной проверки вызывается исключение
//
// Параметры:
//  ИмяКаталога - Строка, имя проверяемого каталога
//
Процедура ПроверитьДоступностьКаталога(ИмяКаталога)
	
	Файл = Новый Файл(ОбщегоНазначенияКлиентСервер.СкорректироватьПуть(ИмяКаталога));
	
	Если Не Файл.Существует() Тогда
		ВызватьИсключение "Указанный каталог """ + ИмяКаталога + """ не существует.";
	КонецЕсли;
	
	ВременныйКаталог = ИмяКаталога + "/" + Строка(Новый УникальныйИдентификатор);
	
	Попытка
		СоздатьКаталог(ВременныйКаталог);
	Исключение
		ВызватьИсключение "Указанный каталог """ + ИмяКаталога + """ недоступен для записи.";
	КонецПопытки;
	
	Попытка
		УдалитьФайлы(ВременныйКаталог);	
	Исключение
		ВызватьИсключение "Для указанного каталога """ + ИмяКаталога + """ нет прав на удаление.";
	КонецПопытки;
КонецПроцедуры // ПроверитьДоступностьКаталога()

// Проверить работоспособность трассировок SQL Server
//
// Параметры:
//  ПолноеИмяСервераСУБД - Строка, полное имя сервера СУБД
//  Каталог - Строка, имя каталога для сбора трассировок
//
Процедура ПроверитьТрассировки(ОписаниеИБ, ТипОССервераСУБД, КаталогЛокальный, КаталогСетевой = "", СобиратьИнформациюОГранулярности) Экспорт
	ВремяНаСервереMSSQL = MSSQL.ВремяНаСервере(ОписаниеИБ);
	ВремяНаКлиенте = ТекущаяДата();
	
	Трассировка = MSSQL.СоздатьТрассировку(ОписаниеИБ, ТипОССервераСУБД, КаталогЛокальный, КаталогСетевой);
	ИдентификаторыСобытий = MSSQL.ПолучитьИдентификаторыСобытий();
	MSSQL.ДобавитьСобытиеТрассировки(
		ИдентификаторыСобытий["Deadlock graph"],
		"SPID, StartTime, TextData, EventSequence",
		Трассировка);
	MSSQL.ОстановитьТрассировку(Трассировка);
	MSSQL.ВыключитьТрассировку(Трассировка);
	MSSQL.ПолучитьПорциюСобытий(0, 1, Трассировка);
	MSSQL.ОчиститьТрассировку(Трассировка, Истина);
	
	Если СобиратьИнформациюОГранулярности Тогда
		ИдентификаторОбъекта = MSSQLПовтИсп.ПолучитьИдентификаторОбъекта(ОписаниеИБ, "Config");
		Если Не ЗначениеЗаполнено(ИдентификаторОбъекта) Тогда
			ВызватьИсключение "Ошибка получения информации о структуре базы данных";
		КонецЕсли;
	КонецЕсли;
	
КонецПроцедуры // ПроверитьТрассировки()

// Проверить работоспособность произвольных показателей ОС
//
// Параметры:
//  ИБ - СправочникОбъект.ИнформационныеБазы - Объект, содержащий список счетчиков
//
Процедура ПроверитьПроизвольныеПоказателиОС(ИБ) Экспорт
	
	СчетчикиВК = КипВнешнийКомпонент.ПолучитьСчетчики();
	КипВнешнийКомпонент.ПодключитьСчетчики(СчетчикиВК);
	ВозможныеИменаСчетчиков = Новый Массив;
	
	СчетчикиАгентов = Новый Соответствие;
	
	Для Каждого ТекСтр Из ИБ.СчетчикиОС Цикл
		
		СтрокаСервера = ИБ.Серверы[ТекСтр.НомерСтрокиСервера-1];
		
		Если СтрокаСервера.СпособСбораСчетчиков = Перечисления.СпособыСбораСчетчиков.PDH Тогда
			Если Не ЗначениеЗаполнено(СтрокаСервера.ЯзыкОС) Тогда
				ТекСтр.Проверен = Ложь;
				ТекСтр.ОписаниеОшибки = "Не указан язык ОС для сервера " + СтрокаСервера.Сервер;
			Иначе
				Попытка
					ИменаСчетчиков = Справочники.СчетчикиПроизводительности.ПолучитьНаименованияСчетчиков(ТекСтр.Счетчик, СтрокаСервера.ЯзыкОС);
					Если ИменаСчетчиков.Количество() = 0 Тогда
						ТекСтр.Проверен = Ложь;
						ТекСтр.ОписаниеОшибки = "Не найдено имя счетчика для языка " + Строка(ТекСтр.ЯзыкОС);
					КонецЕсли;
					Для Каждого ТекИмя Из ИменаСчетчиков Цикл
						ВозможныеИменаСчетчиков.Добавить(ТекИмя.Значение);
					КонецЦикла;
					Индекс = КипWindows.ВключитьСборСчетчикаПроизводительности(СчетчикиВК, СтрокаСервера.Сервер, ВозможныеИменаСчетчиков, Строка(ТекСтр.Счетчик));
					Значение = КипВнешнийКомпонент.ЗначениеСчетчика(СчетчикиВК, Индекс);
					ТекСтр.Проверен = Истина;
					ТекСтр.ОписаниеОшибки = "";
				Исключение
					ТекСтр.Проверен = Ложь;
					ТекСтр.ОписаниеОшибки = ОписаниеОшибки();
				КонецПопытки;
			КонецЕсли;
		ИначеЕсли СтрокаСервера.СпособСбораСчетчиков = Перечисления.СпособыСбораСчетчиков.АгентЦКК Тогда
			ВерсияАгента = СтрокаСервера.АгентЦКК.Версия;
			СоставВерсии = ОбщегоНазначенияКлиентСервер.РазделитьСтроку(СтрокаСервера.АгентЦКК.Версия, ".");
			Если Не ЗначениеЗаполнено(СтрокаСервера.АгентЦКК) Тогда
				ТекСтр.Проверен = Ложь;
				ТекСтр.ОписаниеОшибки = "Не указан Агент ЦКК для сервера " + СтрокаСервера.Сервер;
			ИначеЕсли СоставВерсии.Количество() < 4
				Или Число(СоставВерсии[0]) = 1
					И Число(СоставВерсии[1]) = 0
					И Число(СоставВерсии[2]) < 9 Тогда
				ТекСтр.Проверен = Ложь;
				ТекСтр.ОписаниеОшибки = "Несовместимая версия агента у сервера " + СтрокаСервера.Сервер 
					+ " (" + ВерсияАгента + "). Поддерживаются версии Агента 1.0.9.1 или выше.";
			Иначе
				СчетчикиАгента = СчетчикиАгентов.Получить(СтрокаСервера.АгентЦКК);
				Если СчетчикиАгента = Неопределено Тогда
					СчетчикиАгента = Новый Массив;
				КонецЕсли;
				СчетчикДляПроверки = 
					Новый Структура("АгентЦКК,СчетчикПроизводительности,СтрокаНастройки",
						СтрокаСервера.АгентЦКК, ТекСтр.Счетчик, ТекСтр);
				СчетчикиАгента.Добавить(СчетчикДляПроверки);
				СчетчикиАгентов.Вставить(СтрокаСервера.АгентЦКК, СчетчикиАгента);
				ТекСтр.Проверен = Истина;
				ТекСтр.ОписаниеОшибки = "";
			КонецЕсли;
		Иначе
			ТекСтр.Проверен = Ложь;
			ТекСтр.ОписаниеОшибки = "Не указан способ сбора счетчиков для сервера " + СтрокаСервера.Сервер;
		КонецЕсли;
	КонецЦикла;
	
	КипВнешнийКомпонент.ОтключитьСчетчики(СчетчикиВК);
	
	// Проверка счетчиков Агентов ЦКК
	Для Каждого СчетчикиАгента Из СчетчикиАгентов Цикл
		ПроверитьПоказателиАгента(СчетчикиАгента.Ключ, СчетчикиАгента.Значение);
	КонецЦикла;
	
КонецПроцедуры // ПроверитьПроизвольныеПоказателиОС()

// <Описание функции>
//
// Параметры:
//  <Параметр1>  - <Тип.Вид> - <описание параметра>
//                 <продолжение описания параметра>
//  <Параметр2>  - <Тип.Вид> - <описание параметра>
//                 <продолжение описания параметра>
//
// Возвращаемое значение:
//   <Тип.Вид>   - <описание возвращаемого значения>
//
Функция ПроверитьПоказателиАгента(ТекАгент, СчетчикиАгента)
	
	СобираемыеСчетчики = Новый Массив;
	Для Каждого ТекСтр Из СчетчикиАгента Цикл
		СобираемыеСчетчики.Добавить(Строка(ТекСтр.СчетчикПроизводительности));
	КонецЦикла;
	
	// Включить счетчики и подождать, пока Агент отработает команду
	
	Справочники.АгентыЦКК.ВключитьСборСчетчиковПроизводительности(ТекАгент, СобираемыеСчетчики);
	АгентЦККОбъект = ТекАгент.ПолучитьОбъект();
	АгентЦККОбъект.ТестСбораСчетчиков = Истина;
	АгентЦККОбъект.Записать();
	
	Инструменты = КипВнешнийКомпонент.ПолучитьИнструменты();
	
	ВремяНачалаПроверки = ТекущаяДата();
	Выполнять = Истина;
	Пока ТекущаяДата() < ВремяНачалаПроверки + 20 Цикл
		ДанныеРегистра = РегистрыСведений.ТекущиеЗначенияПроизводительности.ПолучитьЗначения(ТекАгент, ВремяНачалаПроверки);
		Если ДанныеРегистра.Количество() > 0 Тогда
			Прервать;
		КонецЕсли;
		КипВнешнийКомпонент.Пауза(Инструменты, 1000);
	КонецЦикла;
	
	Для Каждого ТекСтр Из СчетчикиАгента Цикл
		ДанныеПоСчетчику = ДанныеРегистра.Получить(ТекСтр.СчетчикПроизводительности);
		Если ДанныеПоСчетчику = Неопределено 
			Или ТекущаяДата() - ДанныеПоСчетчику.ДатаЗамера > 60 Тогда
			ТекСтр.СтрокаНастройки.Проверен = Ложь;
			ТекСтр.СтрокаНастройки.ОписаниеОшибки = "Не удалось получить значение счетчика";
		Иначе
			ТекСтр.СтрокаНастройки.Проверен = Истина;
			ТекСтр.СтрокаНастройки.ОписаниеОшибки = "";
		КонецЕсли;
	КонецЦикла;
	
	Справочники.АгентыЦКК.ОтключитьСборСчетчиковПроизводительности(ТекАгент);
	
КонецФункции // ПроверитьПоказателиАгента()


// Проверить работоспособность COM-соединителя
//
Процедура ПроверитьCOMСоединитель(ЦентральныйСервер, ПортЦентральногоСервера) Экспорт
	
	Попытка
		МенеджерСоединений = ОбщегоНазначения.ПолучитьComСоединитель();
		СоединениеСЦентральнымСервером = МенеджерСоединений.ConnectAgent(СформироватьАдресСервера(
			ЦентральныйСервер, 
			ПортЦентральногоСервера
		));
	Исключение 
		ВызватьИсключение ПодробноеПредставлениеОшибки(ИнформацияОбОшибке());
	КонецПопытки;
	
КонецПроцедуры // ПроверитьCOMСоединитель()
