<?php

defined('B_PROLOG_INCLUDED') || die;

/**
 * @var array $arResult
 */

$values = [];
if (isset($arResult['additionalParameters']['bVarsFromForm']) && $arResult['additionalParameters']['bVarsFromForm']) {
    $values['AREA_LABEL'] = $GLOBALS[$arResult['additionalParameters']['NAME']]['AREA_LABEL'] ?? 'Площадь (м²)';
    $values['DEGREE_LABEL'] = $GLOBALS[$arResult['additionalParameters']['NAME']]['DEGREE_LABEL'] ?? 'Степень загрязнения';
    $values['AREA_MIN'] = (float)($GLOBALS[$arResult['additionalParameters']['NAME']]['AREA_MIN'] ?? 0);
    $values['AREA_MAX'] = (float)($GLOBALS[$arResult['additionalParameters']['NAME']]['AREA_MAX'] ?? 999999);
    $values['DEGREE_MIN'] = (float)($GLOBALS[$arResult['additionalParameters']['NAME']]['DEGREE_MIN'] ?? 0);
    $values['DEGREE_MAX'] = (float)($GLOBALS[$arResult['additionalParameters']['NAME']]['DEGREE_MAX'] ?? 100);
} elseif (isset($arResult['userField']) && $arResult['userField']) {
    $values['AREA_LABEL'] = $arResult['userField']['SETTINGS']['AREA_LABEL'] ?? 'Площадь (м²)';
    $values['DEGREE_LABEL'] = $arResult['userField']['SETTINGS']['DEGREE_LABEL'] ?? 'Степень загрязнения';
    $values['AREA_MIN'] = (float)($arResult['userField']['SETTINGS']['AREA_MIN'] ?? 0);
    $values['AREA_MAX'] = (float)($arResult['userField']['SETTINGS']['AREA_MAX'] ?? 999999);
    $values['DEGREE_MIN'] = (float)($arResult['userField']['SETTINGS']['DEGREE_MIN'] ?? 0);
    $values['DEGREE_MAX'] = (float)($arResult['userField']['SETTINGS']['DEGREE_MAX'] ?? 100);
} else {
    $values = [
        'AREA_LABEL' => 'Площадь (м²)',
        'DEGREE_LABEL' => 'Степень загрязнения',
        'AREA_MIN' => 0,
        'AREA_MAX' => 999999,
        'DEGREE_MIN' => 0,
        'DEGREE_MAX' => 100,
    ];
}

$arResult['settings'] = $values;
