﻿
&НаКлиенте
Процедура ОбработкаКоманды(ПараметрКоманды, ПараметрыВыполненияКоманды)
	
	ПараметрыФормы = Новый Структура;
	Отбор = Новый Структура;
	Отбор.Вставить("Организация", ПараметрКоманды);
	ПараметрыФормы.Вставить("Отбор", Отбор);
	ОткрытьФорму("РегистрСведений.НастройкиУчетаСтраховыхВзносовИП.ФормаСписка",
		ПараметрыФормы,
		ПараметрыВыполненияКоманды.Источник,
		ПараметрыВыполненияКоманды.Уникальность,
		ПараметрыВыполненияКоманды.Окно,
		ПараметрыВыполненияКоманды.НавигационнаяСсылка);
	
КонецПроцедуры
