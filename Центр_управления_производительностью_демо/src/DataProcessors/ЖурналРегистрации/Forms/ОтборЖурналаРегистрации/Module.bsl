
#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	Если Параметры.Свойство("АвтоТест") Тогда // Возврат при получении формы для анализа.
		Возврат;
	КонецЕсли;
	
	ЗаполнитьВажностьИСтатус();
	ЗаполнитьПараметрыОтбора();
	
	СобытияПоУмолчанию = Параметры.СобытияПоУмолчанию;
	Если Не ОбщегоНазначенияКлиентСервер.СпискиЗначенийИдентичны(СобытияПоУмолчанию, События) Тогда
		СобытияОтображаемые = События.Скопировать();
	КонецЕсли;
	
	Служебный.УстановитьОтображениеЗаголовковГрупп(ЭтотОбъект, "ГруппаДанные, ГруппаТранзакции, ГруппаПрочее");
	
	Элементы.РазделениеДанныхСеанса.Видимость = Ложь;
	
КонецПроцедуры

&НаКлиенте
Процедура ОбработкаОповещения(ИмяСобытия, Параметр, Источник)
	
	Перем РедактируемыйСписок, ОтбираемыеПараметры, СтандартнаяОбработка;
	
	Если ИмяСобытия = "ВыборЗначенийЭлементовОтбораЖурналаРегистрации"
	   И Источник = ЭтотОбъект Тогда
		Если РедакторСоставаСвойстваИмяЭлемента = Элементы.Пользователи.Имя Тогда
			СписокПользователей = Параметр;
		ИначеЕсли РедакторСоставаСвойстваИмяЭлемента = Элементы.События.Имя Тогда
			События = Параметр;
		ИначеЕсли РедакторСоставаСвойстваИмяЭлемента = Элементы.Компьютеры.Имя Тогда
			Компьютеры = Параметр;
		ИначеЕсли РедакторСоставаСвойстваИмяЭлемента = Элементы.Приложения.Имя Тогда
			Приложения = Параметр;
		ИначеЕсли РедакторСоставаСвойстваИмяЭлемента = Элементы.Метаданные.Имя Тогда
			Метаданные = Параметр;
		ИначеЕсли РедакторСоставаСвойстваИмяЭлемента = Элементы.РабочиеСерверы.Имя Тогда
			РабочиеСерверы = Параметр;
		ИначеЕсли РедакторСоставаСвойстваИмяЭлемента = Элементы.ОсновныеIPПорты.Имя Тогда
			ОсновныеIPПорты = Параметр;
		ИначеЕсли РедакторСоставаСвойстваИмяЭлемента = Элементы.ВспомогательныеIPПорты.Имя Тогда
			ВспомогательныеIPПорты = Параметр;
		ИначеЕсли РедакторСоставаСвойстваИмяЭлемента = Элементы.РазделениеДанныхСеанса.Имя Тогда
			РазделениеДанныхСеанса = Параметр;
		КонецЕсли;
	КонецЕсли;
	
	СобытияОтображаемые.Очистить();
	
	Если События.Количество() = 0 Тогда
		События = СобытияПоУмолчанию;
		Возврат;
	КонецЕсли;
	
	Если Не ОбщегоНазначенияКлиентСервер.СпискиЗначенийИдентичны(СобытияПоУмолчанию, События) Тогда
		СобытияОтображаемые = События.Скопировать();
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовШапкиФормы

&НаКлиенте
Процедура ИсполнениеВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	
	Перем РедактируемыйСписок, ОтбираемыеПараметры;
	
	СтандартнаяОбработка = Ложь;
	
	РедакторСоставаСвойстваИмяЭлемента = Элемент.Имя;
	
	Если РедакторСоставаСвойстваИмяЭлемента = Элементы.Пользователи.Имя Тогда
		РедактируемыйСписок = СписокПользователей;
		ОтбираемыеПараметры = "Пользователь";
	ИначеЕсли РедакторСоставаСвойстваИмяЭлемента = Элементы.События.Имя Тогда
		РедактируемыйСписок = События;
		ОтбираемыеПараметры = "Событие";
	ИначеЕсли РедакторСоставаСвойстваИмяЭлемента = Элементы.Компьютеры.Имя Тогда
		РедактируемыйСписок = Компьютеры;
		ОтбираемыеПараметры = "Компьютер";
	ИначеЕсли РедакторСоставаСвойстваИмяЭлемента = Элементы.Приложения.Имя Тогда
		РедактируемыйСписок = Приложения;
		ОтбираемыеПараметры = "ИмяПриложения";
	ИначеЕсли РедакторСоставаСвойстваИмяЭлемента = Элементы.Метаданные.Имя Тогда
		РедактируемыйСписок = Метаданные;
		ОтбираемыеПараметры = "Метаданные";
	ИначеЕсли РедакторСоставаСвойстваИмяЭлемента = Элементы.РабочиеСерверы.Имя Тогда
		РедактируемыйСписок = РабочиеСерверы;
		ОтбираемыеПараметры = "РабочийСервер";
	ИначеЕсли РедакторСоставаСвойстваИмяЭлемента = Элементы.ОсновныеIPПорты.Имя Тогда
		РедактируемыйСписок = ОсновныеIPПорты;
		ОтбираемыеПараметры = "ОсновнойIPПорт";
	ИначеЕсли РедакторСоставаСвойстваИмяЭлемента = Элементы.ВспомогательныеIPПорты.Имя Тогда
		РедактируемыйСписок = ВспомогательныеIPПорты;
		ОтбираемыеПараметры = "ВспомогательныйIPПорт";
	ИначеЕсли РедакторСоставаСвойстваИмяЭлемента = Элементы.РазделениеДанныхСеанса.Имя Тогда
		ПараметрыФормы = Новый Структура;
		ПараметрыФормы.Вставить("УстановленныйОтбор", РазделениеДанныхСеанса);
		ОткрытьФорму("Обработка.ЖурналРегистрации.Форма.РазделениеДанныхСеанса", ПараметрыФормы, ЭтотОбъект);
		Возврат;
	Иначе
		СтандартнаяОбработка = Истина;
		Возврат;
	КонецЕсли;
	
	ПараметрыФормы = Новый Структура;
	
	ПараметрыФормы.Вставить("РедактируемыйСписок", РедактируемыйСписок);
	ПараметрыФормы.Вставить("ОтбираемыеПараметры", ОтбираемыеПараметры);
	
	// Открытие редактора свойства.
	ОткрытьФорму("Обработка.ЖурналРегистрации.Форма.РедакторСоставаСвойства",
	             ПараметрыФормы,
	             ЭтотОбъект);
	
КонецПроцедуры

&НаКлиенте
Процедура СобытияОчистка(Элемент, СтандартнаяОбработка)
	
	События = СобытияПоУмолчанию;
	
КонецПроцедуры

&НаКлиенте
Процедура ИнтервалОтбораПриИзменении(Элемент)
	
	ОбработчикОповещения = Новый ОписаниеОповещения("ИнтервалОтбораПриИзмененииЗавершение", ЭтотОбъект);
	
	Диалог = Новый ДиалогРедактированияСтандартногоПериода;
	Диалог.Период = ИнтервалОтбора;
	Диалог.Показать(ОбработчикОповещения);
	
КонецПроцедуры

&НаКлиенте
Процедура ИнтервалОтбораПриИзмененииЗавершение(Период, ДополнительныеПараметры) Экспорт
	
	Если Период = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	ИнтервалОтбора = Период;
	ИнтервалОтбораДатаНачала    = ИнтервалОтбора.ДатаНачала;
	ИнтервалОтбораДатаОкончания = ИнтервалОтбора.ДатаОкончания;
	
КонецПроцедуры

&НаКлиенте
Процедура ИнтервалОтбораДатаПриИзменении(Элемент)
	
	ИнтервалОтбора.Вариант       = ВариантСтандартногоПериода.ПроизвольныйПериод;
	ИнтервалОтбора.ДатаНачала    = ИнтервалОтбораДатаНачала;
	ИнтервалОтбора.ДатаОкончания = ИнтервалОтбораДатаОкончания;
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура УстановитьОтборИЗакрытьФорму(Команда)
	
	ОповеститьОВыборе(
		Новый Структура("Событие, Отбор", 
			"УстановленОтборЖурналаРегистрации", 
			ПолучитьОтборЖурналаРегистрации()));
	
КонецПроцедуры

&НаКлиенте
Процедура УстановитьФлажкиВажности(Команда)
	Для Каждого ЭлементСписка Из Важность Цикл
		ЭлементСписка.Пометка = Истина;
	КонецЦикла;
КонецПроцедуры

&НаКлиенте
Процедура СнятьФлажкиВажности(Команда)
	Для Каждого ЭлементСписка Из Важность Цикл
		ЭлементСписка.Пометка = Ложь;
	КонецЦикла;
КонецПроцедуры

&НаКлиенте
Процедура УстановитьСтатусыТранзакции(Команда)
	Для Каждого ЭлементСписка Из СтатусТранзакции Цикл
		ЭлементСписка.Пометка = Истина;
	КонецЦикла;
КонецПроцедуры

&НаКлиенте
Процедура СнятьСтатусыТранзакции(Команда)
	Для Каждого ЭлементСписка Из СтатусТранзакции Цикл
		ЭлементСписка.Пометка = Ложь;
	КонецЦикла;
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаСервере
Процедура ЗаполнитьВажностьИСтатус()
	// Заполнение ЭУ Важность
	Важность.Добавить("Ошибка",         Строка(УровеньЖурналаРегистрации.Ошибка));
	Важность.Добавить("Предупреждение", Строка(УровеньЖурналаРегистрации.Предупреждение));
	Важность.Добавить("Информация",     Строка(УровеньЖурналаРегистрации.Информация));
	Важность.Добавить("Примечание",     Строка(УровеньЖурналаРегистрации.Примечание));
	
	// Заполнение ЭУ СтатусТранзакции
	СтатусТранзакции.Добавить("НетТранзакции", Строка(СтатусТранзакцииЗаписиЖурналаРегистрации.НетТранзакции));
	СтатусТранзакции.Добавить("Зафиксирована", Строка(СтатусТранзакцииЗаписиЖурналаРегистрации.Зафиксирована));
	СтатусТранзакции.Добавить("НеЗавершена",   Строка(СтатусТранзакцииЗаписиЖурналаРегистрации.НеЗавершена));
	СтатусТранзакции.Добавить("Отменена",      Строка(СтатусТранзакцииЗаписиЖурналаРегистрации.Отменена));
	
КонецПроцедуры

&НаСервере
Процедура ЗаполнитьПараметрыОтбора()
	
	СписокПараметровОтбора = Параметры.Отбор;
	ЕстьОтборПоУровню  = Ложь;
	ЕстьОтборПоСтатусу = Ложь;
	
	Для Каждого ПараметрОтбора Из СписокПараметровОтбора Цикл
		ИмяПараметра = ПараметрОтбора.Представление;
		Значение     = ПараметрОтбора.Значение;
		
		Если ВРег(ИмяПараметра) = ВРег("ДатаНачала") Тогда
			// ДатаНачала/StartDate
			ИнтервалОтбора.ДатаНачала = Значение;
			ИнтервалОтбораДатаНачала  = Значение;
			
		ИначеЕсли ВРег(ИмяПараметра) = ВРег("ДатаОкончания") Тогда
			// ДатаОкончания/EndDate
			ИнтервалОтбора.ДатаОкончания = Значение;
			ИнтервалОтбораДатаОкончания  = Значение;
			
		ИначеЕсли ВРег(ИмяПараметра) = ВРег("Пользователь") Тогда
			// Пользователь/User
			СписокПользователей = Значение;
			
		ИначеЕсли ВРег(ИмяПараметра) = ВРег("Событие") Тогда
			// Событие/Event
			События = Значение;
			
		ИначеЕсли ВРег(ИмяПараметра) = ВРег("Компьютер") Тогда
			// Компьютер/Computer
			Компьютеры = Значение;
			
		ИначеЕсли ВРег(ИмяПараметра) = ВРег("ИмяПриложения") Тогда
			// ИмяПриложения/ApplicationName
			Приложения = Значение;
			
		ИначеЕсли ВРег(ИмяПараметра) = ВРег("Комментарий") Тогда
			// Комментарий/Comment
			Комментарий = Значение;
		 	
		ИначеЕсли ВРег(ИмяПараметра) = ВРег("Метаданные") Тогда
			// Метаданные/Metadata
			Метаданные = Значение;
			
		ИначеЕсли ВРег(ИмяПараметра) = ВРег("Данные") Тогда
			// Данные/Data 
			Данные = Значение;
			
		ИначеЕсли ВРег(ИмяПараметра) = ВРег("ПредставлениеДанных") Тогда
			// ПредставлениеДанных/DataPresentation
			ПредставлениеДанных = Значение;
			
		ИначеЕсли ВРег(ИмяПараметра) = ВРег("Транзакция") Тогда
			// Транзакция/TransactionID
			Транзакция = Значение;
			
		ИначеЕсли ВРег(ИмяПараметра) = ВРег("РабочийСервер") Тогда
			// РабочийСервер/ServerName
			РабочиеСерверы = Значение;
			
		ИначеЕсли ВРег(ИмяПараметра) = ВРег("Сеанс") Тогда
			// Сеанс/Seance
			Сеансы = Значение;
			СтрСеансы = "";
			Для Каждого НомерСеанса Из Сеансы Цикл
				СтрСеансы = СтрСеансы + ?(СтрСеансы = "", "", "; ") + НомерСеанса;
			КонецЦикла;
			
		ИначеЕсли ВРег(ИмяПараметра) = ВРег("ОсновнойIPПорт") Тогда
			// ОсновнойIPПорт/Port
			ОсновныеIPПорты = Значение;
			
		ИначеЕсли ВРег(ИмяПараметра) = ВРег("ВспомогательныйIPПорт") Тогда
			// ВспомогательныйIPПорт/SyncPort
			ВспомогательныеIPПорты = Значение;
			
		ИначеЕсли ВРег(ИмяПараметра) = ВРег("Уровень") Тогда
			// Уровень/Level
			ЕстьОтборПоУровню = Истина;
			Для Каждого ЭлементСпискаЗначений Из Важность Цикл
				Если Значение.НайтиПоЗначению(ЭлементСпискаЗначений.Значение) <> Неопределено Тогда
					ЭлементСпискаЗначений.Пометка = Истина;
				КонецЕсли;
			КонецЦикла;
			
		ИначеЕсли ВРег(ИмяПараметра) = ВРег("СтатусТранзакции") Тогда
			// СтатусТранзакции/TransactionStatus
			ЕстьОтборПоСтатусу = Истина;
			Для Каждого ЭлементСпискаЗначений Из СтатусТранзакции Цикл
				Если Значение.НайтиПоЗначению(ЭлементСпискаЗначений.Значение) <> Неопределено Тогда
					ЭлементСпискаЗначений.Пометка = Истина;
				КонецЕсли;
			КонецЦикла;
			
		ИначеЕсли ВРег(ИмяПараметра) = ВРег("РазделениеДанныхСеанса") Тогда
			
			Если ТипЗнч(Значение) = Тип("СписокЗначений") Тогда
				РазделениеДанныхСеанса = Значение.Скопировать();
			КонецЕсли;
			
		КонецЕсли;
		
	КонецЦикла;
	
	Если Не ЕстьОтборПоУровню Тогда
		Для Каждого ЭлементСпискаЗначений Из Важность Цикл
			ЭлементСпискаЗначений.Пометка = Истина;
		КонецЦикла;
	КонецЕсли;
	
	Если Не ЕстьОтборПоСтатусу Тогда
		Для Каждого ЭлементСпискаЗначений Из СтатусТранзакции Цикл
			ЭлементСпискаЗначений.Пометка = Истина;
		КонецЦикла;
	ИначеЕсли ЕстьОтборПоСтатусу Или ЗначениеЗаполнено(Транзакция) Тогда
		Элементы.ГруппаТранзакции.Заголовок = Элементы.ГруппаТранзакции.Заголовок + " *";
	КонецЕсли;
	
	Если ЗначениеЗаполнено(РабочиеСерверы)
		Или ЗначениеЗаполнено(ОсновныеIPПорты)
		Или ЗначениеЗаполнено(ВспомогательныеIPПорты)
		Или ЗначениеЗаполнено(РазделениеДанныхСеанса)
		Или ЗначениеЗаполнено(Комментарий) Тогда
		Элементы.ГруппаПрочее.Заголовок = Элементы.ГруппаПрочее.Заголовок + " *";
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Функция ПолучитьОтборЖурналаРегистрации()
	
	Сеансы.Очистить();
	Стр = СтрСеансы;
	Стр = СтрЗаменить(Стр, ";", " ");
	Стр = СтрЗаменить(Стр, ",", " ");
	Стр = СокрЛП(Стр);
	ТЧ = Новый ОписаниеТипов("Число");
	
	Пока Не ПустаяСтрока(Стр) Цикл
		Поз = СтрНайти(Стр, " ");
		
		Если Поз = 0 Тогда
			Значение = ТЧ.ПривестиЗначение(Стр);
			Стр = "";
		Иначе
			Значение = ТЧ.ПривестиЗначение(Лев(Стр, Поз-1));
			Стр = СокрЛП(Сред(Стр, Поз+1));
		КонецЕсли;
		
		Если Значение <> 0 Тогда
			Сеансы.Добавить(Значение);
		КонецЕсли;
	КонецЦикла;
	
	Отбор = Новый СписокЗначений;
	
	// Дата начала, окончания
	Если ИнтервалОтбораДатаНачала <> '00010101000000' Тогда 
		Отбор.Добавить(ИнтервалОтбораДатаНачала, "ДатаНачала");
	КонецЕсли;
	Если ИнтервалОтбораДатаОкончания <> '00010101000000' Тогда
		Отбор.Добавить(ИнтервалОтбораДатаОкончания, "ДатаОкончания");
	КонецЕсли;
	
	// Пользователь/User
	Если СписокПользователей.Количество() > 0 Тогда 
		Отбор.Добавить(СписокПользователей, "Пользователь");
	КонецЕсли;
	
	// Событие/Event
	Если События.Количество() > 0 Тогда 
		Отбор.Добавить(События, "Событие");
	КонецЕсли;
	
	// Компьютер/Computer
	Если Компьютеры.Количество() > 0 Тогда 
		Отбор.Добавить(Компьютеры, "Компьютер");
	КонецЕсли;
	
	// ИмяПриложения/ApplicationName
	Если Приложения.Количество() > 0 Тогда 
		Отбор.Добавить(Приложения, "ИмяПриложения");
	КонецЕсли;
	
	// Комментарий/Comment
	Если Не ПустаяСтрока(Комментарий) Тогда 
		Отбор.Добавить(Комментарий, "Комментарий");
	КонецЕсли;
	
	// Метаданные/Metadata
	Если Метаданные.Количество() > 0 Тогда 
		Отбор.Добавить(Метаданные, "Метаданные");
	КонецЕсли;
	
	// Данные/Data 
	Если (Данные <> Неопределено) И (Не Данные.Пустая()) Тогда
		Отбор.Добавить(Данные, "Данные");
	КонецЕсли;
	
	// ПредставлениеДанных/DataPresentation
	Если Не ПустаяСтрока(ПредставлениеДанных) Тогда 
		Отбор.Добавить(ПредставлениеДанных, "ПредставлениеДанных");
	КонецЕсли;
	
	// Транзакция/TransactionID
	Если Не ПустаяСтрока(Транзакция) Тогда 
		Отбор.Добавить(Транзакция, "Транзакция");
	КонецЕсли;
	
	// РабочийСервер/ServerName
	Если РабочиеСерверы.Количество() > 0 Тогда 
		Отбор.Добавить(РабочиеСерверы, "РабочийСервер");
	КонецЕсли;
	
	// Сеанс/Seance
	Если Сеансы.Количество() > 0 Тогда 
		Отбор.Добавить(Сеансы, "Сеанс");
	КонецЕсли;
	
	// ОсновнойIPПорт/Port
	Если ОсновныеIPПорты.Количество() > 0 Тогда 
		Отбор.Добавить(ОсновныеIPПорты, "ОсновнойIPПорт");
	КонецЕсли;
	
	// ВспомогательныйIPПорт/SyncPort
	Если ВспомогательныеIPПорты.Количество() > 0 Тогда 
		Отбор.Добавить(ВспомогательныеIPПорты, "ВспомогательныйIPПорт");
	КонецЕсли;
	
	// РазделениеДанныхСеанса
	Если РазделениеДанныхСеанса.Количество() > 0 Тогда 
		Отбор.Добавить(РазделениеДанныхСеанса, "РазделениеДанныхСеанса");
	КонецЕсли;
	
	// Уровень/Level
	СписокУровней = Новый СписокЗначений;
	Для Каждого ЭлементСпискаЗначений Из Важность Цикл
		Если ЭлементСпискаЗначений.Пометка Тогда 
			СписокУровней.Добавить(ЭлементСпискаЗначений.Значение, ЭлементСпискаЗначений.Представление);
		КонецЕсли;
	КонецЦикла;
	Если СписокУровней.Количество() > 0 И СписокУровней.Количество() <> Важность.Количество() Тогда
		Отбор.Добавить(СписокУровней, "Уровень");
	КонецЕсли;
	
	// СтатусТранзакции/TransactionStatus
	СписокСтатусов = Новый СписокЗначений;
	Для Каждого ЭлементСпискаЗначений Из СтатусТранзакции Цикл
		Если ЭлементСпискаЗначений.Пометка Тогда 
			СписокСтатусов.Добавить(ЭлементСпискаЗначений.Значение, ЭлементСпискаЗначений.Представление);
		КонецЕсли;
	КонецЦикла;
	Если СписокСтатусов.Количество() > 0 И СписокСтатусов.Количество() <> СтатусТранзакции.Количество() Тогда
		Отбор.Добавить(СписокСтатусов, "СтатусТранзакции");
	КонецЕсли;
	
	Возврат Отбор;
	
КонецФункции

#КонецОбласти
