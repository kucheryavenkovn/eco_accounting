﻿
#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	ГоловнаяОрганизация = Параметры.ГоловнаяОрганизация;
	ФизическоеЛицо      = Параметры.ФизическоеЛицо;
	
	Если Год = 0 Тогда
		Год = Год(ТекущаяДатаСеанса());
		
		Запрос = Новый Запрос;
		Запрос.УстановитьПараметр("ФизическоеЛицо", ФизическоеЛицо);
		Запрос.УстановитьПараметр("ГоловнаяОрганизация", ГоловнаяОрганизация);
		Запрос.Текст = 
		"ВЫБРАТЬ
		|	МАКСИМУМ(ВычетыПредыдущегоМестаРаботыНДФЛ.НалоговыйПериод) КАК НалоговыйПериод
		|ИЗ
		|	РегистрСведений.ВычетыПредыдущегоМестаРаботыНДФЛ КАК ВычетыПредыдущегоМестаРаботыНДФЛ
		|ГДЕ
		|	ВычетыПредыдущегоМестаРаботыНДФЛ.ФизическоеЛицо = &ФизическоеЛицо
		|	И ВычетыПредыдущегоМестаРаботыНДФЛ.ГоловнаяОрганизация = &ГоловнаяОрганизация";
		Выборка = Запрос.Выполнить().Выбрать();
		Если Выборка.Следующий() Тогда
			Если Выборка.НалоговыйПериод <> Null Тогда
				Год = Год(Выборка.НалоговыйПериод);
			КонецЕсли;
		КонецЕсли;
	КонецЕсли;
	
	Если ФизическоеЛицо.Пустая() Тогда
		ТолькоПросмотр = Истина;
	КонецЕсли;
	
	УстановитьСписокДоступныхДоходов();
	ПрочитатьДанные();
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовШапкиФормы

&НаКлиенте
Процедура ГодПриИзменении(Элемент)
	УстановитьСписокДоступныхДоходов();
	ПрочитатьДанные();
КонецПроцедуры
	
#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура ЗаписатьИЗакрыть(Команда)
	ЗаписатьНаСервере();
	Закрыть();
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаСервере
Процедура УстановитьСписокДоступныхДоходов()
	
	Элементы.ВычетыКодДохода.СписокВыбора.Очистить();
	
	ДоходыИВычеты = УчетНДФЛ.ВычетыКДоходам(Год);
	
	Доходы = ОбщегоНазначения.ВыгрузитьКолонку(ДоходыИВычеты, "Ключ");
	ДанныеДоходов = ОбщегоНазначения.ЗначенияРеквизитовОбъектов(Доходы, "Код,Наименование");
	
	Для Каждого ДанныеДохода Из ДанныеДоходов Цикл
		Элементы.ВычетыКодДохода.СписокВыбора.Добавить(ДанныеДохода.Ключ,
			ДанныеДохода.Значение.Код + ", " + ДанныеДохода.Значение.Наименование);
	КонецЦикла;
		
	Элементы.ВычетыКодДохода.СписокВыбора.СортироватьПоПредставлению();
	Элементы.ВычетыКодДохода.РежимВыбораИзСписка = Истина;
	
КонецПроцедуры

&НаСервере
Процедура ПрочитатьДанные()
	
	Вычеты.Очистить();
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("ФизическоеЛицо", ФизическоеЛицо);
	Запрос.УстановитьПараметр("ГоловнаяОрганизация", ГоловнаяОрганизация);
	Запрос.УстановитьПараметр("НалоговыйПериод", Дата(Год, 1, 1));
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	ВычетыПредыдущегоМестаРаботыНДФЛ.КодДохода КАК КодДохода,
	|	ВычетыПредыдущегоМестаРаботыНДФЛ.СуммаВычета КАК СуммаВычета
	|ИЗ
	|	РегистрСведений.ВычетыПредыдущегоМестаРаботыНДФЛ КАК ВычетыПредыдущегоМестаРаботыНДФЛ
	|ГДЕ
	|	ВычетыПредыдущегоМестаРаботыНДФЛ.ФизическоеЛицо = &ФизическоеЛицо
	|	И ВычетыПредыдущегоМестаРаботыНДФЛ.ГоловнаяОрганизация = &ГоловнаяОрганизация
	|	И ВычетыПредыдущегоМестаРаботыНДФЛ.НалоговыйПериод = &НалоговыйПериод";
	Вычеты.Загрузить(Запрос.Выполнить().Выгрузить());
	
КонецПроцедуры

&НаСервере
Процедура ЗаписатьНаСервере()
	
	НалоговыйПериод = Дата(Год, 1, 1);
	
	НаборЗаписей = РегистрыСведений.ВычетыПредыдущегоМестаРаботыНДФЛ.СоздатьНаборЗаписей();
	НаборЗаписей.Отбор.ФизическоеЛицо.Установить(ФизическоеЛицо);
	НаборЗаписей.Отбор.ГоловнаяОрганизация.Установить(ГоловнаяОрганизация);
	НаборЗаписей.Отбор.НалоговыйПериод.Установить(НалоговыйПериод);
	
	Для Каждого СтрокаВычета Из Вычеты Цикл
		Запись = НаборЗаписей.Добавить();
		Запись.ГоловнаяОрганизация = ГоловнаяОрганизация;
		Запись.НалоговыйПериод = НалоговыйПериод;
		Запись.ФизическоеЛицо = ФизическоеЛицо;
		Запись.КодДохода = СтрокаВычета.КодДохода;
		Запись.СуммаВычета = СтрокаВычета.СуммаВычета;
	КонецЦикла;
	
	НаборЗаписей.Записать(Истина);
	
КонецПроцедуры

#КонецОбласти
