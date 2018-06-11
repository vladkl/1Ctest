///////////////////////////////////////////////////////////////////////////////
// ПОЛУЧЕНИЕ ИНФОРМАЦИИ

// Функция выполняет подключение к информационной базе и заполняет структуру
// Подключение информацией, необходимой для работы с подключением.
//
// Параметры:
//  ИнформационнаяБаза - СправочникСсылка.ИнформационнаяБаза
//
// Возвращаемое значение:
//  Подключение - Структура, описывающая подключение и содержащая следующие поля:
//                Соединитель - COM-соединитель
//                АгентСервера - Соединение с агентом сервера 1С:Предприятия
//                СерверИнформационнойБазы - Кластер серверов
//                СоединениеСРабочимПроцессом - соединение с рабочим процессом
//                ИБ - текущая информационная база
//                ОписаниеИБ - текущая информационная база
//                                (короткое описание)
//                ИнформационнаяБаза - СправочникСсылка.ИнформационнаяБаза, параметры
//                              текущего подключения к информационной базе
//                СтрокаСоединения - Строка, параметры подключения к ИБ
//                ПричинаОшибки - Строка, причина ошибки
//
Функция ПодключениеИБ(ИнформационнаяБаза) Экспорт
	
	ОтладкаКлиентСервер.Действие("ПодключениеИБ",
	                 ИнформационнаяБаза.ИмяИБ,
	                 ИнформационнаяБаза.СерверИБ);
	
	Соединитель = ОбщегоНазначения.ПолучитьComСоединитель();
	
	// Подключиться к агенту сервера
	АгентСервера = ПолучитьАгентаСервера(
		Соединитель,
		ИнформационнаяБаза.СерверИБ);
	
	// Подключиться к серверу информационной базы
	СерверИнформационнойБазы = ПолучитьСерверИнформационнойБазы(
		АгентСервера,
		ИнформационнаяБаза.СерверИБ,
		ИнформационнаяБаза.АдминистраторКластера,
		ИнформационнаяБаза.ПарольАдминистратораКластера);
	
	// Получить соединение с рабочим процессом
	СоединениеСРабочимПроцессом = ПолучитьСоединениеСРабочимПроцессом(
		АгентСервера,
		СерверИнформационнойБазы,
		Соединитель,
		ИнформационнаяБаза.ИмяПользователяИБ,
		ИнформационнаяБаза.ПарольПользователяИБ);
	
	// Получить информационную базу
	ИБ = ПолучитьИнформационнуюБазу(
		СоединениеСРабочимПроцессом,
		ИнформационнаяБаза.ИмяИБ);
	
	Если ПустаяСтрока(ИБ.DBMS) Тогда
		ВызватьИсключение СловарьКлиентСервер.Получить("ОшибкаАутентификации");
	КонецЕсли;
	
	// Получить описание информационной базы
	ОписаниеИБ = ПолучитьОписаниеИнформационнойБазы(
		АгентСервера,
		СерверИнформационнойБазы,
		ИнформационнаяБаза.ИмяИБ);
		
	// Подготовить строку подключения
	СтрокаСоединения = СформироватьСтрокуСоединения(
		СерверИнформационнойБазы.HostName,
		СерверИнформационнойБазы.MainPort,
		ИнформационнаяБаза.ИмяИБ,
		ИнформационнаяБаза.ИмяПользователяИБ,
		ИнформационнаяБаза.ПарольПользователяИБ);
	
	// Заполнить описание подключения
	Подключение = Новый Структура;
	Подключение.Вставить("СоединениеИБ");
	Подключение.Вставить("Соединитель", Соединитель);
	Подключение.Вставить("АгентСервера", АгентСервера);
	Подключение.Вставить("СерверИнформационнойБазы", СерверИнформационнойБазы);
	Подключение.Вставить("СоединениеСРабочимПроцессом", СоединениеСРабочимПроцессом);
	Подключение.Вставить("ИБ", ИБ);
	Подключение.Вставить("ПараметрыИБ", ПолучитьПараметрыСервера(ИнформационнаяБаза.СерверИБ));
	Подключение.Вставить("ОписаниеИБ", ОписаниеИБ);
	Подключение.Вставить("ИнформационнаяБаза", ИнформационнаяБаза);
	Подключение.Вставить("СтрокаСоединения", СтрокаСоединения);
	
	ОтладкаКлиентСервер.Результат("ПодключениеИБ",
	                  ИнформационнаяБаза.ИмяИБ,
	                  ИнформационнаяБаза.СерверИБ);
	
	Возврат Подключение;
	
КонецФункции // ПодключениеИБ()

// Получить COM-соединение с информационной базой
//
// Параметры:
//  Подключение - Структура, подробности в описании функции
//                ПодключитьИнформационнуюБазу()
//                ПричинаОшибки - Строка, причина ошибки
//
// Возвращаемое значение:
//  COM-соединитель, подключение к информационной базе
//
Функция СоединениеИБ(Подключение) Экспорт
	
	ОтладкаКлиентСервер.Действие("СоединениеИБ",
	                 Подключение.ИнформационнаяБаза.ИмяИБ,
	                 Подключение.ИнформационнаяБаза.СерверИБ);
	
	СоединениеИБ = Подключение.Соединитель.Connect(Подключение.СтрокаСоединения);
	
	ОтладкаКлиентСервер.Результат("СоединениеИБ",
	                  Подключение.ИнформационнаяБаза.ИмяИБ,
	                  Подключение.ИнформационнаяБаза.СерверИБ);
	
	Возврат СоединениеИБ;
	
КонецФункции // СоединениеИБ()

// Функция получает список информационных баз на указанном сервере
//
// Параметры:
//  ИмяСервера - Строка, содержащая имя сервера
//  ИмяАдминистратораКластера - Строка, имя администратора кластера
//  ПарольАдминистратораКластера - Строка, пароль администратора кластера
//
// Возвращаемое значение:
//  СписокЗначений - полученный список информационных баз на указанном сервере
//
Функция ПолучитьСписокИБ(ИмяСервера,
                         ИмяАдминистратораКластера,
                         ПарольАдминистратораКластера) Экспорт
	
	ОтладкаКлиентСервер.Действие("ПолучитьСписокИБ", ИмяСервера);
	
	// Создать соединитель
	Соединитель = ОбщегоНазначения.ПолучитьComСоединитель();
	
	// Подключиться к агенту сервера
	АгентСервера = ПолучитьАгентаСервера(Соединитель, ИмяСервера);
	
	// Подключиться к серверу информационной базы
	СерверИнформационнойБазы = ПолучитьСерверИнформационнойБазы(
		АгентСервера,
		ИмяСервера,
		ИмяАдминистратораКластера,
		ПарольАдминистратораКластера);
	
	// Получение списка ИБ
	СписокИБ = АгентСервера.GetInfoBases(СерверИнформационнойБазы).Выгрузить();
	
	ОтладкаКлиентСервер.Результат("ПолучитьСписокИБ", ИмяСервера, СписокИБ.Количество());
	
	Возврат СписокИБ;
	
КонецФункции // ПолучитьСписокИБ()

// Функция возвращает подключение к агенту сервера
//
// Параметры:
//  Соединитель - COMОбъект, соединитель 1С:предприятия (COMConnector)
//  ИмяСервераИБ - Строка, имя подключаемого сервера
//  ПричинаОшибки - Строка, причина ошибки
//
// Возвращаемое значение:
//  СоединениеСАгентомСервера - возвращаемое подключение к агенту сервера
//
Функция ПолучитьАгентаСервера(Соединитель, ИмяСервераИБ) Экспорт
	
	ПараметрыСервера = ПолучитьПараметрыСервера(ИмяСервераИБ);
	СтрокаСоединения = ПараметрыСервера.Протокол + ПараметрыСервера.ИмяСервера + ":" + ОбщегоНазначенияКлиентСервер.ЧислоВСтроку(ПараметрыСервера.ПортАгента);
	
	ОтладкаКлиентСервер.Действие("ПолучитьАгентаСервера", СтрокаСоединения);
	АгентаСервера = Соединитель.ConnectAgent(СтрокаСоединения);
	ОтладкаКлиентСервер.Результат("ПолучитьАгентаСервера", СтрокаСоединения);
	
	Возврат АгентаСервера;
	
КонецФункции // ПолучитьАгентаСервера()

// Функция получает подключение к серверу информационной базы
//
// Параметры:
//  АгентСервера - СоединениеСАгентомСервера, возвращаемое подключение к агенту
//                 сервера
//  ИмяСервераИБ - Строка, имя подключаемого сервера
//  ИмяАдминистратораКластера - Строка, имя администратора кластера
//  ПарольАдминистратораКластера - Строка, пароль администратора кластера
//
// Возвращаемое значение:
//  КластерСерверов, подключение к серверу информационной базы
//
Функция ПолучитьСерверИнформационнойБазы(АгентСервера,
                                         ИмяСервераИБ,
                                         ИмяАдминистратораКластера,
                                         ПарольАдминистратораКластера)
	
	ОтладкаКлиентСервер.Действие("ПолучитьСерверИнформационнойБазы", ИмяСервераИБ);
	
	// Получить список кластеров серверов для данного агента
	КластерыСерверов = АгентСервера.GetClusters().Выгрузить();
	ПараметрыСервера = ПолучитьПараметрыСервера(ИмяСервераИБ);
	
	// Поиск кластеров, удовлетворяющих параметрам подключения
	Для Каждого Кластер Из КластерыСерверов Цикл
		Если Кластер.MainPort = ПараметрыСервера.ПортКластера Тогда
			СерверИнформационнойБазы = Кластер;
			Прервать;
		КонецЕсли;
	КонецЦикла;
	
	// Проверка найденного кластера
	Если СерверИнформационнойБазы = Неопределено Тогда
		ВызватьИсключение СловарьКлиентСервер.Получить("ОшибкаКластерНеНайден");
	КонецЕсли;
	
	// Аутентификация на кластере серверов
	АгентСервера.Authenticate(
		СерверИнформационнойБазы,
		ИмяАдминистратораКластера,
		ПарольАдминистратораКластера);
	
	ОтладкаКлиентСервер.Результат("ПолучитьСерверИнформационнойБазы", ИмяСервераИБ);
	
	Возврат СерверИнформационнойБазы;
	
КонецФункции // ПолучитьСерверИнформационнойБазы()

// Функция получает описание информационной базы
//
// Параметры:
//  АгентСервера - СоединениеСАгентомСервера, возвращаемое подключение к агенту
//                 сервера
//  СерверИнформационнойБазы - КластерСерверов, подключение к серверу
//                 информационной базы
//  ИмяИнформационнойБазы - Строка, имя информационной базы
//  ПричинаОшибки - Строка, причина ошибки
//
// Возвращаемое значение:
//  ОписаниеИнформационнойБазы - возвращаемое описание информационной базы
//
Функция ПолучитьОписаниеИнформационнойБазы(АгентСервера,
                                           СерверИнформационнойБазы,
                                           ИмяИнформационнойБазы)
	
	ОтладкаКлиентСервер.Действие("ПолучитьОписаниеИнформационнойБазы",
	                 ИмяИнформационнойБазы,
	                 СерверИнформационнойБазы.HostName);
	
	ОписанияИнформационныхБаз = АгентСервера.GetInfoBases(
		СерверИнформационнойБазы);
	
	// Поиск лписания ИБ с необходимыми параметрами подключения
	ИмяИнформационнойБазыВРег = ВРег(ИмяИнформационнойБазы);
	
	Для Каждого ОписаниеИБ Из ОписанияИнформационныхБаз Цикл
		Если ВРег(ОписаниеИБ.Name) = ИмяИнформационнойБазыВРег Тогда
			
			ОтладкаКлиентСервер.Результат("ПолучитьОписаниеИнформационнойБазы",
			                  ИмяИнформационнойБазы,
			                  СерверИнформационнойБазы.HostName);
			
			Возврат ОписаниеИБ;
		КонецЕсли;
	КонецЦикла;
	
	ВызватьИсключение СловарьКлиентСервер.Получить("ОшибкаНеНайденоОписаниеИБ");
	
КонецФункции // ПолучитьОписаниеИнформационнойБазы()

// Функция получает соединение с рабочим процессом
//
// Параметры:
//  АгентСервера - СоединениеСАгентомСервера, возвращаемое подключение к агенту
//                 сервера
//  СерверИнформационнойБазы - КластерСерверов, подключение к серверу
//                 информационной базы
//  Соединитель - COMОбъект, соединитель 1С:предприятия (COMConnector)
//  ИмяПользователяИБ - Строка, имя пользователя информационной базы
//  ПарольПользователяИБ - Строка, пароль пользователя информационной базы
//  ПричинаОшибки - Строка, причина ошибки
//
// Возвращаемое значение:
//  СоединениеСРабочимПроцессом - возвращаемое соединение с рабочим процессом
//
Функция ПолучитьСоединениеСРабочимПроцессом(АгентСервера,
                                            СерверИнформационнойБазы,
                                            Соединитель,
                                            ИмяПользователяИБ,
                                            ПарольПользователяИБ)
	
	ОтладкаКлиентСервер.Действие("ПолучитьСоединениеСРабочимПроцессом");
	
	// Получение рабочего процесса
	ПроцессыCOM = АгентСервера.GetWorkingProcesses(СерверИнформационнойБазы);
	РабочиеПроцессы = ПроцессыCOM.Выгрузить();
	
	// Проверка наличия рабочих процессов
	Если РабочиеПроцессы.Количество() < 1 Тогда
		ВызватьИсключение СловарьКлиентСервер.Получить("ОшибкаНеНайденыРабочиеПроцессы");
	КонецЕсли;
	
	Для Каждого РабочийПроцесс Из РабочиеПроцессы Цикл
		Если РабочийПроцесс.Running = 0 Тогда
			Продолжить;
		Иначе
			Попытка
				// Попытка подключения к рабочему процессу
				СтрокаСоединения = РабочийПроцесс.HostName + ":" + Формат(РабочийПроцесс.MainPort, "ЧН=0; ЧГ=0");
				СоединениеСРабочимПроцессом = Соединитель.ConnectWorkingProcess(СтрокаСоединения);
				СоединениеСРабочимПроцессом.AddAuthentication(ИмяПользователяИБ, ПарольПользователяИБ);
				ОтладкаКлиентСервер.Результат("ПолучитьСоединениеСРабочимПроцессом");
				Возврат СоединениеСРабочимПроцессом;
			Исключение
			КонецПопытки;
		КонецЕсли;
	КонецЦикла;
	
	ВызватьИсключение СловарьКлиентСервер.Получить("ОшибкаНеНайденыРабочиеПроцессы");
	
КонецФункции // ПолучитьСоединениеСРабочимПроцессом()

// Функция получает информационную базу
//
// Параметры:
//  СоединениеСРабочимПроцессом - соединение с рабочим процессом
//                 информационной базы
//  ИмяИнформационнойБазы - Строка, имя информационной базы
//  ПричинаОшибки - Строка, причина ошибки
//
// Возвращаемое значение:
//  ИнформационнаяБаза - возвращаемая информационная база
//
Функция ПолучитьИнформационнуюБазу(СоединениеСРабочимПроцессом,
                                   ИмяИнформационнойБазы)
	Перем НайденнаяИБ;
	
	ОтладкаКлиентСервер.Действие("ПолучитьИнформационнуюБазу", ИмяИнформационнойБазы);
	
	// Получение списка информационных баз
	ИнформационныеБазы = СоединениеСРабочимПроцессом.GetInfoBases().Выгрузить();
	
	// Поиск информационной базы с требуемыми параметрами подключения
	ИмяИнформационнойБазыВРег = ВРег(ИмяИнформационнойБазы);
	
	Для Каждого ИБ Из ИнформационныеБазы Цикл
		
		// Если информационная база найдена
		Если ВРег(ИБ.Name) = ИмяИнформационнойБазыВРег Тогда
			
			// Запомнить информационную базу и прекратить поиск
			НайденнаяИБ = ИБ;
			Прервать;
			
		КонецЕсли;
	КонецЦикла;
	
	// Проверка наличия информационной базы
	Если НайденнаяИБ = Неопределено Тогда
		ВызватьИсключение СловарьКлиентСервер.Получить("ОшибкаНеНайденаИБ");
	КонецЕсли;
	
	ОтладкаКлиентСервер.Результат("ПолучитьИнформационнуюБазу", ИмяИнформационнойБазы);
	
	Возврат НайденнаяИБ;
	
КонецФункции // ПолучитьИнформационнуюБазу()

// Получить соединения с рабочими процессами
//
// Параметры:
//  СоединенияРП - ТаблицаЗначений, список соединений с рабочими процессами
//  Соединитель - ComConnector
//  АгентСервера - ComОбъект, агент сервера
//  ПортКластера - Число, порт кластера, где расположена ИБ
//  Имя - Строка, имя пользователя
//  Пароль - Строка, пароль пользователя
//
// Возвращаемое значение:
//  Массив - соединения с рабочими процессами
//
Процедура ОбновитьСоединенияРП(СоединенияРП, Соединитель, АгентСервера, ПортКластера, Имя, Пароль) Экспорт
	
	Кластеры = АгентСервера.GetClusters();
	
	Для Каждого Кластер Из Кластеры Цикл
		
		Если Кластер.MainPort <> ПортКластера Тогда
			Продолжить;
		КонецЕсли;
		
		РабочиеПроцессы = АгентСервера.GetWorkingProcesses(Кластер);
		
		Для Каждого НовыйРабочийПроцесс Из РабочиеПроцессы Цикл
			
			ИмяСоединения = НовыйРабочийПроцесс.HostName
			              + ":" + Формат(НовыйРабочийПроцесс.MainPort, "ЧГ=0");
			СтрокаСоединения = СоединенияРП.Найти(ИмяСоединения, "Имя");
			
			Если НовыйРабочийПроцесс.Running = 0 Тогда
				Если СтрокаСоединения <> Неопределено Тогда
					ОтладкаКлиентСервер.Сообщение("РабочийПроцессОтключен", ИмяСоединения);
					СоединенияРП.Удалить(СтрокаСоединения);
				КонецЕсли;
				
				Продолжить;
			КонецЕсли;
			
			Если СтрокаСоединения <> Неопределено Тогда
				Продолжить;
			КонецЕсли;
			
			Если НовыйРабочийПроцесс.Running = 0 // процесс Активен = Нет
				ИЛИ  НовыйРабочийПроцесс.Enable = Ложь Тогда //процесс Включен = Нет
				Продолжить;
			Иначе
				Попытка
					ОтладкаКлиентСервер.Действие("ПодключениеРП", ИмяСоединения);
					СоединениеСРабочимПроцессом = Соединитель.ConnectWorkingProcess(ИмяСоединения);
					СоединениеСРабочимПроцессом.AddAuthentication(Имя, Пароль);
					НоваяСтрокаСоединения = СоединенияРП.Добавить();
					НоваяСтрокаСоединения.Соединение = СоединениеСРабочимПроцессом;
					НоваяСтрокаСоединения.Имя = ИмяСоединения;
					ОтладкаКлиентСервер.Результат("ПодключениеРП", ИмяСоединения);
				Исключение
					ОтладкаКлиентСервер.Ошибка(ИнформацияОбОшибке(), Ложь);
				КонецПопытки;
			КонецЕсли;
		КонецЦикла;
	КонецЦикла;
	
КонецПроцедуры // ОбновитьСоединенияРП()

// Получить соединения с информационной базой
//
// Параметры:
//  СоединенияРП - Массив, соединения с рабочими процессами
//  ИБ - Описание ИБ
//
// Возвращаемое значение:
//  Массив - соединения с информационной базой
//
Функция ПолучитьСоединенияИБ(СоединенияРП, ИБ) Экспорт
	
	Соединения = Новый Массив;
	УдаляемыеСоединения = Новый Массив;
	
	//Для Каждого ТекИБ Из СоединенияРП[0].Соединение.GetInfoBases() Цикл
	//КонецЦикла;
		
	Для Каждого СоединениеРП Из СоединенияРП Цикл
		Попытка
			СоединенияИБ = СоединениеРП.Соединение.GetInfoBaseConnections(ИБ);
		Исключение
			ОтладкаКлиентСервер.Протокол(ПодробноеПредставлениеОшибки(ИнформацияОбОшибке()));
			УдаляемыеСоединения.Добавить(СоединениеРП);
			Продолжить;
		КонецПопытки;
		
		Для Каждого СоединениеИБ Из СоединенияИБ Цикл
			Соединения.Добавить(СоединениеИБ);
		КонецЦикла;
	КонецЦикла;
	
	Для Каждого УдаляемоеСоединение Из УдаляемыеСоединения Цикл
		ОтладкаКлиентСервер.Сообщение("РабочийПроцессОтключен", УдаляемоеСоединение.Имя);
		СоединенияРП.Удалить(УдаляемоеСоединение);
	КонецЦикла;
	
	Возврат Соединения;
	
КонецФункции // ПолучитьСоединенияИБ()

// Получить описания соединений с информационной базой
//
// Параметры:
//  АгентСервера - ComОбъект
//  ПортКластера - Число, порт кластера, где расположена ИБ
//  ОписаниеИБ - ComОбъект
//
// Возвращаемое значение:
//  Массив - описания соединений с информационной базой
//
Функция ПолучитьОписанияСоединенийИБ(АгентСервера, ПортКластера, ОписаниеИБ) Экспорт
	
	Соединения = Новый Массив;
	Кластеры = АгентСервера.GetClusters();
	
	Для Каждого Кластер Из Кластеры Цикл
		Если Кластер.MainPort <> ПортКластера Тогда
			Продолжить;
		КонецЕсли;
		
		ОписанияСоединенийИБ = АгентСервера.GetInfoBaseConnections(Кластер, ОписаниеИБ);
		
		Для Каждого ОписаниеСоединенияИБ Из ОписанияСоединенийИБ Цикл
			Соединения.Добавить(ОписаниеСоединенияИБ);
		КонецЦикла;
	КонецЦикла;
	
	Возврат Соединения;
	
КонецФункции // ПолучитьОписанияСоединенийИБ()

// Получить параметры подключения к серверу из его имени. Имя сервера состоит из:
// [<Протокол>://]<ИмяСервера>:[Порт центрального сервера]:[Порт кластера сервероа],
// значения которых по-умолчанию равны 1540 и 1541 соответственно.
//
// Параметры:
//  ИмяСервера - Строка, содержащая параметры в виде
//               <ИмяСервера>:[ПортЦентрального сервера]:[Порт кластера сервероа]
//
// Возвращаемое значение:
//  Структура - содержащая параметры подключения к серверу:
//   - Протокол - Строка, имя протокола
//   - ИмяСервера - Строка, имя сервера
//   - ПортАгента - Число, порт центрального сервера (RAgent)
//   - ПортКластера - Число, порт кластера серверов (RMngr)
//
Функция ПолучитьПараметрыСервера(ИмяСервера) Экспорт
	
	Протокол = СтрНайти(ИмяСервера, "://");
	Параметры = Новый Структура();
	Составляющие = ОбщегоНазначенияКлиентСервер.РазделитьСтроку(ИмяСервера, ":", Истина);
	КоличествоСоставляющих = Составляющие.Количество();
	
	Если Протокол = 0 Тогда
		Параметры.Вставить("Протокол", "tcp://");
		Параметры.Вставить("ИмяСервера", ?(КоличествоСоставляющих > 0, Составляющие[0], "localhost"));
		Параметры.Вставить("ПортАгента", ?(КоличествоСоставляющих > 1, ОбщегоНазначенияКлиентСервер.СтрокуВЧисло(Составляющие[1], 1540), 1540));
		Параметры.Вставить("ПортКластера", ?(КоличествоСоставляющих > 2, ОбщегоНазначенияКлиентСервер.СтрокуВЧисло(Составляющие[2], 1541), 1541));
	Иначе
		Параметры.Вставить("Протокол", Составляющие[0] + "://");
		Параметры.Вставить("ИмяСервера", ?(КоличествоСоставляющих > 1, Прав(Составляющие[1], СтрДлина(Составляющие[1]) - 2), "localhost"));
		Параметры.Вставить("ПортАгента", ?(КоличествоСоставляющих > 2, ОбщегоНазначенияКлиентСервер.СтрокуВЧисло(Составляющие[2], 1540), 1540));
		Параметры.Вставить("ПортКластера", ?(КоличествоСоставляющих > 3, ОбщегоНазначенияКлиентСервер.СтрокуВЧисло(Составляющие[3], 1541), 1541));
	КонецЕсли;
	
	Возврат Параметры;
	
КонецФункции // ПолучитьПараметрыСервера()

// Найти кластер по его порту на указанном центральном сервере
//
// Параметры:
//  АгентСервера - IServerAgentConnection, соединение с центральным сервером
//  Порт - Число, номер порта кластера
//
// Возвращаемое значение:
//  IClusterInfo - искомый кластер, Неопределено, если кластер не найден
//
Функция НайтиКластерПоПорту(АгентСервера, Порт) Экспорт
	
	Кластеры = АгентСервера.GetClusters();
	
	Для Каждого ТекущийКластер Из Кластеры Цикл
		Если ТекущийКластер.MainPort = Порт Тогда
			Возврат ТекущийКластер;
		КонецЕсли;
	КонецЦикла;
	
	Возврат Неопределено;
	
КонецФункции // НайтиКластерПоПорту()

// Найти информационную базу по ее имени
//
// Параметры:
//  АгентСервера - IServerAgentConnection, соединение с центральным сервером
//  ОписаниеКластера - IClusterInfo - кластер, на котором находится ИБ
//  ИмяИБ - Строка, наименование искомой информационной базы
//  Пользователь - Строка, имя пользователя искомой информационной базы
//  Пароль - Строка, пароль пользователя искомой информационной базы
//
// Возвращаемое значение:
//  IInfoBaseInfo - искомая информационная база
//
Функция НайтиИБПоИмени(АгентСервера, ОписаниеКластера, ИмяИБ, Пользователь, Пароль) Экспорт
	
	РабочийПроцесс = ПолучитьСоединениеСРабочимПроцессом(АгентСервера,
	                                                     ОписаниеКластера,
	                                                     ОбщегоНазначения.ПолучитьComСоединитель(),
	                                                     Пользователь,
	                                                     Пароль);
	
	Возврат ПолучитьИнформационнуюБазу(РабочийПроцесс, ИмяИБ);
	
КонецФункции // НайтиИБПоИмени()

// Получить структурированные параметры подключения к информационной базе
// на основе строки подключения к ней
//
// Параметры:
//  СтрокаПодключения - Строка, строка подключения к информационной базе
//
// Возвращаемое значение:
//  Структура - результат анализа строки подключения
//
Функция ПолучитьПараметрыПодключения(СтрокаПодключения) Экспорт
	
	СтруктураПараметров = Новый Структура;
	
	// Разделить строку подключения по точке с запятой ";"
	Фрагменты = ОбщегоНазначенияКлиентСервер.РазделитьСтроку(СтрокаПодключения, ";");
	
	// Для каждой комбинации параметра и значения
	Для Каждого Фрагмент Из Фрагменты Цикл
		// Отделить имена параметров от их значений
		Параметры = ОбщегоНазначенияКлиентСервер.РазделитьСтроку(Фрагмент, "=");
		
		// Сохранить параметры
		ИмяПараметра = Параметры[0];
		ЗначениеПараметра = ?(Параметры.Количество() > 1, Параметры[1], "");
		
		// Разобрать имя сервера
		Если ВРег(Лев(ИмяПараметра, 4)) = "SRVR" Тогда
			КомпонентыИмениСервера = ОбщегоНазначенияКлиентСервер.РазделитьСтроку(ОбщегоНазначенияКлиентСервер.УдалитьКавычки(ЗначениеПараметра), ":");
			СтруктураПараметров.Вставить("ИмяСервера", КомпонентыИмениСервера[0]);
			Если КомпонентыИмениСервера.Количество() > 1 Тогда
				ПортКластера = Число(КомпонентыИмениСервера[1]);
			Иначе
				ПортКластера = 1541;
			КонецЕсли;
			СтруктураПараметров.Вставить("ПортКластера", ПортКластера);
		КонецЕсли;
		
		СтруктураПараметров.Вставить(ИмяПараметра, ЗначениеПараметра);
	КонецЦикла;
	
	Возврат СтруктураПараметров;
	
КонецФункции // ПолучитьПараметрыПодключения()

// Определить файловая ли текущая база
//
// Возвращаемое значение:
//  Истина - текущая база - файловая, иначе - клиент-серверная
//
Функция ЭтоФайловаяБаза() Экспорт
	
	// Определить параметры подключения к информационной базе ЦУП
	ПараметрыПодключения = ИнформационнаяБаза.ПолучитьПараметрыПодключения(
		СтрокаСоединенияИнформационнойБазы());
		
	Возврат ПараметрыПодключения.Свойство("File");
	
КонецФункции // ЭтоФайловаяБаза()

// Сформировать строку соединения с информационной базой
//
// Параметры:
//  ИмяКластера - Строка, имя компьютера на котором расположен кластер ИБ
//  ПортКластера - Число, номер порта кластреа информационной базы
//  ИмяИБ - Строка, имя информационной базы
//  Пользователь - Строка, имя пользователя информационной базы
//  Пароль - Строка, пароль пользователя информационной базы
//
// Возвращаемое значение:
//  Строка - строка подключения к информационной базе
//
Функция СформироватьСтрокуСоединения(ИмяКластера,
                                     ПортКластера,
                                     ИмяИБ,
                                     Пользователь,
                                     Пароль) Экспорт
	
	СтрокаСоединения = "Srvr=""" + ИмяКластера + ":" + Формат(ПортКластера, "ЧН=0; ЧГ=0") + """;Ref=""" + ИмяИБ + """";
	
	Если Не ПустаяСтрока(Пользователь) Тогда
		СтрокаСоединения = СтрокаСоединения + ";Usr=""" + Пользователь + """";
	КонецЕсли;
	
	Если Не ПустаяСтрока(Пароль) Тогда
		СтрокаСоединения = СтрокаСоединения + ";Pwd=""" + Пароль + """";
	КонецЕсли;
	
	Возврат СтрокаСоединения;
	
КонецФункции // СформироватьСтрокуСоединения()


///////////////////////////////////////////////////////////////////////////////
// МЕТАДАННЫЕ

// Получить режим управления блокировкой данных для указанной ИБ
//
// Параметры:
//  СоединениеИБ - ComОбъект, соединение с информационной базой
//
// Возвращаемое значение:
//  РежимУправленияБлокировкойДанныхПоУмолчанию - режим управления блокировками
//
Функция РежимУправленияБлокировкойДанных(СоединениеИБ) Экспорт
	
	Возврат СоединениеИБ.Метаданные.РежимУправленияБлокировкойДанных;
	
КонецФункции // РежимУправленияБлокировкойДанных()


///////////////////////////////////////////////////////////////////////////////
// ДАННЫЕ

// Определить начало и конец интервала содержащего данные в указанной
// информационной базе
//
// Параметры:
//  ИБ - СправочникСсылка.ИнформационнаяБаза
//  НачалоИнтервала - ДатаВремя, начало интервала (возвращаемое значение)
//  КонецИнтервала - ДатаВремя, конец интервала (возвращаемое значение)
//
Процедура ОпределитьИнтервал(ИБ, НачалоИнтервала, КонецИнтервала) Экспорт
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("ИнформационнаяБаза", ИБ);
	Запрос.Текст = "ВЫБРАТЬ
	               |	МИНИМУМ(Интервал.Начало) КАК НачалоИнтервала,
	               |	МАКСИМУМ(Интервал.Конец) КАК КонецИнтервала
	               |ИЗ
	               |	(ВЫБРАТЬ
	               |		МИНИМУМ(ОжиданиеНаБлокировке.Дата) КАК Начало,
	               |		МАКСИМУМ(ОжиданиеНаБлокировке.Дата) КАК Конец
	               |	ИЗ
	               |		Документ.ОжиданиеНаБлокировке КАК ОжиданиеНаБлокировке
	               |	ГДЕ
	               |		ОжиданиеНаБлокировке.ИнформационнаяБаза = &ИнформационнаяБаза
	               |	
	               |	ОБЪЕДИНИТЬ ВСЕ
	               |	
	               |	ВЫБРАТЬ
	               |		МИНИМУМ(Взаимоблокировка.Дата),
	               |		МАКСИМУМ(Взаимоблокировка.Дата)
	               |	ИЗ
	               |		Документ.Взаимоблокировка КАК Взаимоблокировка
	               |	ГДЕ
	               |		Взаимоблокировка.ИнформационнаяБаза = &ИнформационнаяБаза
	               |	
	               |	ОБЪЕДИНИТЬ ВСЕ
	               |	
	               |	ВЫБРАТЬ
	               |		МИНИМУМ(Блокировка.Дата),
	               |		МАКСИМУМ(Блокировка.Дата)
	               |	ИЗ
	               |		Документ.Блокировка КАК Блокировка
	               |	ГДЕ
	               |		Блокировка.ИнформационнаяБаза = &ИнформационнаяБаза
	               |	
	               |	ОБЪЕДИНИТЬ ВСЕ
	               |	
	               |	ВЫБРАТЬ
	               |		МИНИМУМ(ВыполнениеЗапроса.Дата),
	               |		МАКСИМУМ(ВыполнениеЗапроса.Дата)
	               |	ИЗ
	               |		Документ.ВыполнениеЗапроса КАК ВыполнениеЗапроса
	               |	ГДЕ
	               |		ВыполнениеЗапроса.ИнформационнаяБаза = &ИнформационнаяБаза
	               |	
	               |	ОБЪЕДИНИТЬ ВСЕ
	               |	
	               |	ВЫБРАТЬ
	               |		МИНИМУМ(ВыполнениеКода.Дата),
	               |		МАКСИМУМ(ВыполнениеКода.Дата)
	               |	ИЗ
	               |		Документ.ВыполнениеКода КАК ВыполнениеКода
	               |	ГДЕ
	               |		ВыполнениеКода.ИнформационнаяБаза = &ИнформационнаяБаза
	               |	
	               |	ОБЪЕДИНИТЬ ВСЕ
	               |	
	               |	ВЫБРАТЬ
	               |		МИНИМУМ(ЖурналПоказателей.Период),
	               |		МАКСИМУМ(ЖурналПоказателей.Период)
	               |	ИЗ
	               |		РегистрСведений.ЖурналПоказателей КАК ЖурналПоказателей
	               |	ГДЕ
	               |		ЖурналПоказателей.ИнформационнаяБаза = &ИнформационнаяБаза) КАК Интервал";
	Выборка = Запрос.Выполнить().Выбрать();
	
	Если Выборка.Следующий() Тогда
		НачалоИнтервала = Выборка.НачалоИнтервала;
		КонецИнтервала = Выборка.КонецИнтервала;
	Иначе
		НачалоИнтервала = Неопределено;
		КонецИнтервала = Неопределено;
	КонецЕсли;
	
КонецПроцедуры // ОпределитьИнтервал()


///////////////////////////////////////////////////////////////////////////////
// УДАЛЕНИЕ ДАННЫХ

// Удалить закладки информационной базы
//
// Параметры:
//  ИБ - СправочникСсылка.ИнформационнаяБаза
//
Процедура УдалитьЗакладки(ИБ) Экспорт
	
	НачатьТранзакцию();
	Блокировка = Новый БлокировкаДанных;
	СтрокаБлокировки = Блокировка.Добавить("РегистрСведений.Закладки");
	СтрокаБлокировки.УстановитьЗначение("ИнформационнаяБаза", ИБ);
	СтрокаБлокировки.Режим = РежимБлокировкиДанных.Исключительный;
	//Блокировка.Заблокировать();
	
	Набор = РегистрыСведений.Закладки.СоздатьНаборЗаписей();
	Набор.Отбор.ИнформационнаяБаза.Установить(ИБ);
	Набор.Записать(Истина);
	
	ЗафиксироватьТранзакцию();
	
КонецПроцедуры // УдалитьЗакладки()


///////////////////////////////////////////////////////////////////////////////
// СОЗДАНИЕ СТРУКТУР ДАННЫХ

// Создать таблицу соединений рабочих процессов
//
// Возвращаемое значение:
//  ТаблицаЗначений - описание соединений с рабочими процессами:
//                  - Соединение - ComОбъкет
//                  - Имя - Строка
//
Функция СоздатьСоединенияРП() Экспорт
	
	СоединенияРП = Новый ТаблицаЗначений;
	СоединенияРП.Колонки.Добавить("Соединение");
	СоединенияРП.Колонки.Добавить("Имя");
	
	Возврат СоединенияРП;
	
КонецФункции // СоздатьСоединенияРП()