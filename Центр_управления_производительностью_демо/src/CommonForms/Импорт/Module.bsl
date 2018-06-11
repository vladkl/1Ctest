
&НаКлиенте
// Выбор имени файла
//
Процедура ИмяФайлаНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	
	ДиалогВыбора = Новый ДиалогВыбораФайла(РежимДиалогаВыбораФайла.Открытие);
	ДиалогВыбора.Фильтр = "ZIP архив(*.zip)|*.zip";
	ДиалогВыбора.Расширение = "zip";
	
	ОписаниеОповещения = Новый ОписаниеОповещения("ИмяФайлаНачалоВыбораЗавершение", ЭтотОбъект);
	ДиалогВыбора.Показать(ОписаниеОповещения);
	
КонецПроцедуры

// <Описание процедуры>
//
// Параметры:
//  <Параметр1>  - <Тип.Вид> - <описание параметра>
//                 <продолжение описания параметра>
//  <Параметр2>  - <Тип.Вид> - <описание параметра>
//                 <продолжение описания параметра>
//
&НаКлиенте
Процедура ИмяФайлаНачалоВыбораЗавершение(Результат, ДополнительныеПараметры) Экспорт
	
	Если Результат <> Неопределено Тогда
		ИмяФайла = Результат[0];
	КонецЕсли;
	
КонецПроцедуры // ОписаниеОповещения()

&НаКлиенте
Процедура КомандаИмпорт(Команда)
	
	Если ПустаяСтрока(ИмяФайла) Тогда
		ИнтерфейсыКлиент.Предупредить(СловарьКлиентСервер.Получить("ПредупреждениеНеУказаноИмяФайла"));
		Возврат;
	КонецЕсли;
	
	ОтладкаКлиентСервер.Действие("Импорт", ИмяФайла);
	ДанныеДляИмпорта = Новый ДвоичныеДанные(ИмяФайла);
	АдресВоВременномХранилище = ПоместитьВоВременноеХранилище(ДанныеДляИмпорта);
	ОписаниеОшибки = "";
	Если ИмпортироватьНаСервере(АдресВоВременномХранилище, ОписаниеОшибки) = Истина Тогда
		ИнтерфейсыКлиент.Предупредить(СловарьКлиентСервер.Получить("ПредупреждениеДанныеИмпортированы"));
	Иначе
		ИнтерфейсыКлиент.Предупредить(ОписаниеОшибки,, СловарьКлиентСервер.Получить("ПредупреждениеДанныеНеИмпортированы"));
	КонецЕсли;
	
КонецПроцедуры

// Импортировать даные замеров информационной базы
//
// Параметры:
//  <Параметр1>  - <Тип.Вид> - <описание параметра>
//                 <продолжение описания параметра>
//  <Параметр2>  - <Тип.Вид> - <описание параметра>
//                 <продолжение описания параметра>
//
// Возвращаемое значение:
//   <Тип.Вид>   - <описание возвращаемого значения>
//
&НаСервереБезКонтекста
Функция ИмпортироватьНаСервере(АдресВоВременномХранилище, ОписаниеОшибки)
	
	Описание = СловарьКлиентСервер.Получить("Распаковка");
	
	ИмяВременногоФайла = ПолучитьИмяВременногоФайла();
	ДанныеДляИмпорта = ПолучитьИзВременногоХранилища(АдресВоВременномХранилище);
	ДанныеДляИмпорта.Записать(ИмяВременногоФайла);
	ВременныйКаталог = ОбщегоНазначенияКлиентСервер.ИмяКаталога(ИмяВременногоФайла) + "/" + Строка(Новый УникальныйИдентификатор);
	ЧтениеPMC = Новый ЧтениеZipФайла(ИмяВременногоФайла);
	ЧтениеPMC.ИзвлечьВсе(ВременныйКаталог);
	ЧтениеPMC.Закрыть();
	
	// Проверка версии файла
	ТекстовыйДокумент = Новый ТекстовыйДокумент;
	ТекстовыйДокумент.Прочитать(ВременныйКаталог +  "/Description.txt");
	ВерсияФайлаЭкспорта = ТекстовыйДокумент.ПолучитьСтроку(1);
	ВерсияФайлаЭкспорта = СтрЗаменить(ВерсияФайлаЭкспорта, "Версия              : ", "");
	ВерсияВФорматеДляСравнения = ОбщегоНазначенияКлиентСервер.ВерсияВФорматеДляСравнения(ВерсияФайлаЭкспорта);
	Если ВерсияВФорматеДляСравнения < 0002000100000001 Тогда
		ОписаниеОшибки = СловарьКлиентСервер.Получить("ПредупреждениеЗамерыНесовместимойВерсии");
		Возврат Ложь;
	КонецЕсли;
	
	ЧтениеXML = Новый ЧтениеXML;
	Файлы = НайтиФайлы(ВременныйКаталог, СловарьКлиентСервер.Получить("МаскаФайлаПакетаДанных"));
	//ЭлементыФормы.ИндикаторПакетов.МаксимальноеЗначение = Файлы.Количество();
	ИндикаторПакетов = 0;
	ТекущийНомер = 0;
	Всего = 0;
	
	Для Каждого Файл Из Файлы Цикл
		ЧтениеXML.ОткрытьФайл(Файл.ПолноеИмя);
		ЧтениеXML.ПерейтиКСодержимому();
		ЧтениеXML.ПрочитатьАтрибут();
		ТекущееКоличество = Число(ЧтениеXML.ЗначениеАтрибута(0));
		ЧтениеXML.Прочитать();
		//ЭлементыФормы.Индикатор.МаксимальноеЗначение = ТекущееКоличество;
		Всего = Всего + ТекущееКоличество;
		Индикатор = 0;
		
		НачатьТранзакцию();
		Попытка
			Пока ВозможностьЧтенияXML(ЧтениеXML) Цикл
				Объект = ПрочитатьXML(ЧтениеXML);
				Описание = Объект;
				Объект.ОбменДанными.Загрузка = Истина;
				ТипОбъекта = ТипЗнч(Объект);
				
				Если ТипОбъекта = Тип("РегистрСведенийНаборЗаписей.ЖурналПоказателей") Тогда
					Обмен.ЗаписатьНаборЗаписейЖурналаПоказателей(Объект);
				ИначеЕсли ТипОбъекта = Тип("РегистрСведенийНаборЗаписей.Закладки") Тогда
					Обмен.ЗаписатьНаборЗаписейЗакладки(Объект);
				Иначе
					Если ОбщегоНазначения.ЭтоСсылкаНаСправочник(Объект.Ссылка) Тогда
						Объект.УстановитьНовыйКод();
					Иначе
						Объект.УстановитьНовыйНомер();
					КонецЕсли;
					Объект.Записать();
				КонецЕсли;
				
				Индикатор = Индикатор + 1;
				ТекущийНомер = ТекущийНомер + 1;
			КонецЦикла;
		Исключение
			ОтменитьТранзакцию();
			ОтладкаКлиентСервер.Ошибка(ИнформацияОбОшибке());
			ЧтениеXML.Закрыть();
			УдалитьФайлы(ВременныйКаталог);
			Возврат Ложь;
		КонецПопытки;
		ЗафиксироватьТранзакцию();
		
		ЧтениеXML.Закрыть();
		ИндикаторПакетов = ИндикаторПакетов + 1;
	КонецЦикла;
	
	УдалитьФайлы(ВременныйКаталог);
	УдалитьФайлы(ИмяВременногоФайла);
	Описание = "";
	Индикатор = 0;
	ТекущийНомер = 0;
	ИндикаторПакетов = 0;
	ОтладкаКлиентСервер.Результат("Импорт", Всего);
	Всего = 0;
	
	Возврат Истина;
	
КонецФункции // ЭкспортироватьНаСервере()

