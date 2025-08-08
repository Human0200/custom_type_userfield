<?php

use B24\Academy\UserField\PollutionDegreeField;
use Bitrix\Main\Config\Option;
use Bitrix\Main\EventManager;
use Bitrix\Main\IO\Path;

CopyDirFiles(
    Path::combine(__DIR__, '/../components/b24.academy/pollution.degree.field'),
    Path::convertRelativeToAbsolute('/local/components/b24.academy/pollution.degree.field/'),
    true,
    true
);

$eventManager = EventManager::getInstance();
$eventManager->registerEventHandlerCompatible(
    'main',
    'OnUserTypeBuildList',
    'b24.academy',
    PollutionDegreeField::class,
    'getUserTypeDescription'
);

Option::set('b24.academy', 'VERSION', 2023_12_05_15_00_00);
