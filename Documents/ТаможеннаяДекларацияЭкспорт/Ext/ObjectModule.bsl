﻿#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область ОбработчикиСобытий

Процедура ПриКопировании(ОбъектКопирования)
	
	Дата = НачалоДня(ОбщегоНазначения.ТекущаяДатаПользователя());
	Ответственный = Пользователи.ТекущийПользователь();
	
КонецПроцедуры

Процедура ПередЗаписью(Отказ, РежимЗаписи, РежимПроведения)
	
	Если ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;
	
	Если ДокументыОснования.Количество() > 0 Тогда
		ДокументОснование = ДокументыОснования[0].ДокументОснование;
	Иначе
		ДокументОснование = Неопределено;
	КонецЕсли;
	
	ИнформацияОДублях = ИнформацияОДубляхТаможенныхДеклараций();
	
	Если ИнформацияОДублях.ЕстьДубли Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(ИнформацияОДублях.СообщениеПользователю, ЭтотОбъект, , , Отказ);
	КонецЕсли;
	
КонецПроцедуры

Процедура ОбработкаПроведения(Отказ, РежимПроведения)
	
	// ПОДГОТОВКА ПРОВЕДЕНИЯ ПО ДАННЫМ ДОКУМЕНТА
	ПроведениеСервер.ПодготовитьНаборыЗаписейКПроведению(ЭтотОбъект);
	Если РучнаяКорректировка Тогда
		Возврат;
	КонецЕсли;

	ПараметрыПроведения = Документы.ТаможеннаяДекларацияЭкспорт.ПодготовитьПараметрыПроведения(Ссылка, Отказ);
	Если Отказ Тогда
		Возврат;
	КонецЕсли;
	
	// ФОРМИРОВАНИЕ ДВИЖЕНИЙ
	УчетНДС.СформироватьДвиженияТаможеннаяДекларацияЭкспорт(
		ПараметрыПроведения.СведенияТаможенныхДекларацийЭкспорт,
		ПараметрыПроведения.Реквизиты,
		Движения, Отказ);
		
	ПроведениеСервер.УстановитьЗаписьОчищаемыхНаборовЗаписей(ЭтотОбъект);
	
КонецПроцедуры

Процедура ОбработкаУдаленияПроведения(Отказ)
	
	ПроведениеСервер.ПодготовитьНаборыЗаписейКОтменеПроведения(ЭтотОбъект);
	Движения.Записать();
	
КонецПроцедуры

Процедура ОбработкаЗаполнения(ДанныеЗаполнения, СтандартнаяОбработка)
	
	ТипДанныхЗаполнения = ТипЗнч(ДанныеЗаполнения);
	Если ДанныеЗаполнения <> Неопределено И ТипДанныхЗаполнения <> Тип("Структура")
		И Метаданные().ВводитсяНаОсновании.Содержит(ДанныеЗаполнения.Метаданные()) Тогда
		ЗаполнитьПоДокументуОснованию(ДанныеЗаполнения);
	КонецЕсли;
	
	ЗаполнениеДокументов.Заполнить(ЭтотОбъект, ДанныеЗаполнения);
	
КонецПроцедуры

Процедура ОбработкаПроверкиЗаполнения(Отказ, ПроверяемыеРеквизиты)
	
	МассивНепроверяемыхРеквизитов = Новый Массив;
	
	МассивНепроверяемыхРеквизитов.Добавить("ДокументОснование");
	МассивНепроверяемыхРеквизитов.Добавить("СопроводительныеДокументы.ВидДокумента");
	МассивНепроверяемыхРеквизитов.Добавить("СопроводительныеДокументы.НомерТСД");
	МассивНепроверяемыхРеквизитов.Добавить("СопроводительныеДокументы.ДатаТСД");
	
	ПроверитьТаблицуОснований(Отказ);
	ПровестиФЛКНомераДекларации(Отказ);
	ПроверитьСопроводительныеДокументы(Отказ);
	
	ОбщегоНазначения.УдалитьНепроверяемыеРеквизитыИзМассива(ПроверяемыеРеквизиты, МассивНепроверяемыхРеквизитов);
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Процедура ЗаполнитьПоДокументуОснованию(ДанныеЗаполнения)
	
	ИнформацияОДублях = ИнформацияОДубляхТаможенныхДеклараций(ДанныеЗаполнения);
	
	Если ИнформацияОДублях.ЕстьДубли Тогда
		ВызватьИсключение ИнформацияОДублях.СообщениеПользователю;
	КонецЕсли;
	
	ИсключаемыеПоля = "Номер, Дата, Проведен, ПометкаУдаления";
	ЗаполнитьЗначенияСвойств(ЭтотОбъект, ДанныеЗаполнения, , ИсключаемыеПоля);
	
	Основание = ДокументыОснования.Добавить();
	Основание.ДокументОснование = ДанныеЗаполнения.Ссылка;
	
КонецПроцедуры

Функция ИнформацияОДубляхТаможенныхДеклараций(ДокументОтгрузки = Неопределено)
	
	Результат = Новый Структура("ЕстьДубли, СообщениеПользователю");
	
	ЕстьДубли = Ложь;
	СообщенияПользователю = Новый Массив;
	
	СуществующиеДекларации = НайтиТаможенныеДекларацииПоДокументуОтгрузки(ДокументОтгрузки);
	Для Каждого СтрокаТЗ Из СуществующиеДекларации Цикл
		ТекстСообщения = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			НСтр("ru='На основании документа %1 уже введена %2'"),
			СтрокаТЗ.ДокументОтгрузки,
			СтрокаТЗ.Декларация);
		СообщенияПользователю.Добавить(ТекстСообщения);
		ЕстьДубли = Истина;
	КонецЦикла;
	
	СуществующиеДекларации = НайтиТаможенныеДекларацииПоНомеру();
	Если ЗначениеЗаполнено(СуществующиеДекларации) И СуществующиеДекларации.КоличествоДеклараций > 0 Тогда
		ТекстСообщения = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			НСтр("ru='Таможенная декларация номер %1 уже зарегистрирована'"),
			НомерВходящегоДокумента);
		СообщенияПользователю.Добавить(ТекстСообщения);
		ЕстьДубли = Истина;
	КонецЕсли;
	
	СообщениеПользователю = СтрСоединить(СообщенияПользователю, ". ");
	
	Результат.ЕстьДубли             = ЕстьДубли;
	Результат.СообщениеПользователю = СообщениеПользователю;
	
	Возврат Результат;
	
КонецФункции

Функция НайтиТаможенныеДекларацииПоДокументуОтгрузки(ДокументОтгрузки)
	
	Если ЗначениеЗаполнено(ДокументОтгрузки) Тогда
		ДокументыОтгрузки = Новый Массив;
		ДокументыОтгрузки.Добавить(ДокументОтгрузки);
		
	Иначе
		ДокументыОтгрузки = ДокументыОснования.ВыгрузитьКолонку("ДокументОснование");
		
	КонецЕсли;
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("ДокументыОснования", ДокументыОтгрузки);
	Запрос.УстановитьПараметр("ЭтаДекларация"     , Ссылка);
	
	Запрос.Текст =
	"ВЫБРАТЬ
	|	ТаможеннаяДекларацияЭкспортДокументыОснования.Ссылка КАК Декларация,
	|	ТаможеннаяДекларацияЭкспортДокументыОснования.ДокументОснование КАК ДокументОтгрузки
	|ИЗ
	|	Документ.ТаможеннаяДекларацияЭкспорт.ДокументыОснования КАК ТаможеннаяДекларацияЭкспортДокументыОснования
	|ГДЕ
	|	ТаможеннаяДекларацияЭкспортДокументыОснования.ДокументОснование В(&ДокументыОснования)
	|	И НЕ ТаможеннаяДекларацияЭкспортДокументыОснования.Ссылка = &ЭтаДекларация
	|	И ТаможеннаяДекларацияЭкспортДокументыОснования.Ссылка.Проведен";
	
	Возврат Запрос.Выполнить().Выгрузить();
	
КонецФункции

Функция НайтиТаможенныеДекларацииПоНомеру()
	
	Если Не ЗначениеЗаполнено(НомерВходящегоДокумента) Тогда
		Возврат Неопределено;
	КонецЕсли;

	Запрос = Новый Запрос;
	Запрос.Текст =
	"ВЫБРАТЬ
	|	КОЛИЧЕСТВО(РАЗЛИЧНЫЕ ТаможеннаяДекларацияЭкспорт.Ссылка) КАК КоличествоДеклараций
	|ИЗ
	|	Документ.ТаможеннаяДекларацияЭкспорт КАК ТаможеннаяДекларацияЭкспорт
	|ГДЕ
	|	ТаможеннаяДекларацияЭкспорт.НомерВходящегоДокумента = &НомерВходящегоДокумента
	|	И НЕ ТаможеннаяДекларацияЭкспорт.ПометкаУдаления
	|	И НЕ ТаможеннаяДекларацияЭкспорт.Ссылка = &Ссылка";
	
	Запрос.УстановитьПараметр("НомерВходящегоДокумента", НомерВходящегоДокумента);
	Запрос.УстановитьПараметр("Ссылка"                 , Ссылка);
	
	УстановитьПривилегированныйРежим(Истина);
	
	Результат = Запрос.Выполнить().Выбрать();
	Результат.Следующий();
	
	Возврат Результат;
	
КонецФункции

#Область ОбработчикиПроверкиЗаполнения

Процедура ПровестиФЛКНомераДекларации(Отказ)
	
	ДлинаНомера = СтрДлина(СокрЛП(НомерВходящегоДокумента));
	Если ДлинаНомера = 23 ИЛИ (ДлинаНомера >= 25 И ДлинаНомера <= 29) Тогда
		Возврат;
		
	Иначе
		ТекстСообщения =
			НСтр("ru='Регистрационный номер таможенной декларации должен состоять либо из 23 символов, либо количество символов должно быть от 25 до 29.'");
			
		ТекстСообщения = ОбщегоНазначенияКлиентСервер.ТекстОшибкиЗаполнения(
			"Поле",
			"Корректность",
			"Номер", , ,
			ТекстСообщения);
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(ТекстСообщения, , "Объект.НомерВходящегоДокумента", , Отказ);
	КонецЕсли;
	
КонецПроцедуры

Процедура ПроверитьТаблицуОснований(Отказ)
	
	Если ДокументыОснования.Количество() = 0 Тогда
		ТекстСообщения = НСтр("ru = 'Не введено ни одной строки в список ""Основания""'");
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(ТекстСообщения, , "НадписьВыбор", , Отказ);
	КонецЕсли;
	
	Для каждого СтрокаТЧ Из ДокументыОснования Цикл
		Если ЗначениеЗаполнено(СтрокаТЧ.ДокументОснование)
			И НЕ СтрокаТЧ.ДокументОснование.Проведен Тогда
			
			ТекстСообщения = НСтр("ru = 'Таможенную декларацию можно провести только на основании проведенного документа.'");
			ТекстСообщения = ОбщегоНазначенияКлиентСервер.ТекстОшибкиЗаполнения(
				"Колонка",
				"Корректность",
				НСтр("ru='Основания'"),
				СтрокаТЧ.НомерСтроки,
				НСтр("ru='Документы-основания таможенной декларации'"),
				ТекстСообщения);
				
			Если ДокументыОснования.Количество() > 1 Тогда
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю(ТекстСообщения, , "НадписьДокументыОснования", , Отказ);
			Иначе
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю(ТекстСообщения, , "ДокументОснование", , Отказ);
			КонецЕсли;
		КонецЕсли;
	КонецЦикла;
	
	ДокументыОснованияСвернуто = ДокументыОснования.Выгрузить(, "ДокументОснование");
	ДокументыОснованияСвернуто.Колонки.Добавить("Количество", ОбщегоНазначения.ОписаниеТипаЧисло(10, 0));
	ДокументыОснованияСвернуто.ЗаполнитьЗначения(1, "Количество");
	ДокументыОснованияСвернуто.Свернуть("ДокументОснование", "Количество");
	Для Каждого СтрокаДокументОснование Из ДокументыОснованияСвернуто Цикл
		
		Если ЗначениеЗаполнено(СтрокаДокументОснование.ДокументОснование)
			И СтрокаДокументОснование.Количество > 1 Тогда
			
			Отбор = Новый Структура("ДокументОснование", СтрокаДокументОснование.ДокументОснование);
			
			СтрокиТЧ = ДокументыОснования.НайтиСтроки(Отбор);
			
			ТекстСообщения = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
				НСтр("ru = 'Документ %1 уже выбран в строке %2. Повторный выбор не допускается.'"),
				СтрокаДокументОснование.ДокументОснование,
				СтрокиТЧ[0].НомерСтроки);
			ТекстСообщения = ОбщегоНазначенияКлиентСервер.ТекстОшибкиЗаполнения(
				"Колонка",
				"Корректность",
				НСтр("ru='Основания'"),
				СтрокиТЧ[1].НомерСтроки,
				НСтр("ru='Документы-основания таможенной декларации'"),
				ТекстСообщения);
				
			Если ДокументыОснования.Количество() > 1 Тогда
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю(ТекстСообщения, , "НадписьДокументыОснования", , Отказ);
			Иначе
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю(ТекстСообщения, , "ДокументОснование", , Отказ);
			КонецЕсли;
			
		КонецЕсли;
		
	КонецЦикла;
	
КонецПроцедуры

Процедура ПроверитьСопроводительныеДокументы(Отказ)
	
	Для Каждого СопроводительныйДокумент Из СопроводительныеДокументы Цикл
		Если СопроводительныйДокумент.КодТС = "71" ИЛИ СопроводительныйДокумент.КодТС = "72" Тогда
			Продолжить;
		КонецЕсли;
		
		Префикс = "Объект.СопроводительныеДокументы[%1].";
		Префикс = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			Префикс, Формат(СопроводительныйДокумент.НомерСтроки - 1, "ЧН=0; ЧГ="));
		
		Если НЕ ЗначениеЗаполнено(СопроводительныйДокумент.ВидДокумента) Тогда
			ТекстСообщения = ОбщегоНазначенияКлиентСервер.ТекстОшибкиЗаполнения(
				"Колонка",
				"Заполнение",
				НСтр("ru='Сопроводительный документ'"),
				СопроводительныйДокумент.НомерСтроки,
				НСтр("ru='Товаросопроводительные документы'"));
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(ТекстСообщения, , Префикс + "ВидДокумента", , Отказ);
		КонецЕсли;
		
		Если НЕ ЗначениеЗаполнено(СопроводительныйДокумент.НомерТСД) Тогда
			ТекстСообщения = ОбщегоНазначенияКлиентСервер.ТекстОшибкиЗаполнения(
				"Колонка",
				"Заполнение",
				НСтр("ru='Номер'"),
				СопроводительныйДокумент.НомерСтроки,
				НСтр("ru='Товаросопроводительные документы'"));
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(ТекстСообщения, , Префикс + "НомерТСД", , Отказ);
		КонецЕсли;
		
		Если НЕ ЗначениеЗаполнено(СопроводительныйДокумент.ДатаТСД) Тогда
			ТекстСообщения = ОбщегоНазначенияКлиентСервер.ТекстОшибкиЗаполнения(
				"Колонка",
				"Заполнение",
				НСтр("ru='Дата'"),
				СопроводительныйДокумент.НомерСтроки,
				НСтр("ru='Товаросопроводительные документы'"));
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(ТекстСообщения, , Префикс + "ДатаТСД", , Отказ);
		КонецЕсли;
		
	КонецЦикла;
	
КонецПроцедуры

#КонецОбласти

#КонецОбласти

#КонецЕсли