
&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	ТекстПриветствия = ПолучитьОбщийМакет("Приветствие").ПолучитьТекст();
	НеОтображатьПриЗапуске = Константы.ОтключитьПриветствиеПриЗапуске.Получить();
	
КонецПроцедуры

&НаСервереБезКонтекста
Процедура НеОтображатьПриЗапускеПриИзмененииНаСервере(Значение)
	
	Константы.ОтключитьПриветствиеПриЗапуске.Установить(Значение);
	
КонецПроцедуры

&НаКлиенте
Процедура НеОтображатьПриЗапускеПриИзменении(Элемент)
	НеОтображатьПриЗапускеПриИзмененииНаСервере(НеОтображатьПриЗапуске);
КонецПроцедуры

&НаКлиенте
Процедура ТекстПриветствияДокументСформирован(Элемент)
	
	ОбщегоНазначенияКлиент.УстановитьСтильHTMLСтраницы(Элемент.Документ);
	
КонецПроцедуры

