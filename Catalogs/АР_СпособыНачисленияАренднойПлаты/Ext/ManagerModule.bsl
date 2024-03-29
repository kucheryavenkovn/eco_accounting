﻿#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область СлужебныеПроцедурыИФункции

Функция ПолучитьСписокОперандов(ФормулаИндексации = Ложь) Экспорт
	
	Операнды = Новый СписокЗначений;
	Операнды.Добавить("АренднаяПлата", "Арендная плата");
	Операнды.Добавить("Показатель", "Показатель");
	Операнды.Добавить("Ставка", "Ставка");
	Операнды.Добавить("Площадь", "Площадь");
	
	Возврат Операнды;
	
КонецФункции

Функция ПроверитьФормулу(ТекстФормулы, РазрешитьПустуюФормулу = Ложь, ФормулаИндексации = Ложь) Экспорт
	
	ФормулаТекст = ТекстФормулы;
	
	МассивЗначений = Новый Массив;
	ГСЧ = Новый ГенераторСлучайныхЧисел(ТекущаяДата() - Дата(1, 1, 1));
	
	Если НЕ РазрешитьПустуюФормулу И НЕ ЗначениеЗаполнено(ФормулаТекст) Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю( НСтр("ru = 'Формула не заполнена!'") );
		Возврат Ложь;
	ИначеЕсли РазрешитьПустуюФормулу И НЕ ЗначениеЗаполнено(ФормулаТекст) Тогда
		Возврат Истина;
	КонецЕсли;
	
	Операнды = ПолучитьСписокОперандов(ФормулаИндексации);
	
	Для Каждого Операнд из Операнды Цикл
		
		Значение = ГСЧ.СлучайноеЧисло(1000, 10000000);
		МассивЗначений.Добавить(Значение);
		
		ФормулаТекст = СтрЗаменить(ФормулаТекст, "[" + Операнд.Значение + "]", "МассивЗначений[" + МассивЗначений.ВГраница() + "]");
		
	КонецЦикла;
	
	Попытка
		Результат = Вычислить(ФормулаТекст);
		Возврат Истина;
	Исключение
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю( НСтр("ru = 'В формуле обнаружены ошибки!'") );
		Возврат Ложь;
	КонецПопытки;
	
КонецФункции

Функция ВычислитьФормулу(ТекстФормулы, Параметры, ФормулаИндексации = Ложь) Экспорт
	
	ФормулаТекст = ТекстФормулы;
	
	МассивЗначений = Новый Массив;
	
	Операнды = ПолучитьСписокОперандов(ФормулаИндексации);
	
	Для Каждого Операнд из Операнды Цикл
		
		Значение = 0;
		Если НЕ Параметры.Свойство(Операнд.Значение, Значение) Тогда
			ВызватьИсключение "При расчете формулы не определен параметр " + Операнд.Значение;
		КонецЕсли;
		МассивЗначений.Добавить(Значение);
		
		ФормулаТекст = СтрЗаменить(ФормулаТекст, "[" + Операнд.Значение + "]", "МассивЗначений[" + МассивЗначений.ВГраница() + "]");
		
	КонецЦикла;
	
	Попытка
		Результат = Вычислить(ФормулаТекст);
		Возврат Результат;
	Исключение
		Возврат 0;
	КонецПопытки;
	
КонецФункции

Функция Максимум(Значение1, Значение2)
	
	Возврат Макс(Значение1, Значение2);
	
КонецФункции

Функция Минимум(Значение1, Значение2)
	
	Возврат Мин(Значение1, Значение2);
	
КонецФункции

Функция Округлить(Значение, ЧислоЗнаков)
	
	Возврат Окр(Значение, ЧислоЗнаков);
	
КонецФункции

Функция ЦелаяЧасть(Значение)
	
	Возврат Цел(Значение);
	
КонецФункции


#КонецОбласти

#КонецЕсли
