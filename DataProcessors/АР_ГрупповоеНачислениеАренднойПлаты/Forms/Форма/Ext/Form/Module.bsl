﻿
////////////////////////////////////////////////////////////////////////////////
// ПРОЦЕДУРЫ И ФУНКЦИИ ОБЩЕГО НАЗНАЧЕНИЯ

&НаСервере
Процедура СформироватьДокументыНаСервере()
	
	СхемаКомпоновкиДанных = Обработки.АР_ГрупповоеНачислениеАренднойПлаты.ПолучитьМакет("Макет");;
	НастройкиКомпоновки = КомпоновщикНастроек.Настройки;
	КомпоновщикМакета = Новый КомпоновщикМакетаКомпоновкиДанных;
	Попытка 
		МакетКомпоновки = КомпоновщикМакета.Выполнить(СхемаКомпоновкиДанных, НастройкиКомпоновки, , , Тип("ГенераторМакетаКомпоновкиДанныхДляКоллекцииЗначений"));
		
		ПроцессорКомпоновки = Новый ПроцессорКомпоновкиДанных;
		ПроцессорКомпоновки.Инициализировать(МакетКомпоновки, , , Истина);
		
		ПроцессорВывода = Новый ПроцессорВыводаРезультатаКомпоновкиДанныхВКоллекциюЗначений;
		
		ТаблицаЗначений =  Новый ТаблицаЗначений;
		
		ПроцессорВывода.УстановитьОбъект(ТаблицаЗначений);
		ПроцессорВывода.Вывести(ПроцессорКомпоновки);
	Исключение
		Возврат;
	КонецПопытки;
	
	СписокКонтрагентов = Новый СписокЗначений;
	СписокДоговоров = Новый СписокЗначений;
	СписокОбъектовАренды = Новый СписокЗначений;
	СписокУслуг = Новый СписокЗначений;
	
	СписокКонтрагентов.ЗагрузитьЗначения(ТаблицаЗначений.ВыгрузитьКолонку("КонтрагентСсылка"));
	СписокДоговоров.ЗагрузитьЗначения(ТаблицаЗначений.ВыгрузитьКолонку("ДоговорСсылка"));
	СписокОбъектовАренды.ЗагрузитьЗначения(ТаблицаЗначений.ВыгрузитьКолонку("ОбъектАрендыСсылка"));
	СписокУслуг.ЗагрузитьЗначения(ТаблицаЗначений.ВыгрузитьКолонку("УслугаСсылка"));
	
	ЕстьОтборПоУслугам = Ложь;
	Для Каждого ЭлементОтбора Из НастройкиКомпоновки.Отбор.Элементы Цикл
		Если Лев(Строка(ЭлементОтбора.ЛевоеЗначение), 6) = "Услуга" Тогда
			Если ЭлементОтбора.Использование Тогда
				ЕстьОтборПоУслугам = Истина;
				Прервать;
			КонецЕсли;
		КонецЕсли;
	КонецЦикла;
	ЕстьОтборПоОбъекту = Ложь;
	Для Каждого ЭлементОтбора Из НастройкиКомпоновки.Отбор.Элементы Цикл
		Если Лев(Строка(ЭлементОтбора.ЛевоеЗначение), 6) = "Объект" Тогда
			Если ЭлементОтбора.Использование Тогда
				ЕстьОтборПоОбъекту = Истина;
				Прервать;
			КонецЕсли;
		КонецЕсли;
	КонецЦикла;
	Если Не ЕстьОтборПоОбъекту Тогда 
		СписокОбъектовАренды.Добавить(Справочники.АР_ОбъектыАренды.ПустаяСсылка());
	КонецЕсли;
 	
	Запрос = Новый Запрос;
	
	// Сделаем проверку на то, сфорированны ли ранее документы
	Запрос.УстановитьПараметр("СписокКонтрагентов", СписокКонтрагентов);
	Запрос.УстановитьПараметр("СписокДоговоров", СписокДоговоров);
	Запрос.УстановитьПараметр("СписокУслуг", СписокУслуг);
	Запрос.УстановитьПараметр("СписокОбъектовАренды", СписокОбъектовАренды);
	Запрос.УстановитьПараметр("НачалоПериода", Объект.НачалоПериода);
	Запрос.УстановитьПараметр("ОкончаниеПериода", Объект.ОкончаниеПериода);
	Запрос.УстановитьПараметр("ОкончаниеПериодаКД",  КонецДня(Объект.ОкончаниеПериода));
	Запрос.Текст =
	"ВЫБРАТЬ РАЗРЕШЕННЫЕ РАЗЛИЧНЫЕ
	|	АР_НачислениеАренднойПлаты.Ссылка КАК Ссылка,
	|	АР_НачислениеАренднойПлаты.Ссылка.ПометкаУдаления КАК ПометкаУдаления
	|ИЗ
	|	Документ.АР_НачислениеАренднойПлаты.Состав КАК АР_НачислениеАренднойПлаты
	|ГДЕ
	|	АР_НачислениеАренднойПлаты.Ссылка.Контрагент В(&СписокКонтрагентов)
	|	И АР_НачислениеАренднойПлаты.Ссылка.ДоговорКонтрагента В(&СписокДоговоров)
	|	И АР_НачислениеАренднойПлаты.Ссылка.НачалоПериода >= &НачалоПериода
	|	И АР_НачислениеАренднойПлаты.Ссылка.ОкончаниеПериода <= &ОкончаниеПериода
	|	И АР_НачислениеАренднойПлаты.Номенклатура В(&СписокУслуг)
	|	И АР_НачислениеАренднойПлаты.ОбъектАренды В(&СписокОбъектовАренды)
	|	И НЕ АР_НачислениеАренднойПлаты.Ссылка.ПометкаУдаления";
	Выборка = Запрос.Выполнить().Выбрать();
	Отказ = Ложь;
	Пока Выборка.Следующий() Цикл
		Если Объект.ПометитьНаУдалениеСуществующиеДокументы = 1 Тогда
			ДокОбъект = Выборка.Ссылка.ПолучитьОбъект();
			ДокОбъект.УстановитьПометкуУдаления(Истина);
			ТекстСообщения = НСтр("ru = 'Документ """ + Строка(Выборка.Ссылка) + """ помечен на удаление'");
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(ТекстСообщения, Выборка.Ссылка);
		ИначеЕсли Объект.ПометитьНаУдалениеСуществующиеДокументы = 0 Тогда
			ТекстСообщения = НСтр("ru = 'Имеется документ """ + Строка(Выборка.Ссылка) + """, созданный ранее по текущим параметрам отбора'");
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(ТекстСообщения, Выборка.Ссылка,,, Отказ);
		КонецЕсли;
	КонецЦикла;
	
	Если Объект.ПометитьНаУдалениеСуществующиеДокументы = 2 Тогда
		Запрос.Текст = 
		"ВЫБРАТЬ РАЗРЕШЕННЫЕ РАЗЛИЧНЫЕ
		|	НачислениеАренднойПлатыСостав.Ссылка.ДоговорКонтрагента,
		|	НачислениеАренднойПлатыСостав.Номенклатура,
		|	НачислениеАренднойПлатыСостав.ОбъектАренды
		|ИЗ
		|	Документ.АР_НачислениеАренднойПлаты.Состав КАК НачислениеАренднойПлатыСостав
		|ГДЕ
		|	НЕ НачислениеАренднойПлатыСостав.Ссылка.ПометкаУдаления
		|	И НачислениеАренднойПлатыСостав.Ссылка.НачалоПериода = &НачалоПериода
		|	И НачислениеАренднойПлатыСостав.Ссылка.ОкончаниеПериода = &ОкончаниеПериода";
		ТаблицаРанееСформированныхДокументов = Запрос.Выполнить().Выгрузить();
	КонецЕсли;	
	
	Если Отказ Тогда
		ТекстСообщения = НСтр("ru = 'Формирование документов прервано'");
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(ТекстСообщения);
		Возврат;
	КонецЕсли;
	
	// Сформируем документы "Начисление арендной платы"
	Запрос.Текст = 
	
	"ВЫБРАТЬ РАЗРЕШЕННЫЕ РАЗЛИЧНЫЕ
	|	АР_СтатусыОбъектовАрендыСрезПоследних.Договор КАК ДоговорКонтрагента,
	|	АР_СтатусыОбъектовАрендыСрезПоследних.Договор.Владелец КАК Контрагент,
	|	АР_СтатусыОбъектовАрендыСрезПоследних.Договор.Организация КАК Организация,
	|	МАКСИМУМ(АР_СтатусыОбъектовАрендыСрезПоследних.Регистратор.СуммаВключаетНДС) КАК СуммаВключаетНДС,
	|	ЕСТЬNULL(ПараметрыНДСПоДоговорам.СпособВыставленияДокументов = ЗНАЧЕНИЕ(Перечисление.СпособыВыставленияДокументов.УниверсальныйДокумент), ЛОЖЬ) КАК ЭтоУниверсальныйДокумент
	|ИЗ
	|	РегистрСведений.АР_СтатусыОбъектовАренды.СрезПоследних(
	|			&ОкончаниеПериодаКД,
	|			Договор.Владелец В (&СписокКонтрагентов)
	|				И Договор В (&СписокДоговоров)) КАК АР_СтатусыОбъектовАрендыСрезПоследних
	|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.ПараметрыНДСПоДоговорам КАК ПараметрыНДСПоДоговорам
	|		ПО АР_СтатусыОбъектовАрендыСрезПоследних.Договор = ПараметрыНДСПоДоговорам.ДоговорКонтрагента
	|			И АР_СтатусыОбъектовАрендыСрезПоследних.Договор.Организация = ПараметрыНДСПоДоговорам.Организация
	|			И АР_СтатусыОбъектовАрендыСрезПоследних.Договор.Владелец = ПараметрыНДСПоДоговорам.Контрагент
	|ГДЕ
	|	АР_СтатусыОбъектовАрендыСрезПоследних.Статус = &ВАренде
	|	И (АР_СтатусыОбъектовАрендыСрезПоследних.ДатаНачалаАренды МЕЖДУ &НачалоПериода И &ОкончаниеПериода
	|			ИЛИ АР_СтатусыОбъектовАрендыСрезПоследних.ДатаОкончанияАренды МЕЖДУ &НачалоПериода И &ОкончаниеПериода
	|			ИЛИ АР_СтатусыОбъектовАрендыСрезПоследних.ДатаНачалаАренды <= &НачалоПериода
	|				И АР_СтатусыОбъектовАрендыСрезПоследних.ДатаОкончанияАренды >= &ОкончаниеПериода)
	|
	|СГРУППИРОВАТЬ ПО
	|	АР_СтатусыОбъектовАрендыСрезПоследних.Договор,
	|	АР_СтатусыОбъектовАрендыСрезПоследних.Договор.Владелец,
	|	АР_СтатусыОбъектовАрендыСрезПоследних.Договор.Организация,
	|	ЕСТЬNULL(ПараметрыНДСПоДоговорам.СпособВыставленияДокументов = ЗНАЧЕНИЕ(Перечисление.СпособыВыставленияДокументов.УниверсальныйДокумент), ЛОЖЬ)
	|
	|УПОРЯДОЧИТЬ ПО
	|	АР_СтатусыОбъектовАрендыСрезПоследних.Договор.Владелец.Наименование";
	
	Запрос.УстановитьПараметр("ВАренде", Перечисления.АР_СтатусыОбъектовАренды.ВАренде);
		
	Комментарий = "Групповое начисление арендной платы от "+ Формат(ТекущаяДата(), "ДФ = дд.ММ.гггг");
	
	Выборка = Запрос.Выполнить().Выбрать();
	Пока Выборка.Следующий() Цикл  //по парам "Контрагент-Договор"
		
		Начисление = Документы.АР_НачислениеАренднойПлаты.СоздатьДокумент();
		
		ЗаполнитьЗначенияСвойств(Начисление, Выборка);
		Начисление.СчетОрганизации = Начисление.Организация.ОсновнойБанковскийСчет;
		Если Объект.ВремяЗаписиДокуменов = 0 Тогда
			ДатаДокумента = Объект.ДатаНачисления + Число(ТекущаяДата() - НачалоДня(ТекущаяДата()));
		ИначеЕсли Объект.ВремяЗаписиДокуменов = 1 Тогда
			ДатаДокумента = НачалоДня(Объект.ДатаНачисления);
		Иначе
			ДатаДокумента = КонецДня(Объект.ДатаНачисления);
		КонецЕсли;
		
		Уполномоченные = УстановитьРуководителяИГлавногоБухгалтера(Выборка.Организация);
		Начисление.Руководитель = Уполномоченные.Руководитель;
		Начисление.ЗаРуководителяНаОсновании = Справочники.ОснованияПраваПодписи.ОснованиеПраваПодписиФизЛица(Начисление.Руководитель, Начисление.Организация, ДатаДокумента);
		
		Начисление.Дата = ДатаДокумента;
		Начисление.ДатаКурса = Объект.ДатаКурса;
		Начисление.ВидПериода = Объект.ВидПериода;
		Начисление.ВалютаДокумента = Начисление.ДоговорКонтрагента.ВалютаВзаиморасчетов;
		
		Если ПолучитьФункциональнуюОпцию("АР_ИспользоватьСхемуОпределенияСтавокНДСПоАрендеНаОсновеДоговора") Тогда
			Если Объект.ВариантУчетаНДС = 0 Тогда
				СуммаВключаетНДС = Выборка.СуммаВключаетНДС;
			ИначеЕсли Объект.ВариантУчетаНДС = 1 Тогда
				СуммаВключаетНДС = Истина;
			Иначе
				СуммаВключаетНДС = Ложь;
			КонецЕсли;
		Иначе
			СуммаВключаетНДС = Объект.СуммаВключаетНДС;
		КонецЕсли;
		
		Начисление.СуммаВключаетНДС = СуммаВключаетНДС;
		Начисление.НачалоПериода = Объект.НачалоПериода;
		Начисление.ОкончаниеПериода = Объект.ОкончаниеПериода;
		Начисление.Комментарий = Комментарий;
		Начисление.СпособЗачетаАвансов = Перечисления.СпособыЗачетаАвансов.Автоматически;
		ЗаполнениеДокументов.Заполнить(Начисление);
		Начисление.ЭтоУниверсальныйДокумент = Выборка.ЭтоУниверсальныйДокумент;
		Документы.АР_НачислениеАренднойПлаты.ЗаполнитьСчетаУчетаРасчетов(Начисление);
		
		СтруктураКурса = АР_ПроцедурыНачисления.ПолучитьКурсВалюты(Начисление.ВалютаДокумента, Объект.ДатаКурса, Начисление.ДоговорКонтрагента);
        Начисление.КурсВзаиморасчетов = СтруктураКурса.Курс;
		Начисление.КратностьВзаиморасчетов = СтруктураКурса.Кратность;
		Начисление.Ответственный = Пользователи.ТекущийПользователь();
		
		СписокСчетовДляОповещения = Новый СписокЗначений;
		
		Если Объект.ПостояннаяЧастьОплаты Тогда
			Если ПостПоСчетам = 1 Тогда
				Начисление.ДобавитьПоСчету(Истина, Ложь, СписокСчетовДляОповещения);
			Иначе
				Начисление.РассчитатьПостояннуюЧастьОплаты(Ложь);
			КонецЕсли;
		КонецЕсли;
		
		Если Объект.ПеременнаяЧастьОплаты Тогда
			Если ПеремПоСчетам = 1 Тогда
				Начисление.ДобавитьПоСчету(Ложь, Ложь, СписокСчетовДляОповещения);
			Иначе
				Начисление.РассчитатьПеременнуюЧастьОплаты(Ложь);
			КонецЕсли;
		КонецЕсли;
		
		ТаблицаСчетов = Начисление.Состав.Выгрузить(, "СчетНаАренду");
		ТаблицаСчетов.Свернуть("СчетНаАренду");
		Если ТаблицаСчетов.Количество() = 1 Тогда
			Начисление.ДокументОснование = ТаблицаСчетов[0].СчетНаАренду;	
		КонецЕсли;
		
		//теперь необходимо применить отбор по услугам и объектам аренды
		Индекс = 0;
		Пока Индекс < Начисление.Состав.Количество() Цикл
			Стр = Начисление.Состав[Индекс];
			Если (СписокУслуг.НайтиПоЗначению(Стр.Номенклатура) = Неопределено) и ЕстьОтборПоУслугам Тогда
				Начисление.Состав.Удалить(Индекс);
				Продолжить;
			КонецЕсли;
			Если (СписокОбъектовАренды.НайтиПоЗначению(Стр.ОбъектАренды) = Неопределено) и ЕстьОтборПоОбъекту Тогда
				Начисление.Состав.Удалить(Индекс);
				Продолжить;
			КонецЕсли;
			Индекс = Индекс + 1;
		КонецЦикла;
		
		// Проверим, есть ли уже такой документ
		Если Объект.ПометитьНаУдалениеСуществующиеДокументы = 2 Тогда
			ЕстьДокумент = Ложь;
			Для Каждого СтрокаТЧ Из Начисление.Состав Цикл
				СтруктураОтбора = Новый Структура("ДоговорКонтрагента, Номенклатура, ОбъектАренды", 
					Начисление.ДоговорКонтрагента, СтрокаТЧ.Номенклатура, СтрокаТЧ.ОбъектАренды);	
				НайденныеСтроки = ТаблицаРанееСформированныхДокументов.НайтиСтроки(СтруктураОтбора);
				Если НайденныеСтроки.Количество() > 0 Тогда
					ЕстьДокумент = Истина;
					Прервать;
				КонецЕсли;
			КонецЦикла;
			Если ЕстьДокумент Тогда
				Продолжить;
			КонецЕсли;
		КонецЕсли;
		
		Если Начисление.Состав.Количество()>0 Тогда
			Отказ = Ложь;
			
			Попытка
				Начисление.Записать();
				СтрокаТЧ = Объект.СформированныеДокументы.Добавить();
				СтрокаТЧ.Документ = Начисление.Ссылка;
			Исключение
				Отказ = Истина;
			КонецПопытки;
			
			МассивДокументов = Новый Массив;
			МассивДокументов.Добавить(Начисление.Ссылка);
			СчетаФактурыНеТребуются = Документы.АР_НачислениеАренднойПлаты.СчетаФактурыНеТребуются(МассивДокументов);
			
			Если Начисление.ЭтоУниверсальныйДокумент
			   И СчетаФактурыНеТребуются.Количество() = 0 Тогда
				ОбъектСчетаФактуры = Документы.СчетФактураВыданный.СоздатьДокумент();
				ОбъектСчетаФактуры.ДокументыОснования.Очистить();
				ОбъектСчетаФактуры.ВидСчетаФактуры = Перечисления.ВидСчетаФактурыВыставленного.НаРеализацию;
				ОбъектСчетаФактуры.Заполнить(Начисление.Ссылка); 
				
				Попытка
					ОбъектСчетаФактуры.Записать();
					СтатусыДокумента = РегистрыСведений.СтатусыДокументов.НовыеСтатусыДокумента();
					СтатусыДокумента.Статус            = Перечисления.СтатусыДокументовРеализации.НеПодписан;
					СтатусыДокумента.СтатусСФ          = Перечисления.СтатусыСчетаФактуры.НеПроведен;
					СтатусыДокумента.НомерСчетаФактуры = ПрефиксацияОбъектовКлиентСервер.НомерНаПечать(Начисление.Номер, Истина, Ложь);
					РегистрыСведений.СтатусыДокументов.УстановитьСтатусыДокумента(Начисление.Ссылка, СтатусыДокумента);
				Исключение
				КонецПопытки;
			КонецЕсли;
			
			Если Отказ Тогда
				Продолжить;
			КонецЕсли;
			
		КонецЕсли;
		
	КонецЦикла;
	
	ЗаполнитьСостоянияДокументов();
	
	ТекстСообщения = НСтр("ru = 'Формирование документов завершено'");
	ОбщегоНазначенияКлиентСервер.СообщитьПользователю(ТекстСообщения);
	
КонецПроцедуры

&НаСервере
Процедура ЗаполнитьСуществующимиДокументамиНаСервере()
	
	СхемаКомпоновкиДанных = Обработки.АР_ГрупповоеНачислениеАренднойПлаты.ПолучитьМакет("Макет");;
	НастройкиКомпоновки = КомпоновщикНастроек.Настройки;
	КомпоновщикМакета = Новый КомпоновщикМакетаКомпоновкиДанных;
	Попытка 
		МакетКомпоновки = КомпоновщикМакета.Выполнить(СхемаКомпоновкиДанных, НастройкиКомпоновки, , , Тип("ГенераторМакетаКомпоновкиДанныхДляКоллекцииЗначений"));
		
		ПроцессорКомпоновки = Новый ПроцессорКомпоновкиДанных;
		ПроцессорКомпоновки.Инициализировать(МакетКомпоновки, , , Истина);
		
		ПроцессорВывода = Новый ПроцессорВыводаРезультатаКомпоновкиДанныхВКоллекциюЗначений;
		
		ТаблицаЗначений =  Новый ТаблицаЗначений;
		
		ПроцессорВывода.УстановитьОбъект(ТаблицаЗначений);
		ПроцессорВывода.Вывести(ПроцессорКомпоновки);
	Исключение
		Возврат;
	КонецПопытки;
	
	СписокКонтрагентов = Новый СписокЗначений;
	СписокДоговоров = Новый СписокЗначений;
	СписокОбъектовАренды = Новый СписокЗначений;
	СписокУслуг = Новый СписокЗначений;
	
	СписокКонтрагентов.ЗагрузитьЗначения(ТаблицаЗначений.ВыгрузитьКолонку("КонтрагентСсылка"));
	СписокДоговоров.ЗагрузитьЗначения(ТаблицаЗначений.ВыгрузитьКолонку("ДоговорСсылка"));
	СписокОбъектовАренды.ЗагрузитьЗначения(ТаблицаЗначений.ВыгрузитьКолонку("ОбъектАрендыСсылка"));
	СписокУслуг.ЗагрузитьЗначения(ТаблицаЗначений.ВыгрузитьКолонку("УслугаСсылка"));
	
	ЕстьОтборПоУслугам = Ложь;
	Для Каждого ЭлементОтбора Из НастройкиКомпоновки.Отбор.Элементы Цикл
		Если Лев(Строка(ЭлементОтбора.ЛевоеЗначение), 6) = "Услуга" Тогда
			Если ЭлементОтбора.Использование Тогда
				ЕстьОтборПоУслугам = Истина;
				Прервать;
			КонецЕсли;
		КонецЕсли;
	КонецЦикла;
	ЕстьОтборПоОбъекту = Ложь;
	Для Каждого ЭлементОтбора Из НастройкиКомпоновки.Отбор.Элементы Цикл
		Если Лев(Строка(ЭлементОтбора.ЛевоеЗначение), 6) = "Объект" Тогда
			Если ЭлементОтбора.Использование Тогда
				ЕстьОтборПоОбъекту = Истина;
				Прервать;
			КонецЕсли;
		КонецЕсли;
	КонецЦикла;
	Если Не ЕстьОтборПоОбъекту Тогда 
		СписокОбъектовАренды.Добавить(Справочники.АР_ОбъектыАренды.ПустаяСсылка());
	КонецЕсли;
 	
	Запрос = Новый Запрос;
	
	// Сделаем проверку на то, сфорированны ли ранее документы
	Запрос.УстановитьПараметр("СписокКонтрагентов", СписокКонтрагентов);
	Запрос.УстановитьПараметр("СписокДоговоров", СписокДоговоров);
	Запрос.УстановитьПараметр("СписокУслуг", СписокУслуг);
	Запрос.УстановитьПараметр("СписокОбъектовАренды", СписокОбъектовАренды);
	Запрос.УстановитьПараметр("НачалоПериода", Объект.НачалоПериода);
	Запрос.УстановитьПараметр("ОкончаниеПериода", Объект.ОкончаниеПериода);
	Запрос.Текст =
	"ВЫБРАТЬ РАЗРЕШЕННЫЕ РАЗЛИЧНЫЕ
	|	АР_НачислениеАренднойПлаты.Ссылка КАК Ссылка,
	|	АР_НачислениеАренднойПлаты.Ссылка.ПометкаУдаления КАК ПометкаУдаления
	|ИЗ
	|	Документ.АР_НачислениеАренднойПлаты.Состав КАК АР_НачислениеАренднойПлаты
	|ГДЕ
	|	АР_НачислениеАренднойПлаты.Ссылка.Контрагент В(&СписокКонтрагентов)
	|	И АР_НачислениеАренднойПлаты.Ссылка.ДоговорКонтрагента В(&СписокДоговоров)
	|	И АР_НачислениеАренднойПлаты.Ссылка.НачалоПериода >= &НачалоПериода
	|	И АР_НачислениеАренднойПлаты.Ссылка.ОкончаниеПериода <= &ОкончаниеПериода
	|	И АР_НачислениеАренднойПлаты.Номенклатура В(&СписокУслуг)
	|	И АР_НачислениеАренднойПлаты.ОбъектАренды В(&СписокОбъектовАренды)
	|	И НЕ АР_НачислениеАренднойПлаты.Ссылка.ПометкаУдаления
	|
	|УПОРЯДОЧИТЬ ПО
	|	АР_НачислениеАренднойПлаты.Ссылка.Контрагент.Наименование,
	|	АР_НачислениеАренднойПлаты.Ссылка.МоментВремени";
	Выборка = Запрос.Выполнить().Выбрать();
	Пока Выборка.Следующий() Цикл
		СтрокаТЧ = Объект.СформированныеДокументы.Добавить();
		СтрокаТЧ.Документ = Выборка.Ссылка;
	КонецЦикла;
		
	ЗаполнитьСостоянияДокументов();
	
	Если Объект.СформированныеДокументы.Количество() = 0 Тогда
		ТекстСообщения = НСтр("ru = 'Данные для заполнения не обнаружены'");
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(ТекстСообщения);
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Процедура ЗаполнитьСостоянияДокументов()
	
	Для каждого СтрокаТЧ Из Объект.СформированныеДокументы Цикл
		Если СтрокаТЧ.Документ.Проведен Тогда
			СтрокаТЧ.СостояниеДокумента = 1;
		ИначеЕсли СтрокаТЧ.Документ.ПометкаУдаления Тогда
			СтрокаТЧ.СостояниеДокумента = 2;
		Иначе
			СтрокаТЧ.СостояниеДокумента = 0;
		КонецЕсли;
	КонецЦикла;
	
КонецПроцедуры

&НаСервере
Процедура ИнициализироватьКомпоновщикНастроек()
	
	СхемаКомпоновкиДанных = Обработки.АР_ГрупповоеНачислениеАренднойПлаты.ПолучитьМакет("Макет");
	КомпоновщикНастроек = Новый КомпоновщикНастроекКомпоновкиДанных;
	КомпоновщикНастроек.Инициализировать(
		Новый ИсточникДоступныхНастроекКомпоновкиДанных(ПоместитьВоВременноеХранилище(СхемаКомпоновкиДанных, ЭтаФорма.УникальныйИдентификатор))
	);
	КомпоновщикНастроек.ЗагрузитьНастройки(СхемаКомпоновкиДанных.НастройкиПоУмолчанию);
	
КонецПроцедуры

&НаКлиенте
Процедура НастроитьОтбор()
	
	ЕстьПолеОтбора = Ложь;
	ПолеКомпоновки = Новый ПолеКомпоновкиДанных("Услуга.АР_ПостояннаяЧастьОплаты");
	Для Каждого Элемент Из КомпоновщикНастроек.Настройки.Отбор.Элементы Цикл
		Если Элемент.ЛевоеЗначение = ПолеКомпоновки Тогда
			ЭлементОтбора = Элемент;
			ЕстьПолеОтбора = Истина;
		КонецЕсли;
	КонецЦикла;
	
	Если Не ЕстьПолеОтбора Тогда
		ЭлементОтбора = КомпоновщикНастроек.Настройки.Отбор.Элементы.Добавить(Тип("ЭлементОтбораКомпоновкиДанных")); 
	КонецЕсли;	
	
	ЭлементОтбора.ЛевоеЗначение = ПолеКомпоновки;
	ЭлементОтбора.ВидСравнения = ВидСравненияКомпоновкиДанных.Равно;
	ЭлементОтбора.Использование = (Не Объект.ПостояннаяЧастьОплаты ИЛИ Не Объект.ПеременнаяЧастьОплаты) И (Объект.ПостояннаяЧастьОплаты ИЛИ Объект.ПеременнаяЧастьОплаты);
	ЭлементОтбора.ПравоеЗначение = Объект.ПостояннаяЧастьОплаты;
	
КонецПроцедуры

&НаКлиенте
// Компирует элементы из одной коллекции в другую
Процедура СкопироватьЭлементы(ПриемникЗначения, ИсточникЗначения)
	
	ПриемникЭлементов = ПриемникЗначения.Элементы;
	ИсточникЭлементов = ИсточникЗначения.Элементы;
	ПриемникЭлементов.Очистить();
	
	Для каждого ЭлементИсточник Из ИсточникЭлементов Цикл
		
		Если Лев(Строка(ЭлементИсточник.ЛевоеЗначение), 10) = "Контрагент"
			ИЛИ Лев(Строка(ЭлементИсточник.ЛевоеЗначение), 7) = "Договор"
			ИЛИ Лев(Строка(ЭлементИсточник.ЛевоеЗначение), 11) = "Организация"
			ИЛИ ТипЗнч(ЭлементИсточник) = Тип("ГруппаЭлементовОтбораКомпоновкиДанных") Тогда
			ЭлементПриемник = ПриемникЭлементов.Добавить(ТипЗнч(ЭлементИсточник));
			ЗаполнитьЗначенияСвойств(ЭлементПриемник, ЭлементИсточник);
			
			// В некоторых элементах коллекции необходимо заполнить другие коллекции
			Если ТипЗнч(ЭлементИсточник) = Тип("ГруппаЭлементовОтбораКомпоновкиДанных") Тогда
				СкопироватьЭлементы(ЭлементПриемник, ЭлементИсточник);
			КонецЕсли;
		КонецЕсли;
	КонецЦикла;
	
КонецПроцедуры

&НаСервере
Процедура ПровестиДокументыНаСервере()
	
	Для каждого СтрокаТЧ из Объект.СформированныеДокументы Цикл
		Если СтрокаТЧ.Пометка Тогда
			ДокументОбъект = СтрокаТЧ.Документ.ПолучитьОбъект();
			Если ДокументОбъект <> Неопределено И НЕ ДокументОбъект.ПометкаУдаления Тогда
				Попытка
					Если ДокументОбъект.ПроверитьЗаполнение() Тогда
						ДокументОбъект.Записать(РежимЗаписиДокумента.Проведение);
						СтрокаТЧ.Пометка = Ложь;
					КонецЕсли;
				Исключение
					Сообщить("Ошибка проведения документа " + ДокументОбъект);
					Сообщить(ОписаниеОшибки());
				КонецПопытки;
			КонецЕсли;
		КонецЕсли;
	КонецЦикла;
	ЗаполнитьСостоянияДокументов();
	
КонецПроцедуры

&НаСервере
Процедура ПометитьНаУдалениеНаСервере()
	
	Для каждого СтрокаТЧ из Объект.СформированныеДокументы Цикл
		Если СтрокаТЧ.Пометка Тогда
			ДокументОбъект = СтрокаТЧ.Документ.ПолучитьОбъект();
			Если ДокументОбъект <> Неопределено Тогда
				Попытка
					ДокументОбъект.УстановитьПометкуУдаления(НЕ ДокументОбъект.ПометкаУдаления);;
					СтрокаТЧ.Пометка = Ложь;
				Исключение
				КонецПопытки;
			КонецЕсли;
		КонецЕсли;
	КонецЦикла;
	ЗаполнитьСостоянияДокументов();
	
КонецПроцедуры

&НаСервере
Функция ЕстьДокументыВВалюте()
	
	ЕстьВВалюте = Ложь;
	ВалютаРегламентированногоУчета = Константы.ВалютаРегламентированногоУчета.Получить();
	Для каждого СтрокаТЧ Из Объект.СформированныеДокументы Цикл
		Если СтрокаТЧ.Пометка И Не СтрокаТЧ.Документ.ВалютаДокумента = ВалютаРегламентированногоУчета Тогда
			ЕстьВВалюте = Истина;
			Прервать;
		КонецЕсли;
	КонецЦикла;
	
	Возврат ЕстьВВалюте;
	
КонецФункции

&НаСервере
Процедура ДобавитьВнешниеПечатныеФормы(СписокПечатныхФорм)

	ДоступныеКомандыПечати = ДополнительныеОтчетыИОбработки.НовыйЗапросПоДоступнымКомандам(
		Перечисления.ВидыДополнительныхОтчетовИОбработок.ПечатнаяФорма,
		"Документ.АР_НачислениеАренднойПлаты",
		ЛОЖЬ).Выполнить().Выгрузить();
	
		
	Для Каждого КомандаПечати Из ДоступныеКомандыПечати Цикл
		СписокПечатныхФорм.Добавить(Новый Структура("Идентификатор, Ссылка, Внешняя", КомандаПечати.Идентификатор, КомандаПечати.Ссылка, Истина), КомандаПечати.Представление);
	КонецЦикла;

КонецПроцедуры

&НаСервере
Функция ПолучитьСписокПечатныхФорм()
	
	КомандыПечати = УправлениеПечатью.СоздатьКоллекциюКомандПечати();
	Документы.АР_НачислениеАренднойПлаты.ДобавитьКомандыПечати(КомандыПечати);
	
	СписокПечатныхФорм = Новый СписокЗначений;
	
	Для Каждого Команда Из КомандыПечати Цикл
		Если Команда.Идентификатор = "Реестр" ИЛИ Команда.Идентификатор = "АктРуб" ИЛИ Команда.Идентификатор = "АктСводныйРуб" Тогда
			Продолжить;
		КонецЕсли;
		Ключ = Новый Структура("МенеджерПечати, Идентификатор, Обработчик");
		ЗаполнитьЗначенияСвойств(Ключ, Команда);
		Если НЕ ЗначениеЗаполнено(Ключ.МенеджерПечати) Тогда
			Если Лев(Команда.Идентификатор, 11) = "СчетФактура" Тогда
				Ключ.МенеджерПечати = "Документ.СчетФактураВыданный";
			ИначеЕсли Лев(Команда.Идентификатор, 33) = "УниверсальныйПередаточныйДокумент" Тогда
				Ключ.МенеджерПечати = "Обработка.ПечатьУПД";
			Иначе
				Ключ.МенеджерПечати = "Документ.АР_НачислениеАренднойПлаты";
			КонецЕсли;
		КонецЕсли;
		Ключ.Вставить("Внешняя", Ложь);
		Ключ.Вставить("ПараметрыПечати", Новый Структура);
		Для Каждого Элемент Из Команда.ДополнительныеПараметры Цикл
			Ключ.ПараметрыПечати.Вставить(Элемент.Ключ, Элемент.Значение);	
		КонецЦикла;
		СписокПечатныхФорм.Добавить(Ключ, Команда.Представление);
	КонецЦикла;
	
	ДобавитьВнешниеПечатныеФормы(СписокПечатныхФорм);
	
	Возврат СписокПечатныхФорм;
	
КонецФункции

&НаКлиенте
Процедура ВыполнитьПечатьНаКлиенте(КомандаПечати, НаПринтер)
	
	МассивДокументов = Новый Массив;	
	Для каждого СтрокаТЧ Из Объект.СформированныеДокументы Цикл
		Если СтрокаТЧ.Пометка Тогда
			МассивДокументов.Добавить(СтрокаТЧ.Документ);
		КонецЕсли;
	КонецЦикла;
	
	Если МассивДокументов.Количество() = 0 Тогда
		Возврат;
	КонецЕсли;
	
	ДополнительныеПараметры = Новый Структура;
	ДополнительныеПараметры.Вставить("КомандаПечати", КомандаПечати);
	ДополнительныеПараметры.Вставить("НаПринтер", НаПринтер);
	
	ОписаниеОповещения = Новый ОписаниеОповещения("ВыполнитьПечатьНаКлиентеЗавершение", ЭтотОбъект, ДополнительныеПараметры);
	УправлениеПечатьюКлиент.ПроверитьПроведенностьДокументов(ОписаниеОповещения, МассивДокументов, ЭтаФорма);
		
КонецПроцедуры

&НаКлиенте
Процедура ВыполнитьПечатьНаКлиентеЗавершение(МассивДокументов, ДополнительныеПараметры) Экспорт
	
	ЗаполнитьСостоянияДокументов();
	
	КомандаПечати = ДополнительныеПараметры.КомандаПечати;
	НаПринтер = ДополнительныеПараметры.НаПринтер;
	
	Если НЕ КомандаПечати.Внешняя И КомандаПечати.МенеджерПечати = "Документ.СчетФактураВыданный" Тогда
		НастройкиПечати = УчетНДСВызовСервера.ПолучитьНастройкиПечатиСчетовФактур(МассивДокументов);
		КомандаПечати.Идентификатор = НастройкиПечати.СписокМакетов;
		МассивДокументов = НастройкиПечати.СчетаФактуры;
	ИначеЕсли НЕ КомандаПечати.Внешняя И КомандаПечати.МенеджерПечати = "Обработка.ПечатьУПД" Тогда
		НастройкиПечати = УчетНДСВызовСервера.ПолучитьНастройкиПечатиУниверсальныхПередаточныхДокументов(МассивДокументов);
		КомандаПечати.Идентификатор = НастройкиПечати.СписокМакетов;
		МассивДокументов = НастройкиПечати.УниверсальныеПередаточныеДокументы;
	КонецЕсли;
	
	Если КомандаПечати.Внешняя Тогда
	    ДополнительныеОтчетыИОбработкиКлиент.ВыполнитьОткрытиеПечатнойФормы(КомандаПечати, ЭтаФорма, МассивДокументов);
	ИначеЕсли КомандаПечати.Идентификатор = "КомплектДокументов" Тогда
		ПечатьКомплектаСразуНаПринтер = ОбщегоНазначенияВызовСервера.ХранилищеОбщихНастроекЗагрузить("ОбщиеНастройкиПользователя", "ПечатьКомплектаСразуНаПринтер",Ложь);
		ОбщегоНазначенияВызовСервера.ХранилищеОбщихНастроекСохранить("ОбщиеНастройкиПользователя", "ПечатьКомплектаСразуНаПринтер", НаПринтер);
		УправлениеПечатьюБПКлиент.ПечатьКомплектаДокументов(Новый Структура("ОбъектыПечати, МенеджерПечати, Форма", МассивДокументов, КомандаПечати.МенеджерПечати, Новый Структура("ИмяФормы", "Документ.АР_НачислениеАренднойПлаты.Форма.ФормаСписка"))); 
		ОбщегоНазначенияВызовСервера.ХранилищеОбщихНастроекСохранить("ОбщиеНастройкиПользователя", "ПечатьКомплектаСразуНаПринтер", ПечатьКомплектаСразуНаПринтер);
	ИначеЕсли НаПринтер Тогда
		УправлениеПечатьюКлиент.ВыполнитьКомандуПечатиНаПринтер(КомандаПечати.МенеджерПечати, КомандаПечати.Идентификатор, МассивДокументов, КомандаПечати.ПараметрыПечати);
	Иначе
		УправлениеПечатьюКлиент.ВыполнитьКомандуПечати(КомандаПечати.МенеджерПечати, КомандаПечати.Идентификатор, МассивДокументов, ЭтаФорма, КомандаПечати.ПараметрыПечати);
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Функция ПолучитьПараметрыВыбораЗначенияОтбора() Экспорт
	
	СписокПараметров = Новый Структура;
	СписокПараметров.Вставить("Организация", Неопределено);
	СписокПараметров.Вставить("Контрагент", Неопределено);
	
	Возврат СписокПараметров;
	
КонецФункции

////////////////////////////////////////////////////////////////////////////////
// Работа с периодом
//

&НаКлиенте
Процедура ПериодНачалоВыбораЗавершение(СтруктураПериода, ДополнительныеПараметры) Экспорт
	
	// Установим полученный период
	Если СтруктураПериода <> Неопределено Тогда
		Объект.ВидПериода = СтруктураПериода.ВидПериода;
		Период = СтруктураПериода.Период;
		Объект.НачалоПериода = СтруктураПериода.НачалоПериода;
		Объект.ОкончаниеПериода = СтруктураПериода.КонецПериода;
	КонецЕсли;
		
КонецПроцедуры

&НаКлиенте
Процедура ВидПериодаПриИзменении(Элемент)
	
	ВыборПериодаКлиент.ВидПериодаПриИзменении(Элемент, Объект.ВидПериода, Объект.НачалоПериода, Объект.ОкончаниеПериода, Период);
	ВыборПериодаКлиентСервер.ПереключитьТекущуюСтраницуВыбораПериода(Объект.ВидПериода, Элементы.ГруппаПоляВводаПериода);
	
КонецПроцедуры

&НаКлиенте
Процедура ПериодПриИзменении(Элемент)
	
	ВыборПериодаКлиент.ПериодПриИзменении(Элемент, Период, Объект.НачалоПериода, Объект.ОкончаниеПериода);
	
КонецПроцедуры

&НаКлиенте
Процедура ПериодНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	
	ОписаниеОповещения = Новый ОписаниеОповещения("ПериодНачалоВыбораЗавершение", ЭтотОбъект);
	ВыборПериодаКлиент.ПериодНачалоВыбора(ЭтаФорма, Элемент, СтандартнаяОбработка, 
		Объект.ВидПериода, Объект.НачалоПериода, ОписаниеОповещения);
		
КонецПроцедуры

&НаКлиенте
Процедура ПериодОбработкаВыбора(Элемент, ВыбранноеЗначение, СтандартнаяОбработка)
	
	ВыборПериодаКлиент.ПериодОбработкаВыбора(
		Элемент, ВыбранноеЗначение, СтандартнаяОбработка,
		Объект.ВидПериода, Период, Объект.НачалоПериода, Объект.ОкончаниеПериода);
	
КонецПроцедуры

&НаКлиенте
Процедура ПериодАвтоПодбор(Элемент, Текст, ДанныеВыбора, Ожидание, СтандартнаяОбработка)
	
	ВыборПериодаКлиент.ПериодАвтоПодбор(
		Элемент, Текст, ДанныеВыбора, Ожидание, СтандартнаяОбработка,
		Объект.ВидПериода, Период, Объект.НачалоПериода, Объект.ОкончаниеПериода);
	
КонецПроцедуры

&НаКлиенте
Процедура ПериодОкончаниеВводаТекста(Элемент, Текст, ДанныеВыбора, СтандартнаяОбработка)
	
	ВыборПериодаКлиент.ПериодОкончаниеВводаТекста(
		Элемент, Текст, ДанныеВыбора, СтандартнаяОбработка,
		Объект.ВидПериода, Период, Объект.НачалоПериода, Объект.ОкончаниеПериода);
	
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// ПРОЦЕДУРЫ И ФУНКЦИИ ДЛЯ УПРАВЛЕНИЯ ВНЕШНИМ ВИДОМ ФОРМЫ

&НаКлиентеНаСервереБезКонтекста
Процедура УправлениеФормой(Форма)

	Элементы = Форма.Элементы;
	Объект = Форма.Объект;
	
	Элементы.ГруппаПоСчетамПостояннаяЧасть.Доступность = Объект.ПостояннаяЧастьОплаты;
	Элементы.ГруппаПоСчетамПеременнаяЧасть.Доступность = Объект.ПеременнаяЧастьОплаты;

	Форма.Период = ВыборПериодаКлиентСервер.ПолучитьПредставлениеПериодаОтчета(
		Объект.ВидПериода, Объект.НачалоПериода, Объект.ОкончаниеПериода);
		
	ВыборПериодаКлиентСервер.ПереключитьТекущуюСтраницуВыбораПериода(Объект.ВидПериода, Элементы.ГруппаПоляВводаПериода);
	
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// ПРОЦЕДУРЫ - ОБРАБОТЧИКИ СОБЫТИЙ ФОРМЫ

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	Объект.ДатаНачисления = ТекущаяДата();
	Объект.ДатаКурса = ТекущаяДата();
	Объект.ПометитьНаУдалениеСуществующиеДокументы = 1;
	Объект.СуммаВключаетНДС = Истина;
	ПостПоСчетам = 1;
	ПеремПоСчетам = 1;
		
	Если Не ЗначениеЗаполнено(Объект.ВидПериода) Тогда
		Объект.ВидПериода = АР_ОбщиеПроцедуры.ПолучитьВидПериодаПоПериодичности(Константы.АР_ПериодНачисленияАренднойПлаты.Получить());
	КонецЕсли;
	
	ИнициализироватьКомпоновщикНастроек();
	
	Настройки = АР_ОбщиеПроцедуры.ПолучитьНастройкиГрупповыхОбработок();
	Если НЕ Настройки = Неопределено И Настройки.Свойство("УчетнаяЗаписьЭлектроннойПочты") Тогда
		УчетнаяЗаписьЭлектроннойПочты = Настройки.УчетнаяЗаписьЭлектроннойПочты;
	КонецЕсли;
	
	НастроитьТекстИнформацииОНовойСхемеНДС();
	
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
		
	УправлениеФормой(ЭтаФорма);
	
КонецПроцедуры

&НаКлиенте
Процедура ПриЗакрытии(ЗавершениеРаботы)
	
	Если НЕ ЗавершениеРаботы Тогда
		АР_ОбщиеПроцедуры.СохранитьНастройкиГрупповыхОбработок(Новый Структура("УчетнаяЗаписьЭлектроннойПочты", УчетнаяЗаписьЭлектроннойПочты));
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ОбработкаОповещения(ИмяСобытия, Параметр, Источник)
	
	Если ИмяСобытия = "ИзмененаСхемаОпределенияСтавокНДС" Тогда
		НастроитьТекстИнформацииОНовойСхемеНДС();
	КонецЕсли;
	
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// ПРОЦЕДУРЫ - ДЕЙСТВИЯ КОМАНДНЫХ ПАНЕЛЕЙ ФОРМЫ

&НаКлиенте
Процедура СформироватьДокументы(Команда)
	
	Если Объект.СформированныеДокументы.Количество() > 0 Тогда
		
		Оповещение = Новый ОписаниеОповещения("СпроситьобОчисткеСформированныхДокументов", ЭтотОбъект, Ложь);
		ПоказатьВопрос(Оповещение, "Таблица сформированных документов будет очищена. Продолжить?", РежимДиалогаВопрос.ДаНет, 0, КодВозвратаДиалога.Нет);	
		
	Иначе
		СформироватьДокументыЗавершение();
	КонецЕсли;
	
	Оповестить("ГрупповоеСозданиеДокументов_НачислениеАренды");
	
КонецПроцедуры

&НаКлиенте
Процедура ЗаполнитьСуществующимиДокументами(Команда)
	
	Если Объект.СформированныеДокументы.Количество() > 0 Тогда
		
		Оповещение = Новый ОписаниеОповещения("СпроситьобОчисткеСформированныхДокументов", ЭтотОбъект, Истина);
		ПоказатьВопрос(Оповещение, "Таблица сформированных документов будет очищена. Продолжить?", РежимДиалогаВопрос.ДаНет, 0, КодВозвратаДиалога.Нет);	
		
	Иначе
		ЗаполнитьСуществующимиДокументамиЗавершение();
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура СпроситьобОчисткеСформированныхДокументов(РезультатВопроса, ЗаполнитьСуществующими) Экспорт
	
	Если РезультатВопроса = КодВозвратаДиалога.Да Тогда
		Если ЗаполнитьСуществующими Тогда
			ЗаполнитьСуществующимиДокументамиЗавершение();
		Иначе
			СформироватьДокументыЗавершение();
		КонецЕсли;
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ЗаполнитьСуществующимиДокументамиЗавершение()
	
	Объект.СформированныеДокументы.Очистить();
	Если ЭтаФорма.ПроверитьЗаполнение() Тогда
		ЗаполнитьСуществующимиДокументамиНаСервере();	
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура СформироватьДокументыЗавершение()
	
	Объект.СформированныеДокументы.Очистить();
	Если ЭтаФорма.ПроверитьЗаполнение() Тогда
		СформироватьДокументыНаСервере();
		Элементы.Страницы.ТекущаяСтраница = Элементы.ГруппаСформированныеДокументы;
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ВыставлениеСФ(Команда)
	
	ФормаОбработкиСФ = ПолучитьФорму("Обработка.АР_ГрупповоеВыставлениеСФ.Форма");
	ФормаОбработкиСФ.Объект.ВидПериода = Объект.ВидПериода;
	ФормаОбработкиСФ.Объект.НачалоПериода = Объект.НачалоПериода;
	ФормаОбработкиСФ.Объект.ОкончаниеПериода = Объект.ОкончаниеПериода;
	СкопироватьЭлементы(ФормаОбработкиСФ.КомпоновщикНастроек.Настройки.Отбор, КомпоновщикНастроек.Настройки.Отбор);
	ФормаОбработкиСФ.Открыть();
	
КонецПроцедуры

&НаКлиенте
Процедура УстановитьПометки(Команда)
	
	Для каждого СтрокаТЧ Из Объект.СформированныеДокументы Цикл
		СтрокаТЧ.Пометка = Истина;
	КонецЦикла;
	
КонецПроцедуры

&НаКлиенте
Процедура СнятьПометки(Команда)
	
	Для каждого СтрокаТЧ Из Объект.СформированныеДокументы Цикл
		СтрокаТЧ.Пометка = Ложь;
	КонецЦикла;
	
КонецПроцедуры

&НаКлиенте
Процедура Провести(Команда)
	
	ПровестиДокументыНаСервере();
	
	Оповестить("ГрупповоеСозданиеДокументов_НачислениеАренды");
	
КонецПроцедуры

&НаКлиенте
Процедура ПометитьНаУдаление(Команда)
	
	ПометитьНаУдалениеНаСервере();
	
	Оповестить("ГрупповоеСозданиеДокументов_НачислениеАренды");
	
КонецПроцедуры

&НаКлиенте
Процедура ПечатьПросмотр(Команда)
	
	СписокПечатныхФорм = ПолучитьСписокПечатныхФорм();
	ОписаниеОповещения = Новый ОписаниеОповещения("ПечатьЗавершение", ЭтаФорма, Ложь);
	
	СтруктураПараметров = Новый Структура("Заголовок, Список",
		НСтр("ru = 'Выберите печатную форму'"),
		СписокПечатныхФорм);
	
	ОткрытьФорму("ОбщаяФорма.АР_ФормаВыбораИзСписка", СтруктураПараметров, ЭтотОбъект,,,, ОписаниеОповещения);
	
КонецПроцедуры

&НаКлиенте
Процедура ПечатьНаПринтер(Команда)
	
	СписокПечатныхФорм = ПолучитьСписокПечатныхФорм();
	ОписаниеОповещения = Новый ОписаниеОповещения("ПечатьЗавершение", ЭтаФорма, Истина);
	
	СтруктураПараметров = Новый Структура("Заголовок, Список",
		НСтр("ru = 'Выберите печатную форму'"),
		СписокПечатныхФорм);
	
	ОткрытьФорму("ОбщаяФорма.АР_ФормаВыбораИзСписка", СтруктураПараметров, ЭтотОбъект,,,, ОписаниеОповещения);
	
КонецПроцедуры

&НаКлиенте
Процедура ОтправитьПоЭлектроннойПочте(Команда)
	
	МассивДокументов = Новый Массив;
	Для Каждого СтрокаТЧ Из Объект.СформированныеДокументы Цикл
		Если СтрокаТЧ.Пометка Тогда
			МассивДокументов.Добавить(СтрокаТЧ.Документ);
		КонецЕсли;
	КонецЦикла;
	
	Если МассивДокументов.Количество() > 0 Тогда
		АР_ОбщиеПроцедурыКлиент.ОтправитьПоЭлектроннойПочте(МассивДокументов, "АР_НачислениеАренднойПлаты", УчетнаяЗаписьЭлектроннойПочты);
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ОткрытьНастройкуГрупповыхОбработок(Команда)
	
	АР_ОбщиеПроцедурыКлиент.ОткрытьНастройкуГрупповыхОбработок(ЭтаФорма);
	
КонецПроцедуры

&НаКлиенте
Процедура ПерейтиНаНовуюСхемуНДС(Команда)
	ОткрытьФорму("Обработка.АР_ПереходНаНовуюСхемуОпределенияСтавокНДС.Форма");
КонецПроцедуры

&НаКлиенте
Процедура ПечатьЗавершение(ВыбранныйЭлемент, НаПринтер) Экспорт
	
	Если НЕ ВыбранныйЭлемент = Неопределено Тогда
		ВыполнитьПечатьНаКлиенте(ВыбранныйЭлемент.Значение, НаПринтер);
	КонецЕсли;
	
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// ПРОЦЕДУРЫ - ОБРАБОТЧИКИ СОБЫТИЙ РЕКВИЗИТОВ ШАПКИ

&НаКлиенте
Процедура ДатаНачисленияПриИзменении(Элемент)
	
	Объект.ДатаКурса = Объект.ДатаНачисления;
	
КонецПроцедуры

&НаКлиенте
Процедура ПостояннаяЧастьОплатыПриИзменении(Элемент)
	
	НастроитьОтбор();
	УправлениеФормой(ЭтаФорма);
	
КонецПроцедуры

&НаКлиенте
Процедура ПеременнаяЧастьОплатыПриИзменении(Элемент)
	
	НастроитьОтбор();
	УправлениеФормой(ЭтаФорма);
	
КонецПроцедуры

&НаКлиенте
Процедура СформированныеДокументыВыбор(Элемент, ВыбраннаяСтрока, Поле, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	Попытка
		ПоказатьЗначение(, Элементы.СформированныеДокументы.ТекущиеДанные.Документ);
	Исключение
	КонецПопытки;
	
КонецПроцедуры

&НаКлиенте
Процедура ОтборыПравоеЗначениеНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	
	СписокПараметров = ПолучитьПараметрыВыбораЗначенияОтбора();
	АР_ОбщиеПроцедурыКлиент.ОтборыПравоеЗначениеНачалоВыбора(ЭтаФорма, Элемент, ДанныеВыбора, СтандартнаяОбработка, СписокПараметров);
	
КонецПроцедуры

&НаСервере
Функция УстановитьРуководителяИГлавногоБухгалтера(Организация)
	
	СтруктураВозврата = Новый Структура("Руководитель, ЗаРуководителяПоПриказу");
	
	Если НЕ ЗначениеЗаполнено(Организация) Тогда 
		Возврат СтруктураВозврата;
	КонецЕсли;
	
	СтруктураВозврата = Новый Структура("Руководитель, ЗаРуководителяПоПриказу");
	
	ДанныеУполномоченногоЛица = ОтветственныеЛицаБППереопределяемый.ДанныеУполномоченногоЛица(Организация, Пользователи.ТекущийПользователь());
	ОтветственныеЛица = ОтветственныеЛицаБП.ОтветственныеЛица(Организация, Объект.НачалоПериода);
	
	Если ДанныеУполномоченногоЛица = Неопределено Тогда 
		СтруктураВозврата.Руководитель = ОтветственныеЛица.Руководитель;
		СтруктураВозврата.ЗаРуководителяПоПриказу = "";
	Иначе
		СтруктураВозврата.Руководитель = ?(ЗначениеЗаполнено(ДанныеУполномоченногоЛица.Руководитель), ДанныеУполномоченногоЛица.Руководитель, ОтветственныеЛица.Руководитель);
		СтруктураВозврата.ЗаРуководителяПоПриказу = ?(ЗначениеЗаполнено(ДанныеУполномоченногоЛица.Руководитель), ДанныеУполномоченногоЛица.РуководительНаОсновании, "");
	КонецЕсли;
	
	Возврат СтруктураВозврата;
	
КонецФункции

&НаСервере
Процедура НастроитьТекстИнформацииОНовойСхемеНДС()
	
	Если ПолучитьФункциональнуюОпцию("АР_ИспользоватьСхемуОпределенияСтавокНДСПоАрендеНаОсновеДоговора") Тогда
		Элементы.ИнформацияОНовойСхемеНДС.Видимость = Ложь;
		Элементы.СуммаВключаетНДС.Видимость = Ложь;
		Элементы.ВариантУчетаНДС.Видимость = Истина;
	Иначе
		Элементы.ИнформацияОНовойСхемеНДС.Видимость = Истина;
		Элементы.СуммаВключаетНДС.Видимость = Истина;
		Элементы.ВариантУчетаНДС.Видимость = Ложь;
		
		Элементы.ТекстИнформацияОНовойСхемеНДС.Заголовок = "Добавлена возможность явного указания ставок НДС по услугам в договоре аренды. 
			|Рекомендуется выполнить переход на новую схему определения ставок НДС.
			|";
	КонецЕсли;	
	
КонецПроцедуры
