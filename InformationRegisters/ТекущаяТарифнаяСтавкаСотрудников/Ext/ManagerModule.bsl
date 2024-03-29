﻿
#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область ПрограммныйИнтерфейс

#Область ДляВызоваИзДругихПодсистем

// СтандартныеПодсистемы.УправлениеДоступом

// См. УправлениеДоступомПереопределяемый.ПриЗаполненииСписковСОграничениемДоступа.
Процедура ПриЗаполненииОграниченияДоступа(Ограничение) Экспорт
	Ограничение.Текст =
	"РазрешитьЧтениеИзменение
	|ГДЕ
	|	ЗначениеРазрешено(ТекущаяОрганизация)
	|	И ЗначениеРазрешено(ФизическоеЛицо)";
КонецПроцедуры

// Конец СтандартныеПодсистемы.УправлениеДоступом

#КонецОбласти

#КонецОбласти

#Область СлужебныйПрограммныйИнтерфейс

#Область ОбменДанными

// Пересчитывает зависимые данные после загрузки сообщения обмена
//
// Параметры:
//		ЗависимыеДанные - ТаблицаЗначений:
//			* ВедущиеМетаданные - ОбъектМетаданных - Метаданные ведущих данных
//			* ЗависимыеМетаданные - ОбъектМетаданных - Метаданные текущего объекта
//			* ВедущиеДанные - Массив объектов, заполненный при загрузке сообщения обмена
//				по этим объектам требуется обновить зависимые данные
//
Процедура ОбновитьЗависимыеДанныеПослеЗагрузкиОбменаДанными(ЗависимыеДанные) Экспорт
	
	МассивСотрудников = Новый Массив;
	
	Для Каждого СтрокаТаблицы Из ЗависимыеДанные Цикл
		Для Каждого ВедущиеДанные Из СтрокаТаблицы.ВедущиеДанные Цикл
			ОбщегоНазначенияКлиентСервер.ДополнитьМассив(МассивСотрудников, ВедущиеДанные.ВыгрузитьКолонку("Сотрудник"), Истина);
		КонецЦикла;
	КонецЦикла;
	
	КадровыйУчет.ОбновитьТекущиеТарифныеСтавки(МассивСотрудников);
	
КонецПроцедуры

#КонецОбласти

#КонецОбласти

#КонецЕсли
