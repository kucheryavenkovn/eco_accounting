﻿#Область ОбработчикиСобытий

Функция PingGET(Запрос)
	
	Попытка
		
		ОшибкаВыполнениеНевозможно = ОшибкаВыполнениеНевозможно();
		Если ОшибкаВыполнениеНевозможно <> Неопределено Тогда
			Возврат ОшибкаВыполнениеНевозможно;
		КонецЕсли;
		
		Возврат Ответ(200, "");
	
	Исключение
		
		ЗаписатьИсключениеHTTPСервиса(
			ИнформацияОбОшибке(),
			Метаданные.HTTPСервисы.MobileAppReceiptScanner.ШаблоныURL.Ping.Методы.GET);
		
		ВызватьИсключение;
		
	КонецПопытки;
	
	// Отправитель запроса должен обрабатывать и стандартные коды ошибок: 401, 403, 404, 500
	
КонецФункции

Функция ConnectAppPOST(Запрос)
	
	Попытка
		
		ОшибкаВыполнениеНевозможно = ОшибкаВыполнениеНевозможно();
		Если ОшибкаВыполнениеНевозможно <> Неопределено Тогда
			Возврат ОшибкаВыполнениеНевозможно;
		КонецЕсли;
		
		УстановитьМобильноеПриложениеПодключено();
		
		Возврат Ответ(200);
	
	Исключение
		
		ЗаписатьИсключениеHTTPСервиса(
			ИнформацияОбОшибке(),
			Метаданные.HTTPСервисы.MobileAppReceiptScanner.ШаблоныURL.QRCodeCreate.Методы.POST);
		
		ВызватьИсключение;
		
	КонецПопытки;
	
КонецФункции

Функция QRCodeCreatePOST(Запрос)
	
	ТекстЗапроса = Запрос.ПолучитьТелоКакСтроку();
	
	Попытка
	
		ОшибкаВыполнениеНевозможно = ОшибкаВыполнениеНевозможно();
		Если ОшибкаВыполнениеНевозможно <> Неопределено Тогда
			Возврат ОшибкаВыполнениеНевозможно;
		КонецЕсли;
		
		РезультатОбработки = ПринятьQRКоды(ТекстЗапроса);
		
		Если РезультатОбработки.Ошибка Тогда
			Возврат Ошибка(РезультатОбработки.КодОтвета, РезультатОбработки.Сообщение);
		КонецЕсли;
		
		УстановитьМобильноеПриложениеПодключено();
		
		Возврат Ответ(200, РезультатОбработки.Ответ);
		
	Исключение
		
		ЗаписатьИсключениеHTTPСервиса(
			ИнформацияОбОшибке(),
			Метаданные.HTTPСервисы.MobileAppReceiptScanner.ШаблоныURL.QRCodeCreate.Методы.POST,
			ТекстЗапроса);
		
		ВызватьИсключение;
		
	КонецПопытки;
	
КонецФункции

Функция TillSlipDELETE(Запрос)
	
	ТекстЗапроса = Запрос.ПараметрыURL["UUID"];
	
	Попытка
	
		ОшибкаВыполнениеНевозможно = ОшибкаВыполнениеНевозможно();
		Если ОшибкаВыполнениеНевозможно <> Неопределено Тогда
			Возврат ОшибкаВыполнениеНевозможно;
		КонецЕсли;
		
		РезультатОбработки = УдалитьЧек(ТекстЗапроса);
		
		Если РезультатОбработки.Ошибка Тогда
			Возврат Ошибка(РезультатОбработки.КодОтвета, РезультатОбработки.Сообщение);
		КонецЕсли;
		
		УстановитьМобильноеПриложениеПодключено();
		
		Возврат Ответ(200);
	
	Исключение
		
		ЗаписатьИсключениеHTTPСервиса(
			ИнформацияОбОшибке(),
			Метаданные.HTTPСервисы.MobileAppReceiptScanner.ШаблоныURL.TillSlip.Методы.DELETE,
			ТекстЗапроса);
		
		ВызватьИсключение;
		
	КонецПопытки;
	
КонецФункции

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

#Область КомандыМобильногоПриложения

Процедура УстановитьМобильноеПриложениеПодключено()
	
	УстановитьПривилегированныйРежим(Истина);
	
	РегистрыСведений.МобильноеПриложениеСканированиеЧеков.УстановитьМобильноеПриложениеПодключено();
	
	УстановитьПривилегированныйРежим(Ложь);
	
КонецПроцедуры

// Принимает в обработку QR-коды, прочитанные из кассового чека подотчетника мобильным приложением:
// - записывает их в информационную базу
// - инициирует запрос детализации до позиций номенклатуры.
// Права пользователя не проверяются.
//
// Параметры:
//  ТекстЗапроса - Строка - описание см. в ТребованияТекстЗапросаПринятьQRКоды
// 
// Возвращаемое значение:
//  Структура - см. НовыйРезультатОбработки
//    * Ответ - json-строка с объектом НовыйДанныеОтветаПринятьQRКод.
//    * КодОтвета
//       ** 400 - запрос некорректен
//
// В случаях неспецифицированных ошибок вызывает исключение,
// которое должно приводить к формированию ответа с кодом 500.
//
// Невозможность получить детализацию не является ошибкой.
//
Функция ПринятьQRКоды(ТекстЗапроса)
	
	РезультатОбработки = НовыйРезультатОбработки();
	
	Запрос = ДесериализоватьЗапросПринятьQRКоды(ТекстЗапроса, РезультатОбработки);
	
	Если РезультатОбработки.Ошибка Тогда
		Возврат РезультатОбработки;
	КонецЕсли;
	
	УстановитьПривилегированныйРежим(Истина);
	ДанныеОтвета = ЗагрузитьКассовыеЧеки(Запрос.QRCode);
	УстановитьПривилегированныйРежим(Ложь);
	
	РезультатОбработки.Ответ = ОбщегоНазначенияБП.ЗначениеВСтрокуJSON(ДанныеОтвета);
	
	Возврат РезультатОбработки;
	
КонецФункции

// Удаляет (помечает на удаление) чек: исключает его из дальнейшей обработки, например, если он отсканирован ошибочно.
// Удалить чек может только тот пользователь, кто его отправил.
//
// Параметры:
//  ИдентификаторЧека - Строка - уникальный идентификатор чека, ранее сообщенный методом ПринятьQRКоды
// 
// Возвращаемое значение:
//  Структура - см. НовыйРезультатОбработки
//    * Ответ - json-строка с объектом НовыйДанныеОтветаПринятьQRКод.
//    * КодОтвета
//       ** 400 - не указан уникальный идентификатор
//       ** 404 - этот пользователь ранее не отправлял чек либо удалил его ранее
//
// В случаях неспецифицированных ошибок вызывает исключение,
// которое должно приводить к формированию ответа с кодом 500.
//
Функция УдалитьЧек(ИдентификаторЧека)
	
	РезультатОбработки = НовыйРезультатОбработки();
	
	СообщениеНеверныеПараметры = "ru = 'Не указан уникальный идентификатор удаляемого чека'";
	
	Если Не СтроковыеФункцииКлиентСервер.ЭтоУникальныйИдентификатор(ИдентификаторЧека) Тогда
		Возврат УстановитьОшибкуТекстаЗапроса(РезультатОбработки, СообщениеНеверныеПараметры);
	КонецЕсли;
	
	Попытка
		УникальныйИдентификатор = Новый УникальныйИдентификатор(ИдентификаторЧека);
		Ссылка = Документы.КассовыйЧекПодотчетногоЛица.ПолучитьСсылку(УникальныйИдентификатор);
	Исключение
		Возврат УстановитьОшибкуТекстаЗапроса(РезультатОбработки, СообщениеНеверныеПараметры);
	КонецПопытки;
	
	ЧекНайден = Документы.КассовыйЧекПодотчетногоЛица.УдалитьЧекПользователя(Ссылка);
	
	Если Не ЧекНайден Тогда
		РезультатОбработки.Ошибка    = Истина;
		РезультатОбработки.КодОтвета = 404;
	КонецЕсли;
	
	Возврат РезультатОбработки;
	
КонецФункции

#КонецОбласти

#Область ПринятьQRКоды

Функция НовыйЗапросПринятьQRКод()
	
	Запрос = Новый Структура;
	
	Запрос.Вставить("QRCode", Новый Массив); // из Строка
	
	Возврат Запрос;
	
КонецФункции

Функция ТребованияТекстЗапросаПринятьQRКоды()
	
	// См. также НовыйЗапросПринятьQRКод()
	
	Возврат "ru = 'Запрос должен содержать json-строку с объектом, включающим свойства
             |* QRCode (обязательное) - Массив из Строка - тексты QR-кодов'";
	
КонецФункции

Функция ДесериализоватьЗапросПринятьQRКоды(ТекстЗапроса, РезультатОбработки)
	
	Если ТипЗнч(ТекстЗапроса) <> Тип("Строка") Или Не ЗначениеЗаполнено(ТекстЗапроса) Тогда
		Возврат УстановитьОшибкуТекстаЗапроса(
			РезультатОбработки,
			"ru = 'Отсутствует текст запроса'",
			ТребованияТекстЗапросаПринятьQRКоды());
	КонецЕсли;
	
	Попытка
		Запрос = ОбщегоНазначенияБП.СтруктураИзСтрокиJSON(ТекстЗапроса);
	Исключение
		Возврат УстановитьОшибкуТекстаЗапроса(
			РезультатОбработки,
			"ru = 'Объект JSON описан неверно'",
			ТребованияТекстЗапросаПринятьQRКоды());
	КонецПопытки;
	
	Если Не Запрос.Свойство("QRCode") Тогда
		Возврат УстановитьОшибкуТекстаЗапроса(
			РезультатОбработки,
			"ru = 'Отсутствует обязательное свойство QRCode'",
			ТребованияТекстЗапросаПринятьQRКоды());
	КонецЕсли;
	
	Если Не ЗначениеЗаполнено(Запрос.QRCode) Тогда
		Возврат УстановитьОшибкуТекстаЗапроса(
			РезультатОбработки,
			"ru = 'Свойство QRCode не заполнено'",
			ТребованияТекстЗапросаПринятьQRКоды());
	КонецЕсли;
	
	Если ТипЗнч(Запрос.QRCode) <> Тип("Массив") Тогда
		Возврат УстановитьОшибкуТекстаЗапроса(
			РезультатОбработки,
			"ru = 'Свойство QRCode не содержит массив'",
			ТребованияТекстЗапросаПринятьQRКоды());
	КонецЕсли;
		
	Для Каждого ТекстQR Из Запрос.QRCode Цикл
		Если ТипЗнч(ТекстQR) = Тип("Строка") И Не ПустаяСтрока(ТекстQR) Тогда
			Продолжить;
		КонецЕсли;
		Возврат УстановитьОшибкуТекстаЗапроса(
			РезультатОбработки,
			"ru = 'Свойство QRCode содержит недопустимые тексты QR-кодов'",
			ТребованияТекстЗапросаПринятьQRКоды());
	КонецЦикла;
	
	ОбщегоНазначенияКлиентСервер.ДополнитьСтруктуру(Запрос, НовыйЗапросПринятьQRКод(), Ложь);
	
	Возврат Запрос;
	
КонецФункции

Функция НовыйДанныеОтветаПринятьQRКод()
	
	ДанныеОтвета = Новый Структура;
	ДанныеОтвета.Вставить("TillSlip", Новый Массив); // см. НовыйКраткиеДанныеЧека
	
	Возврат ДанныеОтвета;
	
КонецФункции

Функция НовыйКраткиеДанныеЧека()
	
	Данные = Новый Структура;
	Данные.Вставить("UUID",   "");           // XML-представление уникального идентификатора ссылки, в котором будут сохранены данные чека
	Данные.Вставить("QRCode", "");           // Текст из QR-кода, указанного на чеке
	Данные.Вставить("Date",   '0001-01-01'); // Дата покупки
	Данные.Вставить("Sum",    0);            // Сумма покупки
	Данные.Вставить("Number", "");           // Номер документа, в который сохранены данные чека
	Данные.Вставить("State",  "Ожидает");    // Статус чека - имя значения перечисления СтатусыКассовыхЧековПодотчетныхЛиц
	
	Возврат Данные;
	
КонецФункции

Функция ЗагрузитьКассовыеЧеки(QRКоды)
	
	Ссылки = Новый Массив;
	
	Для Каждого КодЧека Из QRКоды Цикл
		
		КассовыйЧек = Документы.КассовыйЧекПодотчетногоЛица.ПолучитьПоQRКоду(КодЧека);
		
		Если Не ЗначениеЗаполнено(КассовыйЧек) Тогда
			Продолжить;
		КонецЕсли;
		
		Ссылки.Добавить(КассовыйЧек);
		
	КонецЦикла;
	
	ДанныеОтвета = НовыйДанныеОтветаПринятьQRКод();
	
	ДанныеСозданныхДокументов = ОбщегоНазначения.ЗначенияРеквизитовОбъектов(
		Ссылки,
		"Дата, Номер, СуммаДокумента, QRКод, Статус",
		Истина);
	
	Для Каждого ДанныеДокумента Из ДанныеСозданныхДокументов Цикл
		
		КраткиеДанныеЧека = НовыйКраткиеДанныеЧека();
		КраткиеДанныеЧека.UUID   = ДанныеДокумента.Ключ.УникальныйИдентификатор();
		КраткиеДанныеЧека.QRCode = ДанныеДокумента.Значение.QRКод;
		КраткиеДанныеЧека.Date   = ДанныеДокумента.Значение.Дата;
		КраткиеДанныеЧека.Sum    = ДанныеДокумента.Значение.СуммаДокумента;
		КраткиеДанныеЧека.Number = ДанныеДокумента.Значение.Номер;
		
		Статус = ДанныеДокумента.Значение.Статус;
		Если Не ЗначениеЗаполнено(Статус) Тогда
			Статус = Перечисления.СтатусыКассовыхЧековПодотчетныхЛиц.Ожидает;
		КонецЕсли;
		
		КраткиеДанныеЧека.State  = ОбщегоНазначения.ИмяЗначенияПеречисления(Статус);
		
		ДанныеОтвета.TillSlip.Добавить(КраткиеДанныеЧека);
		
	КонецЦикла;
	
	РегистрыСведений.КассовыеЧекиПодотчетныхЛицЗапросыДетальныхДанных.НачатьЗапрос(Ссылки);
	
	Возврат ДанныеОтвета;

КонецФункции

#КонецОбласти

#Область ОтветыМобильномуПриложению

Функция Ответ(Знач КодОтвета, ТелоОтвета = "", РазрешеноКешировать = Ложь)
	
	Если Не ЗначениеЗаполнено(КодОтвета) Тогда
		КодОтвета = 500;
	КонецЕсли;
	
	Ответ = Новый HTTPСервисОтвет(КодОтвета);
	
	// Ответ сервиса всегда представляет json-строку в формате UTF-8
	Ответ.Заголовки.Вставить("Accept-Charset", "utf-8");
	Ответ.Заголовки.Вставить("Content-Type",   "application/json;charset=utf-8");
	
	// Как правило, ответы сервиса содержат состояние информационной базы, поэтому кешировать их не следует
	Если Не РазрешеноКешировать Тогда
		Ответ.Заголовки["Cache-Control"] = "no-cache";
	КонецЕсли;
	
	Ответ.УстановитьТелоИзСтроки(ТелоОтвета);
	
	Возврат Ответ;
	
КонецФункции

Функция Ошибка(КодОтвета, СообщениеПользователю)
	
	ИнформацияОбОшибке = НовыйИнформацияОбОшибке();
	ИнформацияОбОшибке.Message = СообщениеПользователю;
	
	Возврат Ответ(КодОтвета, ОбщегоНазначенияБП.ЗначениеВСтрокуJSON(ИнформацияОбОшибке));
	
КонецФункции

Функция ОшибкаВыполнениеНевозможно()
	
	Если Не РегистрыСведений.МобильноеПриложениеСканированиеЧеков.ВключеноСканированиеЧеков() Тогда
		
		Если ВключитьДляРаннегоОзнакомления() Тогда
			Возврат Неопределено;
		КонецЕсли;
		
		СообщениеПользователю = НСтр(
			"ru = 'Функциональность отключена'; en = 'The feature has been disabled'");
		
		Возврат Ошибка(501, СообщениеПользователю);
		
	КонецЕсли;
		
	УстановитьПривилегированныйРежим(Истина);
	НеобходимоОбновление = РегистрыСведений.ПараметрыРаботыПрограммы.НеобходимоОбновление();
	УстановитьПривилегированныйРежим(Ложь);
	
	Если НеобходимоОбновление Тогда
	
		СообщениеПользователю = НСтр(
			"ru = 'Выполнение операции временно невозможно в связи с обновлением на новую версию.';
			|en = 'Temporary unavailable (down for maintenance)'");
		
		Возврат Ошибка(503, СообщениеПользователю);
		
	КонецЕсли;
	
	Возврат Неопределено;
		
КонецФункции

Функция НовыйИнформацияОбОшибке()
	
	ИнформацияОбОшибке = Новый Структура;
	ИнформацияОбОшибке.Вставить("Message", "");
	Возврат ИнформацияОбОшибке;
	
КонецФункции

Функция НовыйРезультатОбработки()
	
	РезультатОбработки = Новый Структура;
	
	// Устанавливается при успешном выполнении
	РезультатОбработки.Вставить("Ответ",     ""); // Машиночитаемый ответ, предполагается json, допускается пустой
	// Устанавливается при ошибке
	РезультатОбработки.Вставить("Ошибка",    Ложь);
	РезультатОбработки.Вставить("КодОтвета", 0);  // Числовой код возврата по RFC2616
	РезультатОбработки.Вставить("Сообщение", ""); // Текст сообщения об ошибке для предъявления пользователю
	
	Возврат РезультатОбработки;
	
КонецФункции

Функция УстановитьОшибкуТекстаЗапроса(РезультатОбработки, ТекстОшибкиМногоязычнаяСтрока, ТребованияТекстЗапросаМногоязычнаяСтрока = "")
	
	РезультатОбработки.Ошибка    = Истина;
	РезультатОбработки.КодОтвета = 400;
	
	// Текст предназначен для записи в информационную базу и вывода внешнему пользователю.
	// Не предназначен для вывода пользователю, непосредственно работающему с системой.
	// Поэтому используется язык информационной базы.
	
	КодЯзыка = ОбщегоНазначения.КодОсновногоЯзыка();
	
	Если ПустаяСтрока(ТребованияТекстЗапросаМногоязычнаяСтрока) Тогда
		Сообщение = НСтр(ТекстОшибкиМногоязычнаяСтрока, КодЯзыка);
	Иначе
		ШаблонСообщения = НСтр("ru = '%1.
	                            |%2'", КодЯзыка);
		
		Сообщение = СтрШаблон(
			ШаблонСообщения,
			НСтр(ТекстОшибкиМногоязычнаяСтрока, КодЯзыка),
			НСтр(ТребованияТекстЗапросаМногоязычнаяСтрока, КодЯзыка));
	КонецЕсли;
		
	РезультатОбработки.Сообщение = Сообщение;
	
	ЗаписьЖурналаРегистрации(ИмяСобытияЖурналаРегистрации(), УровеньЖурналаРегистрации.Предупреждение, , , Сообщение);
	
	Возврат РезультатОбработки;
	
КонецФункции

Функция ВключитьДляРаннегоОзнакомления()
	
	// Мобильное приложение для некоторых пользователей может оказаться доступным раньше, чем для других.
	// Они могут сами найти его в магазине приложений и попробовать использовать.
	// Для них даем такую возможность, если это технически осуществимо.
	// См. также УчетКассовыхЧековПодотчетныхЛиц.УстановитьОпциюУстановкаМобильногоПриложения
	
	Попытка
		
		Если Не РегистрыСведений.МобильноеПриложениеСканированиеЧеков.ДоступноСканированиеЧеков() Тогда
			Возврат Ложь;
		КонецЕсли;
		
		Константы.УстановкаМобильногоПриложенияСканированиеЧеков.Установить(ОбщегоНазначенияБП.ЭтоПолныйИнтерфейс());
			
		Константы.УстановкаМобильногоПриложенияСканированиеЧековПростойИнтерфейс.Установить(ОбщегоНазначенияБП.ЭтоПростойИнтерфейс());
			
		ОбновитьПовторноИспользуемыеЗначения();
		
		Возврат РегистрыСведений.МобильноеПриложениеСканированиеЧеков.ВключеноСканированиеЧеков();
		
	Исключение
		
		ЗаписатьИсключениеHTTPСервиса(ИнформацияОбОшибке(), Метаданные.HTTPСервисы.MobileAppReceiptScanner);
		
		Возврат Ложь;
		
	КонецПопытки;
	
КонецФункции

#КонецОбласти

#Область ЖурналРегистрации

Функция ИмяСобытияЖурналаРегистрации()
	
	Возврат НСтр("ru = 'МобильноеПриложение.КассовыеЧекиПодотчетныхЛиц'", ОбщегоНазначения.КодОсновногоЯзыка());
	
КонецФункции

// Записывает в журнал регистрации исключение при выполнении метода http-сервиса.
// Следует вызывать из обработчика исключения.
// При вызове из http-сервиса информация об исключении не записывается в журнал автоматически
//
// Параметры:
//  ИнформацияОбОшибке - ИнформацияОбОшибке - информация о возникшем исключении, результат ИнформацияОбОшибке()
//  Метод              - ОбъектМетаданных:МетодHTTPСервиса - выполняемый метод
//  ТекстЗапроса       - Строка - параметры, с которыми был вызван метод
//
Процедура ЗаписатьИсключениеHTTPСервиса(ИнформацияОбОшибке, Метод, ТекстЗапроса = "")
	
	ЗаписьЖурналаРегистрации(
		ИмяСобытияЖурналаРегистрации(),
		УровеньЖурналаРегистрации.Ошибка,
		Метод,
		ТекстЗапроса,
		ПодробноеПредставлениеОшибки(ИнформацияОбОшибке));
	
КонецПроцедуры

#КонецОбласти

#КонецОбласти