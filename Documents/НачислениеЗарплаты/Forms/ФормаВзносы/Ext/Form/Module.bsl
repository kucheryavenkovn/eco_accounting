﻿
#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	Если ПустаяСтрока(Параметры.АдресПараметровВХранилище) Тогда
		Отказ = Истина;
		Возврат;
	КонецЕсли;
	
	// "Распаковываем" параметры
	Если Параметры.Свойство("ТребуетсяПересчет") Тогда
		ТребуетсяПересчет = Параметры.ТребуетсяПересчет;
	КонецЕсли;
	
	ПараметрыРасчета = ПолучитьИзВременногоХранилища(Параметры.АдресПараметровВХранилище);
	ЗаполнитьЗначенияСвойств(ЭтотОбъект, ПараметрыРасчета, "Ссылка, Организация, МесяцНачисления, Сотрудник, ФизическоеЛицо, РассчитыватьДокументыПриРедактировании");
	ЗначениеВДанныеФормы(ПараметрыРасчета.Объект, Объект);
	Объект.Начисления.Загрузить(ПараметрыРасчета.Начисления);
	
	ФизическиеЛица = ОбщегоНазначенияКлиентСервер.ЗначениеВМассиве(ФизическоеЛицо);
	СписокКадровыхДанных = "ФамилияИО";
	КадровыеДанныеФизЛиц = КадровыйУчет.КадровыеДанныеФизическихЛиц(Истина, ФизическиеЛица, СписокКадровыхДанных, МесяцНачисления);
	
	ПредставлениеСотрудника = КадровыеДанныеФизЛиц[0].ФамилияИО;
	Заголовок = СтрШаблон(НСтр("ru='Страховые взносы (%1)'"), ПредставлениеСотрудника);
	
	ЗаполнитьТаблицуВзносов(ПараметрыРасчета.МассивСтрок);
	ПолучитьИтоги(ЭтотОбъект);
	
	УстановитьСвойстваЭлементовФормы();
	
	РассчитыватьДокументыПриРедактировании = Константы.РассчитыватьДокументыПриРедактировании.Получить();
	Если НЕ РассчитыватьДокументыПриРедактировании Тогда
		ОбщегоНазначенияКлиентСервер.УстановитьСвойствоЭлементаФормы(
			Элементы,
			"ГруппаПересчитать",
			"Видимость",
			ТребуетсяПересчет И НЕ КорректироватьРасчет);
	КонецЕсли;
	
	Элементы.ГруппаКнопокПросмотр.Видимость       = ТолькоПросмотр;
	Элементы.ГруппаКнопокРедактирование.Видимость = НЕ ТолькоПросмотр;
	Если ТолькоПросмотр Тогда
		Элементы.ФормаЗакрыть.КнопкаПоУмолчанию = Истина;
	Иначе
		Элементы.ФормаОК.КнопкаПоУмолчанию      = Истина;
	КонецЕсли;
	
	ЗарплатаКадрыКлиентСервер.ЗаполнитьМесяцПоДатеВТабличнойЧасти(Взносы, "ДатаПолученияДохода", "ДатаПолученияДоходаСтрокой");
	
	УстановитьФункциональныеОпцииФормы();
	
	УправлениеПризнакомКорректировки();
	
КонецПроцедуры

&НаКлиенте
Процедура ПередЗакрытием(Отказ, ЗавершениеРаботы, ТекстПредупреждения, СтандартнаяОбработка)
	
	Если ЗавершениеРаботы И Модифицированность Тогда
		Отказ = Истина;
		Возврат;
	КонецЕсли;
	
	Если Модифицированность Тогда
		
		Отказ = Истина;
		ВопросСохранитьИзменения(Истина);
		
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовФормы

&НаКлиенте
Процедура КорректироватьРасчетПриИзменении(Элемент)
	
	УправлениеПризнакомКорректировки();
	Если НЕ КорректироватьРасчет Тогда
		Если РассчитыватьДокументыПриРедактировании Тогда
			ПересчитатьДокументНаКлиенте();
		Иначе
			ТребуетсяПересчет = Истина;
			УстановитьВидимостьГруппыПересчет();
		КонецЕсли;
	Иначе
		Если НЕ РассчитыватьДокументыПриРедактировании Тогда
			ТребуетсяПересчет = Ложь;
			УстановитьВидимостьГруппыПересчет();
		КонецЕсли;
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовШапкиФормы

#КонецОбласти

#Область ОбработчикиСобытийТаблицыФормыВзносы

&НаКлиенте
Процедура ВзносыПриНачалеРедактирования(Элемент, НоваяСтрока, Копирование)
	
	Если НЕ Копирование И НоваяСтрока Тогда
		ДанныеТекущейСтроки = Элементы.Взносы.ТекущиеДанные;
		ДанныеТекущейСтроки.ФизическоеЛицо = ФизическоеЛицо;
		ДанныеТекущейСтроки.ДатаПолученияДохода = КонецМесяца(МесяцНачисления);
		ЗарплатаКадрыКлиентСервер.ЗаполнитьМесяцПоДате(ДанныеТекущейСтроки, "ДатаПолученияДохода", "ДатаПолученияДоходаСтрокой");
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ВзносыПриОкончанииРедактирования(Элемент, НоваяСтрока, ОтменаРедактирования)
	
	ПолучитьИтоги(ЭтотОбъект);
	
КонецПроцедуры

&НаКлиенте
Процедура ВзносыПослеУдаления(Элемент)
	
	ПолучитьИтоги(ЭтотОбъект);
	
КонецПроцедуры

&НаКлиенте
Процедура ВзносыДатаПолученияДоходаСтрокойПриИзменении(Элемент)
	
	ДанныеТекущейСтроки = Элементы.Взносы.ТекущиеДанные;
	УчетСтраховыхВзносовКлиент.ВзносыДатаПолученияДоходаСтрокойПриИзменении(ДанныеТекущейСтроки, "ДатаПолученияДохода", "ДатаПолученияДоходаСтрокой", Модифицированность);
	
КонецПроцедуры

&НаКлиенте
Процедура ВзносыДатаПолученияДоходаСтрокойНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	
	ДанныеТекущейСтроки = Элементы.Взносы.ТекущиеДанные;
	УчетСтраховыхВзносовКлиент.ВзносыДатаПолученияДоходаСтрокойНачалоВыбора(ЭтотОбъект, ДанныеТекущейСтроки, "ДатаПолученияДохода", "ДатаПолученияДоходаСтрокой");
	
КонецПроцедуры

&НаКлиенте
Процедура ВзносыДатаПолученияДоходаСтрокойРегулирование(Элемент, Направление, СтандартнаяОбработка)
	
	УчетСтраховыхВзносовКлиент.ВзносыДатаПолученияДоходаСтрокойРегулирование(
		Элементы.Взносы.ТекущиеДанные, 
		"ДатаПолученияДохода", 
		"ДатаПолученияДоходаСтрокой",
		Направление, 
		Модифицированность);
	
КонецПроцедуры

&НаКлиенте
Процедура ВзносыДатаПолученияДоходаСтрокойАвтоПодбор(Элемент, Текст, ДанныеВыбора, ПараметрыПолученияДанных, Ожидание, СтандартнаяОбработка)
	
	ЗарплатаКадрыКлиент.ВводМесяцаАвтоПодборТекста(Текст, ДанныеВыбора, СтандартнаяОбработка);
	
КонецПроцедуры

&НаКлиенте
Процедура ВзносыДатаПолученияДоходаСтрокойОкончаниеВводаТекста(Элемент, Текст, ДанныеВыбора, ПараметрыПолученияДанных, СтандартнаяОбработка)
	
	ЗарплатаКадрыКлиент.ВводМесяцаАвтоПодборТекста(Текст, ДанныеВыбора, СтандартнаяОбработка);
	
КонецПроцедуры

&НаКлиенте
Процедура ВзносыДатаПолученияДоходаСтрокойОчистка(Элемент, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура ОК(Команда)
	
	Если ПроверитьЗаполнениеРеквизитов() Тогда
		ПеренестиИзмененияВОбъектФормыВладельца();
		Закрыть(Новый Структура("Сотрудник, ТребуетсяПересчет", Сотрудник, ТребуетсяПересчет));
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура КарточкаУчетаПоСтраховымВзносам(Команда)
	
	Если НЕ ПроверитьЗаполнениеРеквизитов() Тогда
		Возврат;
	КонецЕсли;
	
	Если Модифицированность Тогда
		ВопросСохранитьИзменения(Ложь);
	Иначе
		СформироватьОтчет();
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ПересчитатьДокумент(Команда)
	
	ПересчитатьДокументНаКлиенте();
	ТребуетсяПересчет = Ложь;
	УстановитьВидимостьГруппыПересчет();
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаСервере
Процедура УстановитьСвойстваЭлементовФормы()
	
	УчетСтраховыхВзносов.УстановитьВидимостьКолонокТаблицыСтраховыхВзносов(ЭтотОбъект, МесяцНачисления);
	
	Если ЗарплатаКадрыПереопределяемый.ПлательщикТолькоЕНВД(Организация, МесяцНачисления) Тогда
		// если применяется только ЕНВД
		
		ОбщегоНазначенияКлиентСервер.УстановитьСвойствоЭлементаФормы(
			Элементы,
			"ВзносыПФРДоПредельнойВеличины",
			"Видимость",
			Взносы.Итог("ПФРДоПредельнойВеличины") <> 0);
			
		ОбщегоНазначенияКлиентСервер.УстановитьСвойствоЭлементаФормы(
			Элементы,
			"ВзносыПФРСПревышения",
			"Видимость",
			Взносы.Итог("ПФРСПревышения") <> 0);
			
		ОбщегоНазначенияКлиентСервер.УстановитьСвойствоЭлементаФормы(
			Элементы,
			"ВзносыПФРПоСуммарномуТарифу",
			"Видимость",
			Взносы.Итог("ПФРПоСуммарномуТарифу") <> 0);
			
		ОбщегоНазначенияКлиентСервер.УстановитьСвойствоЭлементаФормы(
			Элементы,
			"ВзносыПФРНакопительная",
			"Видимость",
			Взносы.Итог("ПФРНакопительная") <> 0);
			
		ОбщегоНазначенияКлиентСервер.УстановитьСвойствоЭлементаФормы(
			Элементы,
			"ВзносыПФРСтраховая",
			"Видимость",
			Взносы.Итог("ПФРСтраховая") <> 0);
			
		ОбщегоНазначенияКлиентСервер.УстановитьСвойствоЭлементаФормы(
			Элементы,
			"ВзносыФСС",
			"Видимость",
			Взносы.Итог("ФСС") <> 0);
			
		ОбщегоНазначенияКлиентСервер.УстановитьСвойствоЭлементаФормы(
			Элементы,
			"ВзносыФФОМС",
			"Видимость",
			Взносы.Итог("ФФОМС") <> 0);
			
		ОбщегоНазначенияКлиентСервер.УстановитьСвойствоЭлементаФормы(
			Элементы,
			"ВзносыТФОМС",
			"Видимость",
			Взносы.Итог("ТФОМС") <> 0);
			
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Процедура УправлениеПризнакомКорректировки()
	
	ОбщегоНазначенияКлиентСервер.УстановитьСвойствоЭлементаФормы(
		Элементы,
		"Взносы",
		"ТолькоПросмотр",
		Не КорректироватьРасчет);
	
КонецПроцедуры

&НаСервере
Процедура ЗаполнитьТаблицуВзносов(МассивСтрок)
	
	Взносы.Очистить();
	Для Каждого СтрокаМассива ИЗ МассивСтрок Цикл
		
		ЗаполнитьЗначенияСвойств(Взносы.Добавить(), СтрокаМассива);
		Если СтрокаМассива.ФиксРасчет Тогда
			КорректироватьРасчет = Истина;
		КонецЕсли;
		
	КонецЦикла;
	
КонецПроцедуры

&НаКлиентеНаСервереБезКонтекста
Процедура ПолучитьИтоги(Форма)
	
	ПоляВзносов = СтрРазделить(УчетСтраховыхВзносовКлиентСервер.РассчитываемыеВзносы(), ",");
	
	Для Каждого ИмяПоля ИЗ ПоляВзносов Цикл
		Форма["Итого" + ИмяПоля] = Форма.Взносы.Итог(ИмяПоля);
	КонецЦикла;
	
КонецПроцедуры

&НаСервере
Процедура ОбновитьВзносыСотрудника()
	
	Если КорректироватьРасчет Тогда
		// Не пересчитываем
		Возврат;
	КонецЕсли;
	
	СтруктураПоиска = Новый Структура("ФизическоеЛицо", ФизическоеЛицо);
	
	МассивСтрок = Объект.Взносы.НайтиСтроки(СтруктураПоиска);
	Для Каждого СтрокаМассива ИЗ МассивСтрок Цикл
		СтрокаМассива.ФиксРасчет = Ложь;
	КонецЦикла;
	Документы.НачислениеЗарплаты.ПересчитатьВзносы(Объект, ФизическоеЛицо);
	МассивСтрок = Объект.Взносы.НайтиСтроки(СтруктураПоиска);
	ЗаполнитьТаблицуВзносов(МассивСтрок);
	ЗарплатаКадрыКлиентСервер.ЗаполнитьМесяцПоДатеВТабличнойЧасти(Взносы, "ДатаПолученияДохода", "ДатаПолученияДоходаСтрокой");
	ПолучитьИтоги(ЭтотОбъект);
	
КонецПроцедуры

&НаКлиенте
Процедура ПересчитатьДокументНаКлиенте()
	
	ОбновитьВзносыСотрудника();
	ОбщегоНазначенияКлиентСервер.УстановитьСвойствоЭлементаФормы(
		Элементы,
		"Взносы",
		"Доступность",
		Истина);
	
КонецПроцедуры

&НаКлиенте
Процедура УстановитьВидимостьГруппыПересчет()
	
	Если РассчитыватьДокументыПриРедактировании Тогда
		Возврат;
	КонецЕсли;
	
	ОбщегоНазначенияКлиентСервер.УстановитьСвойствоЭлементаФормы(
		Элементы,
		"ГруппаПересчитать",
		"Видимость",
		ТребуетсяПересчет);
	
КонецПроцедуры

&НаКлиенте
Процедура ВопросСохранитьИзмененияЗавершение(Результат, ДополнительныеПараметры) Экспорт

	Если Результат = КодВозвратаДиалога.Да Тогда
		Если ПроверитьЗаполнениеРеквизитов() Тогда
			ПеренестиИзмененияВОбъектФормыВладельца();
			Если ДополнительныеПараметры.Закрытие Тогда
				Закрыть(Новый Структура("Сотрудник, ТребуетсяПересчет", Сотрудник, ТребуетсяПересчет));
			КонецЕсли;
		КонецЕсли;
	ИначеЕсли Результат = КодВозвратаДиалога.Нет Тогда
		Если ДополнительныеПараметры.Закрытие Тогда
			Модифицированность = Ложь;
			Закрыть();
		КонецЕсли;
	КонецЕсли;
	
	Если НЕ ДополнительныеПараметры.Закрытие
		И НЕ Результат = КодВозвратаДиалога.Отмена Тогда
		СформироватьОтчет();
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Функция ПроверитьЗаполнениеРеквизитов()
	
	ПроверкаПройдена = Истина;
	Для Каждого СтрокаТаблицы ИЗ Взносы Цикл
		Если НЕ ЗначениеЗаполнено(СтрокаТаблицы.ДатаПолученияДоходаСтрокой) Тогда
			ИндексСтроки = Взносы.Индекс(СтрокаТаблицы);
			ТекстСообщения = ОбщегоНазначенияКлиентСервер.ТекстОшибкиЗаполнения("Колонка",
				"Заполнение",
				"ДатаПолученияДоходаСтрокой",
				ИндексСтроки + 1,
				"Взносы");
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(ТекстСообщения,, "Взносы[" + ИндексСтроки + "].ДатаПолученияДоходаСтрокой");
			ПроверкаПройдена = Ложь;
		КонецЕсли;
	КонецЦикла;
	
	Возврат ПроверкаПройдена;
	
КонецФункции

&НаКлиенте
Процедура СформироватьОтчет()
	
	КарточкаУчетаПоСтраховымВзносам = ВладелецФормы.КарточкаУчетаПоСтраховымВзносамНаСервере(ФизическоеЛицо);
	
	УправлениеПечатьюКлиент.ВыполнитьКомандуПечати("Отчет.КарточкаУчетаПоСтраховымВзносам", "КарточкаУчетаПоСтраховымВзносамПодробнее", 
			КарточкаУчетаПоСтраховымВзносам, ЭтотОбъект);
	
КонецПроцедуры

&НаКлиенте
Процедура ВопросСохранитьИзменения(Закрытие)
	
	ТекстВопроса = НСтр("ru='Данные были изменены. Сохранить изменения?'");
	Оповещение = Новый ОписаниеОповещения("ВопросСохранитьИзмененияЗавершение", ЭтотОбъект, Новый Структура("Закрытие", Закрытие));
	ПоказатьВопрос(Оповещение, ТекстВопроса, РежимДиалогаВопрос.ДаНетОтмена);
	
КонецПроцедуры

&НаСервере
Процедура УстановитьФункциональныеОпцииФормы()
	
	ПараметрыФО = Новый Структура;
	ПараметрыФО.Вставить("Организация", Объект.Организация);
	ПараметрыФО.Вставить("Период", НачалоДня(Объект.МесяцНачисления));
	УстановитьПараметрыФункциональныхОпцийФормы(ПараметрыФО);
	
КонецПроцедуры

#Область ПереносВОсновнуюФорму

&НаКлиенте
Процедура ПеренестиИзмененияВОбъектФормыВладельца()
	
	Если Модифицированность Тогда
		Оповестить("ИзмененыРезультатыРасчетаВзносы", ПоместитьИзмененныеДанныеВоВременноеХранилище(), ЭтотОбъект);
		Модифицированность = Ложь;
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Функция ПоместитьИзмененныеДанныеВоВременноеХранилище()
	
	ВозвращаемыеСведения = Новый Структура;
	
	ДанныеВзносов = Взносы.Выгрузить();
	ДанныеВзносов.ЗаполнитьЗначения(КорректироватьРасчет, "ФиксРасчет");
	ДанныеВзносов.ЗаполнитьЗначения(ФизическоеЛицо,       "ФизическоеЛицо");
	
	ВозвращаемыеСведения.Вставить("Взносы",            ДанныеВзносов);
	ВозвращаемыеСведения.Вставить("ФизическоеЛицо",    ФизическоеЛицо);
	ВозвращаемыеСведения.Вставить("ТребуетсяПересчет", ТребуетсяПересчет);
	
	Возврат ПоместитьВоВременноеХранилище(ВозвращаемыеСведения, Новый УникальныйИдентификатор);
	
КонецФункции

#КонецОбласти

#КонецОбласти
