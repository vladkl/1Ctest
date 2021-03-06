///////////////////////////////////////////////////////////////////////////////
// ЗАВИСИМОСТИ
//

// Найти ссылки всех экспортируемых объектов
//
// Параметры:
//  ИБ - СправочникСсылка.ИнформационноаяБаза
//  Начало - ДатаВремя, начало интервала поиска
//  Конец - ДатаВремя, конец интервала поиска
//
// Возвращаемое значение:
//  ВыборкаИзРезультатаЗапроса
//
Функция НайтиЭкспортируемыеОбъекты(ИБ, Начало, Конец) Экспорт
	
	Зависимости = Новый Соответствие;
	Зависимости.Вставить(ИБ, Истина);
	
	ВыборкаДокументов = Обмен.НайтиДокументы(
		"Блокировка, ОжиданиеНаБлокировке, Взаимоблокировка", ИБ, Начало, Конец);
	
	Пока ВыборкаДокументов.Следующий() Цикл
		Документ = ВыборкаДокументов.Ссылка;
		Обмен.НайтиЗависимости(Документ, Зависимости);
	КонецЦикла;
	
	Возврат Зависимости;
	
КонецФункции // НайтиЭкспортируемыеОбъекты()

// Найти все ссылки на которые рекурсивно ссылается объект
//
// Параметры:
//  Ссылка - ЛюбаяСсылка
//  Зависимости - Соответствие, список зависимостей
//
Процедура НайтиЗависимости(Ссылка, Зависимости) Экспорт
	
	Если Зависимости[Ссылка] = Истина Тогда
		Возврат;
	КонецЕсли;
	
	МетаданныеОбъекта = Ссылка.Метаданные();
	
	Для Каждого Реквизит Из МетаданныеОбъекта.Реквизиты Цикл
		ТипРеквизита = Реквизит.Тип;
		Если ОбщегоНазначения.ЭтоСсылка(ТипРеквизита) Тогда
			ЗначениеРеквизита = Ссылка[Реквизит.Имя];
			НайтиЗависимостиРеквизита(ЗначениеРеквизита, Зависимости);
		КонецЕсли;
	КонецЦикла;
	
	Для Каждого ТабличнаяЧасть Из МетаданныеОбъекта.ТабличныеЧасти Цикл
		Для Каждого Реквизит Из ТабличнаяЧасть.Реквизиты Цикл
			ТипРеквизита = Реквизит.Тип;
			Если ОбщегоНазначения.ЭтоСсылка(ТипРеквизита) Тогда
				ТЧ = Ссылка[ТабличнаяЧасть.Имя];
				Для Каждого СтрокаТЧ ИЗ ТЧ Цикл
					ЗначениеРеквизита = СтрокаТЧ[Реквизит.Имя];
					НайтиЗависимостиРеквизита(ЗначениеРеквизита, Зависимости);
				КонецЦикла;
			КонецЕсли;
		КонецЦикла;
	КонецЦикла;
	
	Зависимости.Вставить(Ссылка, Истина);
	
КонецПроцедуры // НайтиЗависимости()

// Найти зависимости реквизита
//
// Параметры:
//  ЗначениеРеквизита - ЛюбаяСсылка
//  ТипРеквизита - ОписаниеТипаЗначения
//  Зависимости - Соответствие, список зависимостей
//
Процедура НайтиЗависимостиРеквизита(ЗначениеРеквизита, Зависимости) Экспорт
	
	Если Зависимости[ЗначениеРеквизита] = Истина Тогда
		Возврат;
	КонецЕсли;
	
	Если ОбщегоНазначения.ЭтоСсылкаНаСправочник(ЗначениеРеквизита) Тогда
		Если ЗначениеРеквизита.Метаданные().Иерархический Тогда
			Родитель = ЗначениеРеквизита.Родитель;
			Если ЗначениеЗаполнено(Родитель) Тогда
				НайтиЗависимостиРеквизита(Родитель, Зависимости);
			КонецЕсли;
		КонецЕсли;
	КонецЕсли;
	
	НайтиЗависимости(ЗначениеРеквизита, Зависимости);
	Зависимости.Вставить(ЗначениеРеквизита, Истина);
	
КонецПроцедуры // НайтиЗависимостиРеквизита()


///////////////////////////////////////////////////////////////////////////////
// ДОКУМЕНТЫ
//

// Найти документы указанного типа в выбранной информационной базе
// на указанном интервале времени
//
// Параметры:
//  ТипыДокументов - Строка, типы документов через запятую
//  ИБ - СправочникСсылка.ИнформационноаяБаза
//  Начало - ДатаВремя, начало интервала поиска
//  Конец - ДатаВремя, конец интервала поиска
//
// Возвращаемое значение:
//  ВыборкаИзРезультатаЗапроса
//
Функция НайтиДокументы(ТипыДокументов, ИБ, Начало, Конец) Экспорт
	
	Типы = ОбщегоНазначенияКлиентСервер.РазделитьСтроку(ТипыДокументов, ",");
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("ИнформационнаяБаза", ИБ);
	Запрос.УстановитьПараметр("Начало", Начало);
	Запрос.УстановитьПараметр("Конец", Конец);
	
	Для Каждого Тип Из Типы Цикл
		
		Если Не ПустаяСтрока(Запрос.Текст) Тогда
			Запрос.Текст = Запрос.Текст + "
				|
				|ОБЪЕДИНИТЬ ВСЕ
				|";
		КонецЕсли;
		
		Запрос.Текст = Запрос.Текст + "
			|ВЫБРАТЬ
			|	Документ.Ссылка КАК Ссылка
			|ИЗ
			|	Документ." + Тип + " КАК Документ
			|ГДЕ
			|	Документ.ИнформационнаяБаза = &ИнформационнаяБаза
			| И Документ.Дата >= &Начало
			| И Документ.Дата <= &Конец";
			
	КонецЦикла;
	
	Возврат Запрос.Выполнить().Выбрать();
	
КонецФункции // НайтиДокументы()


///////////////////////////////////////////////////////////////////////////////
// РЕГИСТРЫ
//

// Записать набор записей в регистр
//
// Параметры:
//  Набор - РегистрСведенийНаборЗаписей.ЖурналПоказателей
//
Процедура ЗаписатьНаборЗаписейЖурналаПоказателей(Набор) Экспорт
	
	ИБ = Набор.Отбор.ИнформационнаяБаза.Значение;
	
	Для Каждого СтрокаНабора Из Набор Цикл
		НаборЗаписи = РегистрыСведений.ЖурналПоказателей.СоздатьНаборЗаписей();
		НаборЗаписи.Отбор.Период.Установить(СтрокаНабора.Период);
		НаборЗаписи.Отбор.ИнформационнаяБаза.Установить(ИБ);
		НаборЗаписи.Отбор.Год.Установить(СтрокаНабора.Год);
		НаборЗаписи.Отбор.Месяц.Установить(СтрокаНабора.Месяц);
		НаборЗаписи.Отбор.День.Установить(СтрокаНабора.День);
		НаборЗаписи.Отбор.Час.Установить(СтрокаНабора.Час);
		НаборЗаписи.Отбор.Минута.Установить(СтрокаНабора.Минута);
		НаборЗаписи.Отбор.Показатель.Установить(СтрокаНабора.Показатель);
		НаборЗаписи.Отбор.НомерЗаписи.Установить(СтрокаНабора.НомерЗаписи);
		СтрокаНабораЗаписи = НаборЗаписи.Добавить();
		СтрокаНабораЗаписи.Период = СтрокаНабора.Период;
		СтрокаНабораЗаписи.ИнформационнаяБаза = ИБ;
		СтрокаНабораЗаписи.Год = СтрокаНабора.Год;
		СтрокаНабораЗаписи.Месяц = СтрокаНабора.Месяц;
		СтрокаНабораЗаписи.День = СтрокаНабора.День;
		СтрокаНабораЗаписи.Час = СтрокаНабора.Час;
		СтрокаНабораЗаписи.Минута = СтрокаНабора.Минута;
		СтрокаНабораЗаписи.Показатель = СтрокаНабора.Показатель;
		СтрокаНабораЗаписи.НомерЗаписи = СтрокаНабора.НомерЗаписи;
		СтрокаНабораЗаписи.Значение = СтрокаНабора.Значение;
		НаборЗаписи.Записать();
	КонецЦикла;
	
КонецПроцедуры // ЗаписатьНаборЗаписейЖурналаПоказателей()

// Записать набор записей в регистр
//
// Параметры:
//  Набор - РегистрСведенийНаборЗаписей.ЖурналПоказателей
//
Процедура ЗаписатьНаборЗаписейЗакладки(Набор) Экспорт
	
	ИБ = Набор.Отбор.ИнформационнаяБаза.Значение;
	
	Для Каждого СтрокаНабора Из Набор Цикл
		НаборЗаписи = РегистрыСведений.Закладки.СоздатьНаборЗаписей();
		НаборЗаписи.Отбор.ИнформационнаяБаза.Установить(ИБ);
		НаборЗаписи.Отбор.Период.Установить(СтрокаНабора.Период);
		СтрокаНабораЗаписи = НаборЗаписи.Добавить();
		СтрокаНабораЗаписи.ИнформационнаяБаза = ИБ;
		СтрокаНабораЗаписи.Период = СтрокаНабора.Период;
		СтрокаНабораЗаписи.Наименование = СтрокаНабора.Наименование;
		СтрокаНабораЗаписи.Описание = СтрокаНабора.Описание;
		НаборЗаписи.Записать();
	КонецЦикла;
	
КонецПроцедуры // ЗаписатьНаборЗаписейЗакладки()

// Получить набор записей регистра для выбранной ИБ
//
// Параметры:
//  ИБ - СправочникСсылка.ИнформационноаяБаза
//  Начало - ДатаВремя, начало интервала поиска
//  Конец - ДатаВремя, конец интервала поиска
//
// Возвращаемое значение:
//  РегистрСведений.Закладки.НаборЗаписей
//
Функция ПолучитьНаборЗаписейРегистра(Регистр, Поля, ИБ, Начало, Конец) Экспорт
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("ИнформационнаяБаза", ИБ);
	Запрос.УстановитьПараметр("Начало", Начало);
	Запрос.УстановитьПараметр("Конец", Конец);
	
	ИменаПолей = ОбщегоНазначенияКлиентСервер.РазделитьСтроку(Поля, ",");
	ПервоеПоле = Истина;
	
	Запрос.Текст = "
		|ВЫБРАТЬ
		|	";
		
	Для Каждого ИмяПоля Из ИменаПолей Цикл
		Запрос.Текст = Запрос.Текст + ?(ПервоеПоле, "", "," + Символы.ПС + Символы.Таб);
		Запрос.Текст = Запрос.Текст + "Таблица." + ИмяПоля;
		ПервоеПоле = Ложь;
	КонецЦикла;
		
	Запрос.Текст = Запрос.Текст + "
		|ИЗ
		|	РегистрСведений." + Регистр + " КАК Таблица
		|ГДЕ
		|	Таблица.ИнформационнаяБаза = &ИнформационнаяБаза
		|	И Таблица.Период >= &Начало
		|	И Таблица.Период <= &Конец";
	
	Выборка = Запрос.Выполнить().Выбрать();
	Набор = РегистрыСведений[Регистр].СоздатьНаборЗаписей();
	Набор.Отбор.ИнформационнаяБаза.Установить(ИБ);
	
	Пока Выборка.Следующий() Цикл
		СтрокаНабора = Набор.Добавить();
		СтрокаНабора.ИнформационнаяБаза = ИБ;
		
		Для Каждого ИмяПоля Из ИменаПолей Цикл
			СтрокаНабора[ИмяПоля] = Выборка[ИмяПоля];
		КонецЦикла;
	КонецЦикла;
	
	Возврат Набор;
	
КонецФункции // ПолучитьНаборЗаписейЗакладок()
