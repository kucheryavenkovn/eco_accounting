﻿#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область ОбработчикиСобытий

Процедура ПриЗаписи(Отказ, Замещение)
	
	Если ЗарплатаКадры.ОтключитьБизнесЛогикуПриЗаписи(ЭтотОбъект) Тогда
		Возврат;
	КонецЕсли;
	
	СостояниеПодключения = РегистрыСведений.СостояниеОтложенногоПодключенияКСервису.СостояниеПодключенияКСервису();
	Если Не ЗначениеЗаполнено(СостояниеПодключения.Состояние) Тогда
		// Значение константы ИспользуетсяСервисКабинетСотрудника устанавливаем только если это не отложенное
		// подключение к сервису.
		ИспользуетсяСервис = Ложь;
		Если Количество() > 0 Тогда
			ИспользуетсяСервис = ЗначениеЗаполнено(ЭтотОбъект[0].АдресПриложения) И ЗначениеЗаполнено(ЭтотОбъект[0].Идентификатор);
		КонецЕсли;
		Если ИспользуетсяСервис <> Константы.ИспользуетсяСервисКабинетСотрудника.Получить() Тогда
			Константы.ИспользуетсяСервисКабинетСотрудника.Установить(ИспользуетсяСервис);
			Если ИспользуетсяСервис Тогда
				КабинетСотрудникаМенеджерСервиса.АктивироватьТестовыйТариф();
			КонецЕсли;
		КонецЕсли;
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Иначе
ВызватьИсключение НСтр("ru = 'Недопустимый вызов объекта на клиенте.'");
#КонецЕсли