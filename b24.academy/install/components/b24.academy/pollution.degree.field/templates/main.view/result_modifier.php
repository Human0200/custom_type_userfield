<?php

defined('B_PROLOG_INCLUDED') || die;

/**
 * @var CBitrixComponentTemplate $this
 * @var PollutionDegreeFieldComponent $component
 * @var array $arResult
 */

// Дополнительная обработка для отображения
$component = $this->getComponent();
$value = $component->getValue();

// Проверяем, что значения корректные
if ($value['AREA'] < 0) $value['AREA'] = 0;
if ($value['DEGREE'] < 0) $value['DEGREE'] = 0;

$arResult['processedValue'] = $value;
