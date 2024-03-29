﻿
#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	// СтандартныеПодсистемы.ПодключаемыеКоманды
	ПодключаемыеКоманды.ПриСозданииНаСервере(ЭтотОбъект);
	// Конец СтандартныеПодсистемы.ПодключаемыеКоманды
	
	// СтандартныеПодсистемы.ВерсионированиеОбъектов
	ВерсионированиеОбъектов.ПриСозданииНаСервере(ЭтотОбъект);
	// Конец СтандартныеПодсистемы.ВерсионированиеОбъектов
	
	Справочники.Патенты.ОтключитьНедоступныеКомандыФормы(
		Элементы.Оплатить,
		Элементы.ФормаЗаявлениеУтратаПраваНаПатент,
		Элементы.ФормаЗаявлениеПрекращениеДеятельности);
	
	Элементы.Владелец.Видимость = Справочники.Организации.ИспользуетсяНесколькоОрганизаций();
	Элементы.НалогПоПатенту.ТолькоПросмотр = ТолькоПросмотр;
	
	ПериодПереносаСроков = РегистрыСведений.НастройкиПродленияСроковНалоговОтчетов.ПериодПереносаСроковНалоговОтчетов();
	
	ОбновитьПрименяетсяОсвобождениеОтНалога(ЭтотОбъект);
	
	НастроитьБаннерАнтикризис();
	
	ПересчитатьСуммуНалога(ЭтотОбъект);
	
	УстановитьДоступностьНалоговогоОргана(ЭтотОбъект);
	УстановитьЗаголовокСвернутогоОтображенияПостановкаНаУчетВНО();
	
	УправлениеФормой(ЭтотОбъект);
	
КонецПроцедуры

&НаКлиенте
Процедура ОбработкаОповещения(ИмяСобытия, Параметр, Источник)
	
	Если ИмяСобытия = "Запись_НастройкиПродленияСроковНалоговОтчетов" И Параметр.Организация = Объект.Владелец Тогда
		
		ОбработатьЗаписьНастройкиПродленияСроковНалоговОтчетов();
		
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Процедура ПередЗаписьюНаСервере(Отказ, ТекущийОбъект, ПараметрыЗаписи)
	
	// Данные информационной базы, влияющие на список КБК
	Если Не ТекущийОбъект.ПометкаУдаления
	   И Прав(ТекущийОбъект.КБК, 3) = "110" Тогда
	   
		КатегорияПодчинения = Сред(ТекущийОбъект.КБК, 9, 3);
		КатегорииПодчинения = Перечисления.УсловияПримененияТребованийЗаконодательства.КатегорииПодчиненияПатентовПоВидамНалогов();
		Если КатегорииПодчинения.Найти(КатегорияПодчинения) = Неопределено Тогда
			ПараметрыЗаписи.Вставить("ПоявиласьНоваяКатегорияПодчиненияПоВидуНалога", Истина);
		КонецЕсли;
		
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ПослеЗаписи(ПараметрыЗаписи)
	
	СтруктураПараметров = Новый Структура("Владелец, Ссылка");
	ЗаполнитьЗначенияСвойств(СтруктураПараметров, Объект);
	
	Если ПараметрыЗаписи.Свойство("РезультатВыполненияЗаданияКалендаряБухгалтера") Тогда
		КалендарьБухгалтераКлиент.ОжидатьЗавершениеЗаполненияВФоне(ПараметрыЗаписи.РезультатВыполненияЗаданияКалендаряБухгалтера);
	КонецЕсли;
	
	Оповестить("ИзменениеПатента", СтруктураПараметров, ЭтотОбъект);
	
КонецПроцедуры

&НаСервере
Процедура ПослеЗаписиНаСервере(ТекущийОбъект, ПараметрыЗаписи)

	// СтандартныеПодсистемы.УправлениеДоступом
	УправлениеДоступом.ПослеЗаписиНаСервере(ЭтотОбъект, ТекущийОбъект, ПараметрыЗаписи);
	// Конец СтандартныеПодсистемы.УправлениеДоступом
	
	Если Не ТекущийОбъект.ПометкаУдаления
		И ПараметрыЗаписи.Свойство("ПоявиласьНоваяКатегорияПодчиненияПоВидуНалога") Тогда
		Справочники.ВидыНалоговИПлатежейВБюджет.СоздатьПоставляемыеЭлементы();
	КонецЕсли;
	
	РезультатВыполнения = КалендарьБухгалтера.ЗапуститьЗаполнениеВФоне(УникальныйИдентификатор, ТекущийОбъект.Владелец, Ложь, Истина);
	ПараметрыЗаписи.Вставить("РезультатВыполненияЗаданияКалендаряБухгалтера", РезультатВыполнения);
	
КонецПроцедуры

&НаСервере
Процедура ОбработкаПроверкиЗаполненияНаСервере(Отказ, ПроверяемыеРеквизиты)
	
	Если НЕ ЗначениеЗаполнено(Объект.НомерПатента) Тогда
		ТекстСообщения = ОбщегоНазначенияКлиентСервер.ТекстОшибкиЗаполнения(, , НСтр("ru = 'Номер патента'"));
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(ТекстСообщения, , "Объект.НомерПатента", , Отказ);
	КонецЕсли;
		
	Если НалогПоПатенту > 0  И НЕ ЗначениеЗаполнено(Объект.КБК) Тогда
		ТекстСообщения = ОбщегоНазначенияКлиентСервер.ТекстОшибкиЗаполнения(, , НСтр("ru = 'КБК'"));
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(ТекстСообщения, , "Объект.КБК", , Отказ);
	КонецЕсли;
	
	Если Объект.СуммаВторогоПлатежа > 0 И Объект.СуммаПервогоПлатежа > 0
		И НЕ (Объект.ДатаНачала <= Объект.ДатаПервогоПлатежа И Объект.ДатаПервогоПлатежа <= Объект.ДатаОкончания) Тогда
		ТекстСообщения = ОбщегоНазначенияКлиентСервер.ТекстОшибкиЗаполнения(, "КОРРЕКТНОСТЬ", НСтр("ru = 'Дата первого платежа'"));
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(ТекстСообщения, , "Объект.ДатаПервогоПлатежа", , Отказ);
	КонецЕсли;
	
	Если Объект.ПостановкаНаУчетВНалоговомОргане =
			Перечисления.ПостановкаНаУчетВНалоговомОргане.ВДругомНалоговомОргане Тогда
		
		Если НЕ ЗначениеЗаполнено(Объект.НалоговыйОрган) Тогда
			ТекстСообщения = ОбщегоНазначенияКлиентСервер.ТекстОшибкиЗаполнения(, , НСтр("ru = 'Налоговый орган'"));
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(ТекстСообщения, , "Объект.НалоговыйОрган", , Отказ);
		ИначеЕсли НЕ ЗначениеЗаполнено(Объект.КодПоОКТМО) Тогда
			ТекстСообщения = ОбщегоНазначенияКлиентСервер.ТекстОшибкиЗаполнения(, , НСтр("ru = 'ОКТМО'"));
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(ТекстСообщения, , "Объект.КодПоОКТМО", , Отказ);
		КонецЕсли;
		
	КонецЕсли;

КонецПроцедуры

&НаСервере
Процедура ПриЧтенииНаСервере(ТекущийОбъект)

	// СтандартныеПодсистемы.УправлениеДоступом
	Если ОбщегоНазначения.ПодсистемаСуществует("СтандартныеПодсистемы.УправлениеДоступом") Тогда
		МодульУправлениеДоступом = ОбщегоНазначения.ОбщийМодуль("УправлениеДоступом");
		МодульУправлениеДоступом.ПриЧтенииНаСервере(ЭтотОбъект, ТекущийОбъект);
	КонецЕсли;
	// Конец СтандартныеПодсистемы.УправлениеДоступом
	
	// СтандартныеПодсистемы.ПодключаемыеКоманды
	ПодключаемыеКомандыКлиентСервер.ОбновитьКоманды(ЭтотОбъект, Объект);
	// Конец СтандартныеПодсистемы.ПодключаемыеКоманды
	
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
	// СтандартныеПодсистемы.ПодключаемыеКоманды
	ПодключаемыеКомандыКлиент.НачатьОбновлениеКоманд(ЭтотОбъект);
	// Конец СтандартныеПодсистемы.ПодключаемыеКоманды
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовШапкиФормы

&НаКлиенте
Процедура ДатаНачалаПриИзменении(Элемент)
	
	Если НЕ ЗначениеЗаполнено(Объект.ДатаОкончания)
		ИЛИ Объект.ДатаНачала > Объект.ДатаОкончания
		ИЛИ Год(Объект.ДатаОкончания) <> Год(Объект.ДатаНачала) Тогда
		
		Объект.ДатаОкончания = КонецГода(Объект.ДатаНачала);
		
	КонецЕсли;
	
	ОбновитьРасчетНалога();
	
КонецПроцедуры

&НаКлиенте
Процедура ДатаОкончанияПриИзменении(Элемент)
	
	Если НЕ ЗначениеЗаполнено(Объект.ДатаНачала)
		ИЛИ Объект.ДатаНачала > Объект.ДатаОкончания
		ИЛИ Год(Объект.ДатаОкончания) <> Год(Объект.ДатаНачала) Тогда
		
		Объект.ДатаНачала = НачалоГода(Объект.ДатаОкончания);
		
	КонецЕсли;
	
	ОбновитьРасчетНалога();
	
КонецПроцедуры

&НаКлиенте
Процедура ПотенциальноВозможныйГодовойДоходПриИзменении(Элемент)
	
	ОбновитьРасчетНалога();
	
КонецПроцедуры

&НаКлиенте
Процедура ТекстБаннераОбработкаНавигационнойСсылки(Элемент, НавигационнаяСсылкаФорматированнойСтроки, СтандартнаяОбработка)
	
	Если НавигационнаяСсылкаФорматированнойСтроки = "Антикризис" Тогда
		
		СтандартнаяОбработка = Ложь;
		
		Если Модифицированность Тогда
			ЗаблокироватьДанныеФормыДляРедактирования();
		КонецЕсли;
		
		НастройкиУчетаКлиент.ОткрытьНастройкиАнтикризис(Объект.Владелец);
		
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура КартинкаЗакрытьБаннерНажатие(Элемент)
	
	ВидимостьБаннераАнтикризис = Ложь;
	
	СкрытьБаннерАнтикризис(Объект.Владелец);
	
	УправлениеФормой(ЭтотОбъект);
	
КонецПроцедуры

&НаКлиенте
Процедура КодБКНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	
	ВыборКода("КБК", "КБК");
	
КонецПроцедуры

&НаКлиенте
Процедура НалогПоПатентуПриИзменении(Элемент)
	
	Объект.СуммаОсвобожденияОтНалога = СуммаОсвобожденияОтНалогаПоСуммеНалога();
	
	ПересчитатьСуммыПлатежей();
	
КонецПроцедуры

&НаКлиенте
Процедура СуммаОсвобожденияОтНалогаПриИзменении(Элемент)
	
	ПересчитатьСуммыПлатежей();
	
КонецПроцедуры

&НаКлиенте
Процедура СуммаПервогоПлатежаПриИзменении(Элемент)
	
	ПересчитатьСуммуНалога(ЭтотОбъект);
	
КонецПроцедуры

&НаКлиенте
Процедура СуммаВторогоПлатежаПриИзменении(Элемент)
	
	ПересчитатьСуммуНалога(ЭтотОбъект);
	
КонецПроцедуры

&НаКлиенте
Процедура ДатаПервогоПлатежаПриИзменении(Элемент)
	
	УстановитьПредставлениеГруппыОплата(ЭтотОбъект);
	
КонецПроцедуры

&НаКлиенте
Процедура ДатаВторогоПлатежаПриИзменении(Элемент)
	
	УстановитьПредставлениеГруппыОплата(ЭтотОбъект);
	
КонецПроцедуры

&НаКлиенте
Процедура ПостановкаНаУчетВНалоговомОрганеПриИзменении(Элемент)
	
	УстановитьДоступностьНалоговогоОргана(ЭтотОбъект);
	
	УстановитьЗаголовокСвернутогоОтображенияПостановкаНаУчетВНО();
	
КонецПроцедуры

&НаКлиенте
Процедура НалоговыйОрганПриИзменении(Элемент)
	
	НалоговыйОрганПриИзмененииНаСервере();
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура ВыбратьПериод(Команда)
	
	ПараметрыФормы = Новый Структура("НачалоПериода, КонецПериода", Объект.ДатаНачала, Объект.ДатаОкончания);
	ОписаниеОповещения = Новый ОписаниеОповещения("ВыбратьПериодЗавершение", ЭтотОбъект);
	ОткрытьФорму("ОбщаяФорма.ВыборСтандартногоПериода", ПараметрыФормы, Элементы.ВыбратьПериод, , , , ОписаниеОповещения);
	
КонецПроцедуры

&НаКлиенте
Процедура ВыбратьПериодЗавершение(РезультатВыбора, ДопПараметры) Экспорт
	
	Если РезультатВыбора = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	Объект.ДатаНачала    = РезультатВыбора.НачалоПериода;
	Объект.ДатаОкончания = РезультатВыбора.КонецПериода;
	
	ОбновитьРасчетНалога();
	
КонецПроцедуры

&НаКлиенте
Процедура Оплатить(Команда)
	
	Если Не ЗначениеЗаполнено(Объект.Ссылка) ИЛИ Модифицированность Тогда
		Если НЕ Записать() Тогда
			Возврат;
		КонецЕсли;
	КонецЕсли;
	
	ДанныеПатента = ПолучитьДанныеПатента(Объект.Ссылка);
	
	Если НЕ ПроверитьЗаполнение() Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(НСтр("ru = 'Перед оплатой необходимо заполнить данные о патенте'"));
		Возврат;
	КонецЕсли;
	
	Если ЗначениеЗаполнено(ДанныеПатента.СписокПлатежей) Тогда
		
		ОбработкаОповещения = Новый ОписаниеОповещения("ОплатитьВыборЗавершение", ЭтотОбъект);
		ПараметрыФормы = Новый Структура("ДанныеПатента", ДанныеПатента);
		
		ОткрытьФорму("Справочник.Патенты.Форма.ФормаОплаты", ПараметрыФормы, ЭтотОбъект, УникальныйИдентификатор,,,ОбработкаОповещения);
		
	Иначе
		
		ПерейтиКОплатеПатента(ДанныеПатента);
		
	КонецЕсли;
	
Конецпроцедуры

&НаКлиенте
Процедура ЗаявлениеУтратаПраваНаПатент(Команда)
	
	СоздатьЗаявление(
		ПредопределенноеЗначение("Перечисление.ВидыУведомленийОСпецрежимахНалогообложения.ЗаявлениеОбУтратеПраваНаПатент"));
	
КонецПроцедуры

&НаКлиенте
Процедура ЗаявлениеПрекращениеДеятельности(Команда)
	
	СоздатьЗаявление(
		ПредопределенноеЗначение("Перечисление.ВидыУведомленийОСпецрежимахНалогообложения.ЗаявлениеОПрекращенииДеятельностиПоПатентнойСистеме"));
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаКлиентеНаСервереБезКонтекста
Процедура УправлениеФормой(Форма)
	
	УстановитьПредставлениеЭлементовАнтикризис(Форма);
	
	УстановитьПредставлениеГруппыОплата(Форма);
	
КонецПроцедуры

&НаКлиентеНаСервереБезКонтекста
Процедура УстановитьПредставлениеГруппыОплата(Форма)
	
	ШаблонОплата = НСтр("ru = 'Оплата: %1'");
	
	Объект = Форма.Объект;
	Элементы = Форма.Элементы;
	
	ОдинПлатеж = УчетПСНКлиентСервер.УплачиваетсяОдинПлатеж(Объект.ДатаНачала, Объект.ДатаОкончания);
	
	Если ОдинПлатеж Тогда
		
		ТекстОплата = СтрШаблон(ШаблонОплата, "полная сумма не позднее "+ Формат(Объект.ДатаПервогоПлатежа,"ДЛФ=D"));
		
	Иначе
		
		Если НЕ ЗначениеЗаполнено(Объект.ДатаПервогоПлатежа)
			ИЛИ НЕ ЗначениеЗаполнено(Объект.ДатаВторогоПлатежа)
			ИЛИ НЕ ЗначениеЗаполнено(Объект.СуммаПервогоПлатежа)
			ИЛИ НЕ ЗначениеЗаполнено(Объект.СуммаВторогоПлатежа) Тогда
			ТекстОплата = СтрШаблон(ШаблонОплата," не указана");
			
		Иначе
			ТекстОплата = СтрШаблон(ШаблонОплата, Строка(Объект.СуммаПервогоПлатежа) + " руб. не позднее "+ Формат(Объект.ДатаПервогоПлатежа,"ДЛФ=D")
				+ ", " + Строка(Объект.СуммаВторогоПлатежа)+ " руб. не позднее "+ Формат(Объект.ДатаВторогоПлатежа,"ДЛФ=D"));
			
		КонецЕсли;
		
	КонецЕсли;
	
	Элементы.ГруппаОплатаПоЧастям.Видимость = Не ОдинПлатеж;
	Элементы.ГруппаПолныйПлатеж.Видимость   = ОдинПлатеж;
	
	УстановитьЗаголовокГруппы(Форма, "ГруппаОплата", ТекстОплата);
	
КонецПроцедуры

&НаКлиентеНаСервереБезКонтекста
Процедура УстановитьПредставлениеЭлементовАнтикризис(Форма)
	
	Элементы = Форма.Элементы;
	Объект   = форма.Объект;
	
	// Баннер
	ВозможноОсвобождениеОтНалога = УчетПСНКлиентСервер.ВозможноОсвобождениеОтНалога(Объект.ДатаНачала, Объект.ДатаОкончания);
	
	Элементы.ТекстБаннера.Видимость = ВозможноОсвобождениеОтНалога И Форма.ВидимостьБаннераАнтикризис;
	Элементы.КартинкаЗакрытьБаннер.Видимость = ВозможноОсвобождениеОтНалога И Форма.ВидимостьБаннераАнтикризис;
	
	// Освобождение от налога
	Элементы.СуммаОсвобожденияОтНалога.Видимость = Форма.ПрименяетсяОсвобождениеОтНалога;
	Элементы.СуммаКУплате.Видимость = Форма.ПрименяетсяОсвобождениеОтНалога;
	
	Элементы.СуммаОсвобожденияОтНалогаРасширеннаяПодсказка.Заголовок
		= УчетПСНКлиентСервер.ТекстПодсказкиОсвобождениеОтНалога(
			Форма.ПрименяетсяОсвобождениеОтНалога,
			Объект.СуммаОсвобожденияОтНалога,
			Объект.ПотенциальноВозможныйГодовойДоход,
			Объект.ДатаНачала,
			Объект.ДатаОкончания);
	
	Элементы.ДатаВторогоПлатежа.ТолькоПросмотр
		= (Объект.ДатаОкончания < Форма.ПериодПереносаСроков.Начало
			Или Объект.ДатаОкончания > Форма.ПериодПереносаСроков.Окончание);
	
КонецПроцедуры

&НаСервере
Процедура НалоговыйОрганПриИзмененииНаСервере()
	
	Если ЗначениеЗаполнено(Объект.НалоговыйОрган) Тогда 
		Объект.КодПоОКТМО = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Объект.НалоговыйОрган,"КодПоОКТМО");
	КонецЕсли;
	
	УстановитьЗаголовокСвернутогоОтображенияПостановкаНаУчетВНО();
	
КонецПроцедуры

&НаСервере
Процедура УстановитьЗаголовокСвернутогоОтображенияПостановкаНаУчетВНО()
	
	Если Объект.ПостановкаНаУчетВНалоговомОргане = Перечисления.ПостановкаНаУчетВНалоговомОргане.ПоМестуНахожденияОрганизации Тогда
		
		ТекстПостановкаНаУчетВНалоговомОргане = НСтр("ru = 'Налоговая инспекция: по месту жительства'");
		
	ИначеЕсли Объект.ПостановкаНаУчетВНалоговомОргане = Перечисления.ПостановкаНаУчетВНалоговомОргане.ВДругомНалоговомОргане Тогда
		
		Если ЗначениеЗаполнено(Объект.НалоговыйОрган) Тогда
			Шаблон = НСтр("ru = 'Налоговая инспекция: %1 %2'");
			РеквизитыИФНС = ОбщегоНазначения.ЗначенияРеквизитовОбъекта(Объект.НалоговыйОрган, "Код, Наименование");
			ТекстПостановкаНаУчетВНалоговомОргане = СтрШаблон(Шаблон, РеквизитыИФНС.Код, РеквизитыИФНС.Наименование);
			
		Иначе
			ТекстПостановкаНаУчетВНалоговомОргане = НСтр("ru='Налоговая инспекия: <...>'");
			
		КонецЕсли;
		
	КонецЕсли;
	
	УстановитьЗаголовокГруппы(ЭтотОбъект, "ГруппаПостановкаНаУчетВНалоговомОргане", ТекстПостановкаНаУчетВНалоговомОргане);
	
КонецПроцедуры

&НаКлиентеНаСервереБезКонтекста
Процедура УстановитьЗаголовокГруппы(ЭтотОбъект, НазваниеГруппы, ЗаголовокТекст)
	
	ЭтотОбъект.Элементы[НазваниеГруппы].ЗаголовокСвернутогоОтображения = ЗаголовокТекст;
	
КонецПроцедуры

&НаКлиентеНаСервереБезКонтекста
Процедура УстановитьДоступностьНалоговогоОргана(Форма)
	
	Объект = Форма.Объект;
	ПостановкаНаУчетВНО = Объект.ПостановкаНаУчетВНалоговомОргане;
	
	ПостановкаВДругомНО = ПостановкаНаУчетВНО = ПредопределенноеЗначение("Перечисление.ПостановкаНаУчетВНалоговомОргане.ВДругомНалоговомОргане");
	
	Форма.Элементы.ГруппаРеквизиты.Доступность = ПостановкаВДругомНО;
	Если НЕ ПостановкаВДругомНО тогда
		Объект.КодПоОКТМО = "";
		Объект.НалоговыйОрган = Неопределено;
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ВыборКода(ИмяКода, НазваниеМакета)
	
	ПараметрыФормы = Новый Структура;
	ПараметрыФормы.Вставить("ТипОбъекта",		"Справочник");
	ПараметрыФормы.Вставить("НазваниеОбъекта",	"Патенты");
	ПараметрыФормы.Вставить("НазваниеМакета",	НазваниеМакета);
	ПараметрыФормы.Вставить("ТекущийПериод",	Объект.ДатаНачала);
	ПараметрыФормы.Вставить("ТекущийКод",		Объект[ИмяКода]);
	
	ДополнительныеПараметры = Новый Структура;
	ДополнительныеПараметры.Вставить("ИмяКода", ИмяКода);
	
	ОповещениеОЗакрытии = Новый ОписаниеОповещения("ВыборКодаЗавершение", ЭтотОбъект, ДополнительныеПараметры);
	
	ОткрытьФорму("ОбщаяФорма.ФормаВыбораКода", ПараметрыФормы,,,,,ОповещениеОЗакрытии);
	
КонецПроцедуры

&НаКлиенте
Процедура ВыборКодаЗавершение(РезультатЗакрытия, ДополнительныеПараметры) Экспорт
	
	ИмяКода = ДополнительныеПараметры.ИмяКода;	
	
	ВыбранныйКод = РезультатЗакрытия;	
	
	Если ВыбранныйКод <> Неопределено Тогда
		
		Модифицированность = Истина;
		
		Объект[ИмяКода] = ВыбранныйКод;
		
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ОбработатьЗаписьНастройкиПродленияСроковНалоговОтчетов()
	
	Если Модифицированность Тогда
		РазблокироватьДанныеФормыДляРедактирования();
		ОбновитьРасчетНалога(Ложь);
	Иначе
		Прочитать();
		ПересчитатьСуммуНалога(ЭтотОбъект);
		ОбновитьПрименяетсяОсвобождениеОтНалога(ЭтотОбъект);
		УправлениеФормой(ЭтотОбъект);
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ОбновитьРасчетНалога(ПересчитатьСуммуНалога = Истина)
	
	ОбновитьПрименяетсяОсвобождениеОтНалога(ЭтотОбъект);
	
	Если ПересчитатьСуммуНалога Тогда
		НалогПоПатенту = УчетПСНКлиентСервер.НалогПоПатенту(
			Объект.ПотенциальноВозможныйГодовойДоход,
			Объект.ДатаНачала,
			Объект.ДатаОкончания);
		Объект.СуммаОсвобожденияОтНалога = СуммаОсвобожденияОтНалога();
	Иначе
		// Налог по патенту мог быть скорректирован пользователем. Например, в случае применения пониженной ставки налога.
		// Поэтому сумму освобождения от налога нужно рассчитать на основании суммы налога пропорционально длительности
		// периода освобождения. Иначе есть риск завысить освобождение и, следовательно, занизить суммы налоговых платежей.
		Объект.СуммаОсвобожденияОтНалога = СуммаОсвобожденияОтНалогаПоСуммеНалога();
	КонецЕсли;
	
	ПересчитатьСуммыПлатежей();
	
КонецПроцедуры

&НаКлиенте
Процедура ПересчитатьСуммыПлатежей()
	
	СуммаКУплате = НалогПоПатенту - Объект.СуммаОсвобожденияОтНалога;
	
	РасчетПлатежей = УчетПСНКлиентСервер.РасчетПлатежейПоПатенту(СуммаКУплате, Объект.ДатаНачала, Объект.ДатаОкончания);
	ЗаполнитьЗначенияСвойств(Объект, РасчетПлатежей);
	
	УправлениеФормой(ЭтотОбъект);
	
КонецПроцедуры

&НаКлиентеНаСервереБезКонтекста
Функция ПересчитатьСуммуНалога(Форма)
	
	Объект = Форма.Объект;
	
	Форма.СуммаКУплате   = Объект.СуммаПервогоПлатежа + Объект.СуммаВторогоПлатежа;
	Форма.НалогПоПатенту = Форма.СуммаКУплате + Объект.СуммаОсвобожденияОтНалога;
	
	УстановитьПредставлениеГруппыОплата(Форма);
	
КонецФункции

&НаКлиенте
Функция СуммаОсвобожденияОтНалога()
	
	Если ПрименяетсяОсвобождениеОтНалога Тогда
		
		Возврат УчетПСНКлиентСервер.СуммаОсвобожденияОтНалога(
			Объект.ПотенциальноВозможныйГодовойДоход,
			Объект.ДатаНачала,
			Объект.ДатаОкончания);
		
	Иначе
		
		Возврат 0;
		
	КонецЕсли;
	
КонецФункции

&НаКлиенте
Функция СуммаОсвобожденияОтНалогаПоСуммеНалога()
	
	Если ПрименяетсяОсвобождениеОтНалога Тогда
		
		Возврат УчетПСНКлиентСервер.СуммаОсвобожденияОтНалогаПоСуммеНалога(
			НалогПоПатенту,
			Объект.ДатаНачала,
			Объект.ДатаОкончания);
		
	Иначе
		
		Возврат 0;
		
	КонецЕсли;
	
КонецФункции

#Область Антикризис

&НаКлиентеНаСервереБезКонтекста
Процедура ОбновитьПрименяетсяОсвобождениеОтНалога(Форма)
	
	Объект = Форма.Объект;
	
	Форма.ПрименяетсяОсвобождениеОтНалога = УчетПСНКлиентСервер.ПрименяетсяОсвобождениеОтНалога(
		Объект.Владелец,
		Объект.ДатаНачала,
		Объект.ДатаОкончания);
	
КонецПроцедуры

&НаСервере
Процедура НастроитьБаннерАнтикризис()
	
	ВидимостьБаннераАнтикризис = ОбщегоНазначения.ХранилищеОбщихНастроекЗагрузить(
		"ВидимостьБаннераАнтикризисНастройкиНалоговИОтчетов",
		КлючНастройкиБаннераАнтикризис(Объект.Владелец),
		Истина);
	
	ТекстБаннера = НалоговыйУчет.ТекстБаннераНастройкиНалоговИОтчетов(Объект.Владелец,
		ЗадачиБухгалтераКлиентСервер.КодЗадачиПатент());
	
КонецПроцедуры 

&НаСервереБезКонтекста
Функция КлючНастройкиБаннераАнтикризис(Знач Организация)
	
	КодЗадачи = ЗадачиБухгалтераКлиентСервер.КодЗадачиПатент();
	
	Возврат НалоговыйУчет.КлючНастройкиБаннераАнтикризис(Организация, КодЗадачи);
	
КонецФункции

&НаСервереБезКонтекста
Процедура СкрытьБаннерАнтикризис(Знач Организация)
	
	НалоговыйУчет.СохранитьНастройкуБаннераАнтикризис(Организация,
		ЗадачиБухгалтераКлиентСервер.КодЗадачиПатент(),
		Ложь);
	
КонецПроцедуры

#КонецОбласти

&НаКлиенте
Процедура ОплатитьВыборЗавершение(ДанныеПатента, ДополнительныеПараметры) Экспорт
	
	Если ДанныеПатента = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	ПерейтиКОплатеПатента(ДанныеПатента);
	
КонецПроцедуры

&НаКлиенте
Процедура ПерейтиКОплатеПатента(ДанныеПатента)
	
	ОписаниеПараметровОплаты = ПолучитьОписаниеОплатыПатента(ДанныеПатента);
	
	ВыполнениеЗадачБухгалтераКлиент.ВыполнитьДействие(ОписаниеПараметровОплаты);
	
КонецПроцедуры

&НаСервереБезКонтекста
Функция ПолучитьДанныеПатента(Патент)
	Возврат Справочники.Патенты.ДанныеПатентаДляОплаты(Патент);
КонецФункции

&НаСервереБезКонтекста
Функция ПолучитьОписаниеОплатыПатента(ДанныеПатента)
	
	Возврат Справочники.Патенты.ОписаниеОплатыПатента(ДанныеПатента);
	
КонецФункции

&НаКлиенте
Процедура СоздатьЗаявление(ВидЗаявления)
	
	ПараметрыФормы = Новый Структура();
	ПараметрыФормы.Вставить("Организация", Объект.Владелец);
	
	Если ВидЗаявления = ПредопределенноеЗначение(
		"Перечисление.ВидыУведомленийОСпецрежимахНалогообложения.ЗаявлениеОПрекращенииДеятельностиПоПатентнойСистеме") Тогда
		
		ПараметрыЗаполнения = Новый Структура;
		ПараметрыЗаполнения.Вставить("Патент", Объект.Ссылка);
		ПараметрыФормы.Вставить("ПараметрыЗаполнения", ПараметрыЗаполнения);
		
	КонецЕсли;
	
	ПараметрыФормы.Вставить("СформироватьФормуОтчетаАвтоматически", Истина);

	УчетПСНКлиент.ОткрытьФормуЗаявления(ВидЗаявления, ПараметрыФормы, ЭтотОбъект);
	
КонецПроцедуры

// СтандартныеПодсистемы.ПодключаемыеКоманды
&НаКлиенте
Процедура Подключаемый_ВыполнитьКоманду(Команда)
	ПодключаемыеКомандыКлиент.ВыполнитьКоманду(ЭтотОбъект, Команда, Объект);
КонецПроцедуры

&НаСервере
Процедура Подключаемый_ВыполнитьКомандуНаСервере(Контекст, Результат) Экспорт
	ПодключаемыеКоманды.ВыполнитьКоманду(ЭтотОбъект, Контекст, Объект, Результат);
КонецПроцедуры

&НаКлиенте
Процедура Подключаемый_ОбновитьКоманды()
	ПодключаемыеКомандыКлиентСервер.ОбновитьКоманды(ЭтотОбъект, Объект);
КонецПроцедуры

// Конец СтандартныеПодсистемы.ПодключаемыеКоманды

#КонецОбласти
