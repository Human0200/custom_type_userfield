<?php

defined('B_PROLOG_INCLUDED') || die;

use Bitrix\Main\EventManager;
use Bitrix\Main\Loader;
use Bitrix\Main\Localization\Loc;
use Bitrix\Main\ModuleManager;
use Bitrix\Main\IO\Path;

class b24_academy extends CModule
{
    const MODULE_ID = 'b24.academy';
    var $MODULE_ID = self::MODULE_ID;
    var $MODULE_VERSION;
    var $MODULE_VERSION_DATE;
    var $MODULE_NAME;
    var $MODULE_DESCRIPTION;
    var $MODULE_CSS;
    var $strError = '';

    function __construct()
    {
        $arModuleVersion = array();
        include(__DIR__ . '/version.php');
        $this->MODULE_VERSION = $arModuleVersion['VERSION'];
        $this->MODULE_VERSION_DATE = $arModuleVersion['VERSION_DATE'];

        $this->MODULE_NAME = Loc::getMessage('B24_ACADEMY.MODULE_NAME');
        $this->MODULE_DESCRIPTION = Loc::getMessage('B24_ACADEMY.MODULE_DESC');

        $this->PARTNER_NAME = Loc::getMessage('B24_ACADEMY.PARTNER_NAME');
        $this->PARTNER_URI = Loc::getMessage('B24_ACADEMY.PARTNER_URI');
    }

    function DoInstall()
    {
        ModuleManager::registerModule($this->MODULE_ID);
        $this->InstallEvents();
        $this->InstallFiles();
        return true;
    }

    function DoUninstall()
    {
        $this->UnInstallEvents();
        $this->UnInstallFiles();
        ModuleManager::unRegisterModule($this->MODULE_ID);
        return true;
    }

    function InstallEvents()
    {
        $eventManager = EventManager::getInstance();
        $eventManager->registerEventHandlerCompatible(
            'main',
            'OnUserTypeBuildList',
            $this->MODULE_ID,
            'B24\Academy\UserField\PollutionDegreeField',
            'getUserTypeDescription'
        );
        return true;
    }

    function UnInstallEvents()
    {
        $eventManager = EventManager::getInstance();
        $eventManager->unRegisterEventHandler(
            'main',
            'OnUserTypeBuildList',
            $this->MODULE_ID,
            'B24\Academy\UserField\PollutionDegreeField',
            'getUserTypeDescription'
        );
        return true;
    }

    function InstallFiles()
    {
        // Копирование компонентов в /bitrix/components/
        $componentSource = __DIR__ . '/components/b24.academy/pollution.degree.field';
        $componentDestination = $_SERVER['DOCUMENT_ROOT'] . '/bitrix/components/b24.academy/pollution.degree.field';
        
        if (is_dir($componentSource)) {
            CopyDirFiles(
                $componentSource,
                $componentDestination,
                true,
                true
            );
        }

        // Альтернативно можно копировать в /local/components/ (раскомментируйте при необходимости)
        /*
        $localComponentDestination = $_SERVER['DOCUMENT_ROOT'] . '/local/components/b24.academy/pollution.degree.field';
        if (is_dir($componentSource)) {
            CopyDirFiles(
                $componentSource,
                $localComponentDestination,
                true,
                true
            );
        }
        */

        return true;
    }

    function UnInstallFiles()
    {
        // Удаление компонентов из /bitrix/components/
        $componentPath = $_SERVER['DOCUMENT_ROOT'] . '/bitrix/components/b24.academy/pollution.degree.field';
        if (is_dir($componentPath)) {
            DeleteDirFiles($componentPath, $componentPath);
            @rmdir($componentPath);
            
            // Удаляем папку b24.academy если она пустая
            $academyPath = $_SERVER['DOCUMENT_ROOT'] . '/bitrix/components/b24.academy';
            if (is_dir($academyPath) && count(scandir($academyPath)) == 2) {
                @rmdir($academyPath);
            }
        }

        // Удаление из /local/components/ если копировали туда
        /*
        $localComponentPath = $_SERVER['DOCUMENT_ROOT'] . '/local/components/b24.academy/pollution.degree.field';
        if (is_dir($localComponentPath)) {
            DeleteDirFiles($localComponentPath, $localComponentPath);
            @rmdir($localComponentPath);
            
            $localAcademyPath = $_SERVER['DOCUMENT_ROOT'] . '/local/components/b24.academy';
            if (is_dir($localAcademyPath) && count(scandir($localAcademyPath)) == 2) {
                @rmdir($localAcademyPath);
            }
        }
        */

        return true;
    }

    function GetModuleRightList()
    {
        return array(
            "reference_id" => array("D", "R", "W"),
            "reference" => array(
                "[D] " . Loc::getMessage("B24_ACADEMY.DENIED"),
                "[R] " . Loc::getMessage("B24_ACADEMY.READ"),
                "[W] " . Loc::getMessage("B24_ACADEMY.WRITE")
            )
        );
    }
}