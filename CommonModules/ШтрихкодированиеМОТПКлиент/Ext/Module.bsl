﻿#Область СлужебныйПрограммныйИнтерфейс

// Проверяет результат обработки штрихкода на необходимость интерактивного уточнения данных у пользователя.
// 
// Параметры:
//  РезультатОбработки - (См. ШтрихкодированиеИСМП.ИнициализироватьРезультатОбработкиШтрихкода).
// Возвращаемое значение:
//  Булево - Истина, если необходимо уточнить данные у пользователя.
Функция ТребуетсяУточнениеДанныхУПользователя(РезультатОбработки) Экспорт
	
	Возврат РезультатОбработки.ТребуетсяАвторизацияМОТП Или РезультатОбработки.ТребуетсяУточнениеДанных;
	
КонецФункции

Процедура ОткрытьФормуНевозможностиДобавленияОтсканированного(Форма, ПараметрыОткрытияФормы, ОповещениеОЗакрытии = Неопределено) Экспорт
	
	ОткрытьФорму(
		"Обработка.ПроверкаИПодборТабачнойПродукцииМОТП.Форма.ИнформацияОНевозможностиДобавленияОтсканированного",
		ПараметрыОткрытияФормы, Форма,,,, ОповещениеОЗакрытии, РежимОткрытияОкнаФормы.БлокироватьОкноВладельца);
	
КонецПроцедуры

#КонецОбласти