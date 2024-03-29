﻿#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	УстановитьОтборыПриСозданииНаСервере(Параметры);
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовФормы

&НаКлиенте
Процедура ОтборПериодПриИзменении(Элемент)
	
	ОтборПериодИспользование = ЗначениеЗаполнено(ОтборПериод);
	ОтборыСписковКлиентСервер.УстановитьБыстрыйОтбор(ЭтотОбъект, "Период");
	
КонецПроцедуры

&НаКлиенте
Процедура ОтборПериодИспользованиеПриИзменении(Элемент)
	
	ОтборыСписковКлиентСервер.УстановитьБыстрыйОтбор(ЭтотОбъект, "Период");
	
КонецПроцедуры

&НаКлиенте
Процедура ОтборВалютаПриИзменении(Элемент)
	
	ОтборВалютаИспользование = ЗначениеЗаполнено(ОтборВалюта);
	ОтборыСписковКлиентСервер.УстановитьБыстрыйОтбор(ЭтотОбъект, "Валюта");
	
	УправлениеФормой(ЭтотОбъект);
	
КонецПроцедуры

&НаКлиенте
Процедура ОтборВалютаИспользованиеПриИзменении(Элемент)
	
	ОтборыСписковКлиентСервер.УстановитьБыстрыйОтбор(ЭтотОбъект, "Валюта");
	УправлениеФормой(ЭтотОбъект);
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаСервере
Процедура УстановитьОтборыПриСозданииНаСервере(Параметры)
	
	СтруктураОтбора = Неопределено;
	Если Параметры.Свойство("Отбор", СтруктураОтбора) И ТипЗнч(СтруктураОтбора) = Тип("Структура") Тогда
		СтруктураОтбора.Свойство("Валюта", ОтборВалюта);
		СтруктураОтбора.Свойство("Период", ОтборПериод);
		
		ОтборВалютаИспользование = ЗначениеЗаполнено(ОтборВалюта);
		ОтборПериодИспользование = ЗначениеЗаполнено(ОтборПериод);
		
		ЗаполнитьОтборПриОткрытииИзПараметров(Параметры.Отбор);
		
	КонецЕсли;
	
	УстановитьВосстановленныеОтборы();
	
КонецПроцедуры

&НаСервере
Процедура УстановитьВосстановленныеОтборы()
	
	// Из сохраненного отбора может прийти битая ссылка - валюта была удалена позже.
	// Проверим отбор и очистим его, если ссылка битая.
	Если ЗначениеЗаполнено(ОтборВалюта) И Не ОбщегоНазначения.СсылкаСуществует(ОтборВалюта) Тогда
		ОтборВалюта = Справочники.Валюты.ПустаяСсылка();
		ОтборВалютаИспользование = Ложь;
	КонецЕсли;
	
	ОтборыСписковКлиентСервер.УстановитьБыстрыйОтбор(ЭтотОбъект, "Период");
	ОтборыСписковКлиентСервер.УстановитьБыстрыйОтбор(ЭтотОбъект, "Валюта");
	УправлениеФормой(ЭтотОбъект);
	
КонецПроцедуры

&НаСервере
Процедура ЗаполнитьОтборПриОткрытииИзПараметров(Отбор)
	
	// Нужно переложить отборы из параметров в отдельную структуру,
	// которую потом будем использовать в ПриЗагрузкеДанныхИзНастроекНаСервере
	// Так как мы устанавливаем отбор самостоятельно, то нужно очистить те поля
	// структуры "Параметры.Отбор", для которых установлен отбор из кода.
	// Если не очистить поля - то будет вызвана ошибка пересечения отборов.
	
	ОтборыПриОткрытии = Новый Структура;
	
	Если Отбор.Свойство("Валюта")
		И ЗначениеЗаполнено(Отбор.Валюта) Тогда
		
		ОтборыПриОткрытии.Вставить("Валюта", Отбор.Валюта);
		Отбор.Удалить("Валюта");
		
	КонецЕсли;
	
	Если Отбор.Свойство("Период")
		И ЗначениеЗаполнено(Отбор.Период) Тогда
		
		ОтборыПриОткрытии.Вставить("Период", Отбор.Период);
		Отбор.Удалить("Период");
		
	КонецЕсли;
	
КонецПроцедуры

&НаКлиентеНаСервереБезКонтекста
Процедура УправлениеФормой(Форма)
	
	Элементы = Форма.Элементы;
	Элементы.Валюта.Видимость = Не Форма.ОтборВалютаИспользование;
	
КонецПроцедуры

#КонецОбласти