﻿#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	ПодготовитьФормуНаСервере();
	
	Если СопоставлятьКонтрагента Тогда
		Страница = "КОНТРАГЕНТ";
	ИначеЕсли СопоставлятьНоменклатуру Тогда
		Страница = "НОМЕНКЛАТУРА";
	КонецЕсли;
	
	ПереключитьСтраницы(ЭтотОбъект, Страница);
	
	УстановитьУсловноеОформление();
	
КонецПроцедуры

&НаСервере
Процедура ПодготовитьФормуНаСервере()
	
	ЗагрузитьНастройкиНаСервере();
	
	ДокументСсылка = Параметры.ДокументСсылка;
	АдресХранилища = Параметры.АдресХранилища;
	
	ДанныеДляСпоставления = ПолучитьИзВременногоХранилища(АдресХранилища);
	
	СопоставлятьНоменклатуру = ЗначениеЗаполнено(ДанныеДляСпоставления.Номенклатура);
	Если СопоставлятьНоменклатуру Тогда
		
		ЕдиницыИзмерения = Новый Соответствие;
		Для каждого СтрокаТаблицы из ДанныеДляСпоставления.Номенклатура Цикл
			НоваяСтрока = НоменклатураКСопоставлению.Добавить();
			НоваяСтрока.ДанныеНоменклатуры = СтрокаТаблицы.ДанныеНоменклатуры;
			
			ЗаполнитьЗначенияСвойств(НоваяСтрока, СтрокаТаблицы.ДанныеНоменклатуры, "Наименование, Артикул, Услуга");
			НоваяСтрока.НомерСтрокиЗаказа = СтрокаТаблицы.НомерСтрокиЗаказа;
			НоваяСтрока.НаименованиеПредставление  = "Новый: " + НоваяСтрока.Наименование;
			НоваяСтрока.ИдентификаторНоменклатуры  = СтрокаТаблицы.Идентификатор;
			НоваяСтрока.ИдентификаторПредставление = "Код магазина: " + СтрокаТаблицы.Идентификатор;
			
			
			НоваяСтрока.ЗначокДействия             = 2;
			КодЕдиницы = СтрокаТаблицы.ДанныеНоменклатуры.Единица.Код;
			Если ЗначениеЗаполнено(КодЕдиницы) Тогда
				БазоваяЕдиница = ЕдиницыИзмерения.Получить(КодЕдиницы);
				Если БазоваяЕдиница = Неопределено Тогда
					БазоваяЕдиница = Справочники.КлассификаторЕдиницИзмерения.ЕдиницаИзмеренияПоКоду(КодЕдиницы);
					ЕдиницыИзмерения.Вставить(КодЕдиницы, БазоваяЕдиница);
				КонецЕсли;
				НоваяСтрока.Единица                    = БазоваяЕдиница;
			КонецЕсли;
		КонецЦикла;
	КонецЕсли;
	
	СопоставлятьКонтрагента = ЗначениеЗаполнено(ДанныеДляСпоставления.Контрагент);
	
	Если СопоставлятьКонтрагента Тогда
		ДанныеКонтрагента = ДанныеДляСпоставления.Контрагент;
		
		ДанныеПокупателя = ПредставлениеДанныхПокупателя(ДанныеКонтрагента);
		
		Если ПустаяСтрока(ДанныеПокупателя) Тогда
			СоздатьКонтрагента = 2;
			ДанныеПокупателя = НСтр("ru = '<Данные не указаны>'");
			Элементы.СоздатьКонтрагента.ТолькоПросмотр = Истина;
			Элементы.ВыбратьСуществующего.ТолькоПросмотр = Истина;
			УстановитьДоступностьВыбораКонтрагента(ЭтотОбъект);
		Иначе
			СоздатьКонтрагента = 1;
		КонецЕсли;
		
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
	Если ВсеДанныеСопоставлены Тогда
		
		ПараметрОповещения = Новый Структура;
		ПараметрОповещения.Вставить("Контрагент",                                       Контрагент);
		ПараметрОповещения.Вставить("ИдентификаторВызывающейФормы",                     ВладелецФормы.УникальныйИдентификатор);
		ПараметрОповещения.Вставить("АдресТаблицыСопоставленныхДанныхВХранилище",       АдресХранилища);
		ПараметрОповещения.Вставить("ДанныеСопоставленыАвтоматически",                  Истина);
		
		Оповестить("ЗаполненыДанныеИнтернетМагазин", ПараметрОповещения, ВладелецФормы);
		
		Отказ = Истина;
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ПриЗакрытии(ЗавершениеРаботы)
	
	Если ПеренестиВДокумент Тогда
		
		РезультатСопоставления = РезультатСопоставления();
		
		ПараметрОповещения = Новый Структура;
		ПараметрОповещения.Вставить("Контрагент",                         РезультатСопоставления.Контрагент);
		ПараметрОповещения.Вставить("Номенклатура",                       РезультатСопоставления.Номенклатура);
		ПараметрОповещения.Вставить("ИдентификаторВызывающейФормы",       ВладелецФормы.УникальныйИдентификатор);
		
		Оповестить("ЗаполненыДанныеИнтернетМагазин", ПараметрОповещения, ВладелецФормы);
		
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовШапкиФормы

&НаКлиенте
Процедура СоздатьКонтрагентаПриИзменении(Элемент)
	УстановитьДоступностьВыбораКонтрагента(ЭтотОбъект);
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовТаблицыФормыСписок

&НаКлиенте
Процедура СписокНоменклатурыАвтоПодбор(Элемент, Текст, ДанныеВыбора, ПараметрыПолученияДанных, Ожидание, СтандартнаяОбработка)
	ТекДанные = Элементы.Список.ТекущиеДанные;
	Если ТекДанные <> Неопределено
		И НЕ ЗначениеЗаполнено(ТекДанные.Номенклатура) Тогда
		
		СтандартнаяОбработка = Ложь;
		ДанныеВыбора = Новый СписокЗначений;
		ТекстПодбора = НСтр("ru = 'Создать: '")
			+ ТекДанные.Наименование
			+ ?(ПустаяСтрока(ТекДанные.Артикул), "", ", " + ТекДанные.Артикул)
			+ ?(ПустаяСтрока(ТекДанные.Единица), "", ", " + ТекДанные.Единица);
		ДанныеВыбора.Добавить(ТекстПодбора);
		
	КонецЕсли;

КонецПроцедуры

&НаКлиенте
Процедура СписокНоменклатураОбработкаВыбора(Элемент, ВыбранноеЗначение, СтандартнаяОбработка)
	
	ТекДанные = Элементы.Список.ТекущиеДанные;
	Если ТекДанные <> Неопределено 
		И ТипЗнч(ВыбранноеЗначение) = Тип("Строка") Тогда
		СтандартнаяОбработка = Ложь;
		ДанныеЗаполнения = Новый Структура();
		ДанныеЗаполнения.Вставить("НаименованиеПолное",   ТекДанные.Наименование);
		ДанныеЗаполнения.Вставить("Артикул",              ТекДанные.Артикул);
		ДанныеЗаполнения.Вставить("Услуга",               ТекДанные.Услуга);
		ДанныеЗаполнения.Вставить("НоменклатурнаяГруппа", НастройкиЗагрузки.НоменклатурнаяГруппа);
		ДанныеЗаполнения.Вставить("Родитель",             НастройкиЗагрузки.ГруппаНоменклатуры);
		
		Если ТекДанные.Услуга Тогда
			ДанныеЗаполнения.Вставить("ВидНоменклатуры",  НастройкиЗагрузки.ВидНоменклатурыУслуга);
		Иначе
			ДанныеЗаполнения.Вставить("ВидНоменклатуры",  НастройкиЗагрузки.ВидНоменклатуры);
		КонецЕсли;
		
		БазоваяЕдиница = ТекДанные.Единица;
		Если НЕ ТекДанные.Услуга
			И Не ЗначениеЗаполнено(БазоваяЕдиница) Тогда
			БазоваяЕдиница = НастройкиЗагрузки.ЕдиницаИзмерения;
		КонецЕсли;
		ДанныеЗаполнения.Вставить("ЕдиницаИзмерения",     БазоваяЕдиница);
		
		ПараметрыФормы = Новый Структура();
		ПараметрыФормы.Вставить("РежимВыбора", Истина);
		ПараметрыФормы.Вставить("ТекстЗаполнения", ТекДанные.Наименование);
		ПараметрыФормы.Вставить("ЗначенияЗаполнения", ДанныеЗаполнения);
		ОткрытьФорму("Справочник.Номенклатура.ФормаОбъекта",ПараметрыФормы, Элемент);
	Иначе
		Если ЗначениеЗаполнено(ВыбранноеЗначение) Тогда
			ТекДанные.ЗначокДействия = 0;
		КонецЕсли;
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура СписокНоменклатураОчистка(Элемент, СтандартнаяОбработка)
	ТекДанные = Элементы.Список.ТекущиеДанные;
	Если ТекДанные <> Неопределено Тогда
		ТекДанные.ЗначокДействия = 0;
	КонецЕсли;
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы
&НаКлиенте
Процедура Назад(Команда)
	
	Страница = "";
	ТекущаяСтраница = Элементы.СтраницыМастера.ТекущаяСтраница;
	Если ТекущаяСтраница = Элементы.СтраницаНоменклатура И СопоставлятьКонтрагента Тогда
		Страница = "КОНТРАГЕНТ";
	КонецЕсли;
	
	ПереключитьСтраницы(ЭтотОбъект, Страница);
	
КонецПроцедуры

&НаКлиенте
Процедура Далее(Команда)
	
	Страница = "";
	ТекущаяСтраница = Элементы.СтраницыМастера.ТекущаяСтраница;
	Если ТекущаяСтраница = Элементы.СтраницаКонтрагент И СопоставлятьНоменклатуру Тогда
		Страница = "НОМЕНКЛАТУРА";
	КонецЕсли;
	
	ПереключитьСтраницы(ЭтотОбъект, Страница);
	
КонецПроцедуры

&НаКлиенте
Процедура ПеренестиВДокумент(Команда)
	ПеренестиВДокумент = Истина;
	Закрыть(КодВозвратаДиалога.OK);
КонецПроцедуры

&НаКлиенте
Процедура Настройка(Команда)
	
	ОповещениеОЗавершении = Новый ОписаниеОповещения("НастройкиОбменаСИнтернетМагазиномЗавершение", ЭтотОбъект);
	
	ПараметрыФормы = Новый Структура("НастройкаРеквизитов", Истина);
	ОткрытьФорму("Обработка.ОбменСИнтернетМагазином.Форма.ФормаНастройки",ПараметрыФормы,ЭтотОбъект,,,,ОповещениеОЗавершении);
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаСервере
Функция ПредставлениеДанныхПокупателя(ДанныеКонтрагента)
	
	Если СопоставлятьКонтрагента Тогда
		
		НаименованиеКонтрагента = "";
		Если НЕ ПустаяСтрока(ДанныеКонтрагента.ОфициальноеНаименование) Тогда
			НаименованиеКонтрагента = ДанныеКонтрагента.ОфициальноеНаименование;
		ИначеЕсли НЕ ДанныеКонтрагента.ЮрЛицо И НЕ ПустаяСтрока(ДанныеКонтрагента.ФИО) Тогда
			НаименованиеКонтрагента = ДанныеКонтрагента.ФИО;
		КонецЕсли;
		
		Если ПустаяСтрока(НаименованиеКонтрагента) Тогда
			Если ЗначениеЗаполнено(ДанныеКонтрагента.НаименованиеПолное) Тогда
				НаименованиеКонтрагента = ДанныеКонтрагента.НаименованиеПолное;
			Иначе
				НаименованиеКонтрагента = "-";
			КонецЕсли;
		КонецЕсли;
		
		ИНН = ДанныеКонтрагента.ИНН;
		КПП = ДанныеКонтрагента.КПП;
		
		ДанныеПокупателя = НаименованиеКонтрагента
			+ ?(ЗначениеЗаполнено(ИНН), ", " + "ИНН " + ИНН, "")
			+ ?(ЗначениеЗаполнено(КПП), ", " + "КПП " + КПП, "");
		АдресФакт = "";
		АдресЮр = "";
		Телефон = "";
		ЭП = "";
		
		Для Каждого СтрокаИнформации Из ДанныеКонтрагента.КонтактнаяИнформация Цикл
			
			Если Не ЗначениеЗаполнено(СтрокаИнформации.Представление) Тогда
				Продолжить;
			КонецЕсли;
			
			Если ВРег(СтрокаИнформации.Вид) = ВРег("ФактическийАдрес") Тогда
				
				АдресФакт = СтрокаИнформации.Представление;
				
			ИначеЕсли ВРег(СтрокаИнформации.Вид) = ВРег("ЮридическийАдрес") Тогда
				
				АдресЮр = СтрокаИнформации.Представление;
				
			ИначеЕсли ВРег(СтрокаИнформации.Вид) = ВРег("ТелефонРабочий")
				ИЛИ ВРег(СтрокаИнформации.Вид) = ВРег("ТелефонВнутренний")
				ИЛИ ВРег(СтрокаИнформации.Вид) = ВРег("ТелефонМобильный")
				ИЛИ ВРег(СтрокаИнформации.Вид) = ВРег("ТелефонДомашний") Тогда
				
				Телефон = СтрокаИнформации.Представление;
				
			ИначеЕсли ВРег(СтрокаИнформации.Вид) = ВРег("Почта")
				ИЛИ ВРег(СтрокаИнформации.Вид) = ВРег("ЭлектроннаяПочта") Тогда
				
				ЭП = СтрокаИнформации.Представление;
				
			КонецЕсли;
			
		КонецЦикла;
		
		ДанныеПокупателя = ДанныеПокупателя
			+ ?(ЗначениеЗаполнено(Телефон),", " + "тел.: " + Телефон, "")
			+ ?(ЗначениеЗаполнено(ЭП), ", " + "Email: " + ЭП, "")
			+ ?(ЗначениеЗаполнено(АдресЮр), ", " + "Адрес:" + АдресЮр, "")
			+ ?(НЕ ЗначениеЗаполнено(АдресЮр) И ЗначениеЗаполнено(АдресФакт), ", " + "Адрес: " + АдресФакт, "");
			
	КонецЕсли;
	
	Возврат ДанныеПокупателя;

КонецФункции

&НаКлиентеНаСервереБезКонтекста
Процедура УстановитьДоступностьВыбораКонтрагента(Форма)
	Форма.Элементы.Контрагент.Доступность = Форма.СоздатьКонтрагента = 2;
КонецПроцедуры

&НаСервере
Процедура УстановитьУсловноеОформление()
	
	// Серый текст для новой номенклатуры
	ЭлементУО = УсловноеОформление.Элементы.Добавить();
	КомпоновкаДанныхКлиентСервер.ДобавитьОформляемоеПоле(ЭлементУО.Поля, "СписокНоменклатура");
	ОбщегоНазначенияКлиентСервер.ДобавитьЭлементКомпоновки(ЭлементУО.Отбор,
		"НоменклатураКСопоставлению.Номенклатура", ВидСравненияКомпоновкиДанных.НеЗаполнено);
	ЭлементУО.Оформление.УстановитьЗначениеПараметра("ЦветТекста", WebЦвета.ТемноСерый);
	ЭлементУО.Оформление.УстановитьЗначениеПараметра("Текст", Новый ПолеКомпоновкиДанных("НоменклатураКСопоставлению.НаименованиеПредставление"));
	
КонецПроцедуры

&НаКлиенте
Процедура НастройкиОбменаСИнтернетМагазиномЗавершение(Результат, ДополнительныеПараметры) Экспорт
	
	ЗагрузитьНастройкиНаСервере();
	
КонецПроцедуры

&НаСервере
Процедура ЗагрузитьНастройкиНаСервере()
	
	ВидНоменклатурыУслуга = Справочники.ВидыНоменклатуры.ЭлементВидНоменклатурыПоУмолчанию(Истина);
	ЕдиницаИзмерения = Справочники.КлассификаторЕдиницИзмерения.ПолучитьЕдиницуИзмеренияПоУмолчанию();
	
	НастройкиЗагрузки = ОбменСИнтернетМагазином.ПолучитьНастройкиОбмена();
	НастройкиЗагрузки.Вставить("ВидНоменклатурыУслуга", ВидНоменклатурыУслуга);
	НастройкиЗагрузки.Вставить("ЕдиницаИзмерения",      ЕдиницаИзмерения);
	
КонецПроцедуры

&НаСервере
Функция РезультатСопоставления()
	
	РезультатСопоставления = Новый Структура;
	РезультатСопоставления.Вставить("Контрагент");
	РезультатСопоставления.Вставить("Номенклатура", Новый Соответствие);
	
	Если СопоставлятьКонтрагента Тогда
		ДанныеДляСпоставления = ПолучитьИзВременногоХранилища(АдресХранилища);
		ДанныеКонтрагента = ДанныеДляСпоставления.Контрагент;
		Если СоздатьКонтрагента = 1 Тогда
			Контрагент = ОбменСИнтернетМагазином.СоздатьКонтрагента(ДанныеКонтрагента,
				НастройкиЗагрузки.Организация,
				НастройкиЗагрузки.ГруппаКонтрагентов);
		КонецЕсли;
	
		РегистрыСведений.КонтрагентыИнтернетМагазина.УстановитьСоответствие(ДанныеКонтрагента.Идентификатор, Контрагент);
		РезультатСопоставления.Контрагент = Контрагент;
		
	КонецЕсли;
	
	Если СопоставлятьНоменклатуру Тогда
		
		Для каждого НоменклатураКСопоставлениюСтрока Из НоменклатураКСопоставлению Цикл
			
			Если Не ЗначениеЗаполнено(НоменклатураКСопоставлениюСтрока.Номенклатура) Тогда
				
				НоменклатураКСопоставлениюСтрока.Номенклатура =
					ОбменСИнтернетМагазином.СоздатьНоменклатуру(НоменклатураКСопоставлениюСтрока.ДанныеНоменклатуры, НастройкиЗагрузки);
			КонецЕсли;
			
			РезультатСопоставления.Номенклатура.Вставить(НоменклатураКСопоставлениюСтрока.НомерСтрокиЗаказа, НоменклатураКСопоставлениюСтрока.Номенклатура);
			
			РегистрыСведений.НоменклатураИнтернетМагазина.УстановитьСоответствие(
				НоменклатураКСопоставлениюСтрока.ИдентификаторНоменклатуры,
				НоменклатураКСопоставлениюСтрока.Номенклатура);
				
		КонецЦикла;
		
	КонецЕсли;
	
	ОбменСИнтернетМагазином.УдалитьДанныеДляСопоставления(ДокументСсылка);
	
	Возврат РезультатСопоставления;
	
КонецФункции

&НаКлиентеНаСервереБезКонтекста 
Процедура ПереключитьСтраницы(Форма, Страница)
	
	КнопкаНазад = Ложь;
	КнопкаДалее = Ложь;
	
	Элементы = Форма.Элементы;
	Если Страница = "КОНТРАГЕНТ" Тогда
		Элементы.СтраницыМастера.ТекущаяСтраница = Элементы.СтраницаКонтрагент;
		
		Форма.Заголовок = НСтр("ru = 'Помощник сопоставления контрагентов'");
		Элементы.ДекорацияЗаголовок.Заголовок = НСтр("ru = 'Сопоставьте покупателя интернет-магазина с данными в информационной базе'");
		
		КнопкаДалее = Форма.СопоставлятьНоменклатуру;
		
	ИначеЕсли Страница = "НОМЕНКЛАТУРА" Тогда
		Элементы.СтраницыМастера.ТекущаяСтраница = Элементы.СтраницаНоменклатура;
		
		КнопкаНазад = Форма.СопоставлятьКонтрагента;
		
		Форма.Заголовок = НСтр("ru = 'Помощник сопоставления номенклатуры'");
		Элементы.ДекорацияЗаголовок.Заголовок = НСтр("ru = 'Сопоставьте товары и услуги интернет-магазина с данными в информационной базе'");
	КонецЕсли;
	
	КоличествоСтраниц = ?(Форма.СопоставлятьНоменклатуру,1,0) + ?(Форма.СопоставлятьКонтрагента,1,0);
	
	Элементы.ФормаПеренестиВДокумент.Видимость = (КоличествоСтраниц = 1) ИЛИ (Страница = "НОМЕНКЛАТУРА");
	Элементы.ФормаНазад.Видимость = КнопкаНазад;
	Элементы.ФормаДалее.Видимость = КнопкаДалее;
	
	Элементы.ФормаДалее.КнопкаПоУмолчанию = Элементы.ФормаДалее.Видимость;
	Элементы.ФормаПеренестиВДокумент.КнопкаПоУмолчанию = Элементы.ФормаПеренестиВДокумент.Видимость;

	
КонецПроцедуры

#КонецОбласти