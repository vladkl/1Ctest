
#Область ПрограммныйИнтерфейс

// Функция знакомства агента ЦКК с ИБ.
//
Функция HandshakePOST(Запрос)
	
	Данные = ПолучитьДанные(Запрос.ПолучитьТелоКакСтроку());
	
	Если Данные["idAgent"] <> Неопределено Тогда
		УникальныйИдентификаторАгента = Новый УникальныйИдентификатор(Данные["idAgent"]);
	Иначе
		УникальныйИдентификаторАгента = Неопределено;
	КонецЕсли;
	
	ВерсияПакета = Данные["version"];
	Если ВерсияПакета = Неопределено Тогда
		ВерсияПакета = "1.0.0.1";
	КонецЕсли;
	
	Хост = Данные["computerInfo"]["host"];
	
	Если ОбщегоНазначения.ВерсияВЧисло(ВерсияПакета) < 1000000020000001 Тогда
		
		СтрокаПодключения = "host=" + Хост + ";version=" + ВерсияПакета + ";id=" + УникальныйИдентификаторАгента; 
		Сообщение = "Версии агента ниже 1.0.2.1 не поддерживаются!";
		ПодробноеОписание = "Версия агента не поддерживается. Хост: " + Хост + ", строкаПодключения: " + СтрокаПодключения;
		ОбщегоНазначенияВызовСервера.ЗаписатьВЖурнал(
			Сообщение,
			"Ошибка",
			ПодробноеОписание);
		
		Ответ = Новый HTTPСервисОтвет(406);
		Ответ.УстановитьТелоИзСтроки("QMC message. Version agent " + ВерсияПакета + " is not supported.");
		
		Возврат Ответ;
		
	КонецЕсли;
	
	Если УникальныйИдентификаторАгента = Неопределено Тогда
		
		СтрокаПодключения = "host=" + Хост + ";version=" + ВерсияПакета; 
		Сообщение = "Не получен ID агента. " + Данные["ERROR_DESCRIPTION"];
		ПодробноеОписание = "Ошибка инициализации. Хост: " + Хост + ", строка подключения: " + СтрокаПодключения;
		ОбщегоНазначенияВызовСервера.ЗаписатьВЖурнал(
			Сообщение,
			"Ошибка",
			ПодробноеОписание);
		
		Ответ = Новый HTTPСервисОтвет(406);
		Ответ.УстановитьТелоИзСтроки("QMC message. No agent ID specified.");
		
		Возврат Ответ;
		
	КонецЕсли;
	
	АгентЦКК = Справочники.АгентыЦКК.СоздатьЭлементПоУникальномуИдентификатору(УникальныйИдентификаторАгента, Хост, ВерсияПакета);
	Если АгентЦКК.Хост <> Хост Тогда
		
		Сообщение = "Ошибка привязки агента" + Данные["idAgent"];
		СтрокаПодключения = "host=" + Хост + ";version=" + ВерсияПакета + ";id=" + Данные["idAgent"]; 
		ПодробноеОписание = "Агент  " + Данные["idAgent"] + " запущен на другом хосте '" + Хост + "'.
		|Для корректной работы установите агенту новый хост запуска. Строка подключения: " + СтрокаПодключения;
		
		ОбщегоНазначенияВызовСервера.ЗаписатьВЖурнал(
		Сообщение,
		"Ошибка",
		ПодробноеОписание);
		
		Ответ = Новый HTTPСервисОтвет(406);
		Ответ.УстановитьТелоИзСтроки("QMC message. Equipment and agent have different hosts.");
		
		Возврат Ответ;
		
	КонецЕсли;
	
	ДанныеОтвета = Новый Соответствие;
	ДанныеОтвета.Вставить("ServicesData", Новый Соответствие);
	
	ServicesData = ДанныеОтвета["ServicesData"];
	
	СобиратьСчетчики = РегистрыСведений.СостояниеСбораПоказателей.ВключенСборСчетчиков(АгентЦКК);
	СобираемыеСчетчики = Справочники.ИнформационныеБазы.ПолучитьСчетчикиАгента(АгентЦКК);
	
	ПараметрыМонитораПроизводительности = Новый Соответствие;
	ПараметрыМонитораПроизводительности.Вставить("enable", СобиратьСчетчики);
	ПараметрыМонитораПроизводительности.Вставить("counters", СобираемыеСчетчики);
	
	ServicesData.Вставить("PERFORMANCE_MONITOR", ПараметрыМонитораПроизводительности);
	
	Ответ = Новый HTTPСервисОтвет(200);
	Ответ.УстановитьТелоИзСтроки(СформироватьДанныеДляОтправки(ДанныеОтвета));
	
	Возврат Ответ;
	
КонецФункции

// Функция обработки данных от агента ЦКК.
//
Функция InputDataPOST(Запрос)
	
	ВремяНачала = ОценкаПроизводительности.НачатьЗамерВремени();
	
	Данные = ПолучитьДанные(Запрос.ПолучитьТелоКакСтроку());
	
	УникальныйИдентификаторАгента = Новый УникальныйИдентификатор(Данные["idAgent"]);
	
	НачатьТранзакцию();
	
	Попытка
		
		БлокировкаДанных = Новый БлокировкаДанных;
		ЭлементБлокировки = БлокировкаДанных.Добавить("РегистрСведений.ОбъектыБлокировок");
		ЭлементБлокировки.Режим = РежимБлокировкиДанных.Исключительный;
		ЭлементБлокировки.УстановитьЗначение("Объект",Данные["idAgent"]);
		БлокировкаДанных.Заблокировать();
		
		Ответ = ОбработатьДанныеАгентаЦКК(УникальныйИдентификаторАгента, Данные);
		
		ЗафиксироватьТранзакцию();
		
	Исключение
		
		ОтменитьТранзакцию();
		Ответ = Новый HTTPСервисОтвет(500);
		Инфо = ИнформацияОбОшибке();
		ОписаниеОшибки = "{" + Инфо.ИмяМодуля + "(" + Инфо.НомерСтроки + ")}: " + СокрЛП(Инфо.Описание);
		
		Ответ.УстановитьТелоИзСтроки(ОписаниеОшибки);
		
	КонецПопытки;
	
	ДопПараметры = Новый Соответствие;
	ДопПараметры.Вставить("Объект ЦКК", Данные["idAgent"]);
	ОценкаПроизводительности.ЗакончитьЗамерВремени("AgentQMC.InputDataPOST", ВремяНачала);
	
	Возврат Ответ;
	
КонецФункции

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Функция ОбработатьДанныеАгентаЦКК(УникальныйИдентификаторАгента, Данные)
	
	ВерсияПакета = Данные["version"];
	
	АгентЦККСтруктура = Справочники.АгентыЦКК.НайтиПоУникальномуИдентификатору(УникальныйИдентификаторАгента);
	СобиратьСчетчики = РегистрыСведений.СостояниеСбораПоказателей.ВключенСборСчетчиков(АгентЦККСтруктура.Ссылка);
	
	ПараметрыАгента = Новый Структура;
	ПараметрыАгента.Вставить("Ссылка", АгентЦККСтруктура.Ссылка);
	ПараметрыАгента.Вставить("ПериодОтправкиДанных", АгентЦККСтруктура.ПериодОтправкиДанных);
	ПараметрыАгента.Вставить("ОперативныйРежим", СобиратьСчетчики);
	ПараметрыАгента.Вставить("Хост", АгентЦККСтруктура.Хост);
	
	ТекДата = ТекущаяУниверсальнаяДата();
	Если АгентЦККСтруктура.ДатаАктивности + 60 <= ТекДата Тогда
		
		Если АгентЦККСтруктура.Версия <> ВерсияПакета Тогда
			АгентОбъект = АгентЦККСтруктура.Ссылка.ПолучитьОбъект();
			АгентОбъект.Версия = ВерсияПакета;
			АгентОбъект.Записать();
		КонецЕсли;
		
		МенеджерЗаписи = РегистрыСведений.АктивностьАгентовЦКК.СоздатьМенеджерЗаписи();
		МенеджерЗаписи.АгентЦКК = ПараметрыАгента.Ссылка;
		МенеджерЗаписи.ДатаКрайнейАктивности = ТекДата;
		МенеджерЗаписи.Записать(Истина);
		
	КонецЕсли;
	
	МониторПроизводительности(ПараметрыАгента, Данные);
	
	ТелоОтвета = Новый Соответствие;
	ТелоОтвета.Вставить("DUMPS_COLLECT", Ложь);
	ТелоОтвета.Вставить("ServicesData", Новый Соответствие);
	
	ПараметрыОтвета = Новый Структура;
	ПараметрыОтвета.Вставить("Enable", Ложь);
	ТелоОтвета["ServicesData"].Вставить("REMOTE_CONTROL", ПараметрыОтвета);
	ТелоОтвета["ServicesData"].Вставить("GET_SYSTEM_INFO", Ложь);
	
	МониторПроизводительностиОтвет(ТелоОтвета, ПараметрыАгента);
	
	MAIN_SERVICE = Новый Соответствие;
	Если ПараметрыАгента.ОперативныйРежим Тогда
		MAIN_SERVICE.Вставить("SLEEP_SEND", 1);
	Иначе
		Если ПараметрыАгента.ПериодОтправкиДанных <> 10 Тогда
			MAIN_SERVICE.Вставить("SLEEP_SEND", ПараметрыАгента.ПериодОтправкиДанных);
		КонецЕсли;
	КонецЕсли;
	
	Если MAIN_SERVICE.Количество() > 0 Тогда
		ТелоОтвета["ServicesData"].Вставить("MAIN_SERVICE", MAIN_SERVICE);
	КонецЕсли;
	
	Ответ = Новый HTTPСервисОтвет(200);
	Ответ.УстановитьТелоИзСтроки(СформироватьДанныеДляОтправки(ТелоОтвета));
	
	Возврат Ответ;
	
КонецФункции

Функция МониторПроизводительности(ПараметрыАгента, Данные)
	
	ServicesData = Данные["ServicesData"];
	Если ServicesData <> Неопределено Тогда
		
		PERFORMANCE_MONITOR = ServicesData["PERFORMANCE_MONITOR"];
		Если PERFORMANCE_MONITOR <> Неопределено Тогда
			
			executedCommands = PERFORMANCE_MONITOR["executedCommands"];
			Если executedCommands <> Неопределено Тогда
				Для Каждого ТекКоманда Из executedCommands Цикл
					РегистрыСведений.КомандыАгентаЦКК.УстановитьСтатусКоманды(Новый УникальныйИдентификатор(ТекКоманда.Ключ), Перечисления.СтатусыКомандАгентаЦКК.Выполнена);
				КонецЦикла;
			КонецЕсли;
			
			countersCur = PERFORMANCE_MONITOR["countersCur"]; 
			Если countersCur <> Неопределено Тогда
				
				ДатаЗамера = ТекущаяДата();
				
				ДанныеСчетчиков = Новый ТаблицаЗначений;
				ДанныеСчетчиков.Колонки.Добавить("СчетчикПроизводительности", Новый ОписаниеТипов("Строка",,,,Новый КвалификаторыСтроки(150)));
				ДанныеСчетчиков.Колонки.Добавить("Значение", Новый ОписаниеТипов("Число",,,Новый КвалификаторыЧисла(15,5)));
				
				Для Каждого ТекСчетчик Из countersCur Цикл
					НовСтрока = ДанныеСчетчиков.Добавить();
					НовСтрока.СчетчикПроизводительности = ТекСчетчик.Ключ;
					НовСтрока.Значение = ТекСчетчик.Значение;
				КонецЦикла;
				
				Запрос = Новый Запрос;
				
				Запрос.Текст = "
				|ВЫБРАТЬ
				|   ДанныеСчетчиков.СчетчикПроизводительности,
				|   ДанныеСчетчиков.Значение
				|ПОМЕСТИТЬ
				|   ДанныеСчетчиков
				|ИЗ
				|   &ДанныеСчетчиков КАК ДанныеСчетчиков
				|ИНДЕКСИРОВАТЬ ПО
				|   СчетчикПроизводительности
				|;
				|ВЫБРАТЬ
				|   &АгентЦКК КАК АгентЦКК,
				|   СпрСчетчикиПроизводительности.Ссылка КАК СчетчикПроизводительности,
				|   Значение КАК Значение,
				|   &ДатаЗамера
				|ИЗ
				|   ДанныеСчетчиков КАК ДанныеСчетчиков
				|ВНУТРЕННЕЕ СОЕДИНЕНИЕ
				|   Справочник.СчетчикиПроизводительности КАК СпрСчетчикиПроизводительности
				|ПО
				|   СпрСчетчикиПроизводительности.Наименование = ДанныеСчетчиков.СчетчикПроизводительности
				|";
				
				Запрос.УстановитьПараметр("ДанныеСчетчиков", ДанныеСчетчиков);
				Запрос.УстановитьПараметр("АгентЦКК", ПараметрыАгента.Ссылка);
				Запрос.УстановитьПараметр("ДатаЗамера", ДатаЗамера);
				
				Результат = Запрос.Выполнить();
				
				НаборЗаписей = РегистрыСведений.ТекущиеЗначенияПроизводительности.СоздатьНаборЗаписей();
				НаборЗаписей.Отбор.АгентЦКК.Установить(ПараметрыАгента.Ссылка);
				НаборЗаписей.Загрузить(Результат.Выгрузить());
				
				НаборЗаписей.Записать(Истина);
				
			КонецЕсли;
			
		КонецЕсли;
		
	КонецЕсли;
	
КонецФункции

Процедура МониторПроизводительностиОтвет(ТелоОтвета, ПараметрыАгента)
	
	КомандаОтправкиJSON = РегистрыСведений.КомандыАгентаЦКК.ПолучитьКомандуОтправки(ПараметрыАгента.Ссылка, Перечисления.ТипыКомандАгентаЦКК.PerfomanceMonitor, Перечисления.СтатусыКомандАгентаЦКК.Отправлена);
	КомандаОтправки = Неопределено;
	
	Если КомандаОтправкиJSON <> Неопределено Тогда
		
		ServicesData = ТелоОтвета["ServicesData"];
		Если ServicesData = Неопределено Тогда
			ServicesData = Новый Соответствие;
		КонецЕсли;
		
		ЧтениеJSON = Новый ЧтениеJSON();
		ЧтениеJSON.УстановитьСтроку(КомандаОтправкиJSON);
		КомандаОтправки = ПрочитатьJSON(ЧтениеJSON, Истина);
		
	КонецЕсли;
	
	Если ПараметрыАгента.ОперативныйРежим Тогда
		
		ServicesData = ТелоОтвета["ServicesData"];
		Если ServicesData = Неопределено Тогда
			ServicesData = Новый Соответствие;
		КонецЕсли;
		
		Если КомандаОтправки = Неопределено Тогда
			КомандаОтправки = Новый Соответствие;
		КонецЕсли;
		КомандаОтправки.Вставить("everySecondMode", Истина);
		
	КонецЕсли;
	
	Если ЗначениеЗаполнено(КомандаОтправки) Тогда
		ServicesData.Вставить("PERFORMANCE_MONITOR", КомандаОтправки);
		ТелоОтвета.Вставить("ServicesData", ServicesData);
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

Функция ПолучитьДанные(Текст)
	
	ЧтениеJSON = Новый ЧтениеJSON();
	ЧтениеJSON.УстановитьСтроку(Текст);
	
	Данные = ПрочитатьJSON(ЧтениеJSON, Истина);
	
	Возврат Данные;
	
КонецФункции

Функция СформироватьДанныеДляОтправки(Данные)
	
	ЗаписьJSON = Новый ЗаписьJSON();
	ЗаписьJSON.УстановитьСтроку(Новый ПараметрыЗаписиJSON(ПереносСтрокJSON.Нет));
	ЗаписатьJSON(ЗаписьJSON, Данные);
	Результат = ЗаписьJSON.Закрыть();
	
	Возврат Результат;
	
КонецФункции

