
Перем мЭтоНовый; // Флаг, записан ли документ в базу данных.


// Процедура обработки события ПередЗаписью документа.
// Определяет записан ли документ в базу данных.
//
Процедура ПередЗаписью(Отказ, РежимЗаписи, РежимПроведения)
	
	мЭтоНовый = ЭтоНовый();
	
КонецПроцедуры // ПередЗаписью()

// Процедура обработки события ПриЗаписи документа.
// Записать движение в регистры.
//
Процедура ПриЗаписи(Отказ)
	
	Если ОбменДанными.Загрузка = Истина Тогда
		Возврат;
	КонецЕсли;
	
	// Получить ссылку на показатель производительности
	Показатель = Справочники.Показатели.АнализЗапросов;
	Значение = ВремяВыполненияМс/1000;
	
	Попытка
		ЖурналПоказателей.ЗаписатьЗначениеПоказателяАнализа(
			ЭтотОбъект,
			мЭтоНовый,
			Показатель,
			Значение);
	Исключение
		Отказ = Истина;
		ВызватьИсключение;
	КонецПопытки
	
КонецПроцедуры // ПриЗаписи()

// Процедура обработки события ПередУдалением документа.
// Удаляет движения документа.
//
Процедура ПередУдалением(Отказ)
	
	Если Запрос = Справочники.Запросы.ПустаяСсылка() Тогда
		Возврат;
	КонецЕсли;
	
	// Получить ссылку на показатель производительности
	Показатель = Справочники.Показатели.АнализЗапросов;
	Значение = ВремяВыполненияМс/1000;
	
	Попытка
		ЖурналПоказателей.УдалитьЗначениеПоказателяАнализа(
			ЭтотОбъект,
			мЭтоНовый,
			Показатель,
			Значение);
	Исключение
		Отказ = Истина;
		ВызватьИсключение;
	КонецПопытки
	
КонецПроцедуры // ПередУдалением()
