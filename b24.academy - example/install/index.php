<?php

defined('B_PROLOG_INCLUDED') || die;

use Bitrix\Main\EventManager;
use Bitrix\Main\Loader;
use Bitrix\Main\Localization\Loc;
use Bitrix\Main\ModuleManager;

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
}