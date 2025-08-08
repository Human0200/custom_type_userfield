<?php

use B24\Academy\UserField\PollutionDegreeField;
use Bitrix\Main\Config\Option;
use Bitrix\Main\EventManager;
use Bitrix\Main\IO\Path;

// Копируем компоненты в правильную директорию
$componentSource = Path::combine(__DIR__, '/../components/b24.academy/pollution.degree.field');
$componentDestination = Path::convertRelativeToAbsolute('/bitrix/components/b24.academy/pollution.degree.field/');

if (is_dir($componentSource)) {
    CopyDirFiles(
        $componentSource,
        $componentDestination,
        true,
        true
    );
}

// Регистрируем обработчик типа поля
$eventManager = EventManager::getInstance();
$eventManager->registerEventHandlerCompatible(
    'main',
    'OnUserTypeBuildList',
    'b24.academy',
    PollutionDegreeField::class,
    'getUserTypeDescription'
);

Option::set('b24.academy', 'VERSION', 2023_12_05_15_00_00);