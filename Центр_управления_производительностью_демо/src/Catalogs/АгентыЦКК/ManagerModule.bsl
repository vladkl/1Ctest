#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда
    
#Область ПрограммныйИнтерфейс

// Выполняет поиск по реквизиту УникальныйИдентификаторАгента 
//
// Параметры:
//  УникальныйИдентификаторАгента - УникальныйИдентификатор - значение, по которому выполняется поиск. 
// 
// Возвращаемое значение:
//  Структура с ключами - Ссылка - СправочникСсылка.АгентыЦКК
//                      - ДатаАктивности - Дата
//
Функция НайтиПоУникальномуИдентификатору(УникальныйИдентификаторАгента) Экспорт
	
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ ПЕРВЫЕ 1
	               |	Агенты.Ссылка КАК Ссылка,
	               |	Агенты.Версия КАК Версия,
	               |	ЕСТЬNULL(Активность.ДатаКрайнейАктивности, &ПустаяДата) КАК ДатаАктивности,
	               |	Агенты.ПериодОтправкиДанных КАК ПериодОтправкиДанных,
	               |	Агенты.Хост КАК Хост
	               |ИЗ
	               |	Справочник.АгентыЦКК КАК Агенты
	               |		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.АктивностьАгентовЦКК КАК Активность
	               |		ПО (Активность.АгентЦКК = Агенты.Ссылка)
	               |ГДЕ
	               |	Агенты.УникальныйИдентификаторАгента = &УникальныйИдентификаторАгента";
	
	Запрос.УстановитьПараметр("УникальныйИдентификаторАгента", УникальныйИдентификаторАгента);
	Запрос.УстановитьПараметр("ПустаяДата", Дата(1,1,1));
	
	Результат = Запрос.Выполнить();
	
	АгентЦКК = Новый Структура();
	Если НЕ Результат.Пустой() Тогда
		
		Выборка = Результат.Выбрать();
		Выборка.Следующий();
		
		Для Каждого Колонка Из Результат.Колонки Цикл
			АгентЦКК.Вставить(Колонка.Имя, Выборка[Колонка.Имя]);
		КонецЦикла;
		
	Иначе
		Для Каждого Колонка Из Результат.Колонки Цикл
			АгентЦКК.Вставить(Колонка.Имя, Неопределено);
		КонецЦикла;        
	КонецЕсли;
	
	Возврат АгентЦКК;
	
КонецФункции

// Создает новый элемент по реквизиту УникальныйИдентификаторАгента в случае отсутствия.
//
// Параметры:
//  УникальныйИдентификаторАгента - УникальныйИдентификатор - уникальный идентификатор агента для создания. 
// 
// Возвращаемое значение:
//  СправочникСсылка.АгентыЦКК
//
Функция СоздатьЭлементПоУникальномуИдентификатору(УникальныйИдентификаторАгента, Хост, Версия) Экспорт
    
    АгентЦККСтруктура = НайтиПоУникальномуИдентификатору(УникальныйИдентификаторАгента);
    АгентЦКК = АгентЦККСтруктура.Ссылка;
    
    Если АгентЦКК = Неопределено Тогда
        
        НачатьТранзакцию();
        Попытка
            
            Блокировка = Новый БлокировкаДанных;
            ЭлементБлокировки = Блокировка.Добавить("Справочник.АгентыЦКК");
            ЭлементБлокировки.УстановитьЗначение("УникальныйИдентификаторАгента", УникальныйИдентификаторАгента);
            ЭлементБлокировки.Режим = РежимБлокировкиДанных.Исключительный;
            Блокировка.Заблокировать();
            
            АгентЦККСтруктура = НайтиПоУникальномуИдентификатору(УникальныйИдентификаторАгента);
            АгентЦКК = АгентЦККСтруктура.Ссылка;
            Если АгентЦКК = Неопределено Тогда
                
                АгентЦККОбъект = Справочники.АгентыЦКК.СоздатьЭлемент();
                АгентЦККОбъект.Наименование = Хост;
                АгентЦККОбъект.Версия = Версия;
                АгентЦККОбъект.УникальныйИдентификаторАгента = УникальныйИдентификаторАгента;
                АгентЦККОбъект.Хост = Хост;
                АгентЦККОбъект.ДатаРегистрации = ТекущаяУниверсальнаяДата();
                АгентЦККОбъект.Заполнить(Неопределено);
                АгентЦККОбъект.Записать();
                
            КонецЕсли;
            
            ЗафиксироватьТранзакцию();
            
            АгентЦКК = АгентЦККОбъект.Ссылка; 
                        
        Исключение
            
            ОтменитьТранзакцию();
            ВызватьИсключение ПодробноеПредставлениеОшибки(ИнформацияОбОшибке());
            
        КонецПопытки;
        
    ИначеЕсли АгентЦКК.Версия  <> Версия Тогда
        
        АгентЦККОбъект = АгентЦКК.ПолучитьОбъект();
        АгентЦККОбъект.Версия = Версия;
        АгентЦККОбъект.Записать();        
        
    КонецЕсли;
    
    Возврат АгентЦКК;
    
КонецФункции

Процедура ВключитьСборСчетчиковПроизводительности(АгентЦКК, СобираемыеСчетчики = Неопределено) Экспорт
	
	Если СобираемыеСчетчики = Неопределено Тогда
		СобираемыеСчетчики = Справочники.ИнформационныеБазы.ПолучитьСчетчикиАгента(АгентЦКК);
	КонецЕсли;
	НастройкиАгента = Новый Соответствие;
	НастройкиАгента.Вставить("enable", Истина);
	НастройкиАгента.Вставить("counters", СобираемыеСчетчики);
	
	ЗаписьJSON = Новый ЗаписьJSON();
	ЗаписьJSON.УстановитьСтроку(Новый ПараметрыЗаписиJSON(ПереносСтрокJSON.Нет));
	ЗаписатьJSON(ЗаписьJSON, НастройкиАгента);
	РегистрыСведений.КомандыАгентаЦКК.ДобавитьКоманду(АгентЦКК, Перечисления.ТипыКомандАгентаЦКК.PerfomanceMonitor, НастройкиАгента); 
	
КонецПроцедуры

Процедура ОтключитьСборСчетчиковПроизводительности(АгентЦКК) Экспорт
	
	НастройкиАгента = Новый Соответствие;
	НастройкиАгента.Вставить("enable", Ложь);
	
	ЗаписьJSON = Новый ЗаписьJSON();
	ЗаписьJSON.УстановитьСтроку(Новый ПараметрыЗаписиJSON(ПереносСтрокJSON.Нет));
	ЗаписатьJSON(ЗаписьJSON, НастройкиАгента);
	РегистрыСведений.КомандыАгентаЦКК.ДобавитьКоманду(АгентЦКК, Перечисления.ТипыКомандАгентаЦКК.PerfomanceMonitor, НастройкиАгента); 
	
КонецПроцедуры

#КонецОбласти

#КонецЕсли

