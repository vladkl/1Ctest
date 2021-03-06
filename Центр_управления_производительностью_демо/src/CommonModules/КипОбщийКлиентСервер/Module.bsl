///////////////////////////////////////////////////////////////////////////////
// ФАЙЛОВАЯ СИСТЕМА

// Получить символ разделителя каталогов в зависимости от типа ОС
//
// Возвращаемое значение:
//  Строка - Символ разделяющий каталоги и файлы
//
Функция РазделительКаталогов() Экспорт
	
	СисИнфо = Новый СистемнаяИнформация;
	ЭтоWindows = СисИнфо.ТипПлатформы = ТипПлатформы.Windows_x86 Или
		СисИнфо.ТипПлатформы = ТипПлатформы.Windows_x86_64;
	
	Возврат ?(ЭтоWindows, "\", "/");
	
КонецФункции // РазделительКаталогов()

// Получить символ разделителя пути в зависимости от типа ОС
//
// Возвращаемое значение:
//  Строка - Символ разделяющий элементы пути
//
Функция РазделительПути() Экспорт
	
	СисИнфо = Новый СистемнаяИнформация;
	ЭтоWindows = СисИнфо.ТипПлатформы = ТипПлатформы.Windows_x86 Или
		СисИнфо.ТипПлатформы = ТипПлатформы.Windows_x86_64;
	
	Возврат ?(ЭтоWindows, ";", ":");
	
КонецФункции // РазделительПути()
