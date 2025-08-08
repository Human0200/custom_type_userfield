<?php

namespace B24\Academy\UserField;

use Bitrix\Main\Localization\Loc;
use Bitrix\Main\UserField\Types\BaseType;

class PollutionDegreeField extends BaseType
{
    public const USER_TYPE_ID = 'pollution_degree';

    /**
     * Возвращает описание типа поля
     */
    public static function getUserTypeDescription(): array
    {
        return [
            'USER_TYPE_ID' => static::USER_TYPE_ID,
            'CLASS_NAME' => static::class,
            'DESCRIPTION' => Loc::getMessage('USER_TYPE_POLLUTION_DEGREE_DESCRIPTION') ?: 'Степень загрязнения (уровень и источник)',
            'BASE_TYPE' => 'string',
            'VIEW_CALLBACK' => [static::class, 'getPublicView'],
            'EDIT_CALLBACK' => [static::class, 'getPublicEdit'],
        ];
    }

    /**
     * Возвращает HTML для просмотра поля
     */
    public static function renderView(array $userField, ?array $additionalParameters = []): string
    {
        $value = static::extractValue($userField, $additionalParameters);
        $parsedValue = static::parseValue($value);

        return '<div class="pollution-degree-view" style="display: flex; gap: 10px;">' .
            '<span class="pollution-level"><strong>Площадь:</strong> ' . htmlspecialchars($parsedValue['level']) . '</span>' .
            '<span class="pollution-source"><strong>Коэффициент:</strong> ' . htmlspecialchars($parsedValue['source']) . '</span>' .
            '</div>';
    }

    /**
     * Возвращает HTML для редактирования поля
     */
    public static function renderEdit(array $userField, ?array $additionalParameters = []): string
    {
        $fieldName = static::extractFieldName($userField, $additionalParameters);
        $value = static::extractValue($userField, $additionalParameters);
        $required = ($userField['MANDATORY'] === 'Y');

        if (empty($value)) {
            $value = static::getDefaultValue($userField, $additionalParameters ?: []);
        }

        $parsedValue = static::parseValue($value);
        $fieldId = 'pollution_' . md5($fieldName);

        $html = '<div class="pollution-degree-edit" style="display: flex; gap: 15px; align-items: center; flex-wrap: wrap;">';

        // Поле для площади загрязнения
        $html .= '<div style="display: flex; flex-direction: column; min-width: 150px;">';
        $html .= '<label for="' . $fieldId . '_level" style="font-size: 12px; margin-bottom: 3px; font-weight: bold;">Площадь:</label>';
        $html .= '<input type="text" 
                         id="' . $fieldId . '_level" 
                         class="pollution-level-input" 
                         style="width: 100%; padding: 5px; border: 1px solid #ccc; border-radius: 3px;" 
                         value="' . htmlspecialchars($parsedValue['level']) . '"
                         placeholder="Введите площадь"
                         ' . ($required ? 'required' : '') . '>';
        $html .= '</div>';

        // Поле для коэффициента загрязнения
        $html .= '<div style="display: flex; flex-direction: column; min-width: 150px;">';
        $html .= '<label for="' . $fieldId . '_source" style="font-size: 12px; margin-bottom: 3px; font-weight: bold;">Коэффициент:</label>';
        $html .= '<input type="text" 
                         id="' . $fieldId . '_source" 
                         class="pollution-source-input" 
                         style="width: 100%; padding: 5px; border: 1px solid #ccc; border-radius: 3px;" 
                         value="' . htmlspecialchars($parsedValue['source']) . '"
                         placeholder="Введите коэффициент"
                         ' . ($required ? 'required' : '') . '>';
        $html .= '</div>';

        // Скрытое поле для отправки объединенного значения
        $html .= '<input type="hidden" 
                         name="' . htmlspecialchars($fieldName) . '" 
                         id="' . $fieldId . '_combined" 
                         value="' . htmlspecialchars($value) . '">';

        // JavaScript для объединения значений
        $html .= '<script>
        (function() {
            var levelInput = document.getElementById("' . $fieldId . '_level");
            var sourceInput = document.getElementById("' . $fieldId . '_source");
            var hiddenInput = document.getElementById("' . $fieldId . '_combined");
            
            function updateCombinedValue() {
                if (levelInput && sourceInput && hiddenInput) {
                    var levelVal = levelInput.value.trim();
                    var sourceVal = sourceInput.value.trim();
                    hiddenInput.value = levelVal + "," + sourceVal;
                }
            }
            
            if (levelInput) {
                levelInput.addEventListener("input", updateCombinedValue);
                levelInput.addEventListener("blur", updateCombinedValue);
            }
            if (sourceInput) {
                sourceInput.addEventListener("input", updateCombinedValue);
                sourceInput.addEventListener("blur", updateCombinedValue);
            }
        })();
        </script>';

        $html .= '</div>';

        return $html;
    }

    /**
     * Возвращает HTML для настроек поля
     */
    public static function renderSettings($userField, ?array $additionalParameters, $varsFromForm): string
    {
        return '<div class="pollution-degree-settings">
                    <p>Поле "Степень загрязнения" состоит из двух текстовых полей:</p>
                    <ul>
                        <li><strong>Уровень загрязнения:</strong> свободный ввод текста</li>
                        <li><strong>Источник загрязнения:</strong> свободный ввод текста</li>
                    </ul>
                    <p>В базе данных сохраняется как строка в формате: "уровень,источник"</p>
                    <p><em>Пример:</em> "высокий,промышленные выбросы" → сохранится как "высокий,промышленные выбросы"</p>
                </div>';
    }

    /**
     * Возвращает тип столбца в БД
     */
    public static function getDbColumnType(): string
    {
        return 'varchar(255)';
    }

    /**
     * Поддерживается ли обязательность поля
     */
    public static function isMandatorySupported(): bool
    {
        return true;
    }

    /**
     * Поддерживается ли множественность
     */
    public static function isMultiplicitySupported(): bool
    {
        return false;
    }

    /**
     * Возвращает значение по умолчанию
     */
    public static function getDefaultValue(array $userField, array $additionalParameters = []): string
    {
        return ',';
    }

    /**
     * Возвращает HTML для отображения поля
     */
    public static function renderField(array $userField, ?array $additionalParameters = []): string
    {
        return static::renderEdit($userField, $additionalParameters);
    }

    /**
     * Возвращает HTML для формы редактирования
     */
    public static function renderEditForm(array $userField, ?array $additionalParameters): string
    {
        return static::renderEdit($userField, $additionalParameters);
    }

    /**
     * Возвращает HTML для просмотра в админке
     */
    public static function renderAdminListView(array $userField, ?array $additionalParameters): string
    {
        return static::renderView($userField, $additionalParameters);
    }

    /**
     * Возвращает HTML для редактирования в списке админки
     */
    public static function renderAdminListEdit(array $userField, ?array $additionalParameters): string
    {
        return static::renderEdit($userField, $additionalParameters);
    }

    /**
     * Возвращает HTML для фильтра
     */
    public static function renderFilter(array $userField, ?array $additionalParameters): string
    {
        $fieldName = static::extractFieldName($userField, $additionalParameters);
        $value = $additionalParameters['VALUE'] ?? '';
        $parsedValue = static::parseValue($value);
        $fieldId = 'filter_pollution_' . md5($fieldName);

        $html = '<div class="pollution-degree-filter" style="display: flex; gap: 10px; align-items: center;">';

        // Фильтр по уровню
        $html .= '<div style="display: flex; flex-direction: column;">';
        $html .= '<label for="' . $fieldId . '_level" style="font-size: 11px; margin-bottom: 2px;">Уровень:</label>';
        $html .= '<input type="text" 
                         id="' . $fieldId . '_level"
                         name="' . htmlspecialchars($fieldName) . '[level]" 
                         style="width: 100px; padding: 3px; font-size: 12px;"
                         value="' . htmlspecialchars($parsedValue['level']) . '"
                         placeholder="Уровень">';
        $html .= '</div>';

        // Фильтр по источнику
        $html .= '<div style="display: flex; flex-direction: column;">';
        $html .= '<label for="' . $fieldId . '_source" style="font-size: 11px; margin-bottom: 2px;">Источник:</label>';
        $html .= '<input type="text" 
                         id="' . $fieldId . '_source"
                         name="' . htmlspecialchars($fieldName) . '[source]" 
                         style="width: 120px; padding: 3px; font-size: 12px;"
                         value="' . htmlspecialchars($parsedValue['source']) . '"
                         placeholder="Источник">';
        $html .= '</div>';

        $html .= '</div>';

        return $html;
    }

    /**
     * Возвращает текстовое представление
     */
    public static function renderText(array $userField): string
    {
        $value = $userField['VALUE'] ?? '';
        $parsedValue = static::parseValue($value);

        if (empty($parsedValue['level']) && empty($parsedValue['source'])) {
            return '';
        }

        $parts = [];
        if (!empty($parsedValue['level'])) {
            $parts[] = $parsedValue['level'];
        }
        if (!empty($parsedValue['source'])) {
            $parts[] = '(' . $parsedValue['source'] . ')';
        }

        return implode(' ', $parts);
    }

    // Алиасы методов
    public static function getSettingsHtml($userField, ?array $additionalParameters, $varsFromForm): string
    {
        return static::renderSettings($userField, $additionalParameters, $varsFromForm);
    }

    public static function getPublicView(array $userField, ?array $additionalParameters = []): string
    {
        return static::renderView($userField, $additionalParameters);
    }

    public static function getPublicEdit(array $userField, ?array $additionalParameters = []): string
    {
        return static::renderEdit($userField, $additionalParameters);
    }

    public static function getEditFormHtml(array $userField, ?array $additionalParameters): string
    {
        return static::renderEditForm($userField, $additionalParameters);
    }

    public static function getAdminListViewHtml(array $userField, ?array $additionalParameters): string
    {
        return static::renderAdminListView($userField, $additionalParameters);
    }

    public static function getAdminListEditHTML(array $userField, ?array $additionalParameters): string
    {
        return static::renderAdminListEdit($userField, $additionalParameters);
    }

    public static function getFilterHtml(array $userField, ?array $additionalParameters): string
    {
        return static::renderFilter($userField, $additionalParameters);
    }

    public static function getPublicText(array $userField): string
    {
        return static::renderText($userField);
    }

    // Вспомогательные методы

    /**
     * Разбирает строковое значение на компоненты
     */
    private static function parseValue(string $value): array
    {
        if (empty($value)) {
            return ['level' => '', 'source' => ''];
        }

        $parts = explode(',', $value, 2);
        return [
            'level' => trim($parts[0] ?? ''),
            'source' => trim($parts[1] ?? ''),
        ];
    }

    /**
     * Извлекает значение поля из параметров
     */
    private static function extractValue(array $userField, ?array $additionalParameters = []): string
    {
        return $additionalParameters['VALUE'] ?? $userField['VALUE'] ?? '';
    }

    /**
     * Извлекает имя поля из параметров
     */
    private static function extractFieldName(array $userField, ?array $additionalParameters = []): string
    {
        return $additionalParameters['NAME'] ?? $userField['FIELD_NAME'] ?? '';
    }
}
