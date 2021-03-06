#Область СлужебныеПроцедурыИФункции

// См. описание этой же функции в модуле ОбновлениеИнформационнойБазыСлужебный.
Функция ВыполнитьОбновлениеИнформационнойБазы(ПриЗапускеКлиентскогоПриложения = Ложь, Перезапустить = Ложь, ВыполнятьОтложенныеОбработчики = Ложь) Экспорт
	
	ПараметрыОбновления = ОбновлениеИнформационнойБазыСлужебный.ПараметрыОбновления();
	ПараметрыОбновления.ПриЗапускеКлиентскогоПриложения = ПриЗапускеКлиентскогоПриложения;
	ПараметрыОбновления.Перезапустить = Перезапустить;
	ПараметрыОбновления.ВыполнятьОтложенныеОбработчики = ВыполнятьОтложенныеОбработчики;
	
	Попытка
		Результат = ОбновлениеИнформационнойБазыСлужебный.ВыполнитьОбновлениеИнформационнойБазы(ПараметрыОбновления);
	Исключение
		ВызватьИсключение;
	КонецПопытки;
	
	Перезапустить = ПараметрыОбновления.Перезапустить;
	Возврат Результат;
	
КонецФункции

// Снимает блокировку информационной файловой базы.
Процедура СнятьБлокировкуФайловойБазы() Экспорт
	
	Если Не ОбщегоНазначения.ИнформационнаяБазаФайловая() Тогда
		Возврат;
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти
