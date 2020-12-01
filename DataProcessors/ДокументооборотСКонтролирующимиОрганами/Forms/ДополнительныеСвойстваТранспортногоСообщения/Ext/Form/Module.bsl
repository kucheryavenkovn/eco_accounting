﻿#Область ОбработчикиСобытийФормы

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	Если ЗначениеЗаполнено(ТекстПредупреждения) Тогда 
		ПоказатьПредупреждение(, ТекстПредупреждения);
		Отказ = Истина;
		Возврат;
	КонецЕсли;
КонецПроцедуры

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)

	Если Параметры.Ключ.Пустая() Тогда
		Возврат;
	Иначе
		Сообщение = Параметры.Ключ.ПолучитьОбъект();
	КонецЕсли;

	ЗаголовокСертификатов = Неопределено;
	Для Каждого Сертификат Из Сообщение.СертификатыПолучателей Цикл 
		Если ЗаголовокСертификатов = Неопределено Тогда 
			ЗаголовокСертификатов = Дополнительно.ПолучитьЭлементы().Добавить();
			ЗаголовокСертификатов.ТекстОформленияУровень = 0;
			ЗаголовокСертификатов.Имя = "Серийные номера и издатели сертификатов получателей";
		КонецЕсли;
		
		НовСтр2 = ЗаголовокСертификатов.ПолучитьЭлементы().Добавить();
		НовСтр2.ТекстОформленияУровень = 1;
		НовСтр2.Имя = Сертификат.СерийныйНомер;
		Если ЗначениеЗаполнено(Сертификат.Отпечаток) Тогда 
			НовСтр2.Имя = НовСтр2.Имя + СтрШаблон(" (%1)", Сертификат.Отпечаток);
		КонецЕсли;
		НовСтр2.Значение = Сертификат.ПоставщикCN;		
		Если Сертификат.Сторонний Тогда 
			НовСтр2.Значение = НовСтр2.Значение + " (сторонний)";
		КонецЕсли;
	КонецЦикла;	
		
	Если Сообщение.Статус <> Перечисления.СтатусыПисем.Отправленное И Сообщение.Статус <> Перечисления.СтатусыПисем.Полученное Тогда
		Если Сообщение.СертификатыПолучателей.Количество() = 0 Тогда 
			ТекстПредупреждения = "Дополнительные свойства доступны только для отправленных и полученных писем.";
		КонецЕсли;
		Возврат;
	КонецЕсли;

	Если НЕ ПустаяСтрока(Сообщение.ОтКогоАдрес) ИЛИ НЕ ПустаяСтрока(Сообщение.ОтКогоПредставление) Тогда
		НовСтр = Дополнительно.ПолучитьЭлементы().Добавить();
		НовСтр.ТекстОформленияУровень = 0;

		НовСтр.Имя = "От кого";
		НовСтр2 = НовСтр.ПолучитьЭлементы().Добавить();
		НовСтр2.ТекстОформленияУровень = 1;
		НовСтр2.Имя = Сообщение.ОтКогоАдрес;
		НовСтр2.Значение = Сообщение.ОтКогоПредставление;
	КонецЕсли;

	Если Сообщение.Кому.Количество() <> 0 Тогда
		НовСтр = Дополнительно.ПолучитьЭлементы().Добавить();
		НовСтр.ТекстОформленияУровень = 0;
		НовСтр.Имя = "Кому";
		Для Каждого ЭлКому Из Сообщение.Кому Цикл
			НовСтр2 = НовСтр.ПолучитьЭлементы().Добавить();
			НовСтр2.ТекстОформленияУровень = 1;
			НовСтр2.Имя = ЭлКому.АдресЭлектроннойПочты;
			НовСтр2.Значение = ЭлКому.Представление;
		КонецЦикла;
	КонецЕсли;

	Если Сообщение.Копии.Количество() <> 0 Тогда
		НовСтр = Дополнительно.ПолучитьЭлементы().Добавить();
		НовСтр.ТекстОформленияУровень = 0;
		НовСтр.Имя = "Копии";
		Для Каждого ЭлКопии Из Сообщение.Копии Цикл
			НовСтр2 = НовСтр.Строки.Добавить();
			НовСтр2.Имя = ЭлКопии.АдресЭлектроннойПочты;
			НовСтр2.Значение = ЭлКопии.Представление;
		КонецЦикла;
	КонецЕсли;

	Если Сообщение.СкрытыеКопии.Количество() <> 0 Тогда
		НовСтр = Дополнительно.ПолучитьЭлементы().Добавить();
		НовСтр.ТекстОформленияУровень = 0;
		НовСтр.Имя = "Скрытые копии";
		Для Каждого ЭлСкрытыеКопии Из Сообщение.Копии Цикл
			НовСтр2 = НовСтр.ПолучитьЭлементы().Добавить();
			НовСтр2.ТекстОформленияУровень = 0;
			НовСтр2.Имя = ЭлСкрытыеКопии.АдресЭлектроннойПочты;
			НовСтр2.Значение = ЭлСкрытыеКопии.Представление;
		КонецЦикла;
	КонецЕсли;

	НовСтр = Дополнительно.ПолучитьЭлементы().Добавить();
	НовСтр.ТекстОформленияУровень = 0;
	НовСтр.Имя = "Прочее";
	
	НовСтр2 = НовСтр.ПолучитьЭлементы().Добавить();
	НовСтр2.ТекстОформленияУровень = 1;
	НовСтр2.Имя = "Идентификатор сообщения";
	НовСтр2.Значение = Сообщение.ИдентификаторСообщения;
	
	НовСтр2 = НовСтр.ПолучитьЭлементы().Добавить();
	НовСтр2.ТекстОформленияУровень = 1;
	НовСтр2.Имя = "Кодировка";
	НовСтр2.Значение = Сообщение.Кодировка;
	
	НовСтр2 = НовСтр.ПолучитьЭлементы().Добавить();
	НовСтр2.ТекстОформленияУровень = 1;
	НовСтр2.Имя = "Тема";
	НовСтр2.Значение = Сообщение.Тема;
	
	НовСтр2 = НовСтр.ПолучитьЭлементы().Добавить();
	НовСтр2.ТекстОформленияУровень = 1;
	НовСтр2.Имя = "Текст письма";
	НовСтр2.Значение = Сообщение.ТекстПисьма;

	Если Сообщение.ДополнительныеРеквизитыЗаголовка.Количество() <> 0 Тогда
		НовСтр = Дополнительно.ПолучитьЭлементы().Добавить();
		НовСтр.ТекстОформленияУровень = 0;
		НовСтр.Имя = "Дополнительные реквизиты";
		Для Каждого ЭлДопРеквизиты Из Сообщение.ДополнительныеРеквизитыЗаголовка Цикл
			НовСтр2 = НовСтр.ПолучитьЭлементы().Добавить();
			НовСтр2.ТекстОформленияУровень = 1;
			НовСтр2.Имя = ЭлДопРеквизиты.Тип;
			НовСтр2.Значение = ЭлДопРеквизиты.Значение;
		КонецЦикла;
	КонецЕсли;

КонецПроцедуры

&НаСервере
Процедура ПослеЗаписиНаСервере(ТекущийОбъект, ПараметрыЗаписи)
	
	// СтандартныеПодсистемы.УправлениеДоступом
	Если ОбщегоНазначения.ПодсистемаСуществует("СтандартныеПодсистемы.УправлениеДоступом") Тогда
		МодульУправлениеДоступом = ОбщегоНазначения.ОбщийМодуль("УправлениеДоступом");
		МодульУправлениеДоступом.ПослеЗаписиНаСервере(ЭтотОбъект, ТекущийОбъект, ПараметрыЗаписи);
	КонецЕсли;
	// Конец СтандартныеПодсистемы.УправлениеДоступом
	
КонецПроцедуры

&НаСервере
Процедура ПриЧтенииНаСервере(ТекущийОбъект)

	// СтандартныеПодсистемы.УправлениеДоступом
	Если ОбщегоНазначения.ПодсистемаСуществует("СтандартныеПодсистемы.УправлениеДоступом") Тогда
		МодульУправлениеДоступом = ОбщегоНазначения.ОбщийМодуль("УправлениеДоступом");
		МодульУправлениеДоступом.ПриЧтенииНаСервере(ЭтотОбъект, ТекущийОбъект);
	КонецЕсли;
	// Конец СтандартныеПодсистемы.УправлениеДоступом

КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовШапкиФормы

&НаКлиенте
Процедура ДополнительноПередСворачиванием(Элемент, Строка, Отказ)
	
	Отказ = Истина;
	
КонецПроцедуры

#КонецОбласти
