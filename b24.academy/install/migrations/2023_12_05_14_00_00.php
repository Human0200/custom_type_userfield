<?php

use B24\Academy\UserField\CurrencyField;
use Bitrix\Main\Config\Option;
use Bitrix\Main\EventManager;
use Bitrix\Main\IO\Path;

CopyDirFiles(
    Path::combine(__DIR__, '/../components/b24.academy'),
    Path::convertRelativeToAbsolute('/local/components/b24.academy/'),
    true,
    true
);
CopyDirFiles(
    Path::combine(__DIR__, '/../templates/.default/components/bitrix/crm.field.filter'),
    Path::convertRelativeToAbsolute('/local/templates/.default/components/bitrix/crm.field.filter'),
    true,
    true
);

$eventManager = EventManager::getInstance();
$eventManager->registerEventHandlerCompatible(
    'main',
    'OnUserTypeBuildList',
    'b24.academy',
    CurrencyField::class,
    'getUserTypeDescription'
);

Option::set('b24.academy', 'VERSION', 2023_12_05_14_00_00);