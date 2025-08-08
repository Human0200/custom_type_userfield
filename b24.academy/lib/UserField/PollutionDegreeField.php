<?php

namespace B24\Academy\UserField;

use Bitrix\Main\Localization\Loc;
use Bitrix\Main\UserField\Types\BaseType;

class PollutionDegreeField extends BaseType
{
    public const USER_TYPE_ID = 'pollution_degree';
    public const RENDER_COMPONENT = 'b24.academy:pollution.degree.field';

    /**
     * Возвращает описание типа поля
     */
    protected static function getDescription(): array
    {
        return [
            'DESCRIPTION' => Loc::getMessage('B24_ACADEMY.UFTYPE_POLLUTION_DEGREE_DESCRIPTION'),
            'BASE_TYPE' => \CUserTypeManager::BASE_TYPE_STRING,
        ];
    }

    /**
     * Возвращает тип поля в БД
     */
    public static function getDbColumnType(): string
    {
        return 'text';
    }

    /**
     * Подготавливает настройки поля
     */
    public static function prepareSettings($userField): array
    {
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

    /**
     * Обработка значения перед сохранением в БД
     */
    public static function onBeforeSave($userField, $value)
    {
        if (is_array($value)) {
            $area = (float)($value['AREA'] ?? 0);
            $degree = (float)($value['DEGREE'] ?? 0);
            
            // Валидация значений
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

    /**
     * Обработка значения после получения из БД - ИСПРАВЛЕНО
     */
    public static function onAfterFetch($userField, $value)
    {
        // Если пустое значение
        if (empty($value)) {
            return [
                'AREA' => 0,
                'DEGREE' => 0,
            ];
        }

        // Если уже массив (может быть обработан ранее)
        if (is_array($value)) {
            // Проверяем формат массива
            if (isset($value['area']) && isset($value['degree'])) {
                return [
                    'AREA' => (float)$value['area'],
                    'DEGREE' => (float)$value['degree'],
                ];
            }
            
            // Если уже в нужном формате
            if (isset($value['AREA']) && isset($value['DEGREE'])) {
                return [
                    'AREA' => (float)$value['AREA'],
                    'DEGREE' => (float)$value['DEGREE'],
                ];
            }
        }

        // Если строка JSON
        if (is_string($value)) {
            $data = json_decode($value, true);
            if (is_array($data) && isset($data['area']) && isset($data['degree'])) {
                return [
                    'AREA' => (float)$data['area'],
                    'DEGREE' => (float)$data['degree'],
                ];
            }
        }
        
        // Значения по умолчанию
        return [
            'AREA' => 0,
            'DEGREE' => 0,
        ];
    }

    /**
     * Значение по умолчанию
     */
    public static function getDefaultValue($userField, array $additionalParameters = [])
    {
        return json_encode([
            'area' => 0,
            'degree' => 0
        ]);
    }

    /**
     * HTML для отображения в списке (админка)
     */
    public static function getAdminListViewHTML($userField, $additionalParameters): string
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

    /**
     * HTML для редактирования в списке (админка)
     */
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

    /**
     * HTML для настроек поля
     */
    public static function getSettingsHtml($userField, ?array $additionalParameters, $varsFromForm): string
    {
        $settings = static::prepareSettings($userField);
        $name = $additionalParameters['NAME'];
        
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

    /**
     * Форматирует значение для отображения
     */
    public static function formatValue($userField, $value): string
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

    /**
     * Проверяет, является ли значение пустым
     */
    public static function checkFields($userField, $value): array
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