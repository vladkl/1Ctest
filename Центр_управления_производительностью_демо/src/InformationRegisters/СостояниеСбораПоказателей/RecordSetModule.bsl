
Процедура ПриЗаписи(Отказ, Замещение)
	
	МножествоВкл = Новый Соответствие;
	МножествоВыкл = Новый Соответствие;
	Для Каждого ТекЗапись Из ЭтотОбъект Цикл
		АгентыЦКК = Справочники.ИнформационныеБазы.ПолучитьСписокАгентов(ТекЗапись.ИнформационнаяБаза);
		Для Каждого ТекАгент Из АгентыЦКК Цикл
			Если ТекЗапись.ВключенСборСчетчиков Тогда
				МножествоВкл.Вставить(ТекАгент);
			Иначе
				МножествоВыкл.Вставить(ТекАгент);
			КонецЕсли;
		КонецЦикла;
	КонецЦикла;
	
	Для Каждого ТекАгент Из МножествоВкл Цикл
		Справочники.АгентыЦКК.ВключитьСборСчетчиковПроизводительности(ТекАгент.Ключ);
	КонецЦикла;
	
	Для Каждого ТекАгент Из МножествоВыкл Цикл
		Справочники.АгентыЦКК.ОтключитьСборСчетчиковПроизводительности(ТекАгент.Ключ);
	КонецЦикла;
	
КонецПроцедуры
