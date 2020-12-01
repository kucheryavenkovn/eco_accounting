﻿#Область ПрограммныйИнтерфейс

// Возвращает налоговую ставку по умолчанию
//
// Возвращаемое значение:
//  Число - ставка налога в %
//
Функция НалоговаяСтавкаПоУмолчанию() Экспорт
	
	Возврат 15;
	
КонецФункции

// Возвращает корректирующий коэффициент по умолчанию
//
// Возвращаемое значение:
//  Число
//
Функция КорректирующийКоэффициентПоУмолчанию() Экспорт
	
	Возврат 1;
	
КонецФункции

// Возвращает значение коэффициента-дефлятора, установленного на период
//
// Параметры:
//  Период - Дата - период действия коэффициента-дефлятора
//
// Возвращаемое значение:
//  Число(4, 3)
//
Функция КоэффициентДефлятор(Период) Экспорт
	
	Если Период >= '20200101' Тогда
		// Приказ Минэкономразвития России от 21.10.2019 N 684
		// (в ред. приказа Минэкономразвития России от 10.12.2019 N 793)
		Возврат 2.005;
	ИначеЕсли Период >= '20190101' Тогда
		// Приказ Минэкономразвития России от 30.10.2018 N 595
		Возврат 1.915;
	ИначеЕсли Период >= '20180101' Тогда
		// Приказ Минэкономразвития России от 30.10.2017 N 579
		Возврат 1.868;
	ИначеЕсли Период >= '20150101' Тогда
		// Приказ Минэкономразвития России от 29.10.2014 N 685
		// Приказ Минэкономразвития России от 20.10.2015 N 772
		Возврат 1.798;
	Иначе
		// Расчет ЕНВД ранее 2015 года не поддерживается.
		Возврат 0;
	КонецЕсли;
	
КонецФункции

// Возвращает дату, начиная с которой ЕНВД не применяется
// в связи с отменой действия главы 26.3 НК РФ (Федеральный закон от 29.06.2012 N 97-ФЗ).
//
// Возвращаемое значение:
//   Дата - дата отмены ЕНВД.
//
Функция ДатаОтменыЕНВД() Экспорт
	
	Возврат Дата(2021, 1, 1);
	
КонецФункции

// Возвращает дату начала применения вычета расходов на покупку касс из налога
//
// Возвращаемое значение:
//  Дата
//
Функция ДатаНачалаПримененияВычетаНаОнлайнКассы() Экспорт
	
	Возврат НачалоДня(Дата(2018, 1, 1)); // п. 2.2 статьи 346.32 НК РФ
	
КонецФункции

// Возвращает дату окончания применения вычета расходов на покупку касс из налога
//
// Возвращаемое значение:
//  Дата
//
Функция ДатаОкончанияПримененияВычетаНаОнлайнКассы() Экспорт
	
	Возврат КонецДня(Дата(2019, 12, 31)); // п. 2.2 статьи 346.32 НК РФ
	
КонецФункции

// Рассчитывает сумму вмененного налога за квартал без учета расходов, уменьшающих налог
//
// Параметры:
//  ПараметрыРасчета - структура параметров, описанная в НовыеПараметрыРасчетаСуммыНалога()
//
// Возвращаемое значение:
//  Число(15, 0)
//
Функция СуммаНалога(ПараметрыРасчета) Экспорт
	
	ВмененныйДоход = ВмененныйДоходЗаКвартал(ПараметрыРасчета);
	
	СуммаНалога = Окр(ВмененныйДоход * ПараметрыРасчета.НалоговаяСтавка / 100, 0);
	
	Возврат СуммаНалога;
	
КонецФункции

// Рассчитывает сумму вмененного дохода за квартал
//
// Параметры:
//  ПараметрыРасчета - структура параметров, описанная в НовыеПараметрыРасчетаСуммыНалога()
//
// Возвращаемое значение:
//  Число(15, 0)
//
Функция ВмененныйДоходЗаКвартал(ПараметрыРасчета) Экспорт
	
	КоэффициентДефлятор = КоэффициентДефлятор(ПараметрыРасчета.Период);
	
	БазоваяДоходность = ПараметрыРасчета.БазоваяДоходность * КоэффициентДефлятор * ПараметрыРасчета.КорректирующийКоэффициент;
	
	Период = НачалоКвартала(ПараметрыРасчета.Период);
	
	ОдинДень = 86400;
	
	Если ЗначениеЗаполнено(ПараметрыРасчета.ДатаНачала) Тогда
		ДатаНачала = НачалоДня(ПараметрыРасчета.ДатаНачала);
	КонецЕсли;
	
	Если ЗначениеЗаполнено(ПараметрыРасчета.ДатаПрекращения) Тогда
		// Дата прекращения деятельности, указанная в заявлении, не включается
		// в расчет количества дней осуществления деятельности
		ДатаКонца = НачалоДня(ПараметрыРасчета.ДатаПрекращения - ОдинДень);
	КонецЕсли;
	
	ВмененныйДоходЗаКвартал = 0;
	
	Для ИндексМесяца = 0 По 2 Цикл
		
		ЭтоМесяцНачалаДеятельности      = Ложь;
		ЭтоМесяцПрекращенияДеятельности = Ложь;
		
		Если ЗначениеЗаполнено(Период) Тогда
			
			ТекущийМесяц = ДобавитьМесяц(Период, ИндексМесяца);
			
			НачалоМесяца = НачалоМесяца(ТекущийМесяц);
			КонецМесяца  = НачалоДня(КонецМесяца(ТекущийМесяц));
			
			Если ЗначениеЗаполнено(ДатаНачала) Тогда
				
				Если КонецМесяца < ДатаНачала Тогда
					Продолжить;
				КонецЕсли;
				
				ЭтоМесяцНачалаДеятельности = (НачалоМесяца < ДатаНачала И ДатаНачала <= КонецМесяца); 
				
			КонецЕсли;
			
			Если ЗначениеЗаполнено(ДатаКонца) Тогда
				
				Если ДатаКонца < НачалоМесяца Тогда
					Продолжить;
				КонецЕсли;
				
				ЭтоМесяцПрекращенияДеятельности = (НачалоМесяца <= ДатаКонца И ДатаКонца < КонецМесяца); 
				
			КонецЕсли;
			
		КонецЕсли;
		
		Если ЭтоМесяцНачалаДеятельности Или ЭтоМесяцПрекращенияДеятельности Тогда
			
			НачалоПериода = ?(ЭтоМесяцНачалаДеятельности, НачалоДня(ДатаНачала), НачалоМесяца);
			КонецПериода  = ?(ЭтоМесяцПрекращенияДеятельности, НачалоДня(ДатаКонца), КонецМесяца);
			
			КоличествоДнейДеятельности = Макс((КонецПериода - НачалоПериода) / ОдинДень + 1, 0);
			
			Коэффициент =  КоличествоДнейДеятельности / День(КонецМесяца);
			
		Иначе
			
			Коэффициент = 1;
			
		КонецЕсли;
		
		ФизическийПоказатель = ПараметрыРасчета[ИмяПараметраФизическийПоказатель(ИндексМесяца)];
		ВмененныйДоходЗаКвартал = ВмененныйДоходЗаКвартал + Окр(БазоваяДоходность * ФизическийПоказатель * Коэффициент, 0);
		
	КонецЦикла;
	
	Возврат ВмененныйДоходЗаКвартал;
	
КонецФункции

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

// Возвращает пустую структуру параметров, передаваемую в качестве параметра функции СуммаНалога()
//
Функция НовыеПараметрыРасчетаСуммыНалога() Экспорт
	
	Параметры = Новый Структура;
	
	Параметры.Вставить("БазоваяДоходность", 0);
	Параметры.Вставить("ФизическийПоказатель1", 0);
	Параметры.Вставить("ФизическийПоказатель2", 0);
	Параметры.Вставить("ФизическийПоказатель3", 0);
	Параметры.Вставить("КорректирующийКоэффициент", 0);
	Параметры.Вставить("НалоговаяСтавка", 0);
	Параметры.Вставить("Период", '00010101');
	Параметры.Вставить("ДатаНачала",      '00010101');
	Параметры.Вставить("ДатаПрекращения", '00010101');
	
	Возврат Параметры;
	
КонецФункции

Функция ИмяПараметраФизическийПоказатель(ИндексМесяца)
	
	Возврат СтрШаблон("ФизическийПоказатель%1", ИндексМесяца + 1);
	
КонецФункции

#КонецОбласти