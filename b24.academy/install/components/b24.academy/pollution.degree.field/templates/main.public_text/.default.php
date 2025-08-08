<?php

defined('B_PROLOG_INCLUDED') || die;

/**
 * @var array $arResult
 * @var PollutionDegreeFieldComponent $component
 */

$value = $component->getValue();
$settings = $component->getSettings();

printf(
    '%s: %s м², %s: %s',
    $settings['AREA_LABEL'],
    $value['AREA'],
    $settings['DEGREE_LABEL'],
    $value['DEGREE']
);
