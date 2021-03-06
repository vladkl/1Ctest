
&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	УстановитьМакетHTML(Параметры.ИмяМакета);
	Заголовок = Параметры.Заголовок;
	
КонецПроцедуры

&НаСервере
// Установить макет просматриваемого HTML
//
// Параметры:
//  МакетHTML - ОбъектМетаданных, макет HTML
//
Процедура УстановитьМакетHTML(ИмяМакетаHTML) Экспорт
	
	МакетHTML = Справочники.ИнформационныеБазы.ПолучитьМакет(ИмяМакетаHTML);
	HTML = МакетHTML.ПолучитьТекст();
	
КонецПроцедуры // УстановитьМакетHTML()

&НаКлиенте
Процедура КомандаНазад(Команда)
	
	Элементы.HTML.Назад();
	
КонецПроцедуры

&НаКлиенте
Процедура КомандаВперед(Команда)
	
	Элементы.HTML.Вперед();
	
КонецПроцедуры

