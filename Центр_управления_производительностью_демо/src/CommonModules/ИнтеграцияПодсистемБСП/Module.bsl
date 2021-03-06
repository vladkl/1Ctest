////////////////////////////////////////////////////////////////////////////////
// Интеграция подсистем библиотеки друг с другом.
// Здесь размещена обработка программных событий, возникающих в подсистемах-источниках,
// в тех случаях, когда подсистем-приемников более одной или их список заранее неизвестен.
//

#Область СлужебныйПрограммныйИнтерфейс

#Область БазоваяФункциональность

// См. ОбщегоНазначенияПереопределяемый.ПриДобавленииОбработчиковУстановкиПараметровСеанса.
Процедура ПриДобавленииОбработчиковУстановкиПараметровСеанса(Обработчики) Экспорт
	
	ОбновлениеИнформационнойБазыСлужебный.ПриДобавленииОбработчиковУстановкиПараметровСеанса(Обработчики);
	
	МодульОценкаПроизводительностиСлужебный = ОбщегоНазначения.ОбщийМодуль("ОценкаПроизводительностиСлужебный");
	МодульОценкаПроизводительностиСлужебный.ПриДобавленииОбработчиковУстановкиПараметровСеанса(Обработчики);
	
КонецПроцедуры

// См. ОбщегоНазначенияПереопределяемый.ПриДобавленииПараметровРаботыКлиентаПриЗапуске.
Процедура ПриДобавленииПараметровРаботыКлиентаПриЗапуске(Параметры) Экспорт
	
	МодульИнформацияПриЗапуске = ОбщегоНазначения.ОбщийМодуль("ИнформацияПриЗапуске");
	МодульИнформацияПриЗапуске.ПриДобавленииПараметровРаботыКлиентаПриЗапуске(Параметры);
	
	ОбновлениеИнформационнойБазыСлужебный.ПриДобавленииПараметровРаботыКлиентаПриЗапуске(Параметры);
	
	МодульОценкаПроизводительностиСлужебный = ОбщегоНазначения.ОбщийМодуль("ОценкаПроизводительностиСлужебный");
	МодульОценкаПроизводительностиСлужебный.ПриДобавленииПараметровРаботыКлиентаПриЗапуске(Параметры);
	
	//Если ОбщегоНазначения.ПодсистемаСуществует("СтандартныеПодсистемы.ЦентрМониторинга") Тогда
	//	МодульЦентрМониторингаСлужебный = ОбщегоНазначения.ОбщийМодуль("ЦентрМониторингаСлужебный");
	//	МодульЦентрМониторингаСлужебный.ПриДобавленииПараметровРаботыКлиентаПриЗапуске(Параметры);
	//КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область ОбновлениеВерсииИБ

// См. ОбновлениеИнформационнойБазыБСП.ПриДобавленииОбработчиковОбновления.
Процедура ПриДобавленииОбработчиковОбновления(Обработчики) Экспорт
	
	МодульИнформацияПриЗапуске = ОбщегоНазначения.ОбщийМодуль("ИнформацияПриЗапуске");
	МодульИнформацияПриЗапуске.ПриДобавленииОбработчиковОбновления(Обработчики);
	
	ОбновлениеИнформационнойБазыСлужебный.ПриДобавленииОбработчиковОбновления(Обработчики);
	
	МодульОценкаПроизводительностиСлужебный = ОбщегоНазначения.ОбщийМодуль("ОценкаПроизводительностиСлужебный");
	МодульОценкаПроизводительностиСлужебный.ПриДобавленииОбработчиковОбновления(Обработчики);
	
КонецПроцедуры

// См. ОбновлениеИнформационнойБазыБСП.ПослеОбновленияИнформационнойБазы.
Процедура ПослеОбновленияИнформационнойБазы(Знач ПредыдущаяВерсия, Знач ТекущаяВерсия,
	Знач ВыполненныеОбработчики, ВыводитьОписаниеОбновлений, МонопольныйРежим) Экспорт
	
	МодульИнформацияПриЗапуске = ОбщегоНазначения.ОбщийМодуль("ИнформацияПриЗапуске");
	МодульИнформацияПриЗапуске.ПослеОбновленияИнформационнойБазы(ПредыдущаяВерсия, ТекущаяВерсия,
		ВыполненныеОбработчики, ВыводитьОписаниеОбновлений, МонопольныйРежим);
	
КонецПроцедуры

#КонецОбласти

#КонецОбласти
