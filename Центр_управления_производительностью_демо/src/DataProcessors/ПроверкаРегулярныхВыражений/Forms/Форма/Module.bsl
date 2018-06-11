
#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура СоответсвуетШаблону(Команда)
	
	Объект.РезультатВыполнения = "";
	
	РезультатПоиска = РегулярныеВыраженияКлиентСервер.НайтиСовпаденияПоШаблонуПоиска(Объект.ВходныеДанные, Объект.ШаблонПоиска, Истина);
	РезультатМассив = Новый Массив;
	Если РезультатПоиска.Количество() > 0 Тогда
		Для Каждого ТекСовпадение Из РезультатПоиска Цикл
			РезультатМассив.Добавить(ТекСовпадение[0]);
		КонецЦикла;
	КонецЕсли;
	
	Если РегулярныеВыраженияКлиентСервер.СоответствуетШаблонуПоиска(Объект.ВходныеДанные, Объект.ШаблонПоиска) Тогда
		РезультатМассив.Добавить("Соответствует шаблону: ДА");
	Иначе
		РезультатМассив.Добавить("Соответствует шаблону: НЕТ");
	КонецЕсли;
	
	Объект.РезультатВыполнения = СтрСоединить(РезультатМассив, Символы.ПС);
	
КонецПроцедуры

&НаКлиенте
Процедура Заменить(Команда)
	
	Объект.РезультатВыполнения = РегулярныеВыраженияКлиентСервер.ЗаменитьПоШаблонуПоиска(Объект.ВходныеДанные, Объект.ШаблонПоиска, Объект.ШаблонЗамены);
	
КонецПроцедуры

#КонецОбласти
