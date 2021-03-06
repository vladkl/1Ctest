///////////////////////////////////////////////////////////////////////////////
// РЕГИСТРАЦИЯ СООБЩЕНИЙ

// Записать событие в протокол
//
// Параметры:
//  Идентификатор - Строка, идентификатор сообщения для протокола
//  Параметр0 - Произвольный, значение для Словарь.Получить()
//  Параметр1 - Произвольный, значение для Словарь.Получить()
//  Параметр2 - Произвольный, значение для Словарь.Получить()
//
Процедура СостояниеСценария(Состояние) Экспорт
	
	Протокол(СловарьКлиентСервер.Получить("ОтладкаСостояние") + Состояние);
	
КонецПроцедуры // СобытиеСостояниеСценария()

// Записать событие в протокол
//
// Параметры:
//  Событие - СправочникСсылка.Событие
//  Параметры - Произвольный, параметры события
//
Процедура Событие(Событие, Параметры) Экспорт
	
	ЕстьПараметры = ЗначениеЗаполнено(Параметры);
	ПараметрыСобытия = ?(ЕстьПараметры, " (" + Параметры + ")", "");
	Протокол(СловарьКлиентСервер.Получить("ОтладкаСобытие") + Событие + ПараметрыСобытия);
	
КонецПроцедуры // Событие()

// Сформировать полный текст сообщения с учетом даты и времени
//
// Параметры:
//  ТекстСообщения - Строка
//
// Возвращаемое значение:
//  Строка - сообщение с учетом даты и времени
//
Функция СформироватьСообщение(ТекстСообщения)
	
	Возврат Строка(ТекущаяДата())+ ", "+ ТекстСообщения;
	
КонецФункции // СформироватьСообщение()


///////////////////////////////////////////////////////////////////////////////
// СЛУЖЕБНЫЕ ПРОЦЕДУРЫ И ФУНКЦИИ

// Записать в протокол сообщений о текущем состоянии выполнения
//
// Параметры:
//  Текст - Строка, текст сообщения
//
Процедура Протокол(Текст) Экспорт
	
	#Если Клиент Тогда
		Если Не РежимОтладкиЦУП() Тогда
			Возврат;
		КонецЕсли;
	#ИначеЕсли Сервер Тогда
		Если Не Константы.РежимОтладки.Получить() Тогда
			Возврат;
		КонецЕсли;
	#КонецЕсли
	
	Если глЖурнал = Неопределено Тогда
		глЖурнал = Новый Массив;
	КонецЕсли;
	
	ОписаниеСобытия = Новый Структура(
		"ТекстСообщения,УровеньСобытия,ПодробноеОписание",
		СловарьКлиентСервер.Получить("Протокол"),
		"Информация",
		Текст);
	глЖурнал.Добавить(ОписаниеСобытия);
	
	#Если Клиент Тогда
		Если глПоказыватьОтладочныеСообщения() Тогда
			ТекстСообщения = СформироватьСообщение(Текст);
			Сообщить(ТекстСообщения, СтатусСообщения.Информация);
		КонецЕсли;
	#КонецЕсли
	
КонецПроцедуры // Протокол
