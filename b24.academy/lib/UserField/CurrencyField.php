<?php

namespace B24\Academy\UserField;

use Bitrix\Main\Localization\Loc;
use Bitrix\Main\UserField\Types\BaseType;
use Bitrix\Main\Context;

class PollutionDegreeField extends BaseType
{
    public const USER_TYPE_ID = 'pollution_degree';
    public const RENDER_COMPONENT = 'b24.academy:pollution.degree.field';

    protected static function getDescription(): array
    {
        return [
            'DESCRIPTION' => Loc::getMessage('B24_ACADEMY.UFTYPE_POLLUTION_DEGREE_DESCRIPTION'),
            'BASE_TYPE' => \CUserTypeManager::BASE_TYPE_STRING,
        ];
    }

    public static function getDbColumnType(): string
    {
        return 'text';
    }

    public static function prepareSettings(array $userField): array
    {
        return [
            'AREA_LABEL' => $userField['SETTINGS']['AREA_LABEL'] ?? 'Площадь (м²)',
            'DEGREE_LABEL' => $userField['SETTINGS']['DEGREE_LABEL'] ?? 'Степень загрязнения',
            'SHOW_IN_LIST' => $userField['SETTINGS']['SHOW_IN_LIST'] ?? 'Y',
        ];
    }

    public static function onBeforeSave(array $userField, $value)
    {
        if (is_array($value)) {
            return json_encode([
                'area' => (float)$value['AREA'],
                'degree' => (float)$value['DEGREE']
            ]);
        }
        
        return $value;
    }

    public static function onAfterFetch(array $userField, $value)
    {
        if (!empty($value)) {
            $data = json_decode($value, true);
            return [
                'AREA' => $data['area'] ?? 0,
                'DEGREE' => $data['degree'] ?? 0,
            ];
        }
        
        return [
            'AREA' => 0,
            'DEGREE' => 0,
        ];
    }

    public static function getDefaultValue(array $userField, array $additionalParameters = [])
    {
        return json_encode([
            'area' => 0,
            'degree' => 0
        ]);
    }

    public static function getAdminListViewHTML(array $userField, array $additionalParameters): string
    {
        $value = static::onAfterFetch($userField, $additionalParameters['VALUE']);
        return $value['AREA'].' м² / '.$value['DEGREE'];
    }

    public static function getAdminListEditHTML(array $userField, array $additionalParameters): string
    {
        $value = static::onAfterFetch($userField, $additionalParameters['VALUE']);
        
        return '
            <input type="number" name="'.$additionalParameters['NAME'].'[AREA]" value="'.$value['AREA'].'" step="0.01" placeholder="м²">
            <input type="number" name="'.$additionalParameters['NAME'].'[DEGREE]" value="'.$value['DEGREE'].'" step="0.01">
        ';
    }
}