﻿#Область ПрограммныйИнтерфейс

#Область ЗаполнениеПоИНН

Функция ДанныеЗаполненияПоИНН(Знач ИНН) Экспорт
	
	// Заполнение по ИНН в помощнике 3-НДФЛ доступно только для юридических лиц
	ЭтоЮрЛицо = Истина;
	
	ДанныеЗаполнения = Новый Структура("ОписаниеОшибки", "");
	
	ИНН = СокрП(ИНН);
	
	РезультатПроверки = ИдентификационныеНомераНалогоплательщиков.ПроверитьСоответствиеТребованиямИНН(ИНН, ЭтоЮрЛицо);
	
	Если РезультатПроверки.СоответствуетТребованиям Тогда
		РеквизитыКонтрагента = РаботаСКонтрагентами.РеквизитыЮридическогоЛицаПоИНН(ИНН);
		
		РеквизитыКонтрагента.Вставить("ЮридическоеФизическоеЛицо", Перечисления.ЮридическоеФизическоеЛицо.ЮридическоеЛицо);
		
		Если ЗначениеЗаполнено(РеквизитыКонтрагента.ОписаниеОшибки) Тогда
			ДанныеЗаполнения.ОписаниеОшибки = РеквизитыКонтрагента.ОписаниеОшибки;
		Иначе
			
			ОКТМО = "";
			Если ЗначениеЗаполнено(РеквизитыКонтрагента.ЮридическийАдрес)
				И ТипЗнч(РеквизитыКонтрагента.ЮридическийАдрес) = Тип("Структура")
				И РеквизитыКонтрагента.ЮридическийАдрес.Свойство("КонтактнаяИнформация")
				И ЗначениеЗаполнено(РеквизитыКонтрагента.ЮридическийАдрес.КонтактнаяИнформация) Тогда
				
				ЗначениеАдресаJSON = РеквизитыКонтрагента.ЮридическийАдрес.КонтактнаяИнформация;
				СведенияОНалоговомОрганеПоАдресу = АдресныйКлассификатор.КодыАдреса(ЗначениеАдресаJSON, "Сервис1С");
				ОКТМО = СведенияОНалоговомОрганеПоАдресу.ОКТМО;
				
			КонецЕсли;
			
			ДанныеЗаполнения.Вставить("Наименование", РеквизитыКонтрагента.НаименованиеСокращенное);
			ДанныеЗаполнения.Вставить("ИНН",   РеквизитыКонтрагента.ИНН);
			ДанныеЗаполнения.Вставить("КПП",   РеквизитыКонтрагента.КПП);
			ДанныеЗаполнения.Вставить("ОКТМО", ОКТМО);
			
		КонецЕсли;
	Иначе
		ДанныеЗаполнения.ОписаниеОшибки = РезультатПроверки.ОписаниеОшибки;
	КонецЕсли;
	
	Возврат ДанныеЗаполнения;
	
КонецФункции

#КонецОбласти

#КонецОбласти