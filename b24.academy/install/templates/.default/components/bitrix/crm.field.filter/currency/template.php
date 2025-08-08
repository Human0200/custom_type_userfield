<?php

use B24\Academy\UserField\CurrencyField;

defined('B_PROLOG_INCLUDED') || die;

/**
 * @var array{arUserField: array} $arParams
 * @var array{VALUE: array|string} $arResult
 */

print CurrencyField::getFilterHtml($arParams['arUserField'], ['VALUE' => (array) $arResult['VALUE']]);