﻿#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область ОбработчикиСобытий

Процедура ОбработкаПолученияДанныхВыбора(ДанныеВыбора, Параметры, СтандартнаяОбработка)
	
	Если Параметры.Отбор.Свойство("Организация") Тогда
		Если ЗначениеЗаполнено(Параметры.Отбор.Организация) Тогда
			Параметры.Отбор.Организация = ОбщегоНазначенияБПВызовСервераПовтИсп.ГоловнаяОрганизация(Параметры.Отбор.Организация);
		КонецЕсли;
	КонецЕсли;
	
	ЗначениеОтбора    = ?(Параметры.Отбор.Свойство("ВидДоговора"), Параметры.Отбор.ВидДоговора, Неопределено);
	ЕстьНедоступные   = Ложь;
	ДоступныеЗначения = Перечисления.ВидыДоговоровКонтрагентов.ПолучитьСписокДоступныхЗначений(
		ЗначениеОтбора, ЕстьНедоступные);
	Если ЕстьНедоступные Тогда
		Если ДоступныеЗначения.Количество() = 0 Тогда
			Параметры.Отбор.Вставить("ВидДоговора", Неопределено);
		ИначеЕсли ДоступныеЗначения.Количество() = 1 Тогда
			Параметры.Отбор.Вставить("ВидДоговора", ДоступныеЗначения[0].Значение);
		Иначе
			Параметры.Отбор.Вставить("ВидДоговора", Новый ФиксированныйМассив(ДоступныеЗначения.ВыгрузитьЗначения()));
		КонецЕсли;
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область ПрограммныйИнтерфейс

// СтандартныеПодсистемы.ВерсионированиеОбъектов

// Определяет настройки объекта для подсистемы ВерсионированиеОбъектов.
//
// Параметры:
//  Настройки - Структура - настройки подсистемы.
Процедура ПриОпределенииНастроекВерсионированияОбъектов(Настройки) Экспорт

КонецПроцедуры

// Конец СтандартныеПодсистемы.ВерсионированиеОбъектов

Процедура ЗаполнитьРуководителяОрганизации(ДоговорОбъект, КешОбработкиЗаполнения = Неопределено) Экспорт

	ДатаСреза = ?(ЗначениеЗаполнено(ДоговорОбъект.Дата), ДоговорОбъект.Дата, НачалоДня(ТекущаяДатаСеанса()));

	Если ТипЗнч(КешОбработкиЗаполнения) = Тип("Структура") Тогда
		Если КешОбработкиЗаполнения.Свойство("Руководитель")
			И КешОбработкиЗаполнения.Свойство("ДолжностьРуководителя")
			И КешОбработкиЗаполнения.Свойство("ЗаРуководителяПоПриказу")
			И КешОбработкиЗаполнения.Свойство("Организация")
			И КешОбработкиЗаполнения.Свойство("Дата")
			И КешОбработкиЗаполнения.Организация = ДоговорОбъект.Организация // Убеждаемся, что данные кеша актуальны.
			И КешОбработкиЗаполнения.Дата = ДатаСреза Тогда

			// Заполняем по данным кеша.
			ДоговорОбъект.Руководитель 				= КешОбработкиЗаполнения.Руководитель;
			ДоговорОбъект.ДолжностьРуководителя 	= КешОбработкиЗаполнения.ДолжностьРуководителя;
			ДоговорОбъект.ЗаРуководителяПоПриказу 	= КешОбработкиЗаполнения.ЗаРуководителяПоПриказу;
			
			Возврат;
		КонецЕсли;
	КонецЕсли;

	ОтветственныеЛица = ОтветственныеЛицаБП.ОтветственныеЛица(ДоговорОбъект.Организация, ДатаСреза);
	
	ДанныеУполномоченногоЛица = ОтветственныеЛицаБП.ДанныеУполномоченногоЛица(
		ДоговорОбъект.Организация, Пользователи.ТекущийПользователь());
		
	Если НЕ ЗначениеЗаполнено(ДанныеУполномоченногоЛица.Руководитель)
		ИЛИ ДанныеУполномоченногоЛица.Руководитель = ОтветственныеЛица.Руководитель Тогда
		ДоговорОбъект.Руководитель 			= ОтветственныеЛица.Руководитель;
		ДоговорОбъект.ДолжностьРуководителя = ОтветственныеЛица.РуководительДолжность;
		ДоговорОбъект.ЗаРуководителяПоПриказу = "";
	Иначе
		ДоговорОбъект.Руководитель				= ДанныеУполномоченногоЛица.Руководитель;
		ДоговорОбъект.ДолжностьРуководителя		= УчетЗарплаты.ДолжностьФизическогоЛица(
			ДанныеУполномоченногоЛица.Руководитель, ДоговорОбъект.Организация, ДатаСреза);
		ДоговорОбъект.ЗаРуководителяПоПриказу	= ДанныеУполномоченногоЛица.РуководительНаОсновании;
	КонецЕсли;

	// Сохраним в кеш для возможности использования в дальнейшем.
	Если КешОбработкиЗаполнения = Неопределено Тогда
		КешОбработкиЗаполнения = Новый Структура();
	КонецЕсли;
	КешОбработкиЗаполнения.Вставить("Руководитель", 			ДоговорОбъект.Руководитель);
	КешОбработкиЗаполнения.Вставить("ДолжностьРуководителя", 	ДоговорОбъект.ДолжностьРуководителя);
	КешОбработкиЗаполнения.Вставить("ЗаРуководителяПоПриказу", 	ДоговорОбъект.ЗаРуководителяПоПриказу);
	КешОбработкиЗаполнения.Вставить("Организация", 				ДоговорОбъект.Организация);
	КешОбработкиЗаполнения.Вставить("Дата", 					ДатаСреза);

КонецПроцедуры

Процедура ЗаполнитьРуководителяКонтрагента(ДоговорОбъект) Экспорт

	КонтактноеЛицо = Справочники.КонтактныеЛица.КонтактноеЛицоПоУмолчанию(ДоговорОбъект.Владелец);

	Если ЗначениеЗаполнено(КонтактноеЛицо) Тогда
		РеквизитыКонтактногоЛица = ОбщегоНазначения.ЗначенияРеквизитовОбъекта(
			КонтактноеЛицо, "Фамилия, Имя, Отчество, Должность");
		
		ДоговорОбъект.РуководительКонтрагента = ОбщегоНазначенияБПВызовСервера.ПолучитьФамилиюИмяОтчество(
													РеквизитыКонтактногоЛица.Фамилия, 
													РеквизитыКонтактногоЛица.Имя,
													РеквизитыКонтактногоЛица.Отчество,
													Ложь);
		ДоговорОбъект.ДолжностьРуководителяКонтрагента = РеквизитыКонтактногоЛица.Должность;
		
		// Пытаемся определить пол.
		ПредполагаемыйПол = СотрудникиКлиентСервер.ОпределитьПолПоОтчеству(СокрП(ДоговорОбъект.РуководительКонтрагента));
		Если ЗначениеЗаполнено(ПредполагаемыйПол) Тогда
			ДоговорОбъект.ПолРуководителяКонтрагента = ПредполагаемыйПол;
		КонецЕсли;
	
	КонецЕсли;

КонецПроцедуры

Процедура УстановитьДоступныеВидыДоговора(Параметры) Экспорт
	
	Если ТипЗнч(Параметры) <> Тип("Структура") И Параметры <> Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	ВидыДоговора = ?(Параметры <> Неопределено И Параметры.Свойство("ВидДоговора"), Параметры.ВидДоговора, Неопределено);
	ЕстьНедоступные   = Ложь;
	ДоступныеЗначения = Перечисления.ВидыДоговоровКонтрагентов.ПолучитьСписокДоступныхЗначений(
		ВидыДоговора, ЕстьНедоступные);
	Если ЕстьНедоступные Тогда
		КоличествоДоступных = ДоступныеЗначения.Количество();
		Если КоличествоДоступных = 0 Тогда
			ВидыДоговора = Неопределено;
		ИначеЕсли КоличествоДоступных = 1 Тогда
			ВидыДоговора = ДоступныеЗначения[0].Значение;
		Иначе
			ВидыДоговора = Новый ФиксированныйМассив(ДоступныеЗначения.ВыгрузитьЗначения());
		КонецЕсли;
		Если Параметры = Неопределено Тогда
			Параметры = Новый Структура;
		КонецЕсли;
		Параметры.Вставить("ВидДоговора", ВидыДоговора);
	КонецЕсли;
	
КонецПроцедуры

// Заполняет переданный список данными о поддерживаемых форматах сохранения в файл.
//
// Параметры:
//	СписокФорматов - СписокЗначений - Список, который заполняется данными о форматах.
//
Процедура ЗаполнитьПоддерживаемыеФорматыСохранения(СписокФорматов) Экспорт

	СписокФорматов.Добавить("PDF",
		Перечисления.ФорматыСохраненияОтчетов.PDF, Истина, БиблиотекаКартинок.ФорматPDF);
	СписокФорматов.Добавить("RTF", 
		НСтр("ru = 'Текст в формате RTF (.rtf)'"), Ложь, БиблиотекаКартинок.ФорматWord);
	СписокФорматов.Добавить("HTML",
		Перечисления.ФорматыСохраненияОтчетов.HTML, Ложь, БиблиотекаКартинок.ФорматHTML);

КонецПроцедуры

// Рассчитывает необходимость получения счета-фактуры от поставщика.
//
// Параметры:
//   ДоговорКонтрагента - СправочникСсылка.ДоговорыКонтрагентов - Ссылка на договор.
//
// Возвращаемое значение:
//   Истина - если по договору требуется получение счета-фактуры от поставщика, Ложь - в противном случае.
//
Функция ТребуетсяСчетФактураПолученный(ДоговорКонтрагента) Экспорт
	
	Если Не ЗначениеЗаполнено(ДоговорКонтрагента) Тогда
		Возврат Ложь;
	КонецЕсли;
	
	РеквизитыДоговора = ОбщегоНазначения.ЗначенияРеквизитовОбъекта(ДоговорКонтрагента,
		"УчетАгентскогоНДС, ВидДоговора, ВидАгентскогоДоговора");
	
	Если РеквизитыДоговора.ВидАгентскогоДоговора <> Перечисления.ВидыАгентскихДоговоров.РеализацияТоваров
		И РеквизитыДоговора.УчетАгентскогоНДС
		Или РеквизитыДоговора.ВидДоговора = Перечисления.ВидыДоговоровКонтрагентов.СКомитентом Тогда
		Возврат Ложь;
	КонецЕсли;
	
	Возврат Истина;
	
КонецФункции

// Возвращает способ заполнения ставки НДС в договоре, который устанавливается по умолчанию
//
// Параметры:
// Контрагент - Справочник.Контрагенты - контрагент, владелец договора.
//
// Возвращаемое значение:
// Перечисления.СпособыЗаполненияСтавкиНДС - способ заполнения ставки НДС по умолчанию.
Функция СпособЗаполненияСтавкиНДСПоУмолчанию(Контрагент = Неопределено) Экспорт

	СпособЗаполненияСтавкиНДС = Перечисления.СпособыЗаполненияСтавкиНДС.Автоматически;
	
	Если ЗначениеЗаполнено(Контрагент) Тогда
		Если УчетНДС.КонтрагентРезидентТаможенногоСоюза(Контрагент) Тогда
			СпособЗаполненияСтавкиНДС = Перечисления.СпособыЗаполненияСтавкиНДС.БезНДС;
		КонецЕсли;
	КонецЕсли;
	
	Возврат СпособЗаполненияСтавкиНДС;
	
КонецФункции

// Возвращает ставку НДС по договору. Используется в тех платежных документах, когда оплачиваемые ценности
// неизвестны и необходимо понять включает ли платеж сумму НДС.
//
// Параметры:
//   Период - Дата - период, для которого определяется ставка НДС,
//   ДоговорКонтрагента - Справочник.ДоговорыКонтрагентов - договор, по котрому нужно определить ставку НДС.
//
// Возвращаемое значение:
//   Перечисления.СтавкиНДС - ставка по умолчанию из УчетНДСКлиентСервер.СтавкаНДСПоУмолчанию() или "БезНДС"
Функция СтавкаНДСПоДоговору(Период, ДоговорКонтрагента) Экспорт

	Если НЕ ЗначениеЗаполнено(ДоговорКонтрагента) Тогда
		Возврат УчетНДСКлиентСервер.СтавкаНДСПоУмолчанию(Период);
	КонецЕсли;

	СпособЗаполненияСтавкиНДС = 
		РаботаСДоговорамиКонтрагентовБП.СпособЗаполненияСтавкиНДСПоДоговору(ДоговорКонтрагента);
	ПараметрыДоговора = ОбщегоНазначения.ЗначенияРеквизитовОбъекта(ДоговорКонтрагента,
		 "УчетАгентскогоНДС, ВидДоговора");
	
	Если ПараметрыДоговора.УчетАгентскогоНДС Тогда
		Возврат Перечисления.СтавкиНДС.ПустаяСсылка();
	ИначеЕсли СпособЗаполненияСтавкиНДС = Перечисления.СпособыЗаполненияСтавкиНДС.БезНДС
		И (ПараметрыДоговора.ВидДоговора = Перечисления.ВидыДоговоровКонтрагентов.СПоставщиком
		ИЛИ ПараметрыДоговора.ВидДоговора = Перечисления.ВидыДоговоровКонтрагентов.СФакторинговойКомпанией
		ИЛИ ПараметрыДоговора.ВидДоговора = Перечисления.ВидыДоговоровКонтрагентов.СКомитентом
		ИЛИ ПараметрыДоговора.ВидДоговора = Перечисления.ВидыДоговоровКонтрагентов.СКомиссионеромНаЗакупку
		ИЛИ ПараметрыДоговора.ВидДоговора = Перечисления.ВидыДоговоровКонтрагентов.СКомиссионером) Тогда
		Возврат Перечисления.СтавкиНДС.БезНДС;
	КонецЕсли;

	Возврат УчетНДСКлиентСервер.СтавкаНДСПоУмолчанию(Период);
	
КонецФункции

// Возвращает массив документов по договору.
//
// Параметры:
//  Договор	 - СправочникСсылка.ДоговорыКонтрагентов - Договор, по которому нужно получить список документов.
// 
// Возвращаемое значение:
//   - Массив.
//
Функция ДокументыПоДоговору(Договор) Экспорт
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("Договор", Договор);
	
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	ДокументыПоДоговоруКонтрагента.Ссылка КАК ДокументПоДоговору
	|ИЗ
	|	КритерийОтбора.ДокументыПоДоговоруКонтрагента(&Договор) КАК ДокументыПоДоговоруКонтрагента";
	
	Возврат Запрос.Выполнить().Выгрузить().ВыгрузитьКолонку("ДокументПоДоговору");

КонецФункции

#Область ДляВызоваИзДругихПодсистем

// СтандартныеПодсистемы.УправлениеДоступом

// См. УправлениеДоступомПереопределяемый.ПриЗаполненииСписковСОграничениемДоступа.
Процедура ПриЗаполненииОграниченияДоступа(Ограничение) Экспорт
	
	Ограничение.Текст =
	"ПрисоединитьДополнительныеТаблицы
	|ЭтотСписок КАК ЭтотСписок
	|
	|ЛЕВОЕ СОЕДИНЕНИЕ Справочник.Организации КАК ОбособленныеПодразделения 
	|	ПО ОбособленныеПодразделения.ГоловнаяОрганизация = ЭтотСписок.Организация
	|;
	|РазрешитьЧтениеИзменение
	|ГДЕ
	|	ЭтоГруппа
	|ИЛИ ЗначениеРазрешено(ОбособленныеПодразделения.Ссылка)
	|";
	
КонецПроцедуры

// Конец СтандартныеПодсистемы.УправлениеДоступом

#КонецОбласти

#КонецОбласти

#Область ПроцедурыОбновленияИБ

Процедура ЗаполнитьПризнакОплатаВВалюте() Экспорт
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("ВалютаРегламентированногоУчета", Константы.ВалютаРегламентированногоУчета.Получить());
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	ДоговорыКонтрагентов.Ссылка
	|ИЗ
	|	Справочник.ДоговорыКонтрагентов КАК ДоговорыКонтрагентов
	|ГДЕ
	|	ДоговорыКонтрагентов.ВалютаВзаиморасчетов <> &ВалютаРегламентированногоУчета
	|	И НЕ ДоговорыКонтрагентов.РасчетыВУсловныхЕдиницах
	|	И НЕ ДоговорыКонтрагентов.ОплатаВВалюте
	|	И ДоговорыКонтрагентов.ЭтоГруппа = ЛОЖЬ";
	
	Результат        = Запрос.Выполнить();
	ВыборкаДоговоров = Результат.Выбрать();
	
	Пока ВыборкаДоговоров.Следующий() Цикл
		ДоговорОбъект = ВыборкаДоговоров.Ссылка.ПолучитьОбъект();
		ДоговорОбъект.ОплатаВВалюте = Истина;
		ОбновлениеИнформационнойБазы.ЗаписатьОбъект(ДоговорОбъект);
	КонецЦикла;
	
КонецПроцедуры

Функция ПолучитьКоличествоПодчиненныхЭлементовПоВладельцу(Владелец) Экспорт

	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ РАЗРЕШЕННЫЕ
	|	ДоговорыКонтрагентов.Ссылка
	|ИЗ
	|	Справочник.ДоговорыКонтрагентов КАК ДоговорыКонтрагентов
	|ГДЕ
	|	ДоговорыКонтрагентов.Владелец = &Владелец";
	Запрос.УстановитьПараметр("Владелец", Владелец);

	Выборка = Запрос.Выполнить().Выбрать();
	
	Возврат Выборка.Количество();

КонецФункции

Функция ПодготовитьСписокРазрешенныхВалют(ВалютаРегламентированногоУчета, ВсеКромеВалютыРеглУчета) Экспорт
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("ВалютаРегламентированногоУчета", ВалютаРегламентированногоУчета);
	Запрос.УстановитьПараметр("ВсеКромеВалютыРеглУчета", ВсеКромеВалютыРеглУчета);
	
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	Валюты.Ссылка
	|ИЗ
	|	Справочник.Валюты КАК Валюты
	|ГДЕ
	|	(Валюты.Ссылка <> &ВалютаРегламентированногоУчета и &ВсеКромеВалютыРеглУчета)
	|	ИЛИ (Валюты.Ссылка = &ВалютаРегламентированногоУчета и НЕ &ВсеКромеВалютыРеглУчета)";
	
	ВыборкаИзЗапроса = Запрос.Выполнить().Выбрать();
	
	ВозвращаемыйМассив = Новый Массив;
	
	Пока ВыборкаИзЗапроса.Следующий() Цикл
		ВозвращаемыйМассив.Добавить(Новый ПараметрВыбора("Отбор.Ссылка", ВыборкаИзЗапроса.Ссылка));
	КонецЦикла;
	
	Если ВозвращаемыйМассив.Количество() = 0 Тогда
		ВозвращаемыйМассив.Добавить(Новый ПараметрВыбора("Отбор.Ссылка", Справочники.Валюты.ПустаяСсылка()));
	КонецЕсли;
	
	Возврат ВозвращаемыйМассив;
	
КонецФункции

Функция ЗаполнитьПолРуководителяКонтрагента(Параметры) Экспорт
	
	Запрос = Новый Запрос;
	Запрос.Текст =
	"ВЫБРАТЬ ПЕРВЫЕ 1000
	|	ДоговорыКонтрагентов.Ссылка КАК Ссылка,
	|	ДоговорыКонтрагентов.РуководительКонтрагента КАК РуководительКонтрагента
	|ИЗ
	|	Справочник.ДоговорыКонтрагентов КАК ДоговорыКонтрагентов
	|ГДЕ
	|	НЕ ДоговорыКонтрагентов.ЭтоГруппа
	|	И ДоговорыКонтрагентов.РуководительКонтрагента <> """"
	|	И ДоговорыКонтрагентов.ПолРуководителяКонтрагента = ЗНАЧЕНИЕ(Перечисление.ПолФизическогоЛица.ПустаяСсылка)
	|	И &УсловиеНачалаВыборки
	|
	|УПОРЯДОЧИТЬ ПО
	|	Ссылка УБЫВ";
	
	Если Параметры.Свойство("НачалоВыборки") Тогда
		
		НачалоВыборки = Параметры.НачалоВыборки;
		Запрос.Текст = СтрЗаменить(Запрос.Текст, "&УсловиеНачалаВыборки", "ДоговорыКонтрагентов.Ссылка <= &НачалоВыборки");
		Запрос.УстановитьПараметр("НачалоВыборки", НачалоВыборки);
		
	Иначе
		Запрос.УстановитьПараметр("УсловиеНачалаВыборки", Истина);
	КонецЕсли;
	
	ВыборкаДоговоров = Запрос.Выполнить().Выбрать();
	
	Блокировка = Новый БлокировкаДанных;
	ЭлементБлокировки = Блокировка.Добавить("Справочник.ДоговорыКонтрагентов");
	
	Параметры.ПрогрессВыполнения.ВсегоОбъектов = ВыборкаДоговоров.Количество();
	Параметры.ПрогрессВыполнения.ОбработаноОбъектов = 0;
	
	Пока ВыборкаДоговоров.Следующий() Цикл
		
		ПолРуководителя = СотрудникиКлиентСервер.ОпределитьПолПоОтчеству(СокрП(ВыборкаДоговоров.РуководительКонтрагента));
		Если Не ЗначениеЗаполнено(ПолРуководителя) Тогда
			Параметры.ПрогрессВыполнения.ОбработаноОбъектов = Параметры.ПрогрессВыполнения.ОбработаноОбъектов + 1;
			НачалоВыборки = ВыборкаДоговоров.Ссылка;
			Продолжить;
		КонецЕсли;
		
		НачатьТранзакцию();
		Попытка
		
			ЭлементБлокировки.УстановитьЗначение("Ссылка", ВыборкаДоговоров.Ссылка);
			Блокировка.Заблокировать();
			
			ДоговорОбъект = ВыборкаДоговоров.Ссылка.ПолучитьОбъект();
			
			// Если объект ранее был удален или обработан другими сеансами, пропускаем его.
			Если ДоговорОбъект = Неопределено
			 Или ДоговорОбъект.ПолРуководителяКонтрагента <> Перечисления.ПолФизическогоЛица.ПустаяСсылка() Тогда
				ОтменитьТранзакцию();
				Параметры.ПрогрессВыполнения.ОбработаноОбъектов = Параметры.ПрогрессВыполнения.ОбработаноОбъектов + 1;
				НачалоВыборки = ВыборкаДоговоров.Ссылка;
				Продолжить;
			КонецЕсли;
			
			ДоговорОбъект.ПолРуководителяКонтрагента = ПолРуководителя;
			ОбновлениеИнформационнойБазы.ЗаписатьОбъект(ДоговорОбъект);
  
  			ЗафиксироватьТранзакцию();
			Параметры.ПрогрессВыполнения.ОбработаноОбъектов = Параметры.ПрогрессВыполнения.ОбработаноОбъектов + 1;
			НачалоВыборки = ВыборкаДоговоров.Ссылка;
		
		Исключение
			
			ОтменитьТранзакцию();
			
			НачалоВыборки = ВыборкаДоговоров.Ссылка;
			
			ТекстСообщения = СтрШаблон(
		    	НСтр("ru = 'Не удалось обработать договор: %1 по причине:
		     	|%2'"),
			 	ВыборкаДоговоров.Ссылка,
				ПодробноеПредставлениеОшибки(ИнформацияОбОшибке()));
			ЗаписьЖурналаРегистрации(
			 	ОбновлениеИнформационнойБазы.СобытиеЖурналаРегистрации(),
				УровеньЖурналаРегистрации.Предупреждение,
			 	Метаданные.Справочники.ДоговорыКонтрагентов,
				ВыборкаДоговоров.Ссылка,
				ТекстСообщения);
			
		КонецПопытки;
		
	КонецЦикла;
	
	Если Параметры.ПрогрессВыполнения.ВсегоОбъектов > 0
	   И Параметры.ПрогрессВыполнения.ОбработаноОбъектов = 0 Тогда
	   
		ТекстСообщения = СтрШаблон(
			НСтр("ru = 'Процедуре ЗаполнитьПолРуководителяКонтрагента не удалось обработать некоторые договоры (пропущены): %1'"), 
	   		Параметры.ПрогрессВыполнения.ВсегоОбъектов - Параметры.ПрогрессВыполнения.ОбработаноОбъектов);
		ВызватьИсключение ТекстСообщения;
		
	Иначе
		
		ТекстСообщения = СтрШаблон(
			НСтр("ru = 'Процедура ЗаполнитьПолРуководителяКонтрагента обработала очередную порцию договоров: %1'"),
			Параметры.ПрогрессВыполнения.ОбработаноОбъектов);
		ЗаписьЖурналаРегистрации(ОбновлениеИнформационнойБазы.СобытиеЖурналаРегистрации(),
			УровеньЖурналаРегистрации.Информация, Метаданные.Справочники.ДоговорыКонтрагентов, , ТекстСообщения);
			
		Параметры.Вставить("НачалоВыборки", НачалоВыборки);
		
	КонецЕсли;
	
	Параметры.ОбработкаЗавершена = (Параметры.ПрогрессВыполнения.ВсегоОбъектов < 1000
								И Параметры.ПрогрессВыполнения.ВсегоОбъектов = Параметры.ПрогрессВыполнения.ОбработаноОбъектов);
	
КонецФункции

Процедура ЗаполнитьРеквизитСпособЗаполненияСтавкиНДС() Экспорт
	
	ВидыСубконто = Новый Массив;
	ВидыСубконто.Добавить(ПланыВидовХарактеристик.ВидыСубконтоХозрасчетные.Контрагенты);							// Субконто1
	ВидыСубконто.Добавить(ПланыВидовХарактеристик.ВидыСубконтоХозрасчетные.Договоры);								// Субконто2
	
	ЕстьСубконтоДокументыРасчетов      = ПланыСчетов.Хозрасчетный.РасчетыСПоставщикамиИПодрядчиками.ВидыСубконто.Найти(ПланыВидовХарактеристик.ВидыСубконтоХозрасчетные.ДокументыРасчетовСКонтрагентами, "ВидСубконто") <> Неопределено;
	Если ЕстьСубконтоДокументыРасчетов Тогда
		ВидыСубконто.Добавить(ПланыВидовХарактеристик.ВидыСубконтоХозрасчетные.ДокументыРасчетовСКонтрагентами);	// Субконто3
	Иначе
		Возврат;
	КонецЕсли;
	
	МассивСчетов = Новый Массив;
	МассивСчетов.Добавить(ПланыСчетов.Хозрасчетный.РасчетыСПоставщиками);
	МассивСчетов.Добавить(ПланыСчетов.Хозрасчетный.РасчетыСПоставщикамиУЕ);
	
	ВидыДоговоров = Новый Массив;
	ВидыДоговоров.Добавить(Перечисления.ВидыДоговоровКонтрагентов.СПоставщиком);
	ВидыДоговоров.Добавить(Перечисления.ВидыДоговоровКонтрагентов.СКомиссионером);
	ВидыДоговоров.Добавить(Перечисления.ВидыДоговоровКонтрагентов.СКомиссионеромНаЗакупку);
	ВидыДоговоров.Добавить(Перечисления.ВидыДоговоровКонтрагентов.СТранспортнойКомпанией);
	ВидыДоговоров.Добавить(Перечисления.ВидыДоговоровКонтрагентов.СКомитентом);
	ВидыДоговоров.Добавить(Перечисления.ВидыДоговоровКонтрагентов.СФакторинговойКомпанией);
	
	Запрос = Новый Запрос;
	
	Запрос.УстановитьПараметр("ВидыСубконто", ВидыСубконто);
	Запрос.УстановитьПараметр("Счета", МассивСчетов);
	Запрос.УстановитьПараметр("ВидыДоговоров", ВидыДоговоров);
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	НастройкиСистемыНалогообложенияСрезПоследних.Организация КАК Организация
	|ПОМЕСТИТЬ ОрганизацииПлательщикиНДС
	|ИЗ
	|	РегистрСведений.НастройкиСистемыНалогообложения.СрезПоследних КАК НастройкиСистемыНалогообложенияСрезПоследних
	|ГДЕ
	|	НастройкиСистемыНалогообложенияСрезПоследних.ПлательщикНДС = ИСТИНА
	|
	|ИНДЕКСИРОВАТЬ ПО
	|	Организация
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ХозрасчетныйОбороты.Субконто2 КАК Субконто2,
	|	СУММА(ЕСТЬNULL(НДСПредъявленный.НДС, 0)) КАК НДС
	|ПОМЕСТИТЬ НДСПоВзаиморасчетам
	|ИЗ
	|	РегистрБухгалтерии.Хозрасчетный.Обороты(
	|			,
	|			,
	|			,
	|			Счет В (&Счета),
	|			&ВидыСубконто,
	|			Организация В
	|				(ВЫБРАТЬ
	|					ОрганизацииПлательщикиНДС.Организация
	|				ИЗ
	|					ОрганизацииПлательщикиНДС),
	|			,
	|			) КАК ХозрасчетныйОбороты
	|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрНакопления.НДСПредъявленный КАК НДСПредъявленный
	|		ПО ХозрасчетныйОбороты.Субконто3 = НДСПредъявленный.СчетФактура
	|
	|СГРУППИРОВАТЬ ПО
	|	ХозрасчетныйОбороты.Субконто2
	|
	|ИНДЕКСИРОВАТЬ ПО
	|	Субконто2
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	НДСПоВзаиморасчетам.Субконто2 КАК Договор,
	|	НДСПоВзаиморасчетам.НДС КАК НДС
	|ПОМЕСТИТЬ ДоговорыБезНДС
	|ИЗ
	|	НДСПоВзаиморасчетам КАК НДСПоВзаиморасчетам
	|ГДЕ
	|	НДСПоВзаиморасчетам.НДС = 0
	|
	|ИНДЕКСИРОВАТЬ ПО
	|	Договор
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ЖурналУчетаСчетовФактур.СчетФактура.ДоговорКонтрагента КАК СчетФактураДоговор
	|ПОМЕСТИТЬ СчетаФактуры
	|ИЗ
	|	РегистрСведений.ЖурналУчетаСчетовФактур КАК ЖурналУчетаСчетовФактур
	|ГДЕ
	|	ЖурналУчетаСчетовФактур.Организация В
	|			(ВЫБРАТЬ
	|				ОрганизацииПлательщикиНДС.Организация
	|			ИЗ
	|				ОрганизацииПлательщикиНДС)
	|
	|ИНДЕКСИРОВАТЬ ПО
	|	СчетФактураДоговор
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ДоговорыБезНДС.Договор КАК Договор
	|ПОМЕСТИТЬ ПоставщикПоДоговоруНеПредъявляетНДС
	|ИЗ
	|	ДоговорыБезНДС КАК ДоговорыБезНДС
	|ГДЕ
	|	НЕ ДоговорыБезНДС.Договор В
	|				(ВЫБРАТЬ
	|					СчетаФактуры.СчетФактураДоговор
	|				ИЗ
	|					СчетаФактуры)
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ДоговорыКонтрагентов.Ссылка КАК ДоговорСНДС,
	|	ДоговорыКонтрагентов.Владелец КАК Контрагент,
	|	ВЫБОР
	|		КОГДА ЕСТЬNULL(ПоставщикПоДоговоруНеПредъявляетНДС.Договор, ИСТИНА) = ИСТИНА
	|			ТОГДА ИСТИНА
	|		ИНАЧЕ ЛОЖЬ
	|	КОНЕЦ КАК ЗаполнятьСтавкуНДСИзКарточкиНоменклатуры
	|ИЗ
	|	Справочник.ДоговорыКонтрагентов КАК ДоговорыКонтрагентов
	|		ЛЕВОЕ СОЕДИНЕНИЕ ПоставщикПоДоговоруНеПредъявляетНДС КАК ПоставщикПоДоговоруНеПредъявляетНДС
	|		ПО (ПоставщикПоДоговоруНеПредъявляетНДС.Договор = ДоговорыКонтрагентов.Ссылка)
	|ГДЕ
	|	ДоговорыКонтрагентов.ЭтоГруппа = ЛОЖЬ
	|	И ДоговорыКонтрагентов.ВидДоговора В(&ВидыДоговоров)";
	
	Результат 			= Запрос.Выполнить();
	ВыборкаДоговоров 	= Результат.Выбрать();
	
	Пока ВыборкаДоговоров.Следующий() Цикл
		ДоговорОбъект = ВыборкаДоговоров.ДоговорСНДС.ПолучитьОбъект();
		
		Если ВыборкаДоговоров.ЗаполнятьСтавкуНДСИзКарточкиНоменклатуры Тогда
			ДоговорОбъект.СпособЗаполненияСтавкиНДС = Перечисления.СпособыЗаполненияСтавкиНДС.Автоматически;
		Иначе
			ДоговорОбъект.СпособЗаполненияСтавкиНДС = Перечисления.СпособыЗаполненияСтавкиНДС.БезНДС;
		КонецЕсли;
			
		Попытка
			ОбновлениеИнформационнойБазы.ЗаписатьДанные(ДоговорОбъект);
		Исключение
			ТекстСообщения = НСтр("ru = 'Не удалось установить реквизит ""Заполнение ставки НДС в документах"" для договора %1 контрагента %2, рекомендуется самостоятельно установить необходимое значение'");
			ТекстСообщения = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(ТекстСообщения, ВыборкаДоговоров.ДоговорСНДС, ВыборкаДоговоров.Контрагент);
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(ТекстСообщения);
		КонецПопытки;

	КонецЦикла;

КонецПроцедуры

Процедура ЗаполнитьСпособЗаполненияСтавкиНДС(Параметры) Экспорт

	Параметры.ОбработкаЗавершена = Ложь;

	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	ДоговорыКонтрагентов.Ссылка КАК Договор,
	|	ДоговорыКонтрагентов.Владелец КАК Контрагент
	|ИЗ
	|	Справочник.ДоговорыКонтрагентов КАК ДоговорыКонтрагентов
	|ГДЕ
	|	ДоговорыКонтрагентов.ПометкаУдаления = ЛОЖЬ
	|	И ДоговорыКонтрагентов.ЭтоГруппа = ЛОЖЬ
	|	И ДоговорыКонтрагентов.ВидДоговора В(&СписокВидовДоговоров)
	|	И ДоговорыКонтрагентов.СпособЗаполненияСтавкиНДС = ЗНАЧЕНИЕ(Перечисление.СпособыЗаполненияСтавкиНДС.ПустаяСсылка)";

	СписокВидовДоговоров = Новый Массив;
	СписокВидовДоговоров.Добавить(Перечисления.ВидыДоговоровКонтрагентов.СПоставщиком);
	СписокВидовДоговоров.Добавить(Перечисления.ВидыДоговоровКонтрагентов.СФакторинговойКомпанией);
	СписокВидовДоговоров.Добавить(Перечисления.ВидыДоговоровКонтрагентов.СКомитентом);
	СписокВидовДоговоров.Добавить(Перечисления.ВидыДоговоровКонтрагентов.СКомиссионеромНаЗакупку);
	СписокВидовДоговоров.Добавить(Перечисления.ВидыДоговоровКонтрагентов.СКомиссионером);
	
	Запрос.УстановитьПараметр("СписокВидовДоговоров", СписокВидовДоговоров);
	ТаблицаДоговоров = Запрос.Выполнить().Выгрузить();

	Если ТаблицаДоговоров.Количество() = 0 Тогда
		Параметры.ОбработкаЗавершена = Истина;
		Возврат;
	КонецЕсли;
	
	Для каждого ВыборкаДоговоров Из ТаблицаДоговоров Цикл
	
		СправочникОбъект = ВыборкаДоговоров.Договор.ПолучитьОбъект();
		Если СправочникОбъект.УдалитьПредъявляетНДС 
			ИЛИ СправочникОбъект.УчетАгентскогоНДС Тогда
			СправочникОбъект.СпособЗаполненияСтавкиНДС = Перечисления.СпособыЗаполненияСтавкиНДС.Автоматически;
		Иначе
			СправочникОбъект.СпособЗаполненияСтавкиНДС = Перечисления.СпособыЗаполненияСтавкиНДС.БезНДС;
		КонецЕсли;
		
		Попытка
			ОбновлениеИнформационнойБазы.ЗаписатьОбъект(СправочникОбъект);
		Исключение
			ТекстСообщения = НСтр("ru = 'Не удалось установить ""Заполнение ставки НДС в документах"" для договора %1 контрагента %2, рекомендуется самостоятельно установить необходимое значение'");
			ТекстСообщения = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(ТекстСообщения, ВыборкаДоговоров.Договор, ВыборкаДоговоров.Контрагент);
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(ТекстСообщения);
		КонецПопытки;

	КонецЦикла

КонецПроцедуры

Процедура ВключитьУчетПоДоговорамПриНаличииПользовательскихДоговоров() Экспорт
	
	Если НЕ ПолучитьФункциональнуюОпцию("ВестиУчетПоДоговорам") И СуществуютПользовательскиеДоговоры() Тогда
		
		Константы.ВестиУчетПоДоговорам.Установить(Истина);
		
		Если НЕ ПолучитьФункциональнуюОпцию("ИспользоватьДокументыРеализации") Тогда
			Константы.ИспользоватьДокументыРеализации.Установить(Истина);
		КонецЕсли;
		Если НЕ ПолучитьФункциональнуюОпцию("ИспользоватьДокументыПоступления") Тогда
			Константы.ИспользоватьДокументыПоступления.Установить(Истина);
		КонецЕсли;
		
	КонецЕсли;
	
КонецПроцедуры

Функция СуществуютПользовательскиеДоговоры()
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ ПЕРВЫЕ 1
	|	ДоговорыКонтрагентов.Наименование КАК Наименование
	|ИЗ
	|	Справочник.ДоговорыКонтрагентов КАК ДоговорыКонтрагентов
	|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.ОсновныеДоговорыКонтрагента КАК ОсновныеДоговорыКонтрагента
	|		ПО ДоговорыКонтрагентов.Ссылка = ОсновныеДоговорыКонтрагента.Договор
	|ГДЕ
	|	ОсновныеДоговорыКонтрагента.Договор ЕСТЬ NULL
	|	ИЛИ ДоговорыКонтрагентов.Наименование <> &НаименованиеПоУмолчанию";
	Запрос.УстановитьПараметр("НаименованиеПоУмолчанию",
		ПечатьДоговоровКлиентСервер.НаименованиеПоУмолчаниюБезРеквизитов());
	
	Возврат НЕ Запрос.Выполнить().Пустой();
	
КонецФункции

// Обработчик обновления версии 3.0.80 todo
// Заполняет новый реквизит "СпособВыставленияДокументов" 
// - для тех договоров, для которых существует настройка ЭДО (см. ресурс "ИспользоватьУПД" в РегистрСведений.НастройкиОтправкиЭлектронныхДокументов)
// если ресурс "Использовать УПД" = Истина - способ выставления документов "УниверсальныйДокумент" (см. Перечисление.СпособыВыставленияДокументов)
// если ресурс "Использовать УПД" = Ложь   - способ выставления документов "ПередаточныйДокументИСчетФактура" (см. Перечисление.СпособыВыставленияДокументов)
// - для всех остальных договоров - способ выставления документов "Автоматически" (см. Перечисление.СпособыВыставленияДокументов)
//
// Параметры - Структура со свойствами:
//      * ОбработкаЗавершена (Булево). Для того чтобы обработчик был вызван повторно для обработки следующей порции данных, следует записать в него значение Ложь.
//      * ПрогрессВыполнения (Структура). (*) Необходимо заполнять для отображения прогресса обработки данных:
//      * ВсегоОбъектов (Число). Общее количество объектов, которые необходимо обработать.
//      * ОбработаноОбъектов (Число). Сколько объектов уже обработано.
Процедура ЗаполнитьСпособВыставленияДокументовОтложенно(Параметры) Экспорт
	
	Параметры.ОбработкаЗавершена = Ложь;
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	НастройкиОтправкиЭлектронныхДокументов.Отправитель КАК Организация,
	|	НастройкиОтправкиЭлектронныхДокументов.Получатель КАК Контрагент,
	|	НастройкиОтправкиЭлектронныхДокументов.ИспользоватьУПД КАК ИспользоватьУПД
	|ПОМЕСТИТЬ НастройкиЭДО
	|ИЗ
	|	РегистрСведений.НастройкиОтправкиЭлектронныхДокументов КАК НастройкиОтправкиЭлектронныхДокументов
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ДоговорыКонтрагентов.Ссылка КАК Ссылка,
	|	ДоговорыКонтрагентов.Владелец КАК Контрагент,
	|	ДоговорыКонтрагентов.Организация КАК Организация,
	|	ВЫБОР
	|		КОГДА НастройкиЭДО.ИспользоватьУПД ЕСТЬ NULL
	|			ТОГДА ЗНАЧЕНИЕ(Перечисление.СпособыВыставленияДокументов.Автоматически)
	|		КОГДА НастройкиЭДО.ИспользоватьУПД
	|			ТОГДА ЗНАЧЕНИЕ(Перечисление.СпособыВыставленияДокументов.УниверсальныйДокумент)
	|		ИНАЧЕ ЗНАЧЕНИЕ(Перечисление.СпособыВыставленияДокументов.ПередаточныйДокументИСчетФактура)
	|	КОНЕЦ КАК СпособВыставленияДокументов
	|ИЗ
	|	Справочник.ДоговорыКонтрагентов КАК ДоговорыКонтрагентов
	|		ЛЕВОЕ СОЕДИНЕНИЕ НастройкиЭДО КАК НастройкиЭДО
	|		ПО ДоговорыКонтрагентов.Владелец = НастройкиЭДО.Контрагент
	|			И ДоговорыКонтрагентов.Организация = НастройкиЭДО.Организация
	|ГДЕ
	|	ДоговорыКонтрагентов.СпособВыставленияДокументов = ЗНАЧЕНИЕ(Перечисление.СпособыВыставленияДокументов.ПустаяСсылка)
	|	И НЕ ДоговорыКонтрагентов.ПометкаУдаления";
	
	Результат = Запрос.Выполнить();
	
	Если Результат.Пустой() Тогда
		Параметры.ОбработкаЗавершена = Истина;
		Возврат;
	КонецЕсли;
	
	Выборка = Результат.Выбрать();
	
	Блокировка = Новый БлокировкаДанных;
	ЭлементБлокировки = Блокировка.Добавить("Справочник.ДоговорыКонтрагентов");
	
	Пока Выборка.Следующий() Цикл
		
		НачатьТранзакцию();
		
		Попытка
			
			ЭлементБлокировки.УстановитьЗначение("Ссылка", Выборка.Ссылка);
			Блокировка.Заблокировать();
			
			СправочникОбъект = Выборка.Ссылка.ПолучитьОбъект();
			
			// Объект удален или обработан другим сеансом
			Если СправочникОбъект = Неопределено
			 Или СправочникОбъект.СпособВыставленияДокументов <> Перечисления.СпособыВыставленияДокументов.ПустаяСсылка() Тогда
				ОтменитьТранзакцию();
				Продолжить;
			КонецЕсли;
			
			СправочникОбъект.СпособВыставленияДокументов = Выборка.СпособВыставленияДокументов;
			ОбновлениеИнформационнойБазы.ЗаписатьДанные(СправочникОбъект);
			
			ЗафиксироватьТранзакцию();
			
		Исключение
			
			ОтменитьТранзакцию();
			
			ШаблонСообщения = НСтр(
				"ru = 'Не выполнено заполнение реквизита ""Способ выставления документов"" справочника ""Договор контрагента""
				|%1'");
			ТекстСообщения = СтрШаблон(ШаблонСообщения, ПодробноеПредставлениеОшибки(ИнформацияОбОшибке()));
			ЗаписьЖурналаРегистрации(
				ОбновлениеИнформационнойБазы.СобытиеЖурналаРегистрации(),
				УровеньЖурналаРегистрации.Ошибка,
				Метаданные.Справочники.ДоговорыКонтрагентов,
				,
				ТекстСообщения);
			
		КонецПопытки;
		
	КонецЦикла;
	
КонецПроцедуры

#КонецОбласти

#Область ПроцедурыИФункцииПечати

// Заполняет список команд печати.
// 
// Параметры:
//   КомандыПечати - ТаблицаЗначений - состав полей см. в функции УправлениеПечатью.СоздатьКоллекциюКомандПечати
//
Процедура ДобавитьКомандыПечати(КомандыПечати) Экспорт
	
	Если ПравоДоступа("Чтение", Метаданные.Справочники.ШаблоныДоговоров) Тогда
		// Текст договора
		КомандаПечати = КомандыПечати.Добавить();
		КомандаПечати.Идентификатор = "Договор";
		КомандаПечати.Представление = НСтр("ru = 'Договор'");
		КомандаПечати.Обработчик    = "ПечатьДоговоровКлиент.ВыполнитьКомандуПечатиТекстаДоговора";
		КомандаПечати.СписокФорм    = "ФормаЭлемента,ФормаСпискаОбщая";
	КонецЕсли;
	
	Если ПравоДоступа("Чтение", Метаданные.Справочники.Контрагенты) Тогда
		// Печать конвертов
		КомандаПечати = КомандыПечати.Добавить();
		КомандаПечати.Идентификатор = "Конверт";
		КомандаПечати.Представление = НСтр("ru = 'Конверт'");
		КомандаПечати.Обработчик    = "УправлениеПечатьюБПКлиент.ВыполнитьКомандуПечатиКонверта";
		КомандаПечати.СписокФорм    = "ФормаЭлемента,ФормаСпискаОбщая";
	КонецЕсли;
	
КонецПроцедуры

// Возвращает структуру с перечнем полей, которые могут быть поставлены в текст 
// договора по данным из справочника "Договоры контрагентов".
//
Функция ПодготовитьПараметрыПечатиТекстаДоговора(ДоговорКонтрагента) Экспорт
	
	ИменаНеобходимыхРеквизитовДоговора = РеквизитыДоговораДляПечати();
	РеквизитыДоговора = ОбщегоНазначения.ЗначенияРеквизитовОбъекта(
		ДоговорКонтрагента, ИменаНеобходимыхРеквизитовДоговора);
		
	// Дополнительные поля
	РеквизитыДоговора.Вставить("РуководительФИО", ""); // Фамилия Имя Отчество
	РеквизитыДоговора.Вставить("РуководительПол", ""); // Пол физического лица
	РеквизитыДоговора.Вставить("УсловиеОплаты", "");
	РеквизитыДоговора.Вставить("ИмяМакета", "");
	
	ДатаСреза = ?(ЗначениеЗаполнено(РеквизитыДоговора.Дата), РеквизитыДоговора.Дата, ТекущаяДатаСеанса());

	// Если срок оплаты не указан в самом договоре, берем его из константы.
	Если НЕ РеквизитыДоговора.УстановленСрокОплаты Тогда
		Если РеквизитыДоговора.ВидДоговора = Перечисления.ВидыДоговоровКонтрагентов.СПоставщиком
			ИЛИ РеквизитыДоговора.ВидДоговора = Перечисления.ВидыДоговоровКонтрагентов.СКомиссионеромНаЗакупку
			ИЛИ РеквизитыДоговора.ВидДоговора = Перечисления.ВидыДоговоровКонтрагентов.СКомитентом Тогда
			РеквизитыДоговора.Вставить("СрокОплаты", Константы.СрокОплатыПоставщикам.Получить());
		Иначе
			РеквизитыДоговора.Вставить("СрокОплаты", Константы.СрокОплатыПокупателей.Получить());
		КонецЕсли;
	КонецЕсли;
	
	Если ЗначениеЗаполнено(РеквизитыДоговора.Руководитель) Тогда
		ДанныеФизЛица = УчетЗарплаты.ПредставлениеФизическогоЛица(РеквизитыДоговора.Руководитель, ДатаСреза);
		Если ЗначениеЗаполнено(ДанныеФизЛица.ФИОПолные) Тогда
			РеквизитыДоговора.Вставить("РуководительФИО", ДанныеФизЛица.ФИОПолные);
		Иначе
			РеквизитыДоговора.Вставить("РуководительФИО", 
				ОбщегоНазначения.ЗначениеРеквизитаОбъекта(РеквизитыДоговора.Руководитель, "Наименование"));
		КонецЕсли;
		
	Иначе
		ОтветственныеЛица = ОтветственныеЛицаБП.ОтветственныеЛица(
			РеквизитыДоговора.Организация, ДатаСреза, Неопределено);
		
		РеквизитыДоговора.Вставить("Руководитель", 		ОтветственныеЛица.Руководитель);
		РеквизитыДоговора.Вставить("РуководительФИО", 	ОбщегоНазначенияБПВызовСервера.ПолучитьФамилиюИмяОтчество(
															ОтветственныеЛица.РуководительФИО.Фамилия, 
															ОтветственныеЛица.РуководительФИО.Имя,
															ОтветственныеЛица.РуководительФИО.Отчество,
															Ложь));
		РеквизитыДоговора.Вставить("ДолжностьРуководителя", ОтветственныеЛица.РуководительДолжность);
		
	КонецЕсли;
	
	Если ЗначениеЗаполнено(РеквизитыДоговора.Руководитель) Тогда
		РеквизитыДоговора.Вставить("РуководительПол", 
			ОбщегоНазначения.ЗначениеРеквизитаОбъекта(РеквизитыДоговора.Руководитель, "Пол"));
	КонецЕсли;
	
	Возврат РеквизитыДоговора;

КонецФункции

#КонецОбласти

#Область СлужебныеПроцедурыИФункции
	
Функция РеквизитыДоговораДляПечати()
	
	ИменаРеквизитов = Новый Массив;
	
	ИменаРеквизитов.Добавить("Владелец");
	ИменаРеквизитов.Добавить("Организация");
	ИменаРеквизитов.Добавить("Дата");
	ИменаРеквизитов.Добавить("Номер");
	ИменаРеквизитов.Добавить("СрокДействия");
	ИменаРеквизитов.Добавить("ВидДоговора");
	ИменаРеквизитов.Добавить("ВалютаВзаиморасчетов");
	ИменаРеквизитов.Добавить("УстановленСрокОплаты");
	ИменаРеквизитов.Добавить("СрокОплаты");
	ИменаРеквизитов.Добавить("ДатаОплаты");
	ИменаРеквизитов.Добавить("Руководитель");
	ИменаРеквизитов.Добавить("ЗаРуководителяПоПриказу");
	ИменаРеквизитов.Добавить("ДолжностьРуководителя");
	ИменаРеквизитов.Добавить("РуководительКонтрагента");
	ИменаРеквизитов.Добавить("ЗаРуководителяКонтрагентаПоПриказу");
	ИменаРеквизитов.Добавить("ДолжностьРуководителяКонтрагента");
	ИменаРеквизитов.Добавить("ПолРуководителяКонтрагента");
	
	Возврат ИменаРеквизитов;
	
КонецФункции

#КонецОбласти 


#КонецЕсли

