﻿#Область ПрограммныйИнтерфейс

// Загружает данные из сообщения обмена.
//
// Параметры:
//  Источник - Строка - адрес во временном хранилище, по которому помещены ДвоичныеДанные с сообщением обмена
//           - Поток, ПотокВПамяти, ФайловыйПоток - поток, открытый для чтения, содержащий данные сообщения обмена
// ПровестиЗагруженныеДокументы - Булево - Истина: после загрузки провести документы
// ИмяСобытия - Строка - (обязательно, если ПровестиЗагруженныеДокументы) имя события для записи в журнал регистрации
//                       сообщений об ошибках проведения документов
//
// Возвращаемое значение:
//   Структура - результат загрузки.
//    * ЕстьОшибки - Булево - Признак, что во время загрузки сообщения обмена возникли ошибки.
//    * ТекстОшибки - Строка - Текст сообщения об ошибке.
//    * ЗагруженныеОбъекты - Массив - Массив загруженных объектов.
//
Функция ЗагрузитьСообщениеEnterpriseData(Источник, ПровестиЗагруженныеДокументы, ИмяСобытия) Экспорт
	
	ТипИсточника = ТипЗнч(Источник);
	
	ТипыПотока = Новый Массив;
	ТипыПотока.Добавить(Тип("Поток"));
	ТипыПотока.Добавить(Тип("ПотокВПамяти"));
	ТипыПотока.Добавить(Тип("ФайловыйПоток"));
	
	Если ТипыПотока.Найти(ТипИсточника) <> Неопределено Тогда
		ПотокДанных = Источник;
	ИначеЕсли ТипИсточника = Тип("Строка") И ЭтоАдресВременногоХранилища(Источник) Тогда
		
		ДвоичныеДанные = ПолучитьИзВременногоХранилища(Источник);
		ПотокДанных    = ДвоичныеДанные.ОткрытьПотокДляЧтения();
		
	Иначе
		Возврат Неопределено;
	КонецЕсли;
	
	Обработка = Обработки.ВыгрузкаЗагрузкаEnterpriseData.Создать();
	
	ЧтениеXML = Новый ЧтениеXML();
	ЧтениеXML.ОткрытьПоток(ПотокДанных);
	
	РезультатЗагрузки = Обработка.ЗагрузитьДанныеИзXML(ЧтениеXML);// Этот вариант API подсистемы ОбменДанными не умеет проводить документы
	
	Если ПровестиЗагруженныеДокументы И Не РезультатЗагрузки.ЕстьОшибки Тогда
		ПровестиЗагруженныеДокументы(РезультатЗагрузки.ЗагруженныеОбъекты, ИмяСобытия);
	КонецЕсли;
	
	Возврат РезультатЗагрузки;
	
КонецФункции

Процедура ПровестиЗагруженныеДокументы(ЗагруженныеОбъекты, ИмяСобытия)
	
	Для Каждого Ссылка Из ЗагруженныеОбъекты Цикл
		
		МетаданныеДокумента = Ссылка.Метаданные();
		
		Если Не ОбщегоНазначения.ЭтоДокумент(МетаданныеДокумента) Тогда
			Продолжить;
		КонецЕсли;
		
		Если МетаданныеДокумента.Проведение <> Метаданные.СвойстваОбъектов.Проведение.Разрешить Тогда
			Продолжить;
		КонецЕсли;
		
		Объект = Ссылка.ПолучитьОбъект();
		Если Объект = Неопределено Тогда
			Продолжить;
		КонецЕсли;
		
		Попытка
			Объект.Записать(РежимЗаписиДокумента.Проведение);
		Исключение
			
			ШаблонТекстаОшибки = НСтр("ru = 'Загруженный документ не проведен.
	                                   |%1'", Метаданные.ОсновнойЯзык.КодЯзыка);
			
			ТекстОшибки = СтрШаблон(ШаблонТекстаОшибки, ПодробноеПредставлениеОшибки(ИнформацияОбОшибке()));
			
			ЗаписьЖурналаРегистрации(
				ИмяСобытия,
				УровеньЖурналаРегистрации.Предупреждение,
				МетаданныеДокумента,
				Ссылка,
				ТекстОшибки);
				
		КонецПопытки;
			
	КонецЦикла;
	
КонецПроцедуры

#КонецОбласти
