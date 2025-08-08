<?php
namespace B24\Academy\UserField;

use Bitrix\Main\Localization\Loc;
use Bitrix\Main\UserField\Types\BaseType;

class PollutionDegreeField extends BaseType
{
    public const USER_TYPE_ID = 'pollution_degree';
    public const RENDER_COMPONENT = 'b24.academy:pollution.degree.field';

    public static function getDescription(): array
    {
        return [
            'USER_TYPE_ID' => static::USER_TYPE_ID,
            'CLASS_NAME' => __CLASS__,
            'DESCRIPTION' => Loc::getMessage('B24_ACADEMY.FIELD_DESCRIPTION'),
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
            'AREA_LABEL' => $userField['SETTINGS']['AREA_LABEL'] ?? Loc::getMessage('B24_ACADEMY.AREA_LABEL_DEFAULT'),
            'DEGREE_LABEL' => $userField['SETTINGS']['DEGREE_LABEL'] ?? Loc::getMessage('B24_ACADEMY.DEGREE_LABEL_DEFAULT'),
            'AREA_MIN' => (float)($userField['SETTINGS']['AREA_MIN'] ?? 0),
            'AREA_MAX' => (float)($userField['SETTINGS']['AREA_MAX'] ?? 1000),
            'DEGREE_MIN' => (float)($userField['SETTINGS']['DEGREE_MIN'] ?? 0),
            'DEGREE_MAX' => (float)($userField['SETTINGS']['DEGREE_MAX'] ?? 100),
        ];
    }

    public static function onBeforeSave($userField, $value)
    {
        if (!is_array($value)) {
            return json_encode(['area' => 0, 'degree' => 0]);
        }

        $settings = static::prepareSettings($userField);
        return json_encode([
            'area' => max($settings['AREA_MIN'], min($settings['AREA_MAX']), (float)($value['AREA'] ?? 0)),
            'degree' => max($settings['DEGREE_MIN'], min($settings['DEGREE_MAX']), (float)($value['DEGREE'] ?? 0))
        ], JSON_UNESCAPED_UNICODE);
    }

    public static function onAfterFetch($userField, $value)
    {
        if (empty($value)) {
            return ['AREA' => 0, 'DEGREE' => 0];
        }

        if (is_array($value)) {
            return [
                'AREA' => (float)($value['AREA'] ?? $value['area'] ?? 0),
                'DEGREE' => (float)($value['DEGREE'] ?? $value['degree'] ?? 0)
            ];
        }

        $data = json_decode($value, true);
        return [
            'AREA' => (float)($data['area'] ?? 0),
            'DEGREE' => (float)($data['degree'] ?? 0)
        ];
    }

public static function getSettingsHtml($userField, ?array $additionalParameters, $varsFromForm): string
{
    $settings = static::prepareSettings($userField);
    $name = htmlspecialcharsbx($additionalParameters['NAME'] ?? '');
    
    $html = '
    <tr>
        <td width="40%">'.Loc::getMessage('B24_ACADEMY.AREA_LABEL').'</td>
        <td width="60%">
            <input type="text" 
                   name="'.$name.'[AREA_LABEL]" 
                   value="'.htmlspecialcharsbx($settings['AREA_LABEL']).'"
                   size="20">
        </td>
    </tr>
    <tr>
        <td>'.Loc::getMessage('B24_ACADEMY.DEGREE_LABEL').'</td>
        <td>
            <input type="text" 
                   name="'.$name.'[DEGREE_LABEL]" 
                   value="'.htmlspecialcharsbx($settings['DEGREE_LABEL']).'"
                   size="20">
        </td>
    </tr>';

    return $html;
}
}