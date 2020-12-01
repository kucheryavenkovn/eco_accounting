﻿#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область ОбработчикиСобытий

Процедура ОбработкаЗаполнения(ДанныеЗаполнения, СтандартнаяОбработка)
	
	ЗаполнениеДокументов.Заполнить(ЭтотОбъект, ДанныеЗаполнения);
	
КонецПроцедуры

Процедура ОбработкаПроведения(Отказ, РежимПроведения)
	
	// ПОДГОТОВКА ПРОВЕДЕНИЯ ПО ДАННЫМ ДОКУМЕНТА
	
	ПроведениеСервер.ПодготовитьНаборыЗаписейКПроведению(ЭтотОбъект);
	Если РучнаяКорректировка Тогда
		Возврат;
	КонецЕсли;
	
	ПараметрыПроведения = Документы.ПоступлениеНМА.ПодготовитьПараметрыПроведения(Ссылка, Отказ);
	Если Отказ Тогда
		Возврат;
	КонецЕсли;
	
	// ПОДГОТОВКА ПРОВЕДЕНИЯ ПО ДАННЫМ ИНФОРМАЦИОННОЙ БАЗЫ (АНАЛИЗ ОСТАТКОВ И Т.П.)
	
	// Таблица взаиморасчетов
	ТаблицаВзаиморасчеты = УчетВзаиморасчетов.ПодготовитьТаблицуВзаиморасчетовЗачетАвансов(ПараметрыПроведения.ЗачетАвансовТаблицаДокумента,
		ПараметрыПроведения.ЗачетАвансовТаблицаАвансов, ПараметрыПроведения.ЗачетАвансовРеквизиты, Отказ);
	
	// Таблицы документа с корректировкой сумм по курсу авансов
	СтруктураТаблицДокумента = УчетДоходовРасходов.ПодготовитьТаблицыПоступленияПоКурсуАвансов(ПараметрыПроведения.СтруктураТаблицДокумента,
		ТаблицаВзаиморасчеты, ПараметрыПроведения.ЗачетАвансовРеквизиты);
	
	Документы.ПоступлениеНМА.ДобавитьКолонкуСодержание(ПараметрыПроведения.ПоступлениеНематериальныхАктивовРеквизиты,
		СтруктураТаблицДокумента.ТаблицаНематериальныеАктивы);
		
	// Структура таблиц для отражения в налоговом учете УСН
	СтруктураТаблицУСН = Новый Структура("ТаблицаРасчетов", ТаблицаВзаиморасчеты);
	
	// ФОРМИРОВАНИЕ ДВИЖЕНИЙ
	
	// Зачет аванса
	УчетВзаиморасчетов.СформироватьДвиженияЗачетАвансов(ТаблицаВзаиморасчеты,
		ПараметрыПроведения.ЗачетАвансовРеквизиты, Движения, Отказ);
		
	// Поступление нематериальных активов
	УчетНМА.СформироватьДвиженияПоступлениеНМА(СтруктураТаблицДокумента.ТаблицаНематериальныеАктивы,
		ПараметрыПроведения.ПоступлениеНематериальныхАктивовРеквизиты, Движения, Отказ);
		
	// Установка состояния НМА
	УчетНМА.СформироватьДвиженияСостоянияНМАОрганизаций(СтруктураТаблицДокумента.ТаблицаНематериальныеАктивы,
		ПараметрыПроведения.ПоступлениеНематериальныхАктивовРеквизиты, Движения, Отказ);
		
	//Движения регистра "Рублевые суммы документов в валюте"
	УчетНДСБП.СформироватьДвиженияРублевыеСуммыДокументовВВалютеПоступлениеСобственныхТоваровУслуг(СтруктураТаблицДокумента.ТаблицаНематериальныеАктивы, 
		ПараметрыПроведения.ПоступлениеНематериальныхАктивовРеквизиты, Движения, Отказ);
	
	// Учет НДС
	УчетНДС.СформироватьДвиженияПоступлениеНематериальныхАктивовОтПоставщика(
		СтруктураТаблицДокумента.ТаблицаНематериальныеАктивы,
		ПараметрыПроведения.РеквизитыНДС, Движения, Отказ);
		
	УчетНДСРаздельный.СформироватьДвиженияПоступлениеНематериальныхАктивовОтПоставщика(
		СтруктураТаблицДокумента.ТаблицаНематериальныеАктивы,
		ПараметрыПроведения.РеквизитыНДС, Движения, Отказ);
		
	// УСН
	НалоговыйУчетУСН.СформироватьДвиженияУСН(ЭтотОбъект, СтруктураТаблицУСН);

	// Переоценка валютных остатков - после формирования проводок всеми другими механизмами
	ТаблицаПереоценка = УчетДоходовРасходов.ПодготовитьТаблицуПереоценкаВалютныхОстатковПоПроводкамДокумента(
		ПараметрыПроведения.ПереоценкаВалютныхОстатковРеквизиты, Движения, Отказ);

	УчетДоходовРасходов.СформироватьДвиженияПереоценкаВалютныхОстатков(ТаблицаПереоценка,
		ПараметрыПроведения.ПереоценкаВалютныхОстатковРеквизиты, Движения, Отказ);

	УчетУСН.СформироватьДвиженияПереоценкаВалютныхОстатков(ТаблицаПереоценка,
		ПараметрыПроведения.ПереоценкаВалютныхОстатковРеквизиты, Движения, Отказ);

	РаботаСПоследовательностями.ЗарегистрироватьВПоследовательности(ЭтотОбъект, Отказ, Ложь);
		
	// Отложенные расчеты с контрагентами.
	УчетВзаиморасчетовОтложенноеПроведение.ЗарегистрироватьОтложенныеРасчетыСКонтрагентами(
		ЭтотОбъект, Отказ, ПараметрыПроведения.РасчетыСКонтрагентамиОтложенноеПроведение);
		
	ПроведениеСервер.УстановитьЗаписьОчищаемыхНаборовЗаписей(ЭтотОбъект);
		
	Движения.Записать();
	
	ПараметрыДействия = УчетНДСПереопределяемый.НовыеПараметрыСостоянияСчетаФактуры("Проведен", ЭтотОбъект, "СчетФактураПолученный");	
	УчетНДСПереопределяемый.УстановитьСостояниеСчетаФактуры(ПараметрыДействия, Отказ);
	
КонецПроцедуры

Процедура ОбработкаПроверкиЗаполнения(Отказ, ПроверяемыеРеквизиты)
	
	РаздельныйУчетНДСНаСчете19 = УчетнаяПолитика.РаздельныйУчетНДСНаСчете19(Организация, Дата);
	
	МассивНепроверяемыхРеквизитов = Новый Массив();
	
	Если НЕ ПолучитьФункциональнуюОпцию("ВестиУчетПоДоговорам") Тогда
		МассивНепроверяемыхРеквизитов.Добавить("ДоговорКонтрагента");
	КонецЕсли;
	
	// В формах документа счет расчетов и счет авансов редактируются в специальной форме.
	// В случае, если они не заполнены, покажем сообщение возле соответствующей гиперссылки.

	МассивНепроверяемыхРеквизитов.Добавить("СчетУчетаРасчетовСКонтрагентом");
	МассивНепроверяемыхРеквизитов.Добавить("СчетУчетаРасчетовПоАвансам");

	Если НЕ ЗначениеЗаполнено(СчетУчетаРасчетовСКонтрагентом) Тогда
		ТекстСообщения = ОбщегоНазначенияБПКлиентСервер.ПолучитьТекстСообщения(,,
			НСтр("ru = 'Счет учета расчетов с контрагентом'"));
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(ТекстСообщения, ЭтотОбъект,,
			"ПорядокУчетаРасчетов", Отказ);
	КонецЕсли;
		
	Если СпособЗачетаАвансов <> Перечисления.СпособыЗачетаАвансов.НеЗачитывать Тогда 
		Если НЕ ЗначениеЗаполнено(СчетУчетаРасчетовПоАвансам) Тогда
			ТекстСообщения = ОбщегоНазначенияБПКлиентСервер.ПолучитьТекстСообщения(,,
				НСтр("ru = 'Счет учета расчетов по авансам'"));
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(ТекстСообщения, ЭтотОбъект,,
				"ПорядокУчетаРасчетов", Отказ);
		КонецЕсли;
	КонецЕсли;
	
	Если Не ЭтоУниверсальныйДокумент Тогда
		МассивНепроверяемыхРеквизитов.Добавить("НомерВходящегоДокумента");
		МассивНепроверяемыхРеквизитов.Добавить("ДатаВходящегоДокумента");
	КонецЕсли;
	
	МассивНепроверяемыхРеквизитов.Добавить("НематериальныеАктивы.СчетУчетаНДС");
	Если Не НДСВключенВСтоимость Тогда
		
		Для Каждого СтрокаТаблицы Из НематериальныеАктивы Цикл 
			
			Префикс = "НематериальныеАктивы[%1].";
			Префикс = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
				Префикс, Формат(СтрокаТаблицы.НомерСтроки - 1, "ЧН=0; ЧГ="));
			ИмяСписка = НСтр("ru = 'Нематериальные услуги'");

			Если СтрокаТаблицы.СуммаНДС <> 0 
				И НЕ ЗначениеЗаполнено(СтрокаТаблицы.СчетУчетаНДС) Тогда
				ТекстСообщения = ОбщегоНазначенияКлиентСервер.ТекстОшибкиЗаполнения("Колонка",, НСтр("ru = 'Счет НДС'"),
					СтрокаТаблицы.НомерСтроки, ИмяСписка);
				Поле = Префикс + "СчетУчетаНДС";
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю(ТекстСообщения, ЭтотОбъект, Поле, "Объект", Отказ);
			КонецЕсли;
			//Проверка способа учета НДС
			Если РаздельныйУчетНДСНаСчете19 И НЕ ЗначениеЗаполнено(СтрокаТаблицы.СпособУчетаНДС)
				И СтрокаТаблицы.СуммаНДС <> 0 Тогда
				ТекстСообщения = ОбщегоНазначенияКлиентСервер.ТекстОшибкиЗаполнения("Колонка",, НСтр("ru = 'Способ учета НДС'"),
				СтрокаТаблицы.НомерСтроки, ИмяСписка);
				Поле = Префикс + "СпособУчетаНДС";
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю(ТекстСообщения, ЭтотОбъект, Поле, "Объект", Отказ);	
			КонецЕсли;	
		КонецЦикла;
	КонецЕсли;
	
	// Табличная часть "Зачет авансов"
	Если СпособЗачетаАвансов <> Перечисления.СпособыЗачетаАвансов.ПоДокументу Тогда
		МассивНепроверяемыхРеквизитов.Добавить("ЗачетАвансов");
	ИначеЕсли ЗачетАвансов.Количество() = 0 Тогда
		МассивНепроверяемыхРеквизитов.Добавить("ЗачетАвансов");
	
		ТекстСообщения = НСтр("ru = 'Не введено ни одной строки с документом аванса!'");
		Поле = "ПорядокУчетаРасчетов";
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(ТекстСообщения, ЭтотОбъект, , Поле, Отказ);
	КонецЕсли;
	
	ОбщегоНазначения.УдалитьНепроверяемыеРеквизитыИзМассива(ПроверяемыеРеквизиты, МассивНепроверяемыхРеквизитов);
	
КонецПроцедуры

Процедура ОбработкаУдаленияПроведения(Отказ)
	
	ПроведениеСервер.ПодготовитьНаборыЗаписейКОтменеПроведения(ЭтотОбъект);
	Движения.Записать();
	
	ПараметрыДействия = УчетНДСПереопределяемый.НовыеПараметрыСостоянияСчетаФактуры("Проведен", ЭтотОбъект, "СчетФактураПолученный");	
	ПараметрыДействия.СостояниеФлага = Ложь;
	УчетНДСПереопределяемый.УстановитьСостояниеСчетаФактуры(ПараметрыДействия, Отказ);
	
	РаботаСПоследовательностями.ОтменитьРегистрациюВПоследовательности(ЭтотОбъект, Отказ);
	
КонецПроцедуры

Процедура ПередЗаписью(Отказ, РежимЗаписи, РежимПроведения)
	
	Если ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;
	
	ДополнительныеСвойства.Вставить("РежимЗаписи", РежимЗаписи);
		
	Если УчетнаяПолитика.РаздельныйУчетНДСНаСчете19(Организация, Дата) Тогда
		НДСВключенВСтоимость = Ложь;
	КонецЕсли;

	// При групповом перепроведении реквизиты документов не меняются,
	// поэтому обновление связанных данных выполнять не требуется.
	Если ПроведениеСервер.ГрупповоеПерепроведение(ЭтотОбъект) Тогда
		Возврат;
	КонецЕсли;
	
	РаботаСДоговорамиКонтрагентовБП.ЗаполнитьДоговорПередЗаписью(ЭтотОбъект);
	
	// Посчитать суммы документа и записать ее в соответствующий реквизит шапки для показа в журналах
	СуммаДокумента = УчетНДСПереопределяемый.ПолучитьСуммуДокументаСНДС(ЭтотОбъект);
	
	Если СпособЗачетаАвансов <> Перечисления.СпособыЗачетаАвансов.ПоДокументу 
		 И ЗачетАвансов.Количество() > 0 Тогда
		ЗачетАвансов.Очистить();
	КонецЕсли;
	
	ПараметрыДействия = УчетНДСПереопределяемый.НовыеПараметрыСостоянияСчетаФактуры("ПометкаУдаления", ЭтотОбъект, "СчетФактураПолученный");
	УчетНДСПереопределяемый.УстановитьСостояниеСчетаФактуры(ПараметрыДействия, Отказ);
	
	Документы.КорректировкаПоступления.ОбновитьРеквизитыСвязанныхДокументовКорректировки(ЭтотОбъект, Отказ);
	
КонецПроцедуры

Процедура ПриЗаписи(Отказ)
	
	Если ОбменДанными.Загрузка  Тогда
		Возврат;
	КонецЕсли;
	
	Если ДополнительныеСвойства.РежимЗаписи = РежимЗаписиДокумента.Запись Тогда
		УчетНДСПереопределяемый.СинхронизироватьРеквизитыСчетаФактурыПолученного(ЭтотОбъект);
	КонецЕсли;
	
КонецПроцедуры

Процедура ПриКопировании(ОбъектКопирования)
	
	Дата = НачалоДня(ОбщегоНазначения.ТекущаяДатаПользователя());
	Ответственный = Пользователи.ТекущийПользователь();
	
	ЗачетАвансов.Очистить();
	
	СтруктураКурсаВзаиморасчетов = РаботаСКурсамиВалют.ПолучитьКурсВалюты(
	ВалютаДокумента, Дата);
	
	КурсВзаиморасчетов      = СтруктураКурсаВзаиморасчетов.Курс;
	КратностьВзаиморасчетов = СтруктураКурсаВзаиморасчетов.Кратность;
	
КонецПроцедуры

#КонецОбласти

#КонецЕсли