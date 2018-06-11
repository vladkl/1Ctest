#Область ПрограммныйИнтерфейс

// Осуществляет поиск по шаблону в строке
//
// Параметры:
//  Строка - Строка - строка, в которой осуществляется поиск.
//  ШаблонПоиска - Строка - шаблон регулярного выражения поиска.
//  	Модификаторы, которые должны быть помещены в начало шаблона, пример (?i):
//			i - регистро-независимый поиск.
//  	Подстановочные символы:
//  		.  - один любой символ. 
//  		\. - символ точки.
//  		\s - символ пробела.
//  		\d - символ цифры.
//  		\n - символ новой строка.
//  		\r - символ перевода каретки.
//  		\S - не пробельный символ.
//  		*  - любое число символов (должен быть помещен после символа, который необходимо повторять, например .*),
//               поиск жадный по умолчанию. 
//  		+  - один и более символ (должен быть помещен после символа, который необходимо повторять, например .+),
//               поиск жадный по умолчанию.
//  		?  - один символ или его отсутсвие (должен быть помещен после символа, который необходимо повторять, например .?),
//               поиск жадный по умолчанию.
//  		? после * или + - переключает жадный режим поиска в ленивый.
//  		\A, ^ - начало строки.
//  		\z, $ - конец строки.
//  		(, ) - начало и завершение группы , например (на|под).
//  		(?= ...) - при просмотре вперед определяется шаблон, который будет найден, но он не возвращается.
//  		(?: ...) - при просмотре назад определяется шаблон, который будет найден, но он не возвращается.
//  		| - альтернативный разделитель групп.
//  		[, ] - начало и конец списка символов, например [sdf\s], [^R].
//			^ - в начале списка символов означает не в этих символах.
//  		\], \[, \), \(, \}, \{ - открытие и закрытие скобок: ], [, ), (, }, {.
//  		\\, \/ - слэши: \, /.
//  		\? - знак вопроса.
//  		\+ - знак плюса.
//  		\- - знак минуса.
//  		\* - начальный символ.
//  		\^ - карет.
//  		\$ - знак доллара.
//  		\@ - коммерческое at.
//  		\| - знак вертикальной черты.
//  ВсеСовпадения - Булево - когда Ложь, возвращается только первое найденное совпадение,
//					         если Истина, возвращаются все совпадения.
//
// Возвращаемое значение:
//	Массив соответствий строк.
//      Этот массив содержит все совпдаение с шаблоном поиска, каждое совпадение может быть в соответствии,
//      где нулевой элемент соответсвия - это полностью вся строка, а каждое последующий шаблон группы будет
//      содержать часть строки, найденной для этой группы.
//
// Например:
//	Результат = РегулярныеВыраженияКлиентСервер.НайтиСовпаденияПоШаблонуПоиска("Some string
//			|to check 894357 %*(# the matching.", 
//  	"(?i)[^\s]+\s\S*\n+((?:to|check|\s)+)\d+.[\(#%\*]+((?:\s|matching|the)*)",
//		Истина);
//
//	Резульат будет содержать следующие значения:
//	Результат[0].Получить(0) -> "Some string
//						|to check 894357 %*(# the matching"
//	Результат[0].Получить(1) -> "to check "
//	Результат[0].Получить(2) -> " the matching"
//
//
//	Результат = РегулярныеВыраженияКлиентСервер.НайтиСовпаденияПоШаблонуПоиска("Some string
//			|to check 894357 %*(# the matching.", "(?i)[^\s]+\s\S*", True);
//
//  Резульат будет содержать следующие значения:
//	Результат[0].Получить(0) -> "Some string"
//	Результат[1].Получить(0) -> "to check"
//	Результат[2].Получить(0) -> "894357 %*(#"
//	Результат[3].Получить(0) -> "the matching."
//
Функция НайтиСовпаденияПоШаблонуПоиска(Строка, ШаблонПоиска, ВсеСовпадения = Ложь) Экспорт
	
	String = Строка;
	Pattern = ШаблонПоиска;
	Global = ВсеСовпадения;
	
	Result = New Array;
	
	StringLength = StrLen(String);

	If Pattern = "\s+" And Global Then
		Result = FastMatchAllSpaces(String);
	Else
		PatternPart = PatternPartStructure();
		PatternPart.Patterns = ParseWildcardPattern(Pattern);
		PatternParts = New Array;
		PatternParts.Add(PatternPart);
		
		Result = CheckWildcardPattern(String, 1, PatternParts, 0, Global, False);
	EndIf;
	
	Return Result;
	
КонецФункции

// Проверка соответствия строки шаблону регулярного выражения
//
// Параметры:
//  Строка - Строка - строка, для которой осуществляется проверка
//  ШаблонПроверки - Строка - регулярное выражение проверки. См. комментарий к НайтиСовпаденияПоШаблонуПоиска().
//
// Возвращаемое значение:
//	Булево - Истина, если строка соответствует шаблону, Ложь в противном случае.
//
Функция СоответствуетШаблонуПоиска(Строка, ШаблонПроверки) Экспорт
	
	String = Строка;
	Pattern = ШаблонПроверки;
	Result = НайтиСовпаденияПоШаблонуПоиска(String, Pattern, Истина);
	
	If Result.Count() = 1 And Result[0][0] = String Then
		Return True;
	Else
		Return False;
	EndIf
	
КонецФункции

// Поиск по шаблону регулярного выражения в строке и замена с помощь регулярного выражения.
//
// Параметры:
//  Строка       - Строка - строка, в которой осуществляется замена.
//  ШаблонПоиска - Строка - регулярное выражение поиска. См. комментарий к НайтиСовпаденияПоШаблонуПоиска().
//  ШаблонЗамены - String - регулярное выражение замены, шаблон группы может быть в замене.
//
// Возвращаемое значение:
//	Строка - входящая строка после выполнения замены.
//
// Например:
//	Результат  = РегулярныеВыраженияКлиентСервер.ЗаменитьПоШаблонуПоиска("Some string
//			|to check.", 
//  	"\s+",
//		" ");
//	Результат = РегулярныеВыраженияКлиентСервер.ЗаменитьПоШаблонуПоиска("Some <o:p>string
//			|to</o:p> check.", 
//  	"(?i)<o:p\s*>([^<>]*)<\/o:p>",
//		"$1");
//
//	Результат будет содержать следующие значения:
//	Результат -> "Some string
//			   |to check."
//
Функция ЗаменитьПоШаблонуПоиска(Строка, ШаблонПоиска, ШаблонЗамены) Экспорт
	
	String = Строка;
	Pattern = ШаблонПоиска;
	Replacement = ШаблонЗамены;
	
	Result = String;
	
	Match = НайтиСовпаденияПоШаблонуПоиска(String, Pattern, True);
	
	Substrings = New Array;
	Replacements = New Array;
	MaxLength = 0;
	For Each MatchItem In Match Do
		MatchItemString = MatchItem.Get(0);
		If Substrings.Find(MatchItemString) = Undefined Then
			Substrings.Add(MatchItemString);
			MaxLength = Max(MaxLength, StrLen(MatchItemString));
			
			CurReplacement = Replacement;
			For Each MatchItemGroup In MatchItem Do
				If MatchItemGroup.Key > 0 Then
					CurReplacement = StrReplace(CurReplacement, "$" + MatchItemGroup.Key, MatchItemGroup.Value);
				EndIf;
			EndDo;
			Replacements.Add(CurReplacement);
		EndIf;
	EndDo;
	
	SortedSubstrings = New Array;
	SortedReplacements = New Array;
	HaveItems = Substrings.Count() > 0;
	For CurrentLengthMinus = 1 To MaxLength Do
		CurrentLength = MaxLength - CurrentLengthMinus + 1;
		SubstringsLength = Substrings.Count();
		For CurrentSubstringIMinus = 1 To SubstringsLength Do
			CurrentSubstringI = SubstringsLength - CurrentSubstringIMinus;
			Substring = Substrings[CurrentSubstringI];
			If StrLen(Substring) = CurrentLength Then
				SortedSubstrings.Add(Substring);
				SortedReplacements.Add(Replacements[CurrentSubstringI]);
			EndIf;
		EndDo;
	EndDo;
	
	SortedSubstringsLength = SortedSubstrings.Count();
	For SubstringI = 0 To SortedSubstringsLength - 1 Do
		Result = StrReplace(Result, SortedSubstrings[SubstringI], SortedReplacements[SubstringI]);
	EndDo;
	
	Return Result;
	
КонецФункции

// Разделяет строку на массив подстрок по массиву разделителей.
// Результат будет содержать разделители как отдельные элементы массива.
// Разделителями служат шаблоны регулярного выражения.
// Дополнительные подробности см. в описании функции НайтиСовпаденияПоШаблонуПоиска().
//
// Параметры:
//  Строка               - Строка - строка для разделение.
//  ШаблонПоиска         - Строка - регулярное выражение, по которому осуществляется разбиение. См. НайтиСовпаденияПоШаблонуПоиска().
//  ДобавлятьРазделители - Булево - если Истина, разделители будут содержаться в возвращаемом значении,
//                                  если Ложь, если Ложь, то нет.
//
// Возвращаемое значение: 
//  Массив - массив строк, разбитый на части и разделители.
//
Функция РазделитьПоШаблонуПоиска(Знач Строка, ШаблонПоиска, ДобавлятьРазделители = Ложь) Экспорт
	
	String = Строка;
	Pattern = ШаблонПоиска;
	AppendSeparators = ДобавлятьРазделители;
	
	Matches = НайтиСовпаденияПоШаблонуПоиска(String, Pattern, True);
	
	Separators = New Array;
	For Each Match In Matches Do
		Separators.Add(Match[0]);
	EndDo;
	
	Return SplitBySeparators(String, Separators, AppendSeparators);
	
КонецФункции

// Экранирует метасимволы.
// Полный список метасимволов перечислен в описании функции НайтиСовпаденияПоШаблонуПоиска.
//
// Параметры:
//  Строка - Строка - строка для экранирования.
//
// Возвращаемое значение:
//	Строка - строка с экранируемыми символами.
//
Функция ЭкранироватьМетаСимволы(Строка) Экспорт
	
	String = Строка;
	
	Return StrReplace(
		   StrReplace(
		   StrReplace(
		   StrReplace(
		   StrReplace(
		   StrReplace(
		   StrReplace(
		   StrReplace(
		   StrReplace(
		   StrReplace(
		   StrReplace(
		   StrReplace(
		   StrReplace(
		   StrReplace(
		   StrReplace(
		   StrReplace(String,
		   		"\", "\\"),
		   		"/", "\/"),
		   		".", "\."),
		   		"*", "\*"),
		   		"+", "\+"),
		   		"-", "\-"),
		   		"?", "\?"),
		   		"^", "\^"),
		   		"$", "\$"),
		   		"(", "\("),
		   		")", "\)"),
		   		"[", "\["),
		   		"]", "\]"),
		   		"{", "\{"),
		   		"}", "\}"),
		   		"|", "\|");
	
КонецФункции

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

// Splits the wildcard pattern into an array of structures for maching.
Function ParseWildcardPattern(Val Pattern, GroupNumber = 0, FixedStructureResult = True)
	
	PatternPartI = 0;
	PatternSetI = 0;
	PatternSets = New Array();
	PatternSets.Add(New Array);
	PatternLength = StrLen(Pattern);
	LastChar = "";
	ModifiersSection = False;
	PatternSection = False;
	CaseSensitive = True;
	GroupOpenedAt = Undefined; 
	ListOpenedAt = Undefined;
	GroupOpenedCount = 0;
	ListOpenedCount = 0;
	CurrentGroupNumber = GroupNumber;
	GlobalMultiplierIsGreedy = True;
	
	BasePatternPartStructure = New FixedStructure(PatternPartStructure());
	
	// parsing the pattern
	For I = 1 To PatternLength Do
		
 		Char = Mid(Pattern, I, 1);
		
		// section definitions
		If Not PatternSection And Not ModifiersSection Then
			If IsBlankString(Char) Then
				Continue;
			ElsIf Char = "(" Then
				If I < PatternLength Then
					NextChar = Mid(Pattern, I + 1, 1);
					NextNextChar = Mid(Pattern, I + 2, 1);
					If NextChar = "?" And NextNextChar <> ":" Then
						ModifiersSection = True;
						I = I + 1;
						Continue;
					Else
						PatternSection = True;
					EndIf;
				Else
					PatternSection = True;
				EndIf;
			Else 
				PatternSection = True;
			EndIf;
		ElsIf ModifiersSection Then
			If Char = ")" Then
				ModifiersSection = False;
			ElsIf Lower(Char) = "i" Then
				CaseSensitive = False;
			EndIf;
			
			Continue;
		EndIf;
		
		// pattern character parsing
		IsString = False;
		IsSpace = False;
		IsNotSpace = False;
		IsAnyChar = False;
		IsBegin = False;
		IsEnd = False;
		IsDigit = False;
		IsInList = False;
		IsNotInList = False;
		IsGroup = False;
		MultiplierIsGreedy = GlobalMultiplierIsGreedy;
		GroupClosed = False;
		ListClosed = False;
		ListValues = Undefined;
		GroupPatternParts = Undefined;
		
		IsEscapedChar = Char = "\";
		HasMultiplier = False;
		
		ValueChar = Char;
		MultiplierChar = "";
		If IsEscapedChar Then
			If I < PatternLength Then
				NextChar = Mid(Pattern, I + 1, 1);
				If NextChar = "s" Then
					ValueChar = "";
					IsSpace = True;
				ElsIf NextChar = "S" Then
					ValueChar = "";
					IsNotSpace = True;
				ElsIf NextChar = "A" Then
					ValueChar = "";
					IsBegin = True;
				ElsIf NextChar = "z" Then
					ValueChar = "";
					IsEnd = True;
				ElsIf NextChar = "d" Then
					ValueChar = "";
					IsDigit = True;
				ElsIf NextChar = "n" Then
					ValueChar = Chars.LF;
				ElsIf NextChar = "r" Then
					ValueChar = Chars.CR;
				ElsIf NextChar = "(" Or NextChar = ")" Or NextChar = "[" Or NextChar = "]"
					  Or NextChar = "{" Or NextChar = "}" Or NextChar = "\" Or NextChar = "/"
					  Or NextChar = "?" Or NextChar = "*" Or NextChar = "+" Or NextChar = "."
					  Or NextChar = "-" Or NextChar = "^" Or NextChar = "$" Or NextChar = "@" 
					  Or NextChar = "|" Then
					ValueChar = NextChar;
					IsSpace = False;
				EndIf;
			EndIf;
		Else
			If Char = "." Then
				ValueChar = "";
				IsAnyChar = True;
			ElsIf Char = "^" Then
				ValueChar = "";
				IsBegin = True;
			ElsIf Char = "$" Then
				ValueChar = "";
				IsEnd = True;
			ElsIf Char = "(" Then
				GroupOpenedCount = Max(0, GroupOpenedCount + 1);
				If GroupOpenedCount = 1 Then
					GroupOpenedAt = I;
				EndIf;
			ElsIf Char = "[" Then
				ListOpenedCount = Max(0, ListOpenedCount + 1);
				If ListOpenedCount = 1 Then
					ListOpenedAt = I;
				EndIf;
			ElsIf Char = ")" Then
				GroupOpenedCount = Max(0, GroupOpenedCount - 1);
				If GroupOpenedCount = 0 Then
					GroupClosed = True;
				EndIf;
			ElsIf Char = "]" Then
				ListOpenedCount = Max(0, ListOpenedCount - 1);
				If ListOpenedCount = 0 Then
					ListClosed = True;
				EndIf;
			ElsIf Char = "|" And GroupOpenedAt = Undefined And ListOpenedAt = Undefined Then
				PatternSetI = PatternSetI + 1;
				PatternSets.Add(New Array);
				Continue;
			EndIf;
		EndIf;
	
		If ListClosed Then
			
			ListPatternSetsString = Mid(Pattern, ListOpenedAt + 1, I - ListOpenedAt - 1);
			ListPatternSets = ParseWildcardPattern(ListPatternSetsString);
			
			NegativeList = Left(ListPatternSetsString, 1) = "^";
			ListValues = New Array;
			FirstListItemCheck = True;
			For Each ListPatternSet In ListPatternSets.PatternSets Do
				For Each ListPatternPart In ListPatternSet Do
					If FirstListItemCheck And NegativeList Then
						FirstListItemCheck = False;
						Continue;
					EndIf;
					If ListPatternPart.IsSpace Then
						ListValues.Add(" ");
						ListValues.Add(Chars.CR + Chars.LF);
						ListValues.Add(Chars.CR);
						ListValues.Add(Chars.LF);
						ListValues.Add(Chars.Tab);
						ListValues.Add(Chars.NBSp);
					ElsIf ListPatternPart.IsString Then
						ListPatternPartStringLength = StrLen(ListPatternPart.String);
						LastChar = "";
						For ListPatternPartStringI = 1 To ListPatternPartStringLength Do
							CurChar = Mid(ListPatternPart.String, ListPatternPartStringI, 1);
							If CurChar = "-" And LastChar <> "" And ListPatternPartStringI + 1 < ListPatternPartStringLength Then
								LastCharCode = CharCode(LastChar);
								NextCharCode = CharCode(Mid(ListPatternPart.String, ListPatternPartStringI + 1, 1));
								If NextCharCode > LastCharCode Then
									For IC = LastCharCode + 1 To NextCharCode - 1 Do
										ListValues.Add(Char(IC));
									EndDo;
									Continue;
								EndIf;
							EndIf;
							ListValues.Add(CurChar);
							LastChar = CurChar;
						EndDo;
					ElsIf ListPatternPart.IsDigit Then
						ListValues.Add("0");
						ListValues.Add("1");
						ListValues.Add("2");
						ListValues.Add("3");
						ListValues.Add("4");
						ListValues.Add("5");
						ListValues.Add("6");
						ListValues.Add("7");
						ListValues.Add("8");
						ListValues.Add("9");
					Else
						Raise NStr("en = 'Invalid value in the list of chars (""[...]"").'; ru = 'Неверное значение в списке символов (""[...]"").'");						
					EndIf;
				EndDo;
			EndDo;
			ListValues = New FixedArray(ListValues);
			
			IsInList = Not NegativeList;
			IsNotInList = NegativeList;
			
			ListOpenedAt = Undefined;
			
		ElsIf GroupClosed Then
			
			If GroupOpenedAt = Undefined Or GroupOpenedAt = Undefined Then
				Raise NStr("en = 'Found no opening group bracket (""("").'; ru = 'Не найдена открывающая скобка группы (""("").'");
			EndIf;
			GroupPatternPartsString = Mid(Pattern, GroupOpenedAt + 1, I - GroupOpenedAt - 1);
			LookForward = False;
			If Mid(GroupPatternPartsString, 1, 2) = "?:" Then
				// Will not have own group, goes to the main group
				CurrentGroupNumber = 0; 
				// Removing group modifiers
				GroupPatternPartsString = Mid(GroupPatternPartsString, 3);
			ElsIf Mid(GroupPatternPartsString, 1, 2) = "?=" Then
				// Will not have any group and will not be included in the result, but will be matched
				CurrentGroupNumber = 0; 
				LookForward = True;
				// Removing group modifiers
				GroupPatternPartsString = Mid(GroupPatternPartsString, 3);
			Else
				GroupNumber = GroupNumber + 1;
				CurrentGroupNumber = GroupNumber;
			EndIf;
			GroupPatternParts = ParseWildcardPattern(GroupPatternPartsString, GroupNumber, False);
			GroupPatternParts.CaseSensitive = CaseSensitive;
			GroupPatternParts.LookForward = LookForward;
			
			IsGroup = True;
			
			GroupOpenedAt = Undefined;
			
		EndIf;
		
		If I + ?(IsEscapedChar, 1, 0) < PatternLength Then
			NextChar = Mid(Pattern, I + 1 + ?(IsEscapedChar, 1, 0), 1);
			If NextChar = "*" Or NextChar = "?" Or NextChar = "+" Then
				MultiplierChar = NextChar;
				HasMultiplier = True;
			EndIf;
		EndIf;
		
		If HasMultiplier And I + ?(IsEscapedChar, 1, 0) + 1 < PatternLength Then
			NextChar = Mid(Pattern, I + 2 + ?(IsEscapedChar, 1, 0), 1);
			If NextChar = "?" Then
				MultiplierIsGreedy = Not MultiplierIsGreedy;
				MultiplierChar = MultiplierChar + NextChar;
			EndIf;
		EndIf;
		
		If IsEscapedChar Then
			I = I + 1;
		EndIf;
		If HasMultiplier Then
			I = I + StrLen(MultiplierChar);
		EndIf;
		
		ListOrGroupOpened = ListOpenedAt <> Undefined Or GroupOpenedAt <> Undefined;
		IsNotString = (IsAnyChar Or IsSpace Or IsNotSpace Or IsBegin Or IsEnd 
					   Or IsDigit Or IsInList Or IsNotInList Or IsGroup
					   Or ListOrGroupOpened);
		IsString = Not IsNotString;
		
		// adding new parts when the type is changed
		If PatternSets[PatternSetI].Count() = 0 Then 
			PatternPartI = 0;
		ElsIf PatternPartI >= 0 And PatternPartI < PatternSets[PatternSetI].Count() Then
			If (PatternSets[PatternSetI][PatternPartI].IsString <> IsString Or IsNotString Or HasMultiplier)
			   And Not (ListOpenedAt <> Undefined Or GroupOpenedAt <> Undefined) Then
				PatternPartI = PatternPartI + 1;
			EndIf;
		EndIf;
		
		If PatternSets[PatternSetI].Count() = PatternPartI And Not ListOrGroupOpened Then
			PatternPartStructure = New Structure(BasePatternPartStructure);
			PatternPartStructure.IsString = IsString;
			PatternPartStructure.IsSpace = IsSpace;
			PatternPartStructure.IsAnyChar = IsAnyChar;
			PatternPartStructure.IsNotSpace = IsNotSpace;
			PatternPartStructure.IsBegin = IsBegin;
			PatternPartStructure.IsEnd = IsEnd;
			PatternPartStructure.IsDigit = IsDigit;
			PatternPartStructure.IsInList = IsInList;
			PatternPartStructure.IsNotInList = IsNotInList;
			PatternPartStructure.IsGroup = IsGroup;
			PatternPartStructure.Multiplier.Greedy = MultiplierIsGreedy;
			If IsString Then
				PatternPartStructure.String = ValueChar;
			EndIf;
			If IsGroup Then
				PatternPartStructure.GroupNumber = CurrentGroupNumber;
			EndIf;
			PatternPartStructure.List = ListValues;
			PatternPartStructure.Patterns = GroupPatternParts;
			If MultiplierChar = "?" Then
				PatternPartStructure.Multiplier.Min = 0;
				PatternPartStructure.Multiplier.Max = 1;
			ElsIf MultiplierChar = "+" Or MultiplierChar = "+?" Then
				PatternPartStructure.Multiplier.Min = 1;
				PatternPartStructure.Multiplier.Max = Undefined;
			ElsIf MultiplierChar = "*" Or MultiplierChar = "*?" Then
				PatternPartStructure.Multiplier.Min = 0;
				PatternPartStructure.Multiplier.Max = Undefined;
			Else
				PatternPartStructure.Multiplier.Min = 1;
				PatternPartStructure.Multiplier.Max = 1;
			EndIf;
			// checking for unlimited matches in case of zero length matching result
			If PatternPartStructure.Multiplier.Max = Undefined
			   And (PatternPartStructure.IsBegin Or PatternPartStructure.IsEnd) Then
			    PatternPartStructure.Multiplier.Max = 1;
			EndIf;
			PatternPartStructure.Multiplier = New FixedStructure(PatternPartStructure.Multiplier);
			
			PatternSets[PatternSetI].Add(PatternPartStructure);
		ElsIf PatternPartI+1 = PatternSets[PatternSetI].Count() Then
			If IsString Then
				PatternSets[PatternSetI][PatternPartI].String = PatternSets[PatternSetI][PatternPartI].String + ValueChar;
			EndIf;
		ElsIf Not ListOrGroupOpened Then
			Raise NStr("en = 'Calculation error.'; ru = 'Ошибка вычисления.'");
		EndIf;
			
	EndDo;
	
	If GroupOpenedCount > 0 Then
		Raise NStr("en = 'The group closing bracket is not found ("")"").'; ru = 'Не найдена закрывающая скобка группы шаблона ("")"").'");
	ElsIf ListOpenedCount > 0 Then
		Raise NStr("en = 'The list closing bracket is not found (""]"").'; ru = 'Не найдена закрывающая скобка списка значений (""]"").'");
	EndIf;
	
	FixedPatternSets = New Array;
	For Each PatternSet In PatternSets Do
		FixedPatternSet = New Array;
		For Each PatternPart In PatternSet Do
			FixedPatternSet.Add(New FixedStructure(PatternPart));
		EndDo;
		FixedPatternSets.Add(New FixedArray(FixedPatternSet));
	EndDo;
	
	Result = New Structure;
	Result.Insert("PatternSets", New FixedArray(FixedPatternSets));
	Result.Insert("CaseSensitive", CaseSensitive);
	Result.Insert("LookForward", False);
	
	If FixedStructureResult Then
		Return New FixedStructure(Result);
	Else
		Return Result;
	EndIf;
	
EndFunction

Function PatternPartStructure()
	PatternPartStructure = New Structure;
	PatternPartStructure.Insert("IsString", False);
	PatternPartStructure.Insert("IsSpace", False);
	PatternPartStructure.Insert("IsAnyChar", False);
	PatternPartStructure.Insert("IsNotSpace", False);
	PatternPartStructure.Insert("IsBegin", False);
	PatternPartStructure.Insert("IsEnd", False);
	PatternPartStructure.Insert("IsDigit", False);
	PatternPartStructure.Insert("IsInList", False);
	PatternPartStructure.Insert("IsNotInList", False);
	PatternPartStructure.Insert("IsGroup", False);
	PatternPartStructure.Insert("GroupNumber", 0);
	PatternPartStructure.Insert("String", "");
	PatternPartStructure.Insert("List", New Array);
	PatternPartStructure.Insert("Patterns", New Array);
	Multiplier = New Structure;
	Multiplier.Insert("Min", 1);
	Multiplier.Insert("Max", 1);
	Multiplier.Insert("Greedy", False);
	PatternPartStructure.Insert("Multiplier", Multiplier);
	
	Return PatternPartStructure;
EndFunction

Function CheckWildcardPattern(String, CheckAt, PatternParts, PatternPartI, Global, MatchRequired)

	PatternPartsLength = PatternParts.Count();
	PatternSets = PatternParts[PatternPartI].Patterns.PatternSets;
	PatternSetLength = PatternSets.Count();
	CaseSensitive = PatternParts[PatternPartI].Patterns.CaseSensitive;
	CheckNextPatterns = PatternPartI < PatternPartsLength-1;
	
	FoundGroups = New Array;
	StringLength = StrLen(String) - CheckAt + 1;
	StringI = 1;
	If PatternSetLength < 1 Then
		Raise NStr("en = 'The pattern sets are not set.'; ru = 'Наборы шаблонов не заданы.'");
	EndIf;
	
	While True Do
		
		FoundSetStrings = New Array(PatternSetLength);
		FoundSetStringOffsets = New Array(PatternSetLength);
		NotFoundSetStringOffsets = New Array(PatternSetLength);
		SkipPatternSet = False;
		
		For PatternSetI = 0 To PatternSetLength - 1 Do
			
			SubPatternParts = PatternSets[PatternSetI];
			
			CurrentStringI = StringI;
			InitialMatchRequired = MatchRequired;
			SubPatternPartLength = SubPatternParts.Count();
			If Not MatchRequired Then
				If SubPatternPartLength > 0 Then
					InitialMatchRequired = SubPatternParts[0].IsBegin;
				Else
					Raise NStr("en = 'The pattern not set.'; ru = 'Шаблон не задан.'");
				EndIf;
			EndIf;
			SubPatternPartI = 0;
			CurrentMatchRequired = InitialMatchRequired;
			FoundPatternSetGroups = New Map;
			
			// To check next patterns of the container group
			CurrentPatternParts = New Array(SubPatternParts);
			If CheckNextPatterns Then
				For CurPatternPartI = PatternPartI + 1 To PatternPartsLength - 1 Do
					CurrentPatternParts.Add(PatternParts[CurPatternPartI]);
				EndDo;
			EndIf;

			While True Do
				
				CurrentStringIncrement = 1;
				
				FoundSubPatternPart = Undefined;
				If Undefined <> CheckWildcardPatternPartValue(String, CheckAt + CurrentStringI - 1,
												 CurrentPatternParts, SubPatternPartI, CaseSensitive) Then
					FoundSubPatternPart = CheckWildcardPatternPartOnce(String, 
						CheckAt + CurrentStringI - 1, CurrentPatternParts, SubPatternPartI, CaseSensitive, False, 0);
				EndIf;
				
				// Checking, maybe the current result should be skipped because there are other
				// conditions that don't match in that case.
				If FoundSubPatternPart <> Undefined
				   And CurrentPatternParts[SubPatternPartI].Multiplier.Min = 0 
				   And SubPatternPartI < SubPatternPartLength-1 Then
				    For Each FoundSubPatternPartPart In FoundSubPatternPart Do
						If Undefined = CheckWildcardPatternPartValue(String, CheckAt + CurrentStringI - 1 + StrLen(FoundSubPatternPartPart.Value),
														 CurrentPatternParts, SubPatternPartI + 1, CaseSensitive) Then
							FoundSubPatternPart = Undefined;
							Break;
						EndIf;
					EndDo;
				EndIf;

				// If the current pattern is allowed not to be found, searching for next ones.
				While FoundSubPatternPart = Undefined And SubPatternPartI < SubPatternPartLength-1 Do
					If CurrentPatternParts[SubPatternPartI].Multiplier.Min = 0 Then
						SubPatternPartI = SubPatternPartI + 1;
						If Undefined <> CheckWildcardPatternPartValue(String, CheckAt + CurrentStringI - 1,
														 CurrentPatternParts, SubPatternPartI, CaseSensitive) Then
							FoundSubPatternPart = CheckWildcardPatternPartOnce(String, 
								CheckAt + CurrentStringI - 1, CurrentPatternParts, SubPatternPartI, CaseSensitive, False, 0);
							If FoundSubPatternPart <> Undefined Then
								Break;
							EndIf;
						EndIf;
					Else
						Break;
					EndIf;
				EndDo;
				
				If FoundSubPatternPart <> Undefined Then
					CurrentMatchRequired = True;
					SubPatternPartI = SubPatternPartI + 1;
					For Each FoundSubPatternPartGroup In FoundSubPatternPart Do
						FoundSubPatternPartGroupNumber = FoundSubPatternPartGroup.Key;
						FoundSubPatternPartString = FoundSubPatternPartGroup.Value;
						FoundPatternSetGroups.Insert(FoundSubPatternPartGroupNumber, 
							?(FoundPatternSetGroups.Get(FoundSubPatternPartGroupNumber) = Undefined, "", 
								FoundPatternSetGroups.Get(FoundSubPatternPartGroupNumber)) 
							+ FoundSubPatternPartString);
						If FoundSubPatternPartGroupNumber = 0 Then
							CurrentStringIncrement = Find(Mid(String, CheckAt + CurrentStringI - 1), 
								FoundSubPatternPartString) - 1 + StrLen(FoundSubPatternPartString);
						EndIf;
					EndDo;
					
				ElsIf CurrentMatchRequired Then
					If MatchRequired Then
						// Do not continue searching because the current position 
						// is required to be checked only
						Break;
					Else
						// No match found after previous was found 
						// or pattern says to start from the beginning of the string.
						SubPatternPartI = 0;
						CurrentMatchRequired = InitialMatchRequired;
						FoundPatternSetGroups.Clear();
					EndIf;
				EndIf;
				
				If FoundSubPatternPart = Undefined Then
					// Searching for the clothest first match for the optimization
					CurCheckAtStart = CheckAt + CurrentStringI - 1;
					CurCheckAt = CurCheckAtStart + CurrentStringIncrement;
					// Optimization for most often checked part using inline code instead
					// of the function call.
					If CurrentPatternParts[SubPatternPartI].IsString Then
						PatternString = CurrentPatternParts[SubPatternPartI].String;
						PatternStringLength = StrLen(PatternString);
						For CurCheckAt = CurCheckAt To StringLength Do
							If Not CaseSensitive And StrCompare(Mid(String, CurCheckAt, PatternStringLength), PatternString) = 0
						       Or  CaseSensitive And            Mid(String, CurCheckAt, PatternStringLength) = PatternString Then
								Break;
							EndIf;
						EndDo;
					// End optimization.
					Else
						For CurCheckAt = CurCheckAt To StringLength Do
							// Adding found increment to check on the next loop
							// the place where first pattern is found
							If CheckWildcardPatternPartValue(String, 
							   CurCheckAt, CurrentPatternParts, 
							   SubPatternPartI, CaseSensitive) <> Undefined Then
								Break;
							EndIf;
						EndDo;
					EndIf;
					CurrentStringIncrement = CurCheckAt - CurCheckAtStart;
					
					NotFoundSetStringOffsets[PatternSetI] = CurrentStringI + CurrentStringIncrement - StringI;
				EndIf;
				
				If SubPatternPartI >= SubPatternPartLength Then
					FoundSetStrings[PatternSetI] = FoundPatternSetGroups;
					FoundSetStringOffsets[PatternSetI] = Find(Mid(String, CheckAt + StringI - 1), FoundPatternSetGroups.Get(0)) - 1;
					FoundPatternSetGroups = New Map;
					Break;
				EndIf;

				CurrentStringI = CurrentStringI + CurrentStringIncrement;
				
				// End of string, if no need to check for the end of string.
				If CurrentStringI > StringLength + 1 
				   And (SubPatternPartI >= SubPatternPartLength
				        Or Not CurrentPatternParts[SubPatternPartI].IsEnd) Then
					Break;
				EndIf;
				
			EndDo;
			
		EndDo;
		
		// Selecting the shortest result
		BestMatch = Undefined;
		BestMatchOffset = Undefined;
		For FoundSetI = 0 To PatternSetLength - 1 Do
			If FoundSetStringOffsets[FoundSetI] <> Undefined 
			   And (BestMatchOffset = Undefined Or BestMatchOffset > FoundSetStringOffsets[FoundSetI]) Then
				BestMatchOffset = FoundSetStringOffsets[FoundSetI];
				BestMatch = FoundSetStrings[FoundSetI];
			EndIf;
		EndDo;
		
		If BestMatch <> Undefined Then
			StringI = StringI + BestMatchOffset + StrLen(BestMatch.Get(0));
			FoundGroups.Add(BestMatch);
		Else
			// Skipping pattern sets that haven't been found till the closest found.
			MinOffset = Undefined;
			For Each NotFoundOffset In NotFoundSetStringOffsets Do
				If NotFoundOffset <> Undefined
				   And (MinOffset = Undefined Or MinOffset > NotFoundOffset) Then
					MinOffset = NotFoundOffset;
				EndIf;
			EndDo;
			StringI = StringI + ?(MinOffset = Undefined Or MinOffset < 1, 1, MinOffset);
		EndIf;
		
		If ( Not Global And FoundGroups.Count() > 0 ) 
		   Or StringI > StringLength
		   Or MatchRequired Then
			Break;
		EndIf;
		
	EndDo;
	
	Return FoundGroups;
	
EndFunction 

Function CheckWildcardPatternPartOnce(String, CheckAt, PatternParts, PatternPartIndex, CaseSensitive, ForceNotGreedy, Depth)
	
	MaxDepth = 500; // to check that nested call depth is not too deep
	StringLength = StrLen(String);
	StringIncrement = 0;
	StringI = CheckAt;
	FoundGroups = New Map;
	MatchCount = 0;
	NextPatternFound = False;
	PatternPartLength = PatternParts.Count();
	PatternPart = PatternParts[PatternPartIndex];
	PatternPartGroupNumber = PatternPart.GroupNumber;
	While StringI <= StringLength + 1 Do
		
		StringIncrement = 1;
		BreakLoop = False;
		
		FoundPart = CheckWildcardPatternPartValue(String, StringI, PatternParts, PatternPartIndex, CaseSensitive);
		
		// Checking for the rest of the pattern to find where the range of occurrence count
		// is ended.
		If FoundPart <> Undefined And MaxDepth > Depth 
		   And MatchCount + 1 >= PatternPart.Multiplier.Min 
		   And (PatternPart.Multiplier.Max = Undefined Or MatchCount + 1 < PatternPart.Multiplier.Max) Then
		   
			If Not PatternPart.Multiplier.Greedy Or ForceNotGreedy Then
				// For lazy multiplier searching for the first occurrence.
				If PatternPartIndex + 1 < PatternPartLength Then
					FoundNextPart = CheckWildcardPatternPartOnce(String, StringI + 1, PatternParts, PatternPartIndex + 1, 
																 CaseSensitive, True, Depth + 1);
					If FoundNextPart <> Undefined Then
						NextPatternFound = True;
						BreakLoop = True; // found the next part before max times of pattern was found
					Else
						FoundNextPart = CheckWildcardPatternPartOnce(String, StringI, PatternParts, PatternPartIndex + 1, 
																	 CaseSensitive, True, Depth + 1);
						// the next part is found as current, then the current pattern part is failed to be found
						If FoundNextPart <> Undefined Then
							FoundPart = Undefined; 
						EndIf;
					EndIf;
				EndIf;
			Else
			    // For greedy multiplier searching for the last possible occurrence.
				// If there is a possibility to find it on next steps, then skipping
				// the current one.
				FoundPartLength = StrLen(FoundPart);
				CurStringI = StringI + Find(Mid(String, StringI), FoundPart) - 1 + FoundPartLength;
				//FoundNextPart = Undefined;
				LastPatternPartIndex = Undefined;
				While True Do
					CurFoundNextPart = Undefined;
					If CurStringI < StringLength Then 
						CurFoundNextPart = CheckWildcardPatternPartOnce(String, CurStringI, 
							PatternParts, PatternPartIndex, CaseSensitive, True, Depth + 1);
					EndIf;

					If CurFoundNextPart = Undefined Then
						BreakLoop = True; // found the last occurrence of the current part
						NextPatternFound = True;
						If LastPatternPartIndex <> Undefined Then
							PatternPartIndex = LastPatternPartIndex;
						EndIf;
						Break;
					Else
						FoundNextPart = CurFoundNextPart;
						// enhancing the found part till the found next part
						FoundNextPartString = FoundNextPart.Get(0);
						If FoundNextPartString <> "" Then
							Substring = Mid(String, CurStringI);
							FoundNextPartOffset = Find(Substring, FoundNextPartString) - 1;
							FoundNextPartLength = StrLen(FoundNextPartString);
							FoundPart = FoundPart + Left(Substring, FoundNextPartOffset + FoundNextPartLength);
							CurStringI = CurStringI + FoundNextPartOffset + FoundNextPartLength;
							// checking again after that
						// If empty string found then should check next pattern part because
						// previous one was not mandatory.
						ElsIf PatternPartIndex + 1 < PatternParts.Count() 
							  And PatternPartGroupNumber = PatternParts[PatternPartIndex + 1].GroupNumber Then
							LastPatternPartIndex = PatternPartIndex;
							PatternPartIndex = PatternPartIndex + 1;
							PatternPart = PatternParts[PatternPartIndex];
							PatternPartGroupNumber = PatternPart.GroupNumber;
						Else
							BreakLoop = True; // found the last occurrence of the current part
							NextPatternFound = True;
							Break;
						EndIf;
					EndIf;
				EndDo;
			EndIf;
			
		EndIf;
		
		// Storing the found value.
		If FoundPart <> Undefined Then
			For I = 0 To 1 Do
				//PatternPartGroupNumber = PatternParts[PatternPartIndex].GroupNumber;
				If PatternPartGroupNumber <> Undefined Then
					GroupNumber = I * PatternPartGroupNumber;
					If GroupNumber > 0 Or I = 0 Then
						GroupString = FoundGroups.Get(GroupNumber);
						FoundGroups.Insert(GroupNumber, 
							?(GroupString = Undefined, "", GroupString) + FoundPart);
					EndIf;
				EndIf;
			EndDo;
			Substring = Mid(String, StringI);
			If Substring <> "" Then
				StringIncrement = Find(Substring, FoundPart) - 1 + StrLen(FoundPart);
			EndIf;
			MatchCount = MatchCount + 1;
			PreviousPatternFound = FoundPart <> Undefined;
		Else
			BreakLoop = True;
		EndIf;
		
		If BreakLoop Then
			Break;
		EndIf;
		
		If MatchCount < PatternPart.Multiplier.Min And FoundPart = Undefined Then
			Break; // Not matched minimum number of counts.
		EndIf;
		
		If PatternPart.Multiplier.Max <> Undefined And MatchCount >= PatternPart.Multiplier.Max Then
			Break; // Last possible match.
		EndIf;
		
		If StringIncrement = 0 Then
			Break; // The empty match found (0 multiplier).
		EndIf;
		
		StringI = StringI + StringIncrement;

	EndDo;
	
	If FoundGroups.Count() > 0 Then
		Return FoundGroups;
	Else
		Return Undefined;
	EndIf;
	
EndFunction

Function CheckWildcardPatternPartValue(String, CheckAt, PatternParts, PatternPartI, CaseSensitive) 
	
	PatternPart = PatternParts[PatternPartI];
	
	Result = Undefined; 
	
	If PatternPart.IsString Then
		Result = IsStringWildcardCheck(String, CheckAt, PatternPart.String, CaseSensitive);
	ElsIf PatternPart.IsSpace Then
		Result = IsSpaceWildcardCheck(String, CheckAt);
	ElsIf PatternPart.IsAnyChar Then
		Result = IsAnyCharWildcardCheck(String, CheckAt);
	ElsIf PatternPart.IsNotSpace Then
		Result = IsNotSpaceWildcardCheck(String, CheckAt);
	ElsIf PatternPart.IsBegin Then
		Result = IsBeginWildcardCheck(String, CheckAt);
	ElsIf PatternPart.IsEnd Then
		Result = IsEndWildcardCheck(String, CheckAt);
	ElsIf PatternPart.IsDigit Then
		Result = IsDigitWildcardCheck(String, CheckAt);
	ElsIf PatternPart.IsInList Then
		Result = IsInListWildcardCheck(String, CheckAt, PatternPart.List, CaseSensitive);
	ElsIf PatternPart.IsNotInList Then
		Result = IsNotInListWildcardCheck(String, CheckAt, PatternPart.List, CaseSensitive);
	ElsIf PatternPart.IsGroup Then
		Result = IsGroupWildcardCheck(String, CheckAt, PatternParts, PatternPartI);
	Else
		Raise NStr("en = 'Pattern part type not supported.'; ru = 'Тип части шаблона не поддерживается.'");
	EndIf;
	
	// If the current pattern is not mandatory, then thinking it is found if
	// the next pattern is found.
	If PatternPart.Multiplier.Min = 0 And Result = Undefined Then
		If PatternParts.Count() < PatternPartI Then
		   	If Undefined <> CheckWildcardPattern(String, CheckAt, PatternParts, PatternPartI + 1, False, True) Then
				Result = ""; 
			EndIf;
		Else
			Result = "";
		EndIf;
	EndIf;
	
	Return Result;
	
EndFunction

#Область WildcardChecksByPatternType

Function IsStringWildcardCheck(String, CheckAt, PatternString, CaseSensitive) 
	
	StringBeginning = Mid(String, CheckAt, StrLen(PatternString));
	If StrCompare(StringBeginning, PatternString) = 0
	   And (CaseSensitive And StringBeginning = PatternString 
	        Or Not CaseSensitive) Then
		Return StringBeginning;
	Else
		Return Undefined;
	EndIf;
	
EndFunction

Function IsAnyCharWildcardCheck(String, CheckAt)
	
	Char = Mid(String, CheckAt, 1);
	If StrLen(Char) = 1 Then
		Return Char;
	Else
		Return Undefined;
	EndIf;
	
EndFunction

Function IsSpaceWildcardCheck(String, CheckAt)
	
	TwoChars = Mid(String, CheckAt, 2);
	OneChar = Left(TwoChars, 1);
	
	If TwoChars = Chars.CR + Chars.LF Then
		Return TwoChars;
	ElsIf OneChar = " " Or OneChar = Chars.LF Or OneChar = Chars.Tab Or OneChar = Chars.NBSp Then
		Return OneChar;
	Else
		Return Undefined;
	EndIf;
	
EndFunction

Function IsNotSpaceWildcardCheck(String, CheckAt)

	OneChar = Mid(String, CheckAt, 1);
	
	If OneChar = " " Or OneChar = Chars.CR Or OneChar = Chars.LF Or OneChar = Chars.Tab Then
		Return Undefined;
	Else
		Return OneChar;
	EndIf;
	
EndFunction

Function IsBeginWildcardCheck(String, CheckAt)
	
	If CheckAt <= 1 Then
		Return "";
	Else
		Return Undefined;
	EndIf;
	
EndFunction

Function IsEndWildcardCheck(String, CheckAt)
	
	If CheckAt > StrLen(String) Then
		Return "";
	Else
		Return Undefined;
	EndIf;
	
EndFunction

Function IsInListWildcardCheck(String, CheckAt, PatternStrings, CaseSensitive)
	
	// In case if the new line character searched, it can contain CR + LF, so checking 2 chars.
	ShortString = Mid(String, CheckAt, 2);
	For Each PatternString In PatternStrings Do
		
		// Optimization, replacing function call with inline code.
		//FoundPattern = IsStringWildcardCheck(String, CheckAt, PatternString, CaseSensitive);
		//
		//If FoundPattern <> Undefined Then
		//	Return FoundPattern;
		//EndIf;
		StringBeginning = Left(ShortString, StrLen(PatternString));
		If StrCompare(StringBeginning, PatternString) = 0
		   And (CaseSensitive And StringBeginning = PatternString 
		        Or Not CaseSensitive) Then
			Return StringBeginning;
		EndIf;
		
	EndDo;
	
	Return Undefined;
	
EndFunction

Function IsNotInListWildcardCheck(String, CheckAt, PatternStrings, CaseSensitive)
	
	For Each PatternString In PatternStrings Do
		
		FoundPattern = IsStringWildcardCheck(String, CheckAt, PatternString, CaseSensitive);
		
		If FoundPattern <> Undefined Then
			Return Undefined;
		EndIf;
		
	EndDo;
	
	Return Mid(String, CheckAt, 1);
	
EndFunction

Function IsDigitWildcardCheck(String, CheckAt)
	
	Patterns = New Array;
	Patterns.Add("0");
	Patterns.Add("1");
	Patterns.Add("2");
	Patterns.Add("3");
	Patterns.Add("4");
	Patterns.Add("5");
	Patterns.Add("6");
	Patterns.Add("7");
	Patterns.Add("8");
	Patterns.Add("9");
	
	Return IsInListWildcardCheck(String, CheckAt, Patterns, False);
	
EndFunction

Function IsGroupWildcardCheck(String, CheckAt, PatternParts, PatternPartI)
	
	Result = CheckWildcardPattern(String, CheckAt, PatternParts, PatternPartI, False, True);
		
	LookForward = PatternParts[PatternPartI].Patterns.LookForward;
	
	If Result.Count() < 1 Then
		If PatternParts[PatternPartI].Patterns.PatternSets.Count() > 0
		   And PatternParts[PatternPartI].Patterns.PatternSets[0].Count() > 0
		   And PatternParts[PatternPartI].Patterns.PatternSets[0][0].Multiplier.Min = 0 Then
			Return "";
		Else
			Return Undefined;
		EndIf;
	ElsIf Result.Count() = 1 Then
		If Result[0].Count() = 1 Then
			ResultString = Result[0].Get(0);
			If Left(Mid(String, CheckAt), StrLen(ResultString)) = ResultString Then
				If LookForward Then
					Return "";
				Else
					Return ResultString;
				EndIf;
			Else
				Return Undefined;
			EndIf;
		Else
			Raise NStr("en = 'Nested named groups are not supported.'; ru = 'Вложенные именованные группы не поддерживаются.'");
		EndIf;
	Else
		Raise NStr("en = 'The global search performed instead of searching for the first match.'; ru = 'Выполнен глобальный поиск вместо поиска первого вхождения.'");
	EndIf;
	
EndFunction

// Optimized matching for spaces (equal to MatchWildcard(String, "\s+", True))
Function FastMatchAllSpaces(String)
	
	Result = New Array;
	
	If String <> "" Then
	
		SpaceCharacters = " " + Chars.CR + Chars.LF + Chars.Tab + Chars.NBSp;
		StringLength = StrLen(String);
		CurSpaces = "";
		For S = 1 To StringLength + 1 Do
			CurChar = "";
			FoundSpace = False;
			If S <= StringLength Then 
				CurChar = Mid(String, S, 1);
				FoundSpace = StrFind(SpaceCharacters, CurChar) > 0;
			EndIf;
			If FoundSpace Then
				CurSpaces = CurSpaces + CurChar;
			ElsIf Not FoundSpace And CurSpaces <> "" Then
				CurResult = New Map;
				CurResult.Insert(0, CurSpaces);
				Result.Add(CurResult);
				CurSpaces = "";
			EndIf;
		EndDo;
		
	EndIf;
	
	Return Result;
	
EndFunction

#КонецОбласти

// Splits into an array of substrings by an array of separator substrings, the result 
// will have separators as separate array items.
//
// Parameters:
//  String - String - a string to split.
//  Separators - Array of String - separator strings.
//  AppendSeparators - Boolean - If True, separators will be returned in the
// 						result array as appended to previous parts. 
//                      If False, separators will be returned in the
// 						result array as separate parts.
//
// Returns: 
//  Array - an array of strings with source string parts and separators.
//
Function SplitBySeparators(Val String, Separators, AppendSeparators = False) Export
	
	NoSeparatorFound = False;
	
	Result = New Array();
	
	While Not NoSeparatorFound Do
		Length = StrLen(String);
		ClosestSeparatorPosition = Length+1;
		ClosestSeparator = "";
		For Each Separator In Separators Do
			SeparatorPosition = Find(String, Separator);
			If SeparatorPosition > 0 And SeparatorPosition < ClosestSeparatorPosition Then
				ClosestSeparatorPosition = SeparatorPosition;
				ClosestSeparator = Separator;
			EndIf;
		EndDo;
		NoSeparatorFound = ClosestSeparatorPosition = Length+1;
		If Not NoSeparatorFound Then
			If Not AppendSeparators Then
				Result.Add(Left(String, ClosestSeparatorPosition-1));
				Result.Add(ClosestSeparator);
			Else
				Result.Add(Left(String, ClosestSeparatorPosition-1) + ClosestSeparator);
			EndIf;
			String = Mid(String, ClosestSeparatorPosition+StrLen(ClosestSeparator));
		ElsIf String <> "" Then
			Result.Add(String);
		EndIf;
	EndDo;

	Return Result;
	
EndFunction

#КонецОбласти