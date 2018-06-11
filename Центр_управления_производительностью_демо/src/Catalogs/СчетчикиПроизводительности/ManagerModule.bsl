
Процедура ИнициализироватьСчетчики() Экспорт
	
	ТаблицаСчетчиков = Новый ТаблицаЗначений;
	ТаблицаСчетчиков.Колонки.Добавить("Имя", Новый ОписаниеТипов("Строка",, Новый КвалификаторыСтроки(100)));
	ТаблицаСчетчиков.Колонки.Добавить("Код", Новый ОписаниеТипов("Строка",, Новый КвалификаторыСтроки(100)));
	ТаблицаСчетчиков.Колонки.Добавить("Наименование", Новый ОписаниеТипов("Строка",, Новый КвалификаторыСтроки(100)));
	
	Макет = ПолучитьМакет("ПредопределенныеСчетчики");
	Для НомерСтроки = 2 По Макет.ВысотаТаблицы Цикл
		СтрокаТаблицы = ТаблицаСчетчиков.Добавить();
		СтрокаТаблицы.Имя = Макет.Область(НомерСтроки, 1).Текст;
		СтрокаТаблицы.Код = Макет.Область(НомерСтроки, 2).Текст;
		СтрокаТаблицы.Наименование = Макет.Область(НомерСтроки, 3).Текст;
	КонецЦикла;
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	ПредопределенныеСчетчики.Имя КАК Имя,
	|	ПредопределенныеСчетчики.Код КАК Код,
	|	ПредопределенныеСчетчики.Наименование КАК Наименование
	|ПОМЕСТИТЬ ПредопределенныеСчетчики
	|ИЗ
	|	&ПредопределенныеСчетчики КАК ПредопределенныеСчетчики
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ПредопределенныеСчетчики.Имя КАК Имя,
	|	ПредопределенныеСчетчики.Код КАК Код,
	|	ПредопределенныеСчетчики.Наименование КАК Наименование
	|ИЗ
	|	ПредопределенныеСчетчики КАК ПредопределенныеСчетчики
	|		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.СчетчикиПроизводительности КАК СчетчикиПроизводительности
	|		ПО СчетчикиПроизводительности.КодСчетчика = ПредопределенныеСчетчики.Имя
	|ГДЕ
	|	СчетчикиПроизводительности.Ссылка ЕСТЬ NULL";
	
	Запрос.УстановитьПараметр("ПредопределенныеСчетчики", ТаблицаСчетчиков);
	
	РезультатЗапроса = Запрос.Выполнить();
	Выборка = РезультатЗапроса.Выбрать();
	Пока Выборка.Следующий() Цикл
		ШаблонСчетчика = ПолучитьШаблонСчетчика(Выборка.Имя);
		
		НовыйОбъект = Справочники.СчетчикиПроизводительности.СоздатьЭлемент();
		НовыйОбъект.Код = Выборка.Код;
		НовыйОбъект.КодСчетчика = Выборка.Имя;
		НовыйОбъект.Наименование = ШаблонСчетчика["Наименование"];
		НовыйОбъект.Описание = ШаблонСчетчика["Описание"];
		Для Каждого ТекЯзык Из ШаблонСчетчика["Языки"] Цикл
			НовСтрока = НовыйОбъект.НациональноеПредставление.Добавить();
			НовСтрока.Язык = ТекЯзык.Ключ;
			НовСтрока.НаименованиеНациональное = ТекЯзык.Значение;
		КонецЦикла;
		НовыйОбъект.Записать();
	КонецЦикла;
	
КонецПроцедуры

Функция ПолучитьШаблонСчетчика(КодСчетчика) Экспорт
	ШаблонЭлемента = Неопределено;
	Если КодСчетчика = "ЛогическийДискПроцентСвободногоМеста" Тогда
		ШаблонЭлемента = ШаблонЛогическийДискПроцентСвободногоМеста();
	ИначеЕсли КодСчетчика = "ПамятьДоступноМБ" Тогда
		ШаблонЭлемента = ШаблонПамятьДоступноМБ();
	ИначеЕсли КодСчетчика = "ФизическийДискСредняяДлинаОчередиДиска" Тогда
		ШаблонЭлемента = ШаблонФизическийДискСредняяДлинаОчередиДиска();
	ИначеЕсли КодСчетчика = "ФизическийДискСреднееВремяЧтенияСДиска" Тогда
		ШаблонЭлемента = ШаблонФизическийДискСреднееВремяЧтенияСДиска();
	ИначеЕсли КодСчетчика = "ФизическийДискСреднееВремяЗаписиНаДиск" Тогда
		ШаблонЭлемента = ШаблонФизическийДискСреднееВремяЗаписиНаДиск();
	ИначеЕсли КодСчетчика = "ПроцессорПроцентВремениПростоя" Тогда
		ШаблонЭлемента = ШаблонПроцессорПроцентВремениПростоя();
	ИначеЕсли КодСчетчика = "ПроцессорПроцентЗагруженностиПроцессора" Тогда
		ШаблонЭлемента = ШаблонПроцессорПроцентЗагруженностиПроцессора();
	ИначеЕсли КодСчетчика = "ПроцессорПроцентРаботыВПользовательскомРежиме" Тогда
		ШаблонЭлемента = ШаблонПроцессорПроцентРаботыВПользовательскомРежиме();
	ИначеЕсли КодСчетчика = "ПроцессорПрерыванийСек" Тогда
		ШаблонЭлемента = ШаблонПроцессорПрерыванийСек();
	ИначеЕсли КодСчетчика = "SQLServerBufferManagerBufferCacheHitRatio" Тогда
		ШаблонЭлемента = ШаблонSQLServerBufferManagerBufferCacheHitRatio();
	ИначеЕсли КодСчетчика = "SQLServerBufferManagerLazyWritesSec" Тогда
		ШаблонЭлемента = ШаблонSQLServerBufferManagerLazyWritesSec();
	ИначеЕсли КодСчетчика = "SQLServerBufferManagerPageLifeExpectancy" Тогда
		ШаблонЭлемента = ШаблонSQLServerBufferManagerPageLifeExpectancy();
	ИначеЕсли КодСчетчика = "SQLServerBufferManagerPageReadsSec" Тогда
		ШаблонЭлемента = ШаблонSQLServerBufferManagerPageReadsSec();
	ИначеЕсли КодСчетчика = "SQLServerBufferManagerPageWritesSec" Тогда
		ШаблонЭлемента = ШаблонSQLServerBufferManagerPageWritesSec();
	ИначеЕсли КодСчетчика = "SQLServerDatabasesTempdbDataFilesSizeKB" Тогда
		ШаблонЭлемента = ШаблонSQLServerDatabasesTempdbDataFilesSizeKB();
	ИначеЕсли КодСчетчика = "SQLServerDatabasesTempdbLogFilesSizeKB" Тогда
		ШаблонЭлемента = ШаблонSQLServerDatabasesTempdbLogFilesSizeKB();
	ИначеЕсли КодСчетчика = "SQLServerDatabasesTempdbLogFilesUsedSizeKB" Тогда
		ШаблонЭлемента = ШаблонSQLServerDatabasesTempdbLogFilesUsedSizeKB();
	ИначеЕсли КодСчетчика = "SQLServerLatchesLatchWaitsSec" Тогда
		ШаблонЭлемента = ШаблонSQLServerLatchesLatchWaitsSec();
	ИначеЕсли КодСчетчика = "SQLServerLatchesTotalLatchWaitTime_ms" Тогда
		ШаблонЭлемента = ШаблонSQLServerLatchesTotalLatchWaitTime_ms();
	ИначеЕсли КодСчетчика = "SQLServerLocksAverageWaitTime_ms" Тогда
		ШаблонЭлемента = ШаблонSQLServerLocksAverageWaitTime_ms();
	ИначеЕсли КодСчетчика = "SQLServerLocksLockTimeoutsTimeoutMore0sec" Тогда
		ШаблонЭлемента = ШаблонSQLServerLocksLockTimeoutsTimeoutMore0sec();
	ИначеЕсли КодСчетчика = "SQLServerLocksLockWaitTime_ms" Тогда
		ШаблонЭлемента = ШаблонSQLServerLocksLockWaitTime_ms();
	ИначеЕсли КодСчетчика = "SQLServerLocksLockWaitsSec" Тогда
		ШаблонЭлемента = ШаблонSQLServerLocksLockWaitsSec();
	ИначеЕсли КодСчетчика = "SQLServerLocksNumberOfDeadlocksSec" Тогда
		ШаблонЭлемента = ШаблонSQLServerLocksNumberOfDeadlocksSec();
	ИначеЕсли КодСчетчика = "SQLServerSQLErrorsErrorsSec" Тогда
		ШаблонЭлемента = ШаблонSQLServerSQLErrorsErrorsSec();
	ИначеЕсли КодСчетчика = "SQLServerSQLStatisticsBatchRequestsSec" Тогда
		ШаблонЭлемента = ШаблонSQLServerSQLStatisticsBatchRequestsSec();
	ИначеЕсли КодСчетчика = "SQLServerSQLStatisticsSQLAttentionRate" Тогда
		ШаблонЭлемента = ШаблонSQLServerSQLStatisticsSQLAttentionRate();
	ИначеЕсли КодСчетчика = "SQLServerSQLStatisticsSQLCompilationsSec" Тогда
		ШаблонЭлемента = ШаблонSQLServerSQLStatisticsSQLCompilationsSec();
	ИначеЕсли КодСчетчика = "SQLServerSQLStatisticsSQLReCompilationsSec" Тогда
		ШаблонЭлемента = ШаблонSQLServerSQLStatisticsSQLReCompilationsSec();
	ИначеЕсли КодСчетчика = "SQLServerTransactionsFreeSpaceInTempdbKB" Тогда
		ШаблонЭлемента = ШаблонSQLServerTransactionsFreeSpaceInTempdbKB();
	ИначеЕсли КодСчетчика = "SQLServerTransactionsLongestTransactionRunningTime" Тогда
		ШаблонЭлемента = ШаблонSQLServerTransactionsLongestTransactionRunningTime();
	ИначеЕсли КодСчетчика = "SQLServerTransactionsTransactions" Тогда
		ШаблонЭлемента = ШаблонSQLServerTransactionsTransactions();
	ИначеЕсли КодСчетчика = "СистемаКонтекстныхПереключенийСек" Тогда
		ШаблонЭлемента = ШаблонСистемаКонтекстныхПереключенийСек();
	ИначеЕсли КодСчетчика = "СистемаБайтЧтенияФайловСек" Тогда
		ШаблонЭлемента = ШаблонСистемаБайтЧтенияФайловСек();
	ИначеЕсли КодСчетчика = "СистемаБайтЗаписиФайловСек" Тогда
		ШаблонЭлемента = ШаблонСистемаБайтЗаписиФайловСек();
	ИначеЕсли КодСчетчика = "СистемаСчетчикПроцессов" Тогда
		ШаблонЭлемента = ШаблонСистемаСчетчикПроцессов();
	ИначеЕсли КодСчетчика = "СистемаДлинаОчередиПроцессора" Тогда
		ШаблонЭлемента = ШаблонСистемаДлинаОчередиПроцессора();
	ИначеЕсли КодСчетчика = "СистемаПотоки" Тогда
		ШаблонЭлемента = ШаблонСистемаПотоки();
	КонецЕсли;
	
	Возврат ШаблонЭлемента;
КонецФункции

Функция ПолучитьНаименованияСчетчиков(Счетчики, ЯзыкОС) Экспорт
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	               |	СпрСчетчикиПроизводительности.Ссылка КАК Ссылка,
	               |	ВЫБОР &ЯзыкОС
	               |		КОГДА &Англ
	               |			ТОГДА СпрСчетчикиПроизводительности.Наименование
	               |		ИНАЧЕ ТчНациональноеПредставление.НаименованиеНациональное
	               |	КОНЕЦ КАК Представление
	               |ИЗ
	               |	Справочник.СчетчикиПроизводительности КАК СпрСчетчикиПроизводительности
	               |		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.СчетчикиПроизводительности.НациональноеПредставление КАК ТчНациональноеПредставление
	               |		ПО (ТчНациональноеПредставление.Ссылка = СпрСчетчикиПроизводительности.Ссылка)
	               |			И (ТчНациональноеПредставление.Язык = &ЯзыкОС)
	               |ГДЕ
	               |	СпрСчетчикиПроизводительности.Ссылка В(&Счетчики)";
	
	Запрос.УстановитьПараметр("Счетчики", Счетчики);
	Запрос.УстановитьПараметр("ЯзыкОС", ЯзыкОС);
	Запрос.УстановитьПараметр("Англ", Справочники.ЯзыкиОС.Английский);
	
	Результат = Запрос.Выполнить();
	
	СчетчикиРезультат = Новый Соответствие;
	Выборка = Результат.Выбрать();
	Пока Выборка.Следующий() Цикл
		СчетчикиРезультат.Вставить(Выборка.Ссылка, Выборка.Представление);
	КонецЦикла;
	
	Возврат СчетчикиРезультат;
КонецФункции

Функция ПолучитьВсеСчетчики() Экспорт
	Запрос = Новый Запрос;
	Запрос.Текст = "
	|ВЫБРАТЬ
	|	СчетчикиПроизводительности.Ссылка
	|ИЗ
	|	Справочник.СчетчикиПроизводительности КАК СчетчикиПроизводительности
	|ГДЕ
	|	СчетчикиПроизводительности.Предопределенный = ИСТИНА
	|УПОРЯДОЧИТЬ ПО
	|	СчетчикиПроизводительности.Наименование
	|";
	
	Результат = Запрос.Выполнить();
	
	Выборка = Результат.Выбрать();
	
	Счетчики = Новый Массив;
	Пока Выборка.Следующий() Цикл
		Счетчики.Добавить(Выборка.Ссылка);
	КонецЦикла;
	
	Возврат Счетчики;
КонецФункции

Функция ПолучитьСчетчикиОборудования() Экспорт
	Запрос = Новый Запрос;
	Запрос.Текст = "
	|ВЫБРАТЬ
	|	СчетчикиПроизводительности.Ссылка
	|ИЗ
	|	Справочник.СчетчикиПроизводительности КАК СчетчикиПроизводительности
	|ГДЕ
	|	СчетчикиПроизводительности.Предопределенный = ИСТИНА
	|	И СчетчикиПроизводительности.Наименование НЕ ПОДОБНО &Наименование
	|УПОРЯДОЧИТЬ ПО
	|	СчетчикиПроизводительности.Наименование
	|";
	
	Запрос.УстановитьПараметр("Наименование", "%SQLServer:%");
	Результат = Запрос.Выполнить();
	
	Выборка = Результат.Выбрать();
	
	Счетчики = Новый Массив;
	Пока Выборка.Следующий() Цикл
		Счетчики.Добавить(Выборка.Ссылка);
	КонецЦикла;
	
	Возврат Счетчики;	
КонецФункции

Функция СоздатьШаблонПредопределенного(Наименование, НаименованиеРусский, Описание)
	ШаблонЭлемента = Новый Соответствие;
	ШаблонЭлемента.Вставить("Наименование", Наименование);
	ШаблонЭлемента.Вставить("Описание", Описание);
	
	ЯзыкРусский = Новый Соответствие;
	Если ЗначениеЗаполнено(НаименованиеРусский) Тогда
		ЯзыкРусский.Вставить(Справочники.ЯзыкиОС.Русский, НаименованиеРусский);
	КонецЕсли;
	ШаблонЭлемента.Вставить("Языки", ЯзыкРусский);
	
	Возврат ШаблонЭлемента;
КонецФункции

Функция ШаблонЛогическийДискПроцентСвободногоМеста()
	ШаблонЭлемента =
		СоздатьШаблонПредопределенного(
			"\LogicalDisk(_Total)\% Free Space",
			"\Логический диск(_Total)\% свободного места",
			"Процент свободного места - это доля свободного места, имеющегося на логическом диске, по отношению к общему объему выбранного логического диска.");
	
	Возврат ШаблонЭлемента;
КонецФункции

Функция ШаблонПамятьДоступноМБ()
	ШаблонЭлемента =
		СоздатьШаблонПредопределенного(
			"\Memory\Available Mbytes",
			"\Память\Доступно МБ",
			"Это объем физической памяти в МБ, немедленно доступной для выделения процессу или для использования системой. Эта величина равна сумме памяти, выделенной для кэша, свободной памяти и обнуленных страниц памяти. Подробное описание работы диспетчера памяти можно найти в MSDN или в главе 'System Performance and Troubleshooting Guide' руководства 'Windows Server 2003 Resource Kit'.");
	
	Возврат ШаблонЭлемента;
КонецФункции

Функция ШаблонФизическийДискСредняяДлинаОчередиДиска()
	ШаблонЭлемента =
		СоздатьШаблонПредопределенного(
			"\PhysicalDisk(_Total)\Avg. Disk Queue Length",
			"\Физический диск(_Total)\Средняя длина очереди диска",
			"Средняя длина очереди диска - это среднее общее количество запросов на чтение и на запись, которые были поставлены в очередь для соответствующего диска в течение интервала измерения.");
	
	Возврат ШаблонЭлемента;
КонецФункции

Функция ШаблонФизическийДискСреднееВремяЧтенияСДиска()
	ШаблонЭлемента =
		СоздатьШаблонПредопределенного(
			"\PhysicalDisk(_Total)\Avg. Disk Sec/Read",
			"\Физический диск(_Total)\Среднее время чтения с диска (с)",
			"Среднее время чтения с диска - это время в секундах, затрачиваемое в среднем на одну операцию чтения данных с диска.");
	
	Возврат ШаблонЭлемента;
КонецФункции

Функция ШаблонФизическийДискСреднееВремяЗаписиНаДиск()
	ШаблонЭлемента =
		СоздатьШаблонПредопределенного(
			"\PhysicalDisk(_Total)\Avg. Disk Sec/Write",
			"\Физический диск(_Total)\Среднее время записи на диск (с)",
			"Среднее время записи на диск - это время в секундах, затрачиваемое в среднем на одну операцию записи данных на диск.");
	
	Возврат ШаблонЭлемента;
КонецФункции

Функция ШаблонПроцессорПроцентВремениПростоя()
	ШаблонЭлемента =
		СоздатьШаблонПредопределенного(
			"\Processor(_Total)\% Idle Time",
			"\Процессор(_Total)\Процент времени бездействия",
			"'% времени простоя' - доля времени, когда процессор простаивает в течение интервала выборки.");
	
	Возврат ШаблонЭлемента;
КонецФункции

Функция ШаблонПроцессорПроцентЗагруженностиПроцессора()
	ШаблонЭлемента =
		СоздатьШаблонПредопределенного(
			"\Processor(_Total)\% Processor Time",
			"\Процессор(_Total)\% загруженности процессора",
			"Текущий процент времени процессора - показывает, какую часть времени интервала измерения процесс из данного объекта 'Задание' использовал на выполнение кода программы.");
	
	Возврат ШаблонЭлемента;
КонецФункции

Функция ШаблонПроцессорПроцентРаботыВПользовательскомРежиме()
	ШаблонЭлемента =
		СоздатьШаблонПредопределенного(
			"\Processor(_Total)\% User Time",
			"\Процессор(_Total)\% работы в пользовательском режиме",
			"Процент времени работы в пользовательском режиме - это процент времени работы процессора, которое он находился в пользовательском режиме. (Пользовательский режим является ограниченным режимом работы процессора. В пользовательском режиме работают приложения, подсистемы обеспечения среды (например, Win32, POSIX) и интегрируемые подсистемы. Наоборот, привилегированный режим разработан для компонентов операционной системы и позволяет напрямую обращаться к аппаратуре и всей памяти. Операционная система переключает потоки приложений в привилегированный режим для доступа к службам операционной системы.) Этот счетчик отображает средний процент времени занятости процессора по отношению ко всему времени образца.");
	
	Возврат ШаблонЭлемента;
КонецФункции

Функция ШаблонПроцессорПрерыванийСек()
	ШаблонЭлемента =
		СоздатьШаблонПредопределенного(
			"\Processor(_Total)\Interrupts/sec",
			"\Процессор(_Total)\Прерываний/с",
			"'Прерываний/сек' - средняя скорость, в событиях в секунду, с которой процессор получает и обслуживает аппаратные прерывания. Эта величина не включает отложенные вызовы процедур, которые подсчитываются отдельно. Эта величина является косвенным показателем активности устройств, формирующих аппаратные прерывания, таких как системного таймера, мыши, драйверов дисков, линий передачи данных, сетевых адаптеров и других периферийных устройств. Эти устройства обычно прерывают работу процессора при завершении своей работы или при возникновении необходимости обработки запроса. При этом обычное выполнение потока команд приостанавливается. Системный таймер обычно прерывает работу процессора каждые 10 миллисекунд, создавая 'фон' аппаратных прерываний. Поэтому эта величина отображает разницу между значениями последних двух выборок, поделенную на длительность интервала выборки.");
	
	Возврат ШаблонЭлемента;
КонецФункции

Функция ШаблонSQLServerBufferManagerBufferCacheHitRatio()
	ШаблонЭлемента =
		СоздатьШаблонПредопределенного(
			"\SQLServer:Buffer Manager\Buffer Cache Hit Ratio",
			"\SQLServer:Buffer Manager\Buffer Cache Hit Ratio",
			"Percentage of pages that were found in the buffer pool without having to incur a read from disk.");
	
	Возврат ШаблонЭлемента;
КонецФункции

Функция ШаблонSQLServerBufferManagerLazyWritesSec()
	ШаблонЭлемента =
		СоздатьШаблонПредопределенного(
			"\SQLServer:Buffer Manager\Lazy Writes/Sec",
			"\SQLServer:Buffer Manager\Lazy Writes/Sec",
			"Number of buffers written by buffer manager's lazy writer.");
	
	Возврат ШаблонЭлемента;
КонецФункции

Функция ШаблонSQLServerBufferManagerPageLifeExpectancy()
	ШаблонЭлемента =
		СоздатьШаблонПредопределенного(
			"\SQLServer:Buffer Manager\Page Life Expectancy",
			"\SQLServer:Buffer Manager\Page Life Expectancy",
			"Number of seconds a page will stay in the buffer pool without references.");
	
	Возврат ШаблонЭлемента;
КонецФункции

Функция ШаблонSQLServerBufferManagerPageReadsSec()
	ШаблонЭлемента =
		СоздатьШаблонПредопределенного(
			"\SQLServer:Buffer Manager\Page Reads/Sec",
			"\SQLServer:Buffer Manager\Page Reads/Sec",
			"Page Reads/sec is the rate at which the disk was read to resolve hard page faults. It shows the number of reads operations, without regard to the number of pages retrieved in each operation. Hard page faults occur when a process references a page in virtual memory that is not in working set or elsewhere in physical memory, and must be retrieved from disk. This counter is a primary indicator of the kinds of faults that cause system-wide delays. It includes read operations to satisfy faults in the file system cache (usually requested by applications) and in non-cached mapped memory files. Compare the value of Memory\\Pages Reads/sec to the value of Memory\\Pages Input/sec to determine the average number of pages read during each operation.");
	
	Возврат ШаблонЭлемента;
КонецФункции

Функция ШаблонSQLServerBufferManagerPageWritesSec()
	ШаблонЭлемента =
		СоздатьШаблонПредопределенного(
			"\SQLServer:Buffer Manager\Page Writes/Sec",
			"\SQLServer:Buffer Manager\Page Writes/Sec",
			"Page Writes/sec is the rate at which pages are written to disk to free up space in physical memory. Pages are written to disk only if they are changed while in physical memory, so they are likely to hold data, not code.  This counter shows write operations, without regard to the number of pages written in each operation.  This counter displays the difference between the values observed in the last two samples, divided by the duration of the sample interval.");
	
	Возврат ШаблонЭлемента;
КонецФункции

Функция ШаблонSQLServerDatabasesTempdbDataFilesSizeKB()
	ШаблонЭлемента =
		СоздатьШаблонПредопределенного(
			"\SQLServer:Databases(tempdb)\Data File(s) Size (KB)",
			"\SQLServer:Databases(tempdb)\Data File(s) Size (KB)",
			"The cumulative size of all the data files in the database.");
	
	Возврат ШаблонЭлемента;
КонецФункции

Функция ШаблонSQLServerDatabasesTempdbLogFilesSizeKB()
	ШаблонЭлемента =
		СоздатьШаблонПредопределенного(
			"\SQLServer:Databases(tempdb)\Log File(s) Size (KB)",
			"\SQLServer:Databases(tempdb)\Log File(s) Size (KB)",
			"The cumulative size of all the log files in the database.");
	
	Возврат ШаблонЭлемента;
КонецФункции

Функция ШаблонSQLServerDatabasesTempdbLogFilesUsedSizeKB()
	ШаблонЭлемента =
		СоздатьШаблонПредопределенного(
			"\SQLServer:Databases(tempdb)\Log File(s) Used Size (KB)",
			"\SQLServer:Databases(tempdb)\Log File(s) Used Size (KB)",
			"The cumulative used size of all the log files in the database.");
	
	Возврат ШаблонЭлемента;
КонецФункции

Функция ШаблонSQLServerLatchesLatchWaitsSec()
	ШаблонЭлемента =
		СоздатьШаблонПредопределенного(
			"\SQLServer:Latches\Latch Waits/sec",
			"\SQLServer:Latches\Latch Waits/sec",
			"Number of latch requests that could not be granted immediately and had to wait before being granted.");
	
	Возврат ШаблонЭлемента;
КонецФункции

Функция ШаблонSQLServerLatchesTotalLatchWaitTime_ms()
	ШаблонЭлемента =
		СоздатьШаблонПредопределенного(
			"\SQLServer:Latches\Total Latch Wait Time (ms)",
			"\SQLServer:Latches\Total Latch Wait Time (ms)",
			"Total latch wait time (milliseconds) for latch requests that had to wait in the last second.");
	
	Возврат ШаблонЭлемента;
КонецФункции

Функция ШаблонSQLServerLocksAverageWaitTime_ms()
	ШаблонЭлемента =
		СоздатьШаблонПредопределенного(
			"\SQLServer:Locks(_Total)\Average Wait Time (ms)",
			"\SQLServer:Locks(_Total)\Average Wait Time (ms)",
			"The average amount of wait time (milliseconds) for each lock request that resulted in a wait.");
	
	Возврат ШаблонЭлемента;
КонецФункции

Функция ШаблонSQLServerLocksLockTimeoutsTimeoutMore0sec()
	ШаблонЭлемента =
		СоздатьШаблонПредопределенного(
			"\SQLServer:Locks(_Total)\Lock Timeouts (timeout > 0)/sec",
			"\SQLServer:Locks(_Total)\Lock Timeouts (timeout > 0)/sec",
			"Number of lock requests that timed out. This does not include requests for NOWAIT locks.");
	
	Возврат ШаблонЭлемента;
КонецФункции

Функция ШаблонSQLServerLocksLockWaitTime_ms()
	ШаблонЭлемента =
		СоздатьШаблонПредопределенного(
			"\SQLServer:Locks(_Total)\Lock Wait Time (ms)",
			"\SQLServer:Locks(_Total)\Lock Wait Time (ms)",
			"Total wait time (milliseconds) for locks in the last second.");
	
	Возврат ШаблонЭлемента;
КонецФункции

Функция ШаблонSQLServerLocksLockWaitsSec()
	ШаблонЭлемента =
		СоздатьШаблонПредопределенного(
			"\SQLServer:Locks(_Total)\Lock Waits/Sec",
			"\SQLServer:Locks(_Total)\Lock Waits/Sec",
			"Number of lock requests that could not be satisfied immediately and required the caller to wait before being granted the lock.");
	
	Возврат ШаблонЭлемента;
КонецФункции

Функция ШаблонSQLServerLocksNumberOfDeadlocksSec()
	ШаблонЭлемента =
		СоздатьШаблонПредопределенного(
			"\SQLServer:Locks(_Total)\Number of Deadlocks/sec",
			"\SQLServer:Locks(_Total)\Number of Deadlocks/sec",
			"Number of lock requests that resulted in a deadlock.");
	
	Возврат ШаблонЭлемента;
КонецФункции

Функция ШаблонSQLServerSQLErrorsErrorsSec()
	ШаблонЭлемента =
		СоздатьШаблонПредопределенного(
			"\SQLServer:SQL Errors(_Total)\Errors/sec",
			"\SQLServer:SQL Errors(_Total)\Errors/sec",
			"Number of errors/sec");
	
	Возврат ШаблонЭлемента;
КонецФункции

Функция ШаблонSQLServerSQLStatisticsBatchRequestsSec()
	ШаблонЭлемента =
		СоздатьШаблонПредопределенного(
			"\SQLServer:SQL Statistics\Batch Requests/Sec",
			"\SQLServer:SQL Statistics\Batch Requests/Sec",
			"Number of SQL batch requests received by server.");
	
	Возврат ШаблонЭлемента;
КонецФункции

Функция ШаблонSQLServerSQLStatisticsSQLAttentionRate()
	ШаблонЭлемента =
		СоздатьШаблонПредопределенного(
			"\SQLServer:SQL Statistics\SQL Attention rate",
			"\SQLServer:SQL Statistics\SQL Attention rate",
			"Number of attentions per second.");
	
	Возврат ШаблонЭлемента;
КонецФункции

Функция ШаблонSQLServerSQLStatisticsSQLCompilationsSec()
	ШаблонЭлемента =
		СоздатьШаблонПредопределенного(
			"\SQLServer:SQL Statistics\SQL Compilations/Sec",
			"\SQLServer:SQL Statistics\SQL Compilations/Sec",
			"Number of SQL compilations.");
	
	Возврат ШаблонЭлемента;
КонецФункции

Функция ШаблонSQLServerSQLStatisticsSQLReCompilationsSec()
	ШаблонЭлемента =
		СоздатьШаблонПредопределенного(
			"\SQLServer:SQL Statistics\SQL Re-Compilations/Sec",
			"\SQLServer:SQL Statistics\SQL Re-Compilations/Sec",
			"Number of SQL re-compiles.");
	
	Возврат ШаблонЭлемента;
КонецФункции

Функция ШаблонSQLServerTransactionsFreeSpaceInTempdbKB()
	ШаблонЭлемента =
		СоздатьШаблонПредопределенного(
			"\SQLServer:Transactions\Free space in tempdb (KB)",
			"\SQLServer:Transactions\Free space in tempdb (KB)",
			"The free space in tempdb in KB.");
	
	Возврат ШаблонЭлемента;
КонецФункции

Функция ШаблонSQLServerTransactionsLongestTransactionRunningTime()
	ШаблонЭлемента =
		СоздатьШаблонПредопределенного(
			"\SQLServer:Transactions\Longest Transaction Running Time",
			"\SQLServer:Transactions\Longest Transaction Running Time",
			"The longest running time of any transcation in seconds.");
	
	Возврат ШаблонЭлемента;
КонецФункции

Функция ШаблонSQLServerTransactionsTransactions()
	ШаблонЭлемента =
		СоздатьШаблонПредопределенного(
			"\SQLServer:Transactions\Transactions",
			"\SQLServer:Transactions\Transactions",
			"Number of transaction enlistments (local, dtc, and bound).");
	
	Возврат ШаблонЭлемента;
КонецФункции

Функция ШаблонСистемаКонтекстныхПереключенийСек()
	ШаблонЭлемента =
		СоздатьШаблонПредопределенного(
			"\System\Context Switches/sec",
			"\Система\Контекстных переключений/с",
			"Переключений контекста в сек - это совокупная частота, с которой все процессоры компьютера переключаются от одного потока к другому.  Переключение потоков происходит либо когда исполняющийся поток добровольно освобождает процессор, либо когда один поток вытесняется другим потоком, имеющим к тому времени более высокий приоритет и готовым к выполнению, либо при переключении между пользовательским и привилегированным (режимом ядра) режимами для выполнения системного кода или обращения к подсистемам.  Данный счетчик является суммой числа переключений контекста в сек для всех потоков на всех процессорах компьютера.  Существуют счетчики переключений контекста для объектов системы и потоков. Значение этого счетчика вычисляется как разница между двумя последовательными замерами, деленная на продолжительность временного интервала между ними.");
	
	Возврат ШаблонЭлемента;
КонецФункции

Функция ШаблонСистемаБайтЧтенияФайловСек()
	ШаблонЭлемента =
		СоздатьШаблонПредопределенного(
			"\System\File Read Bytes/sec",
			"\Система\Байт чтения файлов/с",
			"Байт чтения файлов/сек - это средняя скорость считывания байт для удовлетворения  системных запросов чтения на всех устройствах данного компьютера, включая запросы чтения данных в файловом кэше.  Измеряется числом байт в секунду.  Этот счетчик показывает разницу значений между двумя последними снятиями показаний, деленную на длительность интервала измерения.");
	
	Возврат ШаблонЭлемента;
КонецФункции

Функция ШаблонСистемаБайтЗаписиФайловСек()
	ШаблонЭлемента =
		СоздатьШаблонПредопределенного(
			"\System\File Write Bytes/sec",
			"\Система\Байт записи файлов/с",
			"Байт записи файлов/сек - это средняя скорость записи байт для удовлетворения  системных запросов записи на всех устройствах данного компьютера, включая запросы записи данных в файловый кэш.  Измеряется числом байт в секунду.  Этот счетчик показывает разницу значений между двумя последними снятиями показаний, деленную на длительность интервала измерения.");
	
	Возврат ШаблонЭлемента;
КонецФункции

Функция ШаблонСистемаСчетчикПроцессов()
	ШаблонЭлемента =
		СоздатьШаблонПредопределенного(
			"\System\Processes",
			"\Система\Счетчик процессов",
			"Счетчик процессов - это количество процессов в компьютере в момент сбора информации. Данный показатель представляет собой конкретное текущее значение, и не является средним значением по некоторому интервалу времени. Каждый процесс соответствует одной выполняемой программе.");
	
	Возврат ШаблонЭлемента;
КонецФункции

Функция ШаблонСистемаДлинаОчередиПроцессора()
	ШаблонЭлемента =
		СоздатьШаблонПредопределенного(
			"\System\Processor Queue Length",
			"\Система\Длина очереди процессора",
			"Длина очереди процессора - это текущая длина очереди процессора, измеряемая числом ожидающих потоков. Все процессоры используют одну общую очередь, в которой потоки ожидают получения циклов процессора. Этот счетчик не включает потоки, которые выполняются в настоящий момент. Длительное время существующая очередь длиной больше двух потоков обычно свидетельствует о перегруженности процессора. Этот счетчик отражает текущее значение, и не является средним значением по некоторому интервалу времени.");
	
	Возврат ШаблонЭлемента;
КонецФункции

Функция ШаблонСистемаПотоки()
	ШаблонЭлемента =
		СоздатьШаблонПредопределенного(
			"\System\Threads",
			"\Система\Потоки",
			"Счетчик потоков - это количество потоков в компьютере в момент сбора информации. Данный показатель представляет собой конкретное текущее значение, и не является средним значением по некоторому интервалу времени. Поток - это базовый объект, который занят выполнением инструкций с помощью процессора.");
	
	Возврат ШаблонЭлемента;
КонецФункции

