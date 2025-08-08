<?php
namespace B24\Academy\Components\PollutionDegreeField;

use Bitrix\Main\Component\BaseUfComponent;
use B24\Academy\UserField\PollutionDegreeField;

defined('B_PROLOG_INCLUDED') || die;

class PollutionDegreeComponent extends BaseUfComponent
{
    protected static function getUserTypeId(): string
    {
        return PollutionDegreeField::USER_TYPE_ID;
    }
}