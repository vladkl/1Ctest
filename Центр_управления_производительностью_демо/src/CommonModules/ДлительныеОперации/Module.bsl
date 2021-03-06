#Область ПрограммныйИнтерфейс

// Запустить выполнение процедуры в фоновом задании, если это возможно.
// При выполнении любого из следующих условий запуск выполняется не в фоне, а сразу в основном потоке:
//  * если приложение запущено в режиме отладки (параметр /C РежимОтладки) - для упрощения отладки конфигурации;
//  * если в файловой ИБ имеются активные фоновые задания - для снижения времени ожидания пользователя;
//  * если выполняется процедура модуля внешней обработки или внешнего отчета.
//
// Не следует использовать эту функцию, если необходимо безусловно запускать фоновое задание.
// Может применяться совместно с функцией ДлительныеОперацииКлиент.ОжидатьЗавершение.
// 
// Параметры:
//  ИмяПроцедуры           - Строка    - имя экспортной процедуры общего модуля, модуля менеджера объекта 
//                                       или модуля обработки, которую необходимо выполнить в фоне.
//                                       Например, "МойОбщийМодуль.МояПроцедура", "Отчет.ЗагруженныеДанные.Сформировать"
//                                       или "Обработка.ЗагрузкаДанных.МодульОбъекта.Загрузить". 
//                                       У процедуры может быть два или три формальных параметра:
//                                        * Параметры       - Структура - произвольные параметры ПараметрыПроцедуры;
//                                        * АдресРезультата - Строка    - адрес временного хранилища, в которое нужно
//                                          поместить результат работы процедуры. Обязательно;
//                                        * АдресДополнительногоРезультата - Строка - если в ПараметрыВыполнения установлен 
//                                          параметр ДополнительныйРезультат, то содержит адрес дополнительного временного
//                                          хранилища, в которое нужно поместить результат работы процедуры. Опционально.
//                                       При необходимости выполнить в фоне функцию, ее следует обернуть в процедуру,
//                                       а ее результат возвращать через второй параметр АдресРезультата.
//  ПараметрыПроцедуры     - Структура - произвольные параметры вызова процедуры ИмяПроцедуры.
//  ПараметрыВыполнения    - Структура - см. функцию ПараметрыВыполненияВФоне.
//
// Возвращаемое значение:
//  Структура              - параметры выполнения задания: 
//   * Статус               - Строка - "Выполняется", если задание еще не завершилось;
//                                     "Выполнено", если задание было успешно выполнено;
//                                     "Ошибка", если задание завершено с ошибкой;
//                                     "Отменено", если задание отменено пользователем или администратором.
//   * ИдентификаторЗадания - УникальныйИдентификатор - если Статус = "Выполняется", то содержит 
//                                     идентификатор запущенного фонового задания.
//   * АдресРезультата       - Строка - адрес временного хранилища, в которое будет
//                                     помещен (или уже помещен) результат работы процедуры.
//   * АдресДополнительногоРезультата - Строка - если установлен параметр ДополнительныйРезультат, 
//                                     содержит адрес дополнительного временного хранилища,
//                                     в которое будет помещен (или уже помещен) результат работы процедуры.
//   * КраткоеПредставлениеОшибки   - Строка - краткая информация об исключении, если Статус = "Ошибка".
//   * ПодробноеПредставлениеОшибки - Строка - подробная информация об исключении, если Статус = "Ошибка".
// 
Функция ВыполнитьВФоне(Знач ИмяПроцедуры, Знач ПараметрыПроцедуры, Знач ПараметрыВыполнения) Экспорт
	
	Если ПараметрыВыполнения.ЗапуститьНеВФоне И ПараметрыВыполнения.ЗапуститьВФоне Тогда
		ВызватьИсключение НСтр("ru = 'Параметры ""ВсегдаНеВФоне"" и ""ВсегдаВФоне""
			|не могут одновременно принимать значение Истина в ДлительныеОперации.ВыполнитьВФоне.'");
	КонецЕсли;
	
	АдресРезультата = ?(ПараметрыВыполнения.АдресРезультата <> Неопределено, 
	    ПараметрыВыполнения.АдресРезультата,
		ПоместитьВоВременноеХранилище(Неопределено, ПараметрыВыполнения.ИдентификаторФормы));
	
	Результат = Новый Структура;
	Результат.Вставить("Статус",    "Выполняется");
	Результат.Вставить("ИдентификаторЗадания", Неопределено);
	Результат.Вставить("АдресРезультата", АдресРезультата);
	Результат.Вставить("АдресДополнительногоРезультата", "");
	Результат.Вставить("КраткоеПредставлениеОшибки", "");
	Результат.Вставить("ПодробноеПредставлениеОшибки", "");
	Результат.Вставить("Сообщения", Новый ФиксированныйМассив(Новый Массив));
	
	ПараметрыЭкспортнойПроцедуры = Новый Массив;
	ПараметрыЭкспортнойПроцедуры.Добавить(ПараметрыПроцедуры);
	ПараметрыЭкспортнойПроцедуры.Добавить(АдресРезультата);
	
	Если ПараметрыВыполнения.ДополнительныйРезультат Тогда
		Результат.АдресДополнительногоРезультата = ПоместитьВоВременноеХранилище(Неопределено, ПараметрыВыполнения.ИдентификаторФормы);
		ПараметрыЭкспортнойПроцедуры.Добавить(Результат.АдресДополнительногоРезультата);
	КонецЕсли;
	
	// Выполнить в основном потоке.
	Если Не ПараметрыВыполнения.БезРасширений
		И (ПараметрыВыполнения.ЗапуститьНеВФоне
		Или Не ВозможноВыполнитьВФоне(ИмяПроцедуры)) Тогда
		Попытка
			ВыполнитьПроцедуру(ИмяПроцедуры, ПараметрыЭкспортнойПроцедуры);
			Результат.Статус = "Выполнено";
		Исключение
			Результат.Статус = "Ошибка";
			Результат.КраткоеПредставлениеОшибки = КраткоеПредставлениеОшибки(ИнформацияОбОшибке());
			Результат.ПодробноеПредставлениеОшибки = ПодробноеПредставлениеОшибки(ИнформацияОбОшибке());
			ЗаписьЖурналаРегистрации("Ошибка выполнения",
				УровеньЖурналаРегистрации.Ошибка, , , Результат.ПодробноеПредставлениеОшибки);
		КонецПопытки;
		Возврат Результат;
	КонецЕсли;
	
	// Выполнить в фоне.
	Попытка
		ФоновоеЗадание = ЗапуститьФоновоеФоновоеЗаданиеСКонтекстомКлиента(ИмяПроцедуры,
			ПараметрыВыполнения, ПараметрыЭкспортнойПроцедуры);
	Исключение
		Результат.Статус = "Ошибка";
		Если ФоновоеЗадание <> Неопределено И ФоновоеЗадание.ИнформацияОбОшибке <> Неопределено Тогда
			Результат.КраткоеПредставлениеОшибки = КраткоеПредставлениеОшибки(ФоновоеЗадание.ИнформацияОбОшибке);
			Результат.ПодробноеПредставлениеОшибки = ПодробноеПредставлениеОшибки(ФоновоеЗадание.ИнформацияОбОшибке);
		Иначе
			Результат.КраткоеПредставлениеОшибки = КраткоеПредставлениеОшибки(ИнформацияОбОшибке());
			Результат.ПодробноеПредставлениеОшибки = ПодробноеПредставлениеОшибки(ИнформацияОбОшибке());
		КонецЕсли;
		Возврат Результат;
	КонецПопытки;
	
	Если ФоновоеЗадание <> Неопределено И ФоновоеЗадание.ИнформацияОбОшибке <> Неопределено Тогда
		Результат.Статус = "Ошибка";
		Результат.КраткоеПредставлениеОшибки = КраткоеПредставлениеОшибки(ФоновоеЗадание.ИнформацияОбОшибке);
		Результат.ПодробноеПредставлениеОшибки = ПодробноеПредставлениеОшибки(ФоновоеЗадание.ИнформацияОбОшибке);
		Возврат Результат;
	КонецЕсли;
	
	Результат.ИдентификаторЗадания = ФоновоеЗадание.УникальныйИдентификатор;
	ФоновоеЗаданиеВыполнено = Ложь;
	
	Если ПараметрыВыполнения.ОжидатьЗавершение <> 0 Тогда
		Попытка
			ФоновоеЗадание.ОжидатьЗавершения(ПараметрыВыполнения.ОжидатьЗавершение);
			ФоновоеЗаданиеВыполнено = Истина;
		Исключение
			// Специальная обработка не требуется, возможно исключение вызвано истечением времени ожидания.
		КонецПопытки;
	КонецЕсли;
	
	Если ФоновоеЗаданиеВыполнено Тогда
		ПрогрессИСообщения = ПрочитатьПрогрессИСообщения(ФоновоеЗадание.УникальныйИдентификатор, "ПрогрессИСообщения");
		Результат.Сообщения = ПрогрессИСообщения.Сообщения;
	КонецЕсли;
	
	ЗаполнитьЗначенияСвойств(Результат, ОперацияВыполнена(ФоновоеЗадание.УникальныйИдентификатор), , "Сообщения");
	Возврат Результат;
	
КонецФункции

// Возвращает новую структуру для параметра ПараметрыВыполнения функции ВыполнитьВФоне.
//
// Параметры:
//   ИдентификаторФормы - УникальныйИдентификатор - уникальный идентификатор формы, 
//                               во временное хранилище которой надо поместить результат выполнения процедуры.
//
// Возвращаемое значение:
//   Структура - со свойствами:
//     * ИдентификаторФормы      - УникальныйИдентификатор - уникальный идентификатор формы, 
//                               во временное хранилище которой надо поместить результат выполнения процедуры.
//     * ДополнительныйРезультат - Булево     - признак использования дополнительного временного хранилища для передачи 
//                                 результата из фонового задания в родительский сеанс. По умолчанию - Ложь.
//     * ОжидатьЗавершение       - Число, Неопределено - таймаут в секундах ожидания завершения фонового задания. 
//                               Если задано Неопределено, то ждать до момента завершения задания. 
//                               Если задано 0, то ждать завершения задания не требуется. 
//                               По умолчанию - 2 секунды; а для низкой скорости соединения - 4. 
//     * НаименованиеФоновогоЗадания - Строка - описание фонового задания. По умолчанию - имя процедуры.
//     * КлючФоновогоЗадания      - Строка    - уникальный ключ для активных фоновых заданий, имеющих такое же имя процедуры.
//                                              По умолчанию, не задан.
//     * АдресРезультата          - Строка - адрес временного хранилища, в которое должен быть помещен результат
//                                           работы процедуры. Если не задан, адрес формируется автоматически.
//     * ЗапуститьВФоне           - Булево - если Истина, то задание будет всегда выполняться в фоне,
//                               за исключением режима отладки.
//                               В файловом варианте, при наличии ранее запущенных заданий,
//                               новое задание становится в очередь и начинает выполняться после завершения предыдущих.
//     * ЗапуститьНеВФоне         - Булево - если Истина, задание всегда будет запускаться непосредственно,
//                               без использования фонового задания.
//     * БезРасширений            - Булево - если Истина, то фоновое задание будет запущено без подключения
//                               расширений конфигурации.
//
Функция ПараметрыВыполненияВФоне(Знач ИдентификаторФормы) Экспорт
	
	Результат = Новый Структура;
	Результат.Вставить("ИдентификаторФормы", ИдентификаторФормы); 
	Результат.Вставить("ДополнительныйРезультат", Ложь);
	Результат.Вставить("ОжидатьЗавершение", ?(ПолучитьСкоростьКлиентскогоСоединения() = СкоростьКлиентскогоСоединения.Низкая, 4, 2));
	Результат.Вставить("НаименованиеФоновогоЗадания", "");
	Результат.Вставить("КлючФоновогоЗадания", "");
	Результат.Вставить("АдресРезультата", Неопределено);
	Результат.Вставить("ЗапуститьНеВФоне", Ложь);
	Результат.Вставить("ЗапуститьВФоне", Ложь);
	Результат.Вставить("БезРасширений", Ложь);
	Возврат Результат;
	
КонецФункции

// Регистрирует информацию о ходе выполнения фонового задания.
// В дальнейшем ее можно считать при помощи функции ПрочитатьПрогресс.
//
// Параметры:
//  Процент - Число  - Необязательный. Процент выполнения.
//  Текст   - Строка - Необязательный. Информация о текущей операции.
//  ДополнительныеПараметры - Произвольный - Необязательный. Любая дополнительная информация,
//      которую необходимо передать на клиент. Значение должно быть простым (сериализуемым в XML строку).
//
Процедура СообщитьПрогресс(Знач Процент = Неопределено, Знач Текст = Неопределено, Знач ДополнительныеПараметры = Неопределено) Экспорт
	
	Если ПолучитьТекущийСеансИнформационнойБазы().ПолучитьФоновоеЗадание() = Неопределено Тогда
		Возврат;
	КонецЕсли;
		
	ПередаваемоеЗначение = Новый Структура;
	Если Процент <> Неопределено Тогда
		ПередаваемоеЗначение.Вставить("Процент", Процент);
	КонецЕсли;
	Если Текст <> Неопределено Тогда
		ПередаваемоеЗначение.Вставить("Текст", Текст);
	КонецЕсли;
	Если ДополнительныеПараметры <> Неопределено Тогда
		ПередаваемоеЗначение.Вставить("ДополнительныеПараметры", ДополнительныеПараметры);
	КонецЕсли;
	
	ПередаваемыйТекст = ОбщегоНазначения.ЗначениеВСтрокуXML(ПередаваемоеЗначение);
	
	Текст = "{" + СообщениеПрогресса() + "}" + ПередаваемыйТекст;
	ОбщегоНазначенияКлиентСервер.СообщитьПользователю(Текст);
	
КонецПроцедуры

// Считывает информацию о ходе выполнения фонового задания.
//
// Параметры:
//   ИдентификаторЗадания - УникальныйИдентификатор - идентификатор фонового задания.
//
// Возвращаемое значение:
//   Неопределено, Структура - информация о ходе выполнения фонового задания, записанная процедурой СообщитьПрогресс:
//    * Процент                 - Число  - Необязательный. Процент выполнения.
//    * Текст                   - Строка - Необязательный. Информация о текущей операции.
//    * ДополнительныеПараметры - Произвольный - Необязательный. Любая дополнительная информация.
//
Функция ПрочитатьПрогресс(Знач ИдентификаторЗадания) Экспорт
	
	Возврат ПрочитатьПрогрессИСообщения(ИдентификаторЗадания, "Прогресс").Прогресс;
	
КонецФункции

// Отменяет выполнение фонового задания по переданному идентификатору.
// 
// Параметры:
//  ИдентификаторЗадания - УникальныйИдентификатор - идентификатор фонового задания. 
// 
Процедура ОтменитьВыполнениеЗадания(Знач ИдентификаторЗадания) Экспорт 
	
	Если Не ЗначениеЗаполнено(ИдентификаторЗадания) Тогда
		Возврат;
	КонецЕсли;
	
	ФоновоеЗадание = НайтиФоновоеЗаданиеПоИдентификатору(ИдентификаторЗадания);
	Если ФоновоеЗадание = Неопределено
		ИЛИ ФоновоеЗадание.Состояние <> СостояниеФоновогоЗадания.Активно Тогда
		
		Возврат;
	КонецЕсли;
	
	Попытка
		ФоновоеЗадание.Отменить();
	Исключение
		// Возможно задание как раз в этот момент закончилось и ошибки нет.
		ЗаписьЖурналаРегистрации("Длительные операции.Отмена выполнения фонового задания",
			УровеньЖурналаРегистрации.Предупреждение, , , ПодробноеПредставлениеОшибки(ИнформацияОбОшибке()));
	КонецПопытки;
	
КонецПроцедуры

// Проверяет состояние фонового задания по переданному идентификатору.
// При аварийном завершении задания вызывает исключение.
//
// Параметры:
//  ИдентификаторЗадания - УникальныйИдентификатор - идентификатор фонового задания. 
//
// Возвращаемое значение:
//  Булево - состояние выполнения задания.
// 
Функция ФоновоеЗаданиеВыполнено(Знач ИдентификаторЗадания) Экспорт
	
	ФоновоеЗадание = НайтиФоновоеЗаданиеПоИдентификатору(ИдентификаторЗадания);
	
	Если ФоновоеЗадание <> Неопределено
		И ФоновоеЗадание.Состояние = СостояниеФоновогоЗадания.Активно Тогда
		Возврат Ложь;
	КонецЕсли;
	
	ОперацияНеВыполнена = Истина;
	ПоказатьПолныйТекстОшибки = Ложь;
	Если ФоновоеЗадание = Неопределено Тогда
		ЗаписьЖурналаРегистрации("Длительные операции.Фоновое задание не найдено",
			УровеньЖурналаРегистрации.Ошибка, , , Строка(ИдентификаторЗадания));
	Иначе
		Если ФоновоеЗадание.Состояние = СостояниеФоновогоЗадания.ЗавершеноАварийно Тогда
			ОшибкаЗадания = ФоновоеЗадание.ИнформацияОбОшибке;
			Если ОшибкаЗадания <> Неопределено Тогда
				ПоказатьПолныйТекстОшибки = Истина;
			КонецЕсли;
		ИначеЕсли ФоновоеЗадание.Состояние = СостояниеФоновогоЗадания.Отменено Тогда
			ЗаписьЖурналаРегистрации(
				"Длительные операции.Фоновое задание отменено администратором",
				УровеньЖурналаРегистрации.Ошибка,
				,
				,
				НСтр("ru = 'ФоновоеЗадание завершилось с неизвестной ошибкой.'"));
		Иначе
			Возврат Истина;
		КонецЕсли;
	КонецЕсли;
	
	Если ПоказатьПолныйТекстОшибки Тогда
		ТекстОшибки = КраткоеПредставлениеОшибки(ФоновоеЗадание.ИнформацияОбОшибке);
		ВызватьИсключение(ТекстОшибки);
	ИначеЕсли ОперацияНеВыполнена Тогда
		ВызватьИсключение(НСтр("ru = 'Не удалось выполнить данную операцию. 
		                             |Подробности см. в Журнале регистрации.'"));
	КонецЕсли;
	
КонецФункции

#КонецОбласти

#Область СлужебныйПрограммныйИнтерфейс

Функция ОперацияВыполнена(Знач ИдентификаторЗадания, Знач ИсключениеПриОшибке = Ложь, Знач ВыводитьПрогрессВыполнения = Ложь, 
	Знач ВыводитьСообщения = Ложь) Экспорт
	
	Результат = Новый Структура;
	Результат.Вставить("Статус", "Выполняется");
	Результат.Вставить("КраткоеПредставлениеОшибки", Неопределено);
	Результат.Вставить("ПодробноеПредставлениеОшибки", Неопределено);
	Результат.Вставить("Прогресс", Неопределено);
	Результат.Вставить("Сообщения", Неопределено);
	
	ФоновоеЗадание = НайтиФоновоеЗаданиеПоИдентификатору(ИдентификаторЗадания);
	Если ФоновоеЗадание = Неопределено Тогда
		ЗаписьЖурналаРегистрации("Длительные операции",
			УровеньЖурналаРегистрации.Ошибка, , , НСтр("ru = 'Фоновое задание не найдено:'") + " " + Строка(ИдентификаторЗадания));
		Если ИсключениеПриОшибке Тогда
			ВызватьИсключение(НСтр("ru = 'Не удалось выполнить данную операцию.'"));
		КонецЕсли;
		Результат.Статус = "Ошибка";
		Возврат Результат;
	КонецЕсли;
	
	Если ВыводитьПрогрессВыполнения Тогда
		ПрогрессИСообщения = ПрочитатьПрогрессИСообщения(ИдентификаторЗадания, ?(ВыводитьСообщения, "ПрогрессИСообщения", "Прогресс"));
		Результат.Прогресс = ПрогрессИСообщения.Прогресс;
		Если ВыводитьСообщения Тогда
			Результат.Сообщения = ПрогрессИСообщения.Сообщения;
		КонецЕсли;
	ИначеЕсли ВыводитьСообщения Тогда
		Результат.Сообщения = ФоновоеЗадание.ПолучитьСообщенияПользователю(Истина);
	КонецЕсли;
	
	Если ФоновоеЗадание.Состояние = СостояниеФоновогоЗадания.Активно Тогда
		Возврат Результат;
	КонецЕсли;
	
	Если ФоновоеЗадание.Состояние = СостояниеФоновогоЗадания.Отменено Тогда
		Результат.Статус = "Отменено";
		Возврат Результат;
	КонецЕсли;
	
	Если ФоновоеЗадание.Состояние = СостояниеФоновогоЗадания.ЗавершеноАварийно 
		Или ФоновоеЗадание.Состояние = СостояниеФоновогоЗадания.Отменено Тогда
		
		Результат.Статус = "Ошибка";
		Если ФоновоеЗадание.ИнформацияОбОшибке <> Неопределено Тогда
			Результат.КраткоеПредставлениеОшибки   = КраткоеПредставлениеОшибки(ФоновоеЗадание.ИнформацияОбОшибке);
			Результат.ПодробноеПредставлениеОшибки = ПодробноеПредставлениеОшибки(ФоновоеЗадание.ИнформацияОбОшибке);
		КонецЕсли;
		Если ИсключениеПриОшибке Тогда
			Если Не ПустаяСтрока(Результат.КраткоеПредставлениеОшибки) Тогда
				ТекстСообщения = Результат.КраткоеПредставлениеОшибки;
			Иначе
				ТекстСообщения = НСтр("ru = 'Не удалось выполнить данную операцию.'");
			КонецЕсли;
			ВызватьИсключение ТекстСообщения;
		КонецЕсли;
		Возврат Результат;
	КонецЕсли;
	
	Результат.Статус = "Выполнено";
	Возврат Результат;
	
КонецФункции

Функция СообщениеПрогресса() Экспорт
	Возврат "СтандартныеПодсистемы.ДлительныеОперации";
КонецФункции

Процедура ВыполнитьПроцедуруМодуляОбъектаОбработки(Параметры, АдресХранилища) Экспорт 
	Если Параметры.ЭтоВнешняяОбработка Тогда
		Ссылка = ОбщегоНазначенияКлиентСервер.СвойствоСтруктуры(Параметры, "ДополнительнаяОбработкаСсылка");
		Обработка = ВнешниеОбработки.Создать(Параметры.ИмяОбработки, БезопасныйРежим());
	Иначе
		Обработка = Обработки[Параметры.ИмяОбработки].Создать();
	КонецЕсли;
	
	ПараметрыМетода = Новый Массив;
	ПараметрыМетода.Добавить(Параметры.ПараметрыВыполнения);
	ПараметрыМетода.Добавить(АдресХранилища);
	ОбщегоНазначения.ВыполнитьМетодОбъекта(Обработка, Параметры.ИмяМетода, ПараметрыМетода);
КонецПроцедуры

Процедура ВыполнитьПроцедуруМодуляОбъектаОтчета(Параметры, АдресХранилища) Экспорт
	Если Параметры.ЭтоВнешнийОтчет Тогда
		Отчет = ВнешниеОтчеты.Создать(Параметры.ИмяОтчета, БезопасныйРежим());
	Иначе
		Отчет = Отчеты[Параметры.ИмяОтчета].Создать();
	КонецЕсли;
	
	ПараметрыМетода = Новый Массив;
	ПараметрыМетода.Добавить(Параметры.ПараметрыВыполнения);
	ПараметрыМетода.Добавить(АдресХранилища);
	ОбщегоНазначения.ВыполнитьМетодОбъекта(Отчет, Параметры.ИмяМетода, ПараметрыМетода);
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Функция ОперацииВыполнены(Знач Задания) Экспорт
	
	Результат = Новый Соответствие;
	Для каждого ФоновоеЗадание Из Задания Цикл
		Результат.Вставить(ФоновоеЗадание.ИдентификаторЗадания, 
			ОперацияВыполнена(ФоновоеЗадание.ИдентификаторЗадания, Ложь, ФоновоеЗадание.ВыводитьПрогрессВыполнения, ФоновоеЗадание.ВыводитьСообщения));
	КонецЦикла;
	Возврат Результат;
	
КонецФункции

Функция ЗапуститьФоновоеФоновоеЗаданиеСКонтекстомКлиента(ИмяПроцедуры,
	ПараметрыВыполнения, ПараметрыПроцедуры = Неопределено) Экспорт
	
	КлючФоновогоЗадания = ПараметрыВыполнения.КлючФоновогоЗадания;
	НаименованиеФоновогоЗадания = ?(ПустаяСтрока(ПараметрыВыполнения.НаименованиеФоновогоЗадания),
		ИмяПроцедуры, ПараметрыВыполнения.НаименованиеФоновогоЗадания);
		
	ВсеПараметры = Новый Структура;
	ВсеПараметры.Вставить("ИмяПроцедуры",       ИмяПроцедуры);
	ВсеПараметры.Вставить("ПараметрыПроцедуры", ПараметрыПроцедуры);
	
	ПараметрыПроцедурыФоновогоЗадания = Новый Массив;
	ПараметрыПроцедурыФоновогоЗадания.Добавить(ВсеПараметры);
	
	Возврат ВыполнитьФоновоеФоновоеЗадание(ПараметрыВыполнения,
		"ДлительныеОперации.ВыполнитьСКонтекстомКлиента", ПараметрыПроцедурыФоновогоЗадания,
		КлючФоновогоЗадания, НаименованиеФоновогоЗадания);
	
КонецФункции

// Продолжение процедуры ЗапуститьФоновоеФоновоеЗаданиеСКонтекстомКлиента.
Процедура ВыполнитьСКонтекстомКлиента(ВсеПараметры) Экспорт
	
	ВыполнитьПроцедуру(ВсеПараметры.ИмяПроцедуры, ВсеПараметры.ПараметрыПроцедуры);
	
КонецПроцедуры

Процедура ВыполнитьПроцедуру(ИмяПроцедуры, ПараметрыПроцедуры)
	
	ЧастиИмени = СтрРазделить(ИмяПроцедуры, ".");
	ЭтоПроцедураМодуляОбработки = (ЧастиИмени.Количество() = 4) И ВРег(ЧастиИмени[2]) = "МОДУЛЬОБЪЕКТА";
	Если Не ЭтоПроцедураМодуляОбработки Тогда
		ОбщегоНазначения.ВыполнитьМетодКонфигурации(ИмяПроцедуры, ПараметрыПроцедуры);
		Возврат;
	КонецЕсли;
	
	ЭтоОбработка = ВРег(ЧастиИмени[0]) = "ОБРАБОТКА";
	ЭтоОтчет = ВРег(ЧастиИмени[0]) = "ОТЧЕТ";
	Если ЭтоОбработка Или ЭтоОтчет Тогда
		МенеджерОбъекта = ?(ЭтоОтчет, Отчеты, Обработки);
		ОбработкаОтчетОбъект = МенеджерОбъекта[ЧастиИмени[1]].Создать();
		ОбщегоНазначения.ВыполнитьМетодОбъекта(ОбработкаОтчетОбъект, ЧастиИмени[3], ПараметрыПроцедуры);
		Возврат;
	КонецЕсли;
	
	ЭтоВнешняяОбработка = ВРег(ЧастиИмени[0]) = "ВНЕШНЯЯОБРАБОТКА";
	ЭтоВнешнийОтчет = ВРег(ЧастиИмени[0]) = "ВНЕШНИЙОТЧЕТ";
	Если ЭтоВнешняяОбработка Или ЭтоВнешнийОтчет Тогда
		ВыполнитьПроверкуПравДоступа("ИнтерактивноеОткрытиеВнешнихОбработок", Метаданные);
		МенеджерОбъекта = ?(ЭтоВнешнийОтчет, ВнешниеОтчеты, ВнешниеОбработки);
		ОбработкаОтчетОбъект = МенеджерОбъекта.Создать(ЧастиИмени[1], БезопасныйРежим());
		ОбщегоНазначения.ВыполнитьМетодОбъекта(ОбработкаОтчетОбъект, ЧастиИмени[3], ПараметрыПроцедуры);
		Возврат;
	КонецЕсли;
	
	ВызватьИсключение ОценкаПроизводительностиКлиентСервер.ПодставитьПараметрыВСтроку(
		НСтр("ru = 'Неверный формат параметра ИмяПроцедуры (переданное значение: %1)'"), ИмяПроцедуры);
	
КонецПроцедуры

Функция НайтиФоновоеЗаданиеПоИдентификатору(Знач ИдентификаторЗадания)
	
	Если ТипЗнч(ИдентификаторЗадания) = Тип("Строка") Тогда
		ИдентификаторЗадания = Новый УникальныйИдентификатор(ИдентификаторЗадания);
	КонецЕсли;
	
	ФоновоеЗадание = ФоновыеЗадания.НайтиПоУникальномуИдентификатору(ИдентификаторЗадания);
	Возврат ФоновоеЗадание;
	
КонецФункции

// Считывает информацию о ходе выполнения фонового задания и сообщения, которые в нем были сформированы.
//
// Параметры:
//   ИдентификаторЗадания - УникальныйИдентификатор - идентификатор фонового задания.
//   Режим                - Строка - "ПрогрессИСообщения", "Прогресс" или "Сообщения".
//
// Возвращаемое значение:
//   Структура - со свойствами:
//    * Прогресс  - Неопределено, Структура - Информация о ходе выполнения фонового задания, записанная процедурой СообщитьПрогресс:
//     ** Процент                 - Число  - Необязательный. Процент выполнения.
//     ** Текст                   - Строка - Необязательный. Информация о текущей операции.
//     ** ДополнительныеПараметры - Произвольный - Необязательный. Любая дополнительная информация.
//    * Сообщения - ФиксированныйМассив - Массив объектов СообщениеПользователю, которые были сформированы в фоновом задании.
//
Функция ПрочитатьПрогрессИСообщения(Знач ИдентификаторЗадания, Знач Режим = "ПрогрессИСообщения")
	
	Результат = Новый Структура("Сообщения, Прогресс", Новый Массив, Неопределено);
	
	ФоновоеЗадание = ФоновыеЗадания.НайтиПоУникальномуИдентификатору(ИдентификаторЗадания);
	Если ФоновоеЗадание = Неопределено Тогда
		Возврат Результат;
	КонецЕсли;
	
	МассивСообщений = ФоновоеЗадание.ПолучитьСообщенияПользователю(Истина);
	Если МассивСообщений = Неопределено Тогда
		Возврат Результат;
	КонецЕсли;
	
	Количество = МассивСообщений.Количество();
	Сообщения = Новый Массив;
	ЧитатьСообщения = (Режим = "ПрогрессИСообщения" Или Режим = "Сообщения"); 
	ЧитатьПрогресс  = (Режим = "ПрогрессИСообщения" Или Режим = "Прогресс"); 
	
	Если ЧитатьСообщения И Не ЧитатьПрогресс Тогда
		Результат.Сообщения = Новый ФиксированныйМассив(МассивСообщений);
		Возврат Результат;
	КонецЕсли;
	
	Для Номер = 0 По Количество - 1 Цикл
		Сообщение = МассивСообщений[Номер];
		
		Если ЧитатьПрогресс И СтрНачинаетсяС(Сообщение.Текст, "{") Тогда
			Позиция = СтрНайти(Сообщение.Текст, "}");
			Если Позиция > 2 Тогда
				ИдентификаторМеханизма = Сред(Сообщение.Текст, 2, Позиция - 2);
				Если ИдентификаторМеханизма = СообщениеПрогресса() Тогда
					ПолученныйТекст = Сред(Сообщение.Текст, Позиция + 1);
					Результат.Прогресс = ОбщегоНазначения.ЗначениеИзСтрокиXML(ПолученныйТекст);
					Продолжить;
				КонецЕсли;
			КонецЕсли;
		КонецЕсли;
		Если ЧитатьСообщения Тогда
			Сообщения.Добавить(Сообщение);
		КонецЕсли;
	КонецЦикла;
	
	Результат.Сообщения = Новый ФиксированныйМассив(Сообщения);
	Возврат Результат;
	
КонецФункции

Функция ВозможноВыполнитьВФоне(ИмяПроцедуры)
	
	ЧастиИмени = СтрРазделить(ИмяПроцедуры, ".");
	Если ЧастиИмени.Количество() = 0 Тогда
		Возврат Ложь;
	КонецЕсли;
	
	ЭтоВнешняяОбработка = (ВРег(ЧастиИмени[0]) = "ВНЕШНЯЯОБРАБОТКА");
	ЭтоВнешнийОтчет = (ВРег(ЧастиИмени[0]) = "ВНЕШНИЙОТЧЕТ");
	Возврат Не (ЭтоВнешняяОбработка Или ЭтоВнешнийОтчет);

КонецФункции

Функция ВыполнитьФоновоеФоновоеЗадание(ПараметрыВыполнения, ИмяМетода, Параметры, Ключ, Наименование)
	
	Возврат ФоновыеЗадания.Выполнить(ИмяМетода, Параметры, Ключ, Наименование);
	
КонецФункции

#КонецОбласти
