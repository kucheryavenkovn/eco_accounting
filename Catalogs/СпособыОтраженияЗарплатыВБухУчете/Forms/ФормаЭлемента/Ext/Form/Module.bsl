﻿#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	// Обработчик подсистемы "Свойства"
	ДополнительныеПараметры = Новый Структура;
	ДополнительныеПараметры.Вставить("Объект", Объект);
	ДополнительныеПараметры.Вставить("ИмяЭлементаДляРазмещения", "ГруппаДополнительныеРеквизиты");
	УправлениеСвойствами.ПриСозданииНаСервере(ЭтаФорма, ДополнительныеПараметры);
	
	Если Параметры.Ключ.Пустая() Тогда
		ПодготовитьФормуНаСервере();
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
	// СтандартныеПодсистемы.Свойства
	УправлениеСвойствамиКлиент.ПослеЗагрузкиДополнительныхРеквизитов(ЭтотОбъект);
	// Конец СтандартныеПодсистемы.Свойства
	
КонецПроцедуры

&НаСервере
Процедура ПриЗаписиНаСервере(Отказ, ТекущийОбъект, ПараметрыЗаписи)
	
	ЗаписатьЗаписьПослеРедактированияВФорме(ЭтаФорма, ТекущийОбъект);
	
КонецПроцедуры

&НаСервере
Процедура ПриЧтенииНаСервере(ТекущийОбъект)
	
	// СтандартныеПодсистемы.Свойства
	УправлениеСвойствами.ПриЧтенииНаСервере(ЭтаФорма, ТекущийОбъект);
	// Конец СтандартныеПодсистемы.Свойства
	
	ПодготовитьФормуНаСервере();
	
КонецПроцедуры

&НаСервере
Процедура ПослеЗаписиНаСервере(ТекущийОбъект, ПараметрыЗаписи)
	
	ПрочитатьЗаписьДляРедактированияВФорме(ЭтаФорма, Объект.Ссылка);
	
КонецПроцедуры

&НаСервере
Процедура ОбработкаПроверкиЗаполненияНаСервере(Отказ, ПроверяемыеРеквизиты)
	
	// СтандартныеПодсистемы.Свойства
	УправлениеСвойствами.ОбработкаПроверкиЗаполнения(ЭтаФорма, Отказ, ПроверяемыеРеквизиты);
	// Конец СтандартныеПодсистемы.Свойства
	
КонецПроцедуры

&НаКлиенте
Процедура ОбработкаОповещения(ИмяСобытия, Параметр, Источник)
	
	// Подсистема "Свойства"
	Если УправлениеСвойствамиКлиент.ОбрабатыватьОповещения(ЭтаФорма, ИмяСобытия, Параметр) Тогда
		ОбновитьЭлементыДополнительныхРеквизитов();
		УправлениеСвойствамиКлиент.ПослеЗагрузкиДополнительныхРеквизитов(ЭтотОбъект);
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Процедура ПередЗаписьюНаСервере(Отказ, ТекущийОбъект, ПараметрыЗаписи)
	
	// Обработчик подсистемы "Свойства"
	УправлениеСвойствами.ПередЗаписьюНаСервере(ЭтаФорма, ТекущийОбъект);

КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовШапкиФормы

&НаКлиенте
Процедура СчетПриИзменении(Элемент)
	
	БухгалтерскийУчетКлиентСервер.УстановитьСвойстваСубконтоШапкиПриИзмененииСчета(
		ЭтотОбъект, ПорядокОтраженияВБухУчете, ПараметрыУстановкиСвойствСубконто(ЭтотОбъект));
		
	Если ПорядокОтраженияВБухУчете.Счет <> ПредопределенноеЗначение("ПланСчетов.Хозрасчетный.РасходыНаОплатуТрудаБудущихПериодов") Тогда
		ПорядокОтраженияВБухУчете.СчетНУ      = Неопределено;
		ПорядокОтраженияВБухУчете.СубконтоНУ1 = Неопределено;
		ПорядокОтраженияВБухУчете.СубконтоНУ2 = Неопределено;
		ПорядокОтраженияВБухУчете.СубконтоНУ3 = Неопределено;
		БухгалтерскийУчетКлиентСервер.УстановитьСвойстваСубконтоШапкиПриИзмененииСчета(
			ЭтотОбъект, ПорядокОтраженияВБухУчете, ПараметрыУстановкиСвойствСубконтоНУ(ЭтотОбъект));
	КонецЕсли;
		
	УправлениеСчетомНУ(ЭтаФорма);
	УстановитьТекстНадписиСчетУчетаРасходовПоСтраховымВзносам(ЭтаФорма);
	ПродублироватьЗначенияДляСчетаЕНВД();
	
КонецПроцедуры

&НаКлиенте
Процедура Субконто1ПриИзменении(Элемент)
	
	ПриИзмененииСубконто(1);
	
КонецПроцедуры

&НаКлиенте
Процедура Субконто1НачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	
	НачалоВыбораСубконто(Элемент, ДанныеВыбора, СтандартнаяОбработка);
	
КонецПроцедуры

&НаКлиенте
Процедура Субконто2ПриИзменении(Элемент)
	
	ПриИзмененииСубконто(2);
	
КонецПроцедуры

&НаКлиенте
Процедура Субконто2НачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	
	НачалоВыбораСубконто(Элемент, ДанныеВыбора, СтандартнаяОбработка);
	
КонецПроцедуры

&НаКлиенте
Процедура Субконто3ПриИзменении(Элемент)
	
	ПриИзмененииСубконто(3);
	
КонецПроцедуры

&НаКлиенте
Процедура Субконто3НачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	
	НачалоВыбораСубконто(Элемент, ДанныеВыбора, СтандартнаяОбработка);
	
КонецПроцедуры

&НаКлиенте
Процедура СчетНУПриИзменении(Элемент)
		
	БухгалтерскийУчетКлиентСервер.УстановитьСвойстваСубконтоШапкиПриИзмененииСчета(
		ЭтотОбъект, ПорядокОтраженияВБухУчете, ПараметрыУстановкиСвойствСубконтоНУ(ЭтотОбъект));
		
	УстановитьТекстНадписиСчетУчетаРасходовПоСтраховымВзносам(ЭтаФорма);
	
КонецПроцедуры

&НаКлиенте
Процедура СубконтоНУ1ПриИзменении(Элемент)
	
	ПриИзмененииСубконтоНУ(1);
	
КонецПроцедуры

&НаКлиенте
Процедура СубконтоНУ1НачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	
	НачалоВыбораСубконтоНУ(Элемент, ДанныеВыбора, СтандартнаяОбработка);
	
КонецПроцедуры

&НаКлиенте
Процедура СубконтоНУ2ПриИзменении(Элемент)
	
	ПриИзмененииСубконтоНУ(2);
	
КонецПроцедуры

&НаКлиенте
Процедура СубконтоНУ2НачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	
	НачалоВыбораСубконтоНУ(Элемент, ДанныеВыбора, СтандартнаяОбработка);
	
КонецПроцедуры

&НаКлиенте
Процедура СубконтоНУ3ПриИзменении(Элемент)
	
	ПриИзмененииСубконтоНУ(3);
	
КонецПроцедуры

&НаКлиенте
Процедура СубконтоНУ3НачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	
	НачалоВыбораСубконтоНУ(Элемент, ДанныеВыбора, СтандартнаяОбработка);
	
КонецПроцедуры

&НаКлиенте
Процедура ВидЗатратЕНВДПриИзменении(Элемент)
	
	Модифицированность = Истина;
	ПоказатьАналитикуЕНВД(ЭтаФорма);
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаСервере
Процедура ПодготовитьФормуНаСервере()

	Если Параметры.Ключ.Пустая() Тогда
		СпособОтраженияЗарплатыВБухУчетеСсылка = Справочники.СпособыОтраженияЗарплатыВБухУчете.ПолучитьСсылку();
		Если ЗначениеЗаполнено(ЭтаФорма.Параметры.ЗначениеКопирования) Тогда 
			СкопироватьЗаписьДляРедактированияВФорме(ЭтаФорма, СпособОтраженияЗарплатыВБухУчетеСсылка, ЭтаФорма.Параметры.ЗначениеКопирования);	
		КонецЕсли;
		ИнициализироватьЗаписьДляРедактированияВФорме(ЭтаФорма, СпособОтраженияЗарплатыВБухУчетеСсылка);
	Иначе
		ПрочитатьЗаписьДляРедактированияВФорме(ЭтаФорма, Объект.Ссылка);
	КонецЕсли;
	
	ОсновнаяОрганизация = БухгалтерскийУчетПереопределяемый.ПолучитьЗначениеПоУмолчанию("ОсновнаяОрганизация");
	
	УстановитьТекстНадписиСчетУчетаРасходовПоСтраховымВзносам(ЭтаФорма);
	ПоказатьАналитикуЕНВД(ЭтаФорма);
	
	БухгалтерскийУчетКлиентСервер.УстановитьНачальныеСвойстваСубконтоШапки(
		ЭтотОбъект, ПорядокОтраженияВБухУчете, ПараметрыУстановкиСвойствСубконто(ЭтотОбъект));
	БухгалтерскийУчетКлиентСервер.УстановитьНачальныеСвойстваСубконтоШапки(
		ЭтотОбъект, ПорядокОтраженияВБухУчете, ПараметрыУстановкиСвойствСубконтоНУ(ЭтотОбъект));
    		
	УправлениеСчетомНУ(ЭтаФорма);
	УстановитьТекстНадписиСчетУчетаРасходовПоСтраховымВзносам(ЭтаФорма);
	
	Если ВидЗатратЕНВД = Неопределено Тогда
		ВидЗатратЕНВД = ПредопределенноеЗначение("Справочник.СтатьиЗатрат.ПустаяСсылка");
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Процедура ИнициализироватьЗаписьДляРедактированияВФорме(Форма, ВедущийОбъект)
	
	МетаданныеРегистра = Метаданные.РегистрыСведений.ПорядокОтраженияЗарплатыВБухУчете;	
	
	ИмяЭлемента = "ПорядокОтраженияВБухУчете";
	МенеджерЗаписи = РегистрыСведений.ПорядокОтраженияЗарплатыВБухУчете.СоздатьМенеджерЗаписи();
	МенеджерЗаписи.СпособОтраженияЗарплатыВБухУчете = ВедущийОбъект;
	МенеджерЗаписи.ЕНВД = Ложь;
	Форма.ЗначениеВРеквизитФормы(МенеджерЗаписи, ИмяЭлемента);
	
	ИмяЭлемента = "ПорядокОтраженияВБухУчетеЕНВД";
	МенеджерЗаписиЕНВД = РегистрыСведений.ПорядокОтраженияЗарплатыВБухУчете.СоздатьМенеджерЗаписи();
	МенеджерЗаписиЕНВД.СпособОтраженияЗарплатыВБухУчете = ВедущийОбъект;
	МенеджерЗаписиЕНВД.ЕНВД = Истина;
	Форма.ЗначениеВРеквизитФормы(МенеджерЗаписиЕНВД, ИмяЭлемента);
	
КонецПроцедуры

&НаСервере
Процедура ПрочитатьЗаписьДляРедактированияВФорме(Форма, ВедущийОбъект)
	
	Если НЕ Форма.Параметры.Ключ.Пустая() Тогда
		ИнициализироватьЗаписьДляРедактированияВФорме(Форма, ВедущийОбъект);
	КонецЕсли;
	
	МетаданныеРегистра = Метаданные.РегистрыСведений.ПорядокОтраженияЗарплатыВБухУчете;	
		
	ИмяЭлемента = "ПорядокОтраженияВБухУчете";
	МенеджерЗаписи = РегистрыСведений.ПорядокОтраженияЗарплатыВБухУчете.СоздатьМенеджерЗаписи();
	МенеджерЗаписи.СпособОтраженияЗарплатыВБухУчете = ВедущийОбъект;
	МенеджерЗаписи.ЕНВД = Ложь;
	МенеджерЗаписи.Прочитать();
	
	Форма.ЗначениеВРеквизитФормы(МенеджерЗаписи, ИмяЭлемента);
	
	ИмяЭлемента = "ПорядокОтраженияВБухУчетеЕНВД";
	МенеджерЗаписи = РегистрыСведений.ПорядокОтраженияЗарплатыВБухУчете.СоздатьМенеджерЗаписи();
	МенеджерЗаписи.СпособОтраженияЗарплатыВБухУчете = ВедущийОбъект;
	МенеджерЗаписи.ЕНВД = Истина;
	МенеджерЗаписи.Прочитать();
	
	Форма.ЗначениеВРеквизитФормы(МенеджерЗаписи, ИмяЭлемента);
	
	Для НомерСубконто = 1 По 3 Цикл				
		Если ТипЗнч(Форма.ПорядокОтраженияВБухУчетеЕНВД["Субконто" + НомерСубконто])  = Тип("СправочникСсылка.СтатьиЗатрат") 
			ИЛИ ТипЗнч(Форма.ПорядокОтраженияВБухУчетеЕНВД["Субконто" + НомерСубконто])  = Тип("СправочникСсылка.ПрочиеДоходыИРасходы") Тогда
			Форма.ВидЗатратЕНВД = Форма.ПорядокОтраженияВБухУчетеЕНВД["Субконто" + НомерСубконто];	
			Прервать;
		КонецЕсли;
	КонецЦикла;
	
КонецПроцедуры

&НаСервере
Процедура СкопироватьЗаписьДляРедактированияВФорме(Форма, ВедущийОбъект, КопируемыйОбъект)
	
	Если НЕ Форма.Параметры.Ключ.Пустая() Тогда
		Возврат;
	КонецЕсли;
	
	МетаданныеРегистра = Метаданные.РегистрыСведений.ПорядокОтраженияЗарплатыВБухУчете;	
	
	МенеджерЗаписиКопируемыйОбъект = РегистрыСведений.ПорядокОтраженияЗарплатыВБухУчете.СоздатьМенеджерЗаписи();
	МенеджерЗаписиКопируемыйОбъект.СпособОтраженияЗарплатыВБухУчете = КопируемыйОбъект;
	МенеджерЗаписиКопируемыйОбъект.ЕНВД = Ложь;
	МенеджерЗаписиКопируемыйОбъект.Прочитать();
	
	МенеджерЗаписиЕНВДКопируемыйОбъект = РегистрыСведений.ПорядокОтраженияЗарплатыВБухУчете.СоздатьМенеджерЗаписи();
	МенеджерЗаписиЕНВДКопируемыйОбъект.СпособОтраженияЗарплатыВБухУчете = КопируемыйОбъект;
	МенеджерЗаписиЕНВДКопируемыйОбъект.ЕНВД = Истина;
	МенеджерЗаписиЕНВДКопируемыйОбъект.Прочитать();
	
		
	ИмяЭлемента = "ПорядокОтраженияВБухУчете";
	МенеджерЗаписи = РегистрыСведений.ПорядокОтраженияЗарплатыВБухУчете.СоздатьМенеджерЗаписи();
	МенеджерЗаписи.СпособОтраженияЗарплатыВБухУчете = ВедущийОбъект;
	МенеджерЗаписи.ЕНВД = Ложь;
	МенеджерЗаписи.Прочитать();
	ЗаполнитьЗначенияСвойств(МенеджерЗаписи, МенеджерЗаписиКопируемыйОбъект);
	МенеджерЗаписи.СпособОтраженияЗарплатыВБухУчете = ВедущийОбъект;
	
	Форма.ЗначениеВРеквизитФормы(МенеджерЗаписи, ИмяЭлемента);
	
	ИмяЭлемента = "ПорядокОтраженияВБухУчетеЕНВД";
	МенеджерЗаписи = РегистрыСведений.ПорядокОтраженияЗарплатыВБухУчете.СоздатьМенеджерЗаписи();
	МенеджерЗаписи.СпособОтраженияЗарплатыВБухУчете = ВедущийОбъект;
	МенеджерЗаписи.ЕНВД = Истина;
	МенеджерЗаписи.Прочитать();
	ЗаполнитьЗначенияСвойств(МенеджерЗаписи, МенеджерЗаписиЕНВДКопируемыйОбъект);
	МенеджерЗаписи.СпособОтраженияЗарплатыВБухУчете = ВедущийОбъект;
	
	Форма.ЗначениеВРеквизитФормы(МенеджерЗаписи, ИмяЭлемента);
	
	Для НомерСубконто = 1 По 3 Цикл				
		Если ТипЗнч(Форма.ПорядокОтраженияВБухУчетеЕНВД["Субконто" + НомерСубконто])  = Тип("СправочникСсылка.СтатьиЗатрат") 
			ИЛИ ТипЗнч(Форма.ПорядокОтраженияВБухУчетеЕНВД["Субконто" + НомерСубконто])  = Тип("СправочникСсылка.ПрочиеДоходыИРасходы") Тогда
			Форма.ВидЗатратЕНВД = Форма.ПорядокОтраженияВБухУчетеЕНВД["Субконто" + НомерСубконто];	
			Прервать;
		КонецЕсли;
	КонецЦикла;
	
КонецПроцедуры

&НаКлиентеНаСервереБезКонтекста
Процедура УстановитьТекстНадписиСчетУчетаРасходовПоСтраховымВзносам(Форма)
	
	ТекущаяЗапись = Форма.ПорядокОтраженияВБухУчете;
		
	Текст = "Счет учета расходов по страховым взносам ";
	
	Если ЗначениеЗаполнено(ТекущаяЗапись.Счет) Тогда
	    		
		Если ТекущаяЗапись.Счет = ПредопределенноеЗначение("ПланСчетов.Хозрасчетный.РасходыНаОплатуТрудаБудущихПериодов") Тогда
			
			Текст = Текст + "по БУ: " + ТекущаяЗапись.Счет + " по НУ: " + ТекущаяЗапись.СчетНУ;
					
		Иначе
			
			Текст = "Порядок отражения страховых взносов в БУ и НУ совпадает";
			
		КонецЕсли;
		
	Иначе
		
		Текст = "Порядок отражения страховых взносов в БУ и НУ совпадает";
		
	КонецЕсли;
	
	Форма.НадписьСчетУчетаРасходовПоСтраховымВзносам = Текст;
			
КонецПроцедуры

&НаКлиентеНаСервереБезКонтекста
Процедура УправлениеСчетомНУ(Форма)
	
	ТекущаяЗапись = Форма.ПорядокОтраженияВБухУчете;
	ЭтоРБП = ТекущаяЗапись.Счет = ПредопределенноеЗначение("ПланСчетов.Хозрасчетный.РасходыНаОплатуТрудаБудущихПериодов");
	
	Форма.Элементы.СчетНУ.Доступность = ЭтоРБП;
	Форма.Элементы.СчетНУ.АвтоОтметкаНезаполненного = ЭтоРБП;
	
КонецПроцедуры	

&НаСервере
Процедура ЗаписатьЗаписьПослеРедактированияВФорме(Форма, ВедущийОбъект, ДанныеМодифицированы = Ложь)
	      
	Если Форма.Модифицированность Тогда

		Форма.ПорядокОтраженияВБухУчете.ЕНВД = Ложь;
		Форма.ПорядокОтраженияВБухУчете.СпособОтраженияЗарплатыВБухУчете = ВедущийОбъект.Ссылка;
		МенеджерЗаписи = Форма.РеквизитФормыВЗначение("ПорядокОтраженияВБухУчете");
		Если НЕ ЗначениеЗаполнено(МенеджерЗаписи.Счет) Тогда
			МенеджерЗаписи.Удалить();
		Иначе
			МенеджерЗаписи.Записать();
		КонецЕсли;
		
		ЗаписыватьЕНВД = Ложь;
		НомерСубконтоСтатьиЗатрат = 0;
		Для НомерСубконто = 1 По 3 Цикл
			Если ТипЗнч(Форма.ПорядокОтраженияВБухУчете["Субконто" + НомерСубконто])  = Тип("СправочникСсылка.СтатьиЗатрат") 
				ИЛИ ТипЗнч(Форма.ПорядокОтраженияВБухУчете["Субконто" + НомерСубконто])  = Тип("СправочникСсылка.ПрочиеДоходыИРасходы") Тогда
				ЗаписыватьЕНВД = Истина;
				НомерСубконтоСтатьиЗатрат = ?(НомерСубконтоСтатьиЗатрат = 0, НомерСубконто, НомерСубконтоСтатьиЗатрат);
			КонецЕсли;
		КонецЦикла;
		
		Если ЗаписыватьЕНВД Тогда
			Форма.ПорядокОтраженияВБухУчетеЕНВД.Счет = Форма.ПорядокОтраженияВБухУчете.Счет;
		Иначе
			Форма.ПорядокОтраженияВБухУчетеЕНВД.Счет = "";
		КонецЕсли;
		
		Для НомерСубконто = 1 По 3 Цикл				
			Если ЗаписыватьЕНВД Тогда				
				Если ТипЗнч(Форма.ПорядокОтраженияВБухУчете["Субконто" + НомерСубконто])  = Тип("СправочникСсылка.СтатьиЗатрат") 
					ИЛИ ТипЗнч(Форма.ПорядокОтраженияВБухУчете["Субконто" + НомерСубконто])  = Тип("СправочникСсылка.ПрочиеДоходыИРасходы") Тогда
					Форма.ПорядокОтраженияВБухУчетеЕНВД["Субконто" + НомерСубконто] = Форма.ВидЗатратЕНВД;	
				Иначе
					Форма.ПорядокОтраженияВБухУчетеЕНВД["Субконто" + НомерСубконто] = Форма.ПорядокОтраженияВБухУчетеЕНВД["Субконто" + НомерСубконто];					
				КонецЕсли;
			Иначе				
				Форма.ПорядокОтраженияВБухУчетеЕНВД["Субконто" + НомерСубконто] = "";
			КонецЕсли;
		КонецЦикла;
			
		Форма.ПорядокОтраженияВБухУчетеЕНВД.ОтражениеВУСН = Перечисления.ОтражениеВУСН.НеПринимаются;
		Форма.ПорядокОтраженияВБухУчетеЕНВД.ЕНВД = Истина;
		Форма.ПорядокОтраженияВБухУчетеЕНВД.СпособОтраженияЗарплатыВБухУчете = ВедущийОбъект.Ссылка;
		МенеджерЗаписи = Форма.РеквизитФормыВЗначение("ПорядокОтраженияВБухУчетеЕНВД");		
		Если НЕ ЗначениеЗаполнено(МенеджерЗаписи.Счет) ИЛИ НЕ ПолучитьФункциональнуюОпцию("ИспользуетсяЕНВД") Тогда
			МенеджерЗаписи.Удалить();
		Иначе
			МенеджерЗаписи.Записать();
		КонецЕсли;
		
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ПродублироватьЗначенияДляСчетаЕНВД()
		
	Если ПорядокОтраженияВБухУчетеЕНВД.Счет <> ПорядокОтраженияВБухУчете.Счет Тогда
		ПорядокОтраженияВБухУчетеЕНВД.Счет = ПорядокОтраженияВБухУчете.Счет;
		ПродублироватьЗначенияДляСубконтоЕНВД();
	КонецЕсли;	
	
КонецПроцедуры

&НаКлиенте
Процедура ПродублироватьЗначенияДляСубконтоЕНВД()
		
	ПоказыватьАналитикуЕНВД = Ложь;	
	Для НомерСубконто = 1 По 3 Цикл
		Если ТипЗнч(ПорядокОтраженияВБухУчете["Субконто" + НомерСубконто])  = Тип("СправочникСсылка.СтатьиЗатрат") Тогда
			ПоказыватьАналитикуЕНВД = Истина;			
			Если ТипЗнч(ВидЗатратЕНВД) <> Тип("СправочникСсылка.СтатьиЗатрат") Тогда
				ПорядокОтраженияВБухУчетеЕНВД["Субконто" + НомерСубконто] = ПредопределенноеЗначение("Справочник.СтатьиЗатрат.ПустаяСсылка");
				ВидЗатратЕНВД = ПредопределенноеЗначение("Справочник.СтатьиЗатрат.ПустаяСсылка");
			КонецЕсли;
		ИначеЕсли ТипЗнч(ПорядокОтраженияВБухУчете["Субконто" + НомерСубконто])  = Тип("СправочникСсылка.ПрочиеДоходыИРасходы") Тогда			
			ПоказыватьАналитикуЕНВД = Истина;
			Если ТипЗнч(ВидЗатратЕНВД) <> Тип("СправочникСсылка.ПрочиеДоходыИРасходы") Тогда
				ПорядокОтраженияВБухУчетеЕНВД["Субконто" + НомерСубконто] = ПредопределенноеЗначение("Справочник.ПрочиеДоходыИРасходы.ПустаяСсылка");				
				ВидЗатратЕНВД = ПредопределенноеЗначение("Справочник.ПрочиеДоходыИРасходы.ПустаяСсылка");
			КонецЕсли;
		Иначе
			ПорядокОтраженияВБухУчетеЕНВД["Субконто" + НомерСубконто] = ПредопределенноеЗначение("Справочник.СтатьиЗатрат.ПустаяСсылка");
			ПорядокОтраженияВБухУчетеЕНВД["Субконто" + НомерСубконто] = ПорядокОтраженияВБухУчете["Субконто" + НомерСубконто];
		КонецЕсли;
	КонецЦикла;
	
	Если НЕ ПоказыватьАналитикуЕНВД Тогда
		ВидЗатратЕНВД = ПредопределенноеЗначение("Справочник.СтатьиЗатрат.ПустаяСсылка");
	КонецЕсли;
	
	ПоказатьАналитикуЕНВД(ЭтаФорма, ПоказыватьАналитикуЕНВД);
	
КонецПроцедуры

&НаКлиентеНаСервереБезКонтекста
Процедура ПоказатьАналитикуЕНВД(Форма, ПоказыватьАналитикуЕНВД = Неопределено)
		
	Если ПоказыватьАналитикуЕНВД = Неопределено Тогда
		ПоказыватьАналитикуЕНВД = Ложь;
		Для НомерСубконто = 1 По 3 Цикл
			Если ТипЗнч(Форма.ПорядокОтраженияВБухУчете["Субконто" + НомерСубконто])  = Тип("СправочникСсылка.СтатьиЗатрат") 
				ИЛИ ТипЗнч(Форма.ПорядокОтраженияВБухУчете["Субконто" + НомерСубконто])  = Тип("СправочникСсылка.ПрочиеДоходыИРасходы") Тогда
				ПоказыватьАналитикуЕНВД = Истина;			
			КонецЕсли;
		КонецЦикла;
	КонецЕсли;
	
	Форма.Элементы.ГруппаСтраницаСчетИСубконтоЕНВД.Доступность = ПоказыватьАналитикуЕНВД;
	
	Форма.Элементы.ВидЗатратЕНВД.АвтоОтметкаНезаполненного = ПоказыватьАналитикуЕНВД;
	
	Если ПоказыватьАналитикуЕНВД Тогда
		Форма.НадписьСчетУчетаПоЕНВД = "Расходы отражаются на отдельной статье затрат";
	Иначе
		Форма.НадписьСчетУчетаПоЕНВД = "Отражается аналогично расходам по основной системе налогообложения";
	КонецЕсли;
		
КонецПроцедуры

&НаКлиенте
Процедура Подключаемый_СвойстваВыполнитьКоманду(ЭлементИлиКоманда, НавигационнаяСсылка = Неопределено, СтандартнаяОбработка = Неопределено)
	УправлениеСвойствамиКлиент.ВыполнитьКоманду(ЭтотОбъект, ЭлементИлиКоманда, СтандартнаяОбработка);
КонецПроцедуры

&НаСервере
Процедура ОбновитьЭлементыДополнительныхРеквизитов()
	
	УправлениеСвойствами.ОбновитьЭлементыДополнительныхРеквизитов(ЭтаФорма, РеквизитФормыВЗначение("Объект"));

КонецПроцедуры

&НаКлиенте
Процедура ПриИзмененииСубконто(НомерСубконто)
	
	БухгалтерскийУчетКлиентСервер.УстановитьСвойстваСубконтоШапкиПриИзмененииСубконто(
		ЭтотОбъект, ПорядокОтраженияВБухУчете, НомерСубконто, ПараметрыУстановкиСвойствСубконто(ЭтотОбъект));
		
	ПродублироватьЗначенияДляСубконтоЕНВД();
	
КонецПроцедуры

&НаКлиенте
Процедура НачалоВыбораСубконто(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	
	ДанныеОбъекта = БухгалтерскийУчетКлиентСервер.ДанныеУстановкиПараметровСубконто(
		ПорядокОтраженияВБухУчете, ПараметрыУстановкиСвойствСубконто(ЭтотОбъект));
	
	ОбщегоНазначенияБПКлиент.НачалоВыбораЗначенияСубконто(ЭтотОбъект, Элемент, СтандартнаяОбработка, ДанныеОбъекта);
	
КонецПроцедуры

&НаКлиентеНаСервереБезКонтекста
Функция ПараметрыУстановкиСвойствСубконто(Форма)

	Результат = БухгалтерскийУчетКлиентСервер.ПараметрыУстановкиСвойствСубконтоПоШаблону(
		"Субконто", "", "Субконто", "", "Счет");
		
	Результат.ДопРеквизиты.Вставить("Организация", Форма.ОсновнаяОрганизация);
	
	Возврат Результат;

КонецФункции

&НаКлиенте
Процедура ПриИзмененииСубконтоНУ(НомерСубконто)
	
	БухгалтерскийУчетКлиентСервер.УстановитьСвойстваСубконтоШапкиПриИзмененииСубконто(
		ЭтотОбъект, ПорядокОтраженияВБухУчете, НомерСубконто, ПараметрыУстановкиСвойствСубконто(ЭтотОбъект));
	
КонецПроцедуры

&НаКлиенте
Процедура НачалоВыбораСубконтоНУ(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	
	ДанныеОбъекта = БухгалтерскийУчетКлиентСервер.ДанныеУстановкиПараметровСубконто(
		ПорядокОтраженияВБухУчете, ПараметрыУстановкиСвойствСубконтоНУ(ЭтотОбъект));
	
	ОбщегоНазначенияБПКлиент.НачалоВыбораЗначенияСубконто(ЭтотОбъект, Элемент, СтандартнаяОбработка, ДанныеОбъекта);
	
КонецПроцедуры

&НаКлиентеНаСервереБезКонтекста
Функция ПараметрыУстановкиСвойствСубконтоНУ(Форма)

	Результат = БухгалтерскийУчетКлиентСервер.ПараметрыУстановкиСвойствСубконтоПоШаблону(
		"СубконтоНУ", "", "СубконтоНУ", "", "СчетНУ");
		
	Результат.ДопРеквизиты.Вставить("Организация", Форма.ОсновнаяОрганизация);
	
	Возврат Результат;

КонецФункции

// СтандартныеПодсистемы.Свойства

&НаКлиенте
Процедура ОбновитьЗависимостиДополнительныхРеквизитов()
	УправлениеСвойствамиКлиент.ОбновитьЗависимостиДополнительныхРеквизитов(ЭтотОбъект);
КонецПроцедуры

&НаКлиенте
Процедура Подключаемый_ПриИзмененииДополнительногоРеквизита(Элемент)
	УправлениеСвойствамиКлиент.ОбновитьЗависимостиДополнительныхРеквизитов(ЭтотОбъект);
КонецПроцедуры

// Конец СтандартныеПодсистемы.Свойства

#КонецОбласти
