﻿#Область ПрограммныйИнтерфейс

// Определяет номер версии для указанного сервиса.
//
// Параметры:
//	Сервис - Перечисление.СервисыОбменаСБанками - Ссылка на сервис.
//	ВерсияСервиса - Строка - Возвращается номер версии сервиса в формате X.Y.
//
Процедура ОпределитьВерсиюСервиса(Сервис, ВерсияСервиса) Экспорт
	
	Если Сервис = ПредопределенноеЗначение("Перечисление.СервисыОбменаСБанками.ЗаявкиНаКредит") Тогда
		ВерсияСервиса = "1.1";
	ИначеЕсли Сервис = ПредопределенноеЗначение("Перечисление.СервисыОбменаСБанками.ФинансоваяОтчетность") Тогда
		ВерсияСервиса = "1.0";
	Иначе
		ВерсияСервиса = "";
	КонецЕсли;

КонецПроцедуры

Процедура СертификатСоответствуетОтборуПриПодбореДляОрганизации(Сертификат, ПараметрыОтбора, Результат) Экспорт
	
	// Обязательные параметры Сервис, Организация.
	Если ПараметрыОтбора.Сервис = ПредопределенноеЗначение("Перечисление.СервисыОбменаСБанками.ЗаявкиНаКредит") Тогда
		ЗаявкиНаКредитКлиентСервер.СертификатСоответствуетОтбору(Сертификат, ПараметрыОтбора, Результат);
	ИначеЕсли ПараметрыОтбора.Сервис = ПредопределенноеЗначение("Перечисление.СервисыОбменаСБанками.ФинансоваяОтчетность") Тогда
		ФинОтчетностьВБанкиКлиентСервер.СертификатСоответствуетОтбору(Сертификат, ПараметрыОтбора, Результат);
	КонецЕсли;
	
КонецПроцедуры

Процедура СертификатСоответствуетОтборуПриВыводеСтроки(Сертификат, ПараметрыОтбора, Результат) Экспорт
	
	// Обязательные параметры Сервис, Организация.
	Если ПараметрыОтбора.Сервис = ПредопределенноеЗначение("Перечисление.СервисыОбменаСБанками.ЗаявкиНаКредит") Тогда
		ЗаявкиНаКредитКлиентСервер.СертификатСоответствуетОтбору(Сертификат, ПараметрыОтбора, Результат);
	ИначеЕсли ПараметрыОтбора.Сервис = ПредопределенноеЗначение("Перечисление.СервисыОбменаСБанками.ФинансоваяОтчетность") Тогда
		ФинОтчетностьВБанкиКлиентСервер.СертификатСоответствуетОтбору(Сертификат, ПараметрыОтбора, Результат);
	КонецЕсли;
	
КонецПроцедуры

Процедура СертификатСоответствуетОтборуПриВыбореСертификата(Сертификат, ПараметрыОтбора, Результат) Экспорт
	
	// Обязательные параметры Сервис, Организация.
	Если ПараметрыОтбора.Сервис = ПредопределенноеЗначение("Перечисление.СервисыОбменаСБанками.ЗаявкиНаКредит") Тогда
		ЗаявкиНаКредитКлиентСервер.СертификатСоответствуетОтбору(Сертификат, ПараметрыОтбора, Результат);
	ИначеЕсли ПараметрыОтбора.Сервис = ПредопределенноеЗначение("Перечисление.СервисыОбменаСБанками.ФинансоваяОтчетность") Тогда
		ФинОтчетностьВБанкиКлиентСервер.СертификатСоответствуетОтбору(Сертификат, ПараметрыОтбора, Результат);
	КонецЕсли;
	
КонецПроцедуры

Процедура СертификатСоответствуетОтборуПередКриптооперацией(Сертификат, ПараметрыОтбора, Результат) Экспорт
	
	// Обязательные параметры Сервис, Организация.
	Если ПараметрыОтбора.Сервис = ПредопределенноеЗначение("Перечисление.СервисыОбменаСБанками.ЗаявкиНаКредит") Тогда
		ЗаявкиНаКредитКлиентСервер.СертификатСоответствуетОтбору(Сертификат, ПараметрыОтбора, Результат);
	ИначеЕсли ПараметрыОтбора.Сервис = ПредопределенноеЗначение("Перечисление.СервисыОбменаСБанками.ФинансоваяОтчетность") Тогда
		ФинОтчетностьВБанкиКлиентСервер.СертификатСоответствуетОтбору(Сертификат, ПараметрыОтбора, Результат);
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти
