﻿
&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	ПараметрыВыбора = Новый Массив;
	ПараметрыВыбора.Добавить(Новый ПараметрВыбора("Отбор.Организация", Запись.Организация));
	
	Элементы.ВидОплатыПлатежнойКартой.ПараметрыВыбора = Новый ФиксированныйМассив(ПараметрыВыбора)
	
КонецПроцедуры
