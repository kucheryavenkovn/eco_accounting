﻿#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	НастройкиУчетаФормаСписка.ПриСозданииНаСервере(ЭтотОбъект, Отказ, СтандартнаяОбработка);
	
	Элементы.ОтборОрганизация.Видимость = ПолучитьФункциональнуюОпцию(
		"ИспользоватьНесколькоОрганизацийБухгалтерскийУчет");
	
КонецПроцедуры

&НаКлиенте
Процедура ОбработкаОповещения(ИмяСобытия, Параметр, Источник)
	
	НастройкиУчетаФормаСпискаКлиент.ОбработкаОповещения(ЭтотОбъект, ИмяСобытия, Параметр, Источник);
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовТаблицыФормыСписок

&НаКлиенте
Процедура СписокПередНачаломДобавления(Элемент, Отказ, Копирование, Родитель, Группа, Параметр)
	
	НастройкиУчетаФормаСпискаКлиент.СписокПередНачаломДобавления(ЭтотОбъект, Элемент, Отказ, Копирование, Родитель, Группа);
	
КонецПроцедуры

&НаКлиенте
Процедура СписокПередУдалением(Элемент, Отказ)
	
	НастройкиУчетаФормаСпискаКлиент.СписокПередУдалением(ЭтотОбъект, Элемент, Отказ, "Запись_НастройкиУчетаСтраховыхВзносовИП");
	
КонецПроцедуры

&НаКлиенте
Процедура СписокПослеУдаления(Элемент)
	
	НастройкиУчетаФормаСпискаКлиент.СписокПослеУдаления(ЭтотОбъект, "Запись_НастройкиУчетаСтраховыхВзносовИП");
	
КонецПроцедуры

&НаСервере
Процедура СписокПередЗагрузкойПользовательскихНастроекНаСервере(Элемент, Настройки)
	
	НастройкиУчетаФормаСписка.СписокПередЗагрузкойПользовательскихНастроекНаСервере(ЭтотОбъект, Элемент, Настройки);
	
КонецПроцедуры

#КонецОбласти
