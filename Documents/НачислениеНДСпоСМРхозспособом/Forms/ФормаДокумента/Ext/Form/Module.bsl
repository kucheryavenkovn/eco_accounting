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
	
	Если Параметры.Ключ.Пустая() Тогда // проверить объект на то, что он еще не внесен в ИБ
		
		ЗаполнитьРеквизитыИзПараметровФормы(ЭтаФорма);
		
		Если Объект.Дата < '20051231' Тогда
			Объект.Дата = НачалоДня('20051231235959');
		Иначе
			Объект.Дата = НачалоДня(КонецКвартала(Объект.Дата));
		КонецЕсли;
		
		УстановитьСостояниеДокумента();
		
	КонецЕсли;
	
	ТекущаяДатаДокумента = Объект.Дата;
	ТекущаяОрганизация   = Объект.Организация;
	
	ОбновитьИтогиВПодвалеСервер();
	
	// Попытаемся найти счет-фактуру
	СчетФактура = УчетНДСПереопределяемый.НайтиПодчиненныйСчетФактуруВыданныйНаРеализацию(Объект.Ссылка);
	
	ТекущаяДатаДокумента = Объект.Дата;
	
	ОтобразитьНалоговыйПериод(ЭтаФорма);
	
	УстановитьУсловноеОформление();
	
	УчетНДС.ПрименитьПраваДоступаСчетаФактуры(
		СчетФактура,
		Элементы.СчетФактураПросмотр,
		Элементы.СчетФактураРедактирование);
	
	ЗаполнитьРеквизитыПроСчетФактуру(ЭтаФорма);
	УправлениеФормой(ЭтаФорма);
	
КонецПроцедуры

&НаКлиенте
Процедура ОбработкаОповещения(ИмяСобытия, Параметр, Источник)

	Если ИмяСобытия = "Запись_СчетФактураВыданный"
		И Параметр.ДокументыОснования.Найти(Объект.Ссылка) <> Неопределено Тогда
		ЗаполнитьРеквизитыПроСчетФактуру(ЭтаФорма, Параметр.РеквизитыСФ);
		УправлениеФормой(ЭтаФорма);
	Иначе
		ОбщегоНазначенияБПКлиент.ОбработкаОповещенияФормыДокумента(ЭтаФорма, Объект.Ссылка, ИмяСобытия, Параметр, Источник);
	КонецЕсли;

КонецПроцедуры

&НаКлиенте
Процедура ПослеЗаписи(ПараметрыЗаписи)
	
	Оповестить("СостояниеРегламентнойОперации", 
		?(Объект.Проведен, ПредопределенноеЗначение("Перечисление.ВидыСостоянийРегламентныхОпераций.Выполнено"), 
						   ПредопределенноеЗначение("Перечисление.ВидыСостоянийРегламентныхОпераций.НеВыполнено")));
	
КонецПроцедуры

&НаСервере
Процедура ПриЧтенииНаСервере(ТекущийОбъект)

	// СтандартныеПодсистемы.УправлениеДоступом
	Если ОбщегоНазначения.ПодсистемаСуществует("СтандартныеПодсистемы.УправлениеДоступом") Тогда
		МодульУправлениеДоступом = ОбщегоНазначения.ОбщийМодуль("УправлениеДоступом");
		МодульУправлениеДоступом.ПриЧтенииНаСервере(ЭтотОбъект, ТекущийОбъект);
	КонецЕсли;
	// Конец СтандартныеПодсистемы.УправлениеДоступом
	
	// СтандартныеПодсистемы.ДатыЗапретаИзменения
	ДатыЗапретаИзменения.ОбъектПриЧтенииНаСервере(ЭтаФорма, ТекущийОбъект);
	// Конец СтандартныеПодсистемы.ДатыЗапретаИзменения
	
	УстановитьСостояниеДокумента();
	
	// СтандартныеПодсистемы.ПодключаемыеКоманды
	ПодключаемыеКомандыКлиентСервер.ОбновитьКоманды(ЭтотОбъект, Объект);
	// Конец СтандартныеПодсистемы.ПодключаемыеКоманды
КонецПроцедуры

&НаКлиенте
Процедура ПередЗаписью(Отказ, ПараметрыЗаписи)
	
	Если ПараметрыЗаписи.РежимЗаписи = ПредопределенноеЗначение("РежимЗаписиДокумента.Проведение") Тогда
		КлючеваяОперация = "ПроведениеНачислениеНДСпоСМРхозспособом";
		ОценкаПроизводительностиКлиент.НачатьЗамерВремени(Истина, КлючеваяОперация);
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Процедура ПослеЗаписиНаСервере(ТекущийОбъект, ПараметрыЗаписи)

	// СтандартныеПодсистемы.УправлениеДоступом
	УправлениеДоступом.ПослеЗаписиНаСервере(ЭтотОбъект, ТекущийОбъект, ПараметрыЗаписи);
	// Конец СтандартныеПодсистемы.УправлениеДоступом
	
	Если ПараметрыЗаписи.Свойство("ВыписатьСчетФактуру") 
		И ПараметрыЗаписи.ВыписатьСчетФактуру Тогда 
		
		ПараметрыСоздания = УчетНДСКлиентСервер.НовыеПараметрыСозданияВыданногоСчетаФактуры();
		ПараметрыСоздания.Основание = ТекущийОбъект.Ссылка;
		РеквизитыСФ = УчетНДСВызовСервера.СоздатьСчетФактуруВыданныйНаОсновании(ПараметрыСоздания);
		
		ЗаполнитьРеквизитыПроСчетФактуру(ЭтаФорма, РеквизитыСФ);
		
		УправлениеФормой(ЭтаФорма);
		
	КонецЕсли;
	
	УстановитьСостояниеДокумента();
	
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
Процедура ДатаПриИзменении(Элемент)

	ДатаКонецМесяца = КонецМесяца(Объект.Дата);
	Если День(Объект.Дата) <> День(ДатаКонецМесяца) Тогда
		Объект.Дата = НачалоДня(ДатаКонецМесяца);
	КонецЕсли;

	Если Объект.Дата < '20051231' Тогда
		ТекстВопроса = НСтр("ru = 'Документ не может быть создан ранее 31 декабря 2005 года. Установить дату документа на 31.12.2005 г.?'");
		Оповещение = Новый ОписаниеОповещения("ВопросДатаПриИзмененииЗавершение", ЭтотОбъект);
		ПоказатьВопрос(Оповещение, ТекстВопроса, РежимДиалогаВопрос.ДаНет, , КодВозвратаДиалога.Да);
		Возврат;
	ИначеЕсли Не (НачалоДня(ТекущаяДатаДокумента) = НачалоДня(Объект.Дата)) тогда
		Объект.Дата = НачалоДня(КонецКвартала(Объект.Дата));
	КонецЕсли;

	ОтобразитьНалоговыйПериод(ЭтаФорма);

КонецПроцедуры

&НаКлиенте
Процедура ОрганизацияПриИзменении(Элемент)

	Если ТекущаяОрганизация = Объект.Организация
		ИЛИ Не ЗначениеЗаполнено(Объект.Организация) Тогда
		Возврат;
	КонецЕсли;

	СчетаУчета 			= Неопределено;
	ПараметрыОбработки 	= Неопределено;
	ПриИзмененииОрганизацииСервер(СчетаУчета, ПараметрыОбработки);

	ТекущаяОрганизация  = Объект.Организация;

КонецПроцедуры

&НаКлиенте
Процедура НадписьСчетФактураНажатие(Элемент, СтандартнаяОбработка)

	СтандартнаяОбработка = Ложь;
	БухгалтерскийУчетКлиентПереопределяемый.ОткрытьСчетФактуру(ЭтаФорма, СчетФактура, "СчетФактураВыданный");

КонецПроцедуры


#КонецОбласти

#Область ОбработчикиСобытийЭлементовТаблицыФормыСМРхозспособом

&НаКлиенте
Процедура СМРхозспособомПриНачалеРедактирования(Элемент, НоваяСтрока, Копирование)
	
	Если НоваяСтрока И НЕ Копирование Тогда
		Элемент.ТекущиеДанные.СтавкаНДС = УчетНДСКлиентСервер.СтавкаНДСПоУмолчанию(Объект.Дата);
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура СМРхозспособомСтавкаНДСПриИзменении(Элемент)

	ТД = Элементы.СМРхозспособом.ТекущиеДанные;

	// Рассчитать сумму НДС в табличной части.
	ТД.НДС = УчетНДСКлиентСервер.РассчитатьСуммуНДС(ТД.СуммаБезНДС, Ложь, УчетНДСВызовСервераПовтИсп.ПолучитьСтавкуНДС(ТД.СтавкаНДС));

	ОбновитьИтогиВПодвалеСервер();

КонецПроцедуры

&НаКлиенте
Процедура СМРхозспособомСуммаБезНДСПриИзменении(Элемент)

	// Рассчитать реквизиты табличной части.
	ТД = Элементы.СМРхозспособом.ТекущиеДанные;

	// Рассчитать сумму НДС в табличной части.
	ТД.НДС = УчетНДСКлиентСервер.РассчитатьСуммуНДС(ТД.СуммаБезНДС, Ложь, УчетНДСВызовСервераПовтИсп.ПолучитьСтавкуНДС(ТД.СтавкаНДС));

	ОбновитьИтогиВПодвалеСервер();

КонецПроцедуры

&НаКлиенте
Процедура СМРхозспособомПослеУдаления(Элемент)

	ОбновитьИтогиВПодвалеСервер();

КонецПроцедуры


#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура Заполнить(Команда)

	Если Объект.СМРхозспособом.Количество() > 0 Тогда
		Если Объект.Проведен Тогда
			ТекстВопроса = НСтр("ru = 'Перед заполнением проведение документа будет отменено, а табличная часть будет очищена. Заполнить?'");
		Иначе
			ТекстВопроса = НСтр("ru = 'Перед заполнением табличная часть1 будет очищена. Заполнить?'");
		КонецЕсли;
		Оповещение = Новый ОписаниеОповещения("ВопросЗаполнитьДокументЗавершение", ЭтотОбъект);
		ПоказатьВопрос(Оповещение, ТекстВопроса, РежимДиалогаВопрос.ДаНет, , КодВозвратаДиалога.Нет);
	Иначе
		ЗаполнитьДокументСервер();
		Если НЕ Объект.СМРхозспособом.Количество() > 0 Тогда
			СтрокаСообщения = Символы.ПС + НСтр("ru=' - не обнаружены расходы на строительство хоз. способом, начисление НДС не требуется'");
			
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(НСтр("ru='Документ не заполнен:'") + СтрокаСообщения, Объект.Ссылка, "Объект.СМРхозспособом");
		КонецЕсли;
	КонецЕсли;

КонецПроцедуры

&НаКлиенте
Процедура ВыписатьСчетФактуру(Команда)
	
	РеквизитыСФ = УчетНДСКлиент.СоздатьСчетФактуруВыданный(ЭтаФорма);
	
	Если РеквизитыСФ <> Неопределено Тогда 
		ЗаполнитьРеквизитыПроСчетФактуру(ЭтаФорма, РеквизитыСФ);
		УправлениеФормой(ЭтаФорма);
	КонецЕсли;
	
КонецПроцедуры


#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаСервере
Процедура УстановитьУсловноеОформление()

	УсловноеОформление.Элементы.Очистить();


	// СМРхозспособомНДС

	ЭлементУО = УсловноеОформление.Элементы.Добавить();

	КомпоновкаДанныхКлиентСервер.ДобавитьОформляемоеПоле(ЭлементУО.Поля, "СМРхозспособомНДС");

	ГруппаОтбора1 = КомпоновкаДанныхКлиентСервер.ДобавитьГруппуОтбора(ЭлементУО.Отбор.Элементы, ТипГруппыЭлементовОтбораКомпоновкиДанных.ГруппаИли);

		ОбщегоНазначенияКлиентСервер.ДобавитьЭлементКомпоновки(ГруппаОтбора1,
			"Объект.СМРхозспособом.СтавкаНДС", ВидСравненияКомпоновкиДанных.Равно, Перечисления.СтавкиНДС.НДС0);

		ОбщегоНазначенияКлиентСервер.ДобавитьЭлементКомпоновки(ГруппаОтбора1,
			"Объект.СМРхозспособом.СтавкаНДС", ВидСравненияКомпоновкиДанных.Равно, Перечисления.СтавкиНДС.БезНДС);

	ЭлементУО.Оформление.УстановитьЗначениеПараметра("ТолькоПросмотр", Истина);

КонецПроцедуры

&НаКлиентеНаСервереБезКонтекста
Процедура УправлениеФормой(Форма)
	
	Объект   = Форма.Объект;
	Элементы = Форма.Элементы;
	
	Элементы.ПодразделениеОрганизации.Доступность = ЗначениеЗаполнено(Объект.Организация);
	
	// Счет-фактура
	УчетНДСКлиентСервер.НастроитьПоляСчетаФактуры(
		Элементы.СчетФактураКнопка,
		Элементы.СчетФактураСсылка,
		Элементы.НадписьСчетФактура,
		Ложь,
		Истина,
		Форма.СчетФактура);
		
КонецПроцедуры

&НаСервере
Процедура УстановитьСостояниеДокумента()
	
	СостояниеДокумента = ОбщегоНазначенияБП.СостояниеДокумента(Объект);
	
КонецПроцедуры

&НаКлиентеНаСервереБезКонтекста
// Заполняет текст про счет-фактуру в форме документа.
//   Вызывается из обработчика ПриОткрытии этой формы и из обработчика ПослеЗаписи
// формы счета-фактуры.
//
Процедура ЗаполнитьРеквизитыПроСчетФактуру(Форма, РеквизитыСФ = Неопределено)

	УчетНДСКлиентСервер.ЗаполнитьРеквизитыФормыПроСчетФактуруВыданный(
		Форма, 
		РеквизитыСФ,
		Истина);
	
КонецПроцедуры

&НаКлиентеНаСервереБезКонтекста
Процедура ОтобразитьНалоговыйПериод(Форма)

	Объект = Форма.Объект;
	Форма.НадписьНалоговыйПериод = ПредставлениеПериода(НачалоДня(НачалоКвартала(Объект.Дата)), КонецДня(Объект.Дата), "ФП = Истина");

КонецПроцедуры

&НаСервере
Процедура ЗаполнитьДокументСервер()

	Документы.НачислениеНДСпоСМРхозспособом.ЗаполнитьДокумент(Объект);
	ОбновитьИтогиВПодвалеСервер();

КонецПроцедуры

&НаСервере
Процедура ПриИзмененииОрганизацииСервер(СчетаУчета, ПараметрыОбработки)

	// Выполняем общие действия для всех документов при изменении Организация.
	ЗаполнениеДокументов.ПриИзмененииЗначенияОрганизации(Объект, Пользователи.ТекущийПользователь());

	УправлениеФормой(ЭтаФорма);

КонецПроцедуры

&НаСервере
Процедура ОбновитьИтогиВПодвалеСервер()

	НадписьНДС         = Объект.СМРхозспособом.Итог("НДС");
	НадписьСуммаБезНДС = Объект.СМРхозспособом.Итог("СуммаБезНДС");

КонецПроцедуры

&НаСервереБезКонтекста
Процедура ЗаполнитьРеквизитыИзПараметровФормы(Форма)
	
	ПараметрыЗаполненияФормы = Неопределено;
	
	Если Форма.Параметры.Свойство("ПараметрыЗаполненияФормы",ПараметрыЗаполненияФормы) Тогда
	
		ЗаполнитьЗначенияСвойств(Форма.Объект,ПараметрыЗаполненияФормы);			
	
	КонецЕсли; 		

КонецПроцедуры

&НаКлиенте
Процедура ВопросЗаполнитьДокументЗавершение(Результат, ДополнительныеПараметры) Экспорт
	
	Если Результат = КодВозвратаДиалога.Да Тогда
		
		ЗаполнитьДокументСервер();
		
		Если НЕ Объект.СМРхозспособом.Количество() > 0 Тогда
			СтрокаСообщения = Символы.ПС + НСтр("ru=' - не обнаружены расходы на строительство хоз. способом, начисление НДС не требуется'");
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(НСтр("ru='Документ не заполнен:'") + СтрокаСообщения, Объект.Ссылка, "Объект.СМРхозспособом");
		КонецЕсли;
		
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ВопросДатаПриИзмененииЗавершение(ОтветНаВопрос, ДополнительныеПараметры) Экспорт
	
	Если ОтветНаВопрос = КодВозвратаДиалога.Нет Тогда
		Объект.Дата = ТекущаяДатаДокумента;
	Иначе
		Объект.Дата = '20051231';
		ОтобразитьНалоговыйПериод(ЭтаФорма);
	КонецЕсли;
	
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