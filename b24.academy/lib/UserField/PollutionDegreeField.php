<?php

namespace B24\Academy\UserField;

use Bitrix\Main\Localization\Loc;
use Bitrix\Main\UserField\Types\BaseType;

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

public static function prepareSettings($userField): array
{
    if (!is_array($userField)) {
        $userField = [];
    }
    
    if (!isset($userField['SETTINGS']) || !is_array($userField['SETTINGS'])) {
        $userField['SETTINGS'] = [];
    }

    return [
        'AREA_LABEL' => $userField['SETTINGS']['AREA_LABEL'] ?? 'Площадь (м²)',
        'DEGREE_LABEL' => $userField['SETTINGS']['DEGREE_LABEL'] ?? 'Степень загрязнения',
        'SHOW_IN_LIST' => $userField['SETTINGS']['SHOW_IN_LIST'] ?? 'Y',
        'AREA_MIN' => (float)($userField['SETTINGS']['AREA_MIN'] ?? 0),
        'AREA_MAX' => (float)($userField['SETTINGS']['AREA_MAX'] ?? 999999),
        'DEGREE_MIN' => (float)($userField['SETTINGS']['DEGREE_MIN'] ?? 0),
        'DEGREE_MAX' => (float)($userField['SETTINGS']['DEGREE_MAX'] ?? 100),
    ];
}

    public static function onBeforeSave(array $userField, $value)
    {
        if (is_array($value)) {
            $area = (float)($value['AREA'] ?? 0);
            $degree = (float)($value['DEGREE'] ?? 0);
            
            $settings = static::prepareSettings($userField);
            
            $area = max($settings['AREA_MIN'], min($settings['AREA_MAX'], $area));
            $degree = max($settings['DEGREE_MIN'], min($settings['DEGREE_MAX'], $degree));
            
            return json_encode([
                'area' => $area,
                'degree' => $degree
            ]);
        }
        
        return $value;
    }

    public static function onAfterFetch(array $userField, $value)
    {
        if (!empty($value)) {
            $data = json_decode($value, true);
            if (is_array($data)) {
                return [
                    'AREA' => (float)($data['area'] ?? 0),
                    'DEGREE' => (float)($data['degree'] ?? 0),
                ];
            }
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

public static function getAdminListViewHtml($userField, $additionalParameters): string
{
    $value = static::onAfterFetch($userField, $additionalParameters['VALUE']);
    
    return sprintf(
        '<span title="Площадь: %s м², Степень: %s">%s м² / %s</span>',
        $value['AREA'],
        $value['DEGREE'],
        $value['AREA'],
        $value['DEGREE']
    );
}

   public static function getAdminListEditHTML($userField, $additionalParameters): string
    {
        $value = static::onAfterFetch($userField, $additionalParameters['VALUE']);
        $settings = static::prepareSettings($userField);
        $fieldName = $additionalParameters['NAME'];
        
        return sprintf('
            <div style="display: flex; gap: 5px; align-items: center;">
                <input type="number" 
                       name="%s[AREA]" 
                       value="%s" 
                       step="0.01" 
                       min="%s" 
                       max="%s"
                       placeholder="%s"
                       style="width: 80px;">
                <span>м²</span>
                <input type="number" 
                       name="%s[DEGREE]" 
                       value="%s" 
                       step="0.01" 
                       min="%s" 
                       max="%s"
                       placeholder="%s"
                       style="width: 60px;">
            </div>',
            $fieldName,
            $value['AREA'],
            $settings['AREA_MIN'],
            $settings['AREA_MAX'],
            $settings['AREA_LABEL'],
            $fieldName,
            $value['DEGREE'],
            $settings['DEGREE_MIN'],
            $settings['DEGREE_MAX'],
            $settings['DEGREE_LABEL']
        );
    }

public static function getSettingsHtml($userField, $additionalParameters, $varsFromForm): string
{
    // Приводим $userField к массиву, если это необходимо
    if (!is_array($userField)) {
        $userField = [];
    }
    
    $settings = static::prepareSettings($userField);
    $name = $additionalParameters['NAME'] ?? '';
    
    if ($varsFromForm) {
        $settings['AREA_LABEL'] = $_REQUEST[$name]['AREA_LABEL'] ?? $settings['AREA_LABEL'];
        $settings['DEGREE_LABEL'] = $_REQUEST[$name]['DEGREE_LABEL'] ?? $settings['DEGREE_LABEL'];
        $settings['AREA_MIN'] = (float)($_REQUEST[$name]['AREA_MIN'] ?? $settings['AREA_MIN']);
        $settings['AREA_MAX'] = (float)($_REQUEST[$name]['AREA_MAX'] ?? $settings['AREA_MAX']);
        $settings['DEGREE_MIN'] = (float)($_REQUEST[$name]['DEGREE_MIN'] ?? $settings['DEGREE_MIN']);
        $settings['DEGREE_MAX'] = (float)($_REQUEST[$name]['DEGREE_MAX'] ?? $settings['DEGREE_MAX']);
    }
    
    return '
    <tr>
        <td>Подпись для площади:</td>
        <td><input type="text" name="'.$name.'[AREA_LABEL]" value="'.htmlspecialchars($settings['AREA_LABEL']).'" size="30"></td>
    </tr>
    <tr>
        <td>Подпись для степени:</td>
        <td><input type="text" name="'.$name.'[DEGREE_LABEL]" value="'.htmlspecialchars($settings['DEGREE_LABEL']).'" size="30"></td>
    </tr>
    <tr>
        <td>Минимальная площадь:</td>
        <td><input type="number" name="'.$name.'[AREA_MIN]" value="'.$settings['AREA_MIN'].'" step="0.01"></td>
    </tr>
    <tr>
        <td>Максимальная площадь:</td>
        <td><input type="number" name="'.$name.'[AREA_MAX]" value="'.$settings['AREA_MAX'].'" step="0.01"></td>
    </tr>
    <tr>
        <td>Минимальная степень:</td>
        <td><input type="number" name="'.$name.'[DEGREE_MIN]" value="'.$settings['DEGREE_MIN'].'" step="0.01"></td>
    </tr>
    <tr>
        <td>Максимальная степень:</td>
        <td><input type="number" name="'.$name.'[DEGREE_MAX]" value="'.$settings['DEGREE_MAX'].'" step="0.01"></td>
    </tr>';
}

    public static function formatValue(array $userField, $value): string
    {
        $data = static::onAfterFetch($userField, $value);
        $settings = static::prepareSettings($userField);
        
        return sprintf(
            '%s: %s м², %s: %s',
            $settings['AREA_LABEL'],
            $data['AREA'],
            $settings['DEGREE_LABEL'],
            $data['DEGREE']
        );
    }

    public static function checkFields(array $userField, $value): array
    {
        $errors = [];
        
        if ($userField['MANDATORY'] === 'Y') {
            $data = static::onAfterFetch($userField, $value);
            
            if ($data['AREA'] <= 0 && $data['DEGREE'] <= 0) {
                $errors[] = [
                    'id' => $userField['FIELD_NAME'],
                    'text' => 'Поле "' . $userField['LIST_COLUMN_LABEL'] . '" обязательно для заполнения'
                ];
            }
        }
        
        return $errors;
    }
}