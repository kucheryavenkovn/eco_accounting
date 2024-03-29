﻿#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

////////////////////////////////////////////////////////////////////////////////
// ПРОЦЕДУРЫ И ФУНКЦИИ ОБЩЕГО НАЗНАЧЕНИЯ

////////////////////////////////////////////////////////////////////////////////
// ПРОЦЕДУРЫ - ОБРАБОТЧИКИ СОБЫТИЙ

Процедура ОбработкаЗаполнения(ДанныеЗаполнения, СтандартнаяОбработка)
	
	ЗаполнениеДокументов.Заполнить(ЭтотОбъект, ДанныеЗаполнения);

КонецПроцедуры

Процедура ПриКопировании(ОбъектКопирования)

	Дата = НачалоДня(ОбщегоНазначения.ТекущаяДатаПользователя());
	Ответственный = Пользователи.ТекущийПользователь();

КонецПроцедуры

Процедура ПередЗаписью(Отказ, РежимЗаписи, РежимПроведения)
	
	Если ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;
		
КонецПроцедуры

Процедура ПриЗаписи(Отказ)
	
	Если ОбменДанными.Загрузка  Тогда
		Возврат;
	КонецЕсли;
	
КонецПроцедуры

Процедура ОбработкаПроверкиЗаполнения(Отказ, ПроверяемыеРеквизиты)
	
	// Исключаем из проверки реквизиты, заполнение которых стало необязательным:
	МассивНепроверяемыхРеквизитов = Новый Массив();
		
	// Проверяем табличную часть "Параметры экплуатации":
	ИмяСписка = НСтр("ru = 'Параметры эксплуатации'");
	Для каждого СтрокаТЧ Из ПараметрыЭксплуатации Цикл
		Префикс = "ПараметрыЭксплуатации[" + Формат(СтрокаТЧ.НомерСтроки - 1, "ЧН=0; ЧГ=") + "].";
		
		Если СтрокаТЧ.ТипОбслуживания = Перечисления.АР_ТипыОбслуживанияОбъектовАренды.ПоГрафику Тогда
			Если Не ЗначениеЗаполнено(СтрокаТЧ.ГрафикОбслуживания) Тогда
				ТекстСообщения = ОбщегоНазначенияБПКлиентСервер.ПолучитьТекстСообщения("Колонка",, НСтр("ru = 'График обслуживания'"),
				СтрокаТЧ.НомерСтроки, ИмяСписка);
				Поле = Префикс + "ГрафикОбслуживания";
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю(ТекстСообщения, ЭтотОбъект, Поле, "Объект", Отказ);
			КонецЕсли;
		ИначеЕсли СтрокаТЧ.ТипОбслуживания = Перечисления.АР_ТипыОбслуживанияОбъектовАренды.ПоВыработке Тогда
			Если Не ЗначениеЗаполнено(СтрокаТЧ.ПоказательВыработки) Тогда
				ТекстСообщения = ОбщегоНазначенияБПКлиентСервер.ПолучитьТекстСообщения("Колонка",, НСтр("ru = 'Показатель выработки'"),
				СтрокаТЧ.НомерСтроки, ИмяСписка);
				Поле = Префикс + "ПоказательВыработки";
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю(ТекстСообщения, ЭтотОбъект, Поле, "Объект", Отказ);
			КонецЕсли;
			Если Не ЗначениеЗаполнено(СтрокаТЧ.ПороговоеЗначениеВыработки) Тогда
				ТекстСообщения = ОбщегоНазначенияБПКлиентСервер.ПолучитьТекстСообщения("Колонка",, НСтр("ru = 'Пороговое значение выработки'"),
				СтрокаТЧ.НомерСтроки, ИмяСписка);
				Поле = Префикс + "ПороговоеЗначениеВыработки";
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю(ТекстСообщения, ЭтотОбъект, Поле, "Объект", Отказ);
			КонецЕсли;
		КонецЕсли;
		
	КонецЦикла;
	
	// Удаляем из проверяемых реквизитов все, по которым автоматическая проверка не нужна:
	ОбщегоНазначения.УдалитьНепроверяемыеРеквизитыИзМассива(ПроверяемыеРеквизиты, МассивНепроверяемыхРеквизитов);
	
КонецПроцедуры

Процедура ОбработкаПроведения(Отказ, РежимПроведения)

	// ПОДГОТОВКА ПРОВЕДЕНИЯ ПО ДАННЫМ ДОКУМЕНТА

	ПроведениеСервер.ПодготовитьНаборыЗаписейКПроведению(ЭтотОбъект);
	Если РучнаяКорректировка Тогда
		Возврат;
	КонецЕсли;

	ПараметрыПроведения = Документы.АР_ВводПараметровЭксплуатацииОбъектов.ПодготовитьПараметрыПроведения(Ссылка, Отказ);
	Если Отказ Тогда
		Возврат;
	КонецЕсли;

	// ПОДГОТОВКА ПРОВЕДЕНИЯ ПО ДАННЫМ ИНФОРМАЦИОННОЙ БАЗЫ

	// ФОРМИРОВАНИЕ ДВИЖЕНИЙ
	
	АР_ОбщиеПроцедуры.СформироватьДвиженияПоРегистру(ПараметрыПроведения.ПараметрыЭксплуатации, Движения, "АР_ПараметрыЭксплуатацииОбъектов", Отказ);
		
	ПроведениеСервер.УстановитьЗаписьОчищаемыхНаборовЗаписей(ЭтотОбъект);
	
КонецПроцедуры

Процедура ОбработкаУдаленияПроведения(Отказ)

	ПроведениеСервер.ПодготовитьНаборыЗаписейКОтменеПроведения(ЭтотОбъект);
	Движения.Записать();

КонецПроцедуры

#КонецЕсли
