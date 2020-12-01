﻿#Область ПрограммныйИнтерфейс

// Дозаполнение параметров структуры с настройками.
//
// Параметры:
//   Настройки - Структура - Описание в ОМ.РезервОтпусков.НастройкиРезервовОтпусков().
//   Организация - Спр.Организации.СправочникСсылка - Организация.
//   Период - Дата - Период дат.
//
Процедура ЗаполнитьНастройкиРезервовОтпусков(Настройки, Организация, Период) Экспорт
	
	
	
КонецПроцедуры

// Уточняет необходимость выполнять расчет резервов, устанавливается в Ложь, 
// когда резервы рассчитываются в другой программе.
//
// Параметры:
//	РезервыРассчитываются - тип булево.
//
Процедура ПолучитьЗначениеРезервыРассчитываются(РезервыРассчитываются) Экспорт
	
	РезервыРассчитываются = ПолучитьФункциональнуюОпцию("УчетЗарплатыИКадровСредствамиБухгалтерии");
	
КонецПроцедуры

// Уточняет возможность использования автоматического расчета резервов, 
// устанавливается в Ложь, когда авторасчет резервов отключен.
//
// Возвращаемое значение:
//  Булево - Истина, если используется авторасчет.
//
Функция РезервыРассчитываютсяАвтоматически() Экспорт
	
	Возврат ПолучитьФункциональнуюОпцию("УчетЗарплатыИКадровСредствамиБухгалтерии");
	
КонецФункции

// Процедура предназначена для формирования движений по месту внедрения.
//
// Параметры:
//	Объект - конкретный экземпляр документа Начисление оценочных обязательств по отпускам (ДокументОбъект.НачислениеОценочныхОбязательствПоОтпускам)
//	Отказ  - булево, признак отказа от проведения документа.
//	РежимПроведения - режим проведения документа.
//
Процедура СформироватьДвижения(Объект, Отказ, РежимПроведения) Экспорт

КонецПроцедуры

// Процедура предназначена для дополнения таблицы параметров данными об остатках отпусков 
// и ФОТ с учетом специфики места внедрения.
//
// Параметры:
//   Организация - Спр.Организации.СправочникСсылка - Организация.
//   Период - Дата - Период дат.
//   ОстаткиОтпусков - таблица значений.
//		Структура таблицы ОстаткиОтпусков.
//			Организация
//			Подразделение
//			МестоВСтруктуреПредприятия
//			Сотрудник
//			СпособОтраженияЗарплатыВБухучете
//			СтатьяФинансирования
//			ОблагаетсяЕНВД
//			ОстатокОтпусков
//			ОтпускАвансом
//			СреднийЗаработок
//
Процедура ДополнитьТаблицуОстатковОтпусков(Организация, Период, ОстаткиОтпусков) Экспорт
	
	ПараметрыПолученияСотрудниковОрганизаций = КадровыйУчет.ПараметрыПолученияСотрудниковОрганизацийПоСпискуФизическихЛиц();
	ПараметрыПолученияСотрудниковОрганизаций.Вставить("Организация",                   Организация);
	ПараметрыПолученияСотрудниковОрганизаций.Вставить("ОтбиратьПоГоловнойОрганизации", Ложь);
	ПараметрыПолученияСотрудниковОрганизаций.Вставить("НачалоПериода",                 КонецГода(Период));
	ПараметрыПолученияСотрудниковОрганизаций.Вставить("ОкончаниеПериода",              КонецГода(Период));
	ПараметрыПолученияСотрудниковОрганизаций.Вставить("КадровыеДанные",                "ДатаПриема,Подразделение,СпособОтраженияЗарплатыВБухучете");
	ПараметрыПолученияСотрудниковОрганизаций.Вставить("Отборы");
	
	ТаблицаСотрудников = КадровыйУчет.СотрудникиОрганизации(Истина, ПараметрыПолученияСотрудниковОрганизаций);
	
	НастройкиУчетаЗарплаты    = РегистрыСведений.НастройкиУчетаЗарплаты.Получить(Новый Структура("Организация", Организация));
	ПродолжительностьОтпуска  = НастройкиУчетаЗарплаты.ПродолжительностьОтпуска;
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("Организация",              Организация);
	Запрос.УстановитьПараметр("Период",                   Период);
	Запрос.УстановитьПараметр("НачалоПериода",            НачалоГода(Период));
	Запрос.УстановитьПараметр("ОкончаниеПериода",         КонецГода(Период));
	Запрос.УстановитьПараметр("СотрудникиОрганизации",    ТаблицаСотрудников);
	Запрос.УстановитьПараметр("ОстаткиОтпусков",          ОстаткиОтпусков);
	Запрос.УстановитьПараметр("ПродолжительностьОтпуска", ПродолжительностьОтпуска);
	Запрос.УстановитьПараметр("ЦенаМесяца",               Окр(ПродолжительностьОтпуска/12,2));
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	ОстаткиОтпусков.Сотрудник КАК Сотрудник,
	|	ОстаткиОтпусков.Подразделение КАК Подразделение,
	|	ОстаткиОтпусков.ОблагаетсяЕНВД КАК ОблагаетсяЕНВД,
	|	ОстаткиОтпусков.СпособОтраженияЗарплатыВБухучете КАК СпособОтраженияЗарплатыВБухучете,
	|	ОстаткиОтпусков.СреднийЗаработок КАК СреднийЗаработок
	|ПОМЕСТИТЬ ВТ_ОстаткиОтпусков
	|ИЗ
	|	&ОстаткиОтпусков КАК ОстаткиОтпусков
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	СотрудникиОрганизации.Сотрудник КАК Сотрудник,
	|	СотрудникиОрганизации.Подразделение КАК Подразделение,
	|	СотрудникиОрганизации.СпособОтраженияЗарплатыВБухучете КАК СпособОтраженияЗарплатыВБухучете,
	|	ВЫБОР
	|		КОГДА РАЗНОСТЬДАТ(СотрудникиОрганизации.ДатаПриема, &Период, МЕСЯЦ) >= 11
	|			ТОГДА &ПродолжительностьОтпуска
	|		ИНАЧЕ (РАЗНОСТЬДАТ(СотрудникиОрганизации.ДатаПриема, &Период, МЕСЯЦ) + 1) * &ЦенаМесяца
	|	КОНЕЦ КАК ЗаработаноДней
	|ПОМЕСТИТЬ ВТ_Сотрудники
	|ИЗ
	|	&СотрудникиОрганизации КАК СотрудникиОрганизации
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	РасчетРезерваОтпусков.Сотрудник КАК Сотрудник,
	|	МАКСИМУМ(РасчетРезерваОтпусков.ОстатокОтпуска) КАК НакопленоДней
	|ПОМЕСТИТЬ ВТ_РасчетРезервов
	|ИЗ
	|	РегистрСведений.РасчетРезерваОтпусков КАК РасчетРезерваОтпусков
	|ГДЕ
	|	РасчетРезерваОтпусков.Организация = &Организация
	|	И КОНЕЦПЕРИОДА(РасчетРезерваОтпусков.ПериодРасчета, МЕСЯЦ) = КОНЕЦПЕРИОДА(ДОБАВИТЬКДАТЕ(&Период, ГОД, -1), МЕСЯЦ)
	|	И РасчетРезерваОтпусков.Сотрудник В
	|			(ВЫБРАТЬ
	|				ВТ_Сотрудники.Сотрудник
	|			ИЗ
	|				ВТ_Сотрудники КАК ВТ_Сотрудники)
	|
	|СГРУППИРОВАТЬ ПО
	|	РасчетРезерваОтпусков.Сотрудник
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	Отпуск.Сотрудник КАК Сотрудник,
	|	СУММА(Отпуск.КоличествоДнейОсновногоОтпуска) КАК ИспользованоДней
	|ПОМЕСТИТЬ ВТ_Отпуска
	|ИЗ
	|	Документ.Отпуск КАК Отпуск
	|ГДЕ
	|	Отпуск.Организация = &Организация
	|	И Отпуск.Проведен
	|	И Отпуск.ПериодРегистрации МЕЖДУ &НачалоПериода И &ОкончаниеПериода
	|
	|СГРУППИРОВАТЬ ПО
	|	Отпуск.Сотрудник
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	&Организация КАК Организация,
	|	ВТ_Сотрудники.Сотрудник КАК Сотрудник,
	|	ЕСТЬNULL(ВТ_РасчетРезервов.НакопленоДней, 0) + ЕСТЬNULL(ВТ_Сотрудники.ЗаработаноДней, 0) - ЕСТЬNULL(ВТ_Отпуска.ИспользованоДней, 0) КАК ОстатокОтпусков,
	|	ЕСТЬNULL(ВТ_ОстаткиОтпусков.Подразделение, ВТ_Сотрудники.Подразделение) КАК Подразделение,
	|	"""" КАК МестоВСтруктуреПредприятия,
	|	ЕСТЬNULL(ВТ_ОстаткиОтпусков.СпособОтраженияЗарплатыВБухучете, ВТ_Сотрудники.СпособОтраженияЗарплатыВБухучете) КАК СпособОтраженияЗарплатыВБухучете,
	|	ЗНАЧЕНИЕ(Справочник.СтатьиФинансированияЗарплата.ПустаяСсылка) КАК СтатьяФинансирования,
	|	ЕСТЬNULL(ВТ_ОстаткиОтпусков.ОблагаетсяЕНВД, ЛОЖЬ) КАК ОблагаетсяЕНВД,
	|	ЕСТЬNULL(ВТ_ОстаткиОтпусков.СреднийЗаработок, 0) КАК СреднийЗаработок,
	|	0 КАК ОтпускАвансом
	|ИЗ
	|	ВТ_Сотрудники КАК ВТ_Сотрудники
	|		ЛЕВОЕ СОЕДИНЕНИЕ ВТ_РасчетРезервов КАК ВТ_РасчетРезервов
	|		ПО ВТ_Сотрудники.Сотрудник = ВТ_РасчетРезервов.Сотрудник
	|		ЛЕВОЕ СОЕДИНЕНИЕ ВТ_Отпуска КАК ВТ_Отпуска
	|		ПО ВТ_Сотрудники.Сотрудник = ВТ_Отпуска.Сотрудник
	|		ЛЕВОЕ СОЕДИНЕНИЕ ВТ_ОстаткиОтпусков КАК ВТ_ОстаткиОтпусков
	|		ПО ВТ_Сотрудники.Сотрудник = ВТ_ОстаткиОтпусков.Сотрудник";
	
	ОстаткиОтпусков = Запрос.Выполнить().Выгрузить();
	
КонецПроцедуры

Процедура ИспользуетсяОбменЗУПБП(ОбменИспользуется, Организация) Экспорт
	

КонецПроцедуры


#КонецОбласти

