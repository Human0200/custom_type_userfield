#!/bin/bash

# Полный скрипт для создания модуля "Степень загрязнения" для Bitrix24
# Запустите скрипт в директории, где хотите создать модуль

MODULE_DIR="b24.academy"

echo "🚀 Создание модуля пользовательского поля 'Степень загрязнения'..."

# Удаление старой структуры если существует
if [ -d "$MODULE_DIR" ]; then
    echo "🗑️  Удаление существующей структуры модуля..."
    rm -rf "$MODULE_DIR"
fi

# Создание основной структуры директорий
echo "📁 Создание структуры директорий..."
mkdir -p "$MODULE_DIR"
mkdir -p "$MODULE_DIR/lib/UserField"
mkdir -p "$MODULE_DIR/install"
mkdir -p "$MODULE_DIR/install/components/b24.academy/pollution.degree.field"
mkdir -p "$MODULE_DIR/install/components/b24.academy/pollution.degree.field/templates/.default"
mkdir -p "$MODULE_DIR/install/components/b24.academy/pollution.degree.field/templates/main.edit"
mkdir -p "$MODULE_DIR/install/components/b24.academy/pollution.degree.field/templates/main.view"
mkdir -p "$MODULE_DIR/install/components/b24.academy/pollution.degree.field/templates/main.admin_settings"
mkdir -p "$MODULE_DIR/install/migrations"
mkdir -p "$MODULE_DIR/lang/ru/lib/UserField"
mkdir -p "$MODULE_DIR/lang/en/lib/UserField"
mkdir -p "$MODULE_DIR/lang/ru/install"
mkdir -p "$MODULE_DIR/lang/en/install"

# Создание основного файла include.php
echo "📄 Создание include.php..."
cat > "$MODULE_DIR/include.php" << 'EOF'
<?php

defined('B_PROLOG_INCLUDED') || die;
EOF

# Создание основного класса поля (ИСПРАВЛЕННАЯ ВЕРСИЯ)
echo "📄 Создание основного класса PollutionDegreeField..."
cat > "$MODULE_DIR/lib/UserField/PollutionDegreeField.php" << 'EOF'
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
     * Обработка значения после получения из БД
     */
    public static function onAfterFetch($userField, $value)
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
EOF

# Создание класса компонента
echo "📄 Создание компонента..."
cat > "$MODULE_DIR/install/components/b24.academy/pollution.degree.field/class.php" << 'EOF'
<?php

use B24\Academy\UserField\PollutionDegreeField;
use Bitrix\Main\Component\BaseUfComponent;

defined('B_PROLOG_INCLUDED') || die;

class PollutionDegreeFieldComponent extends BaseUfComponent
{
    /**
     * Возвращает ID типа пользовательского поля
     */
    protected static function getUserTypeId(): string
    {
        return PollutionDegreeField::USER_TYPE_ID;
    }

    /**
     * Возвращает настройки поля
     */
    public function getSettings(): array
    {
        return PollutionDegreeField::prepareSettings($this->userField);
    }

    /**
     * Форматирует значение для отображения
     */
    public function formatValue($value): string
    {
        return PollutionDegreeField::formatValue($this->userField, $value);
    }

    /**
     * Получает данные значения
     */
    public function getValue()
    {
        return PollutionDegreeField::onAfterFetch($this->userField, $this->value);
    }

    /**
     * Проверяет, является ли поле множественным
     */
    public function isMultiple(): bool
    {
        return $this->userField['MULTIPLE'] === 'Y';
    }

    /**
     * Возвращает атрибуты для HTML полей
     */
    public function getFieldAttributes(string $fieldType = 'area'): array
    {
        $settings = $this->getSettings();
        $value = $this->getValue();
        
        $attributes = [
            'type' => 'number',
            'step' => '0.01',
            'class' => 'pollution-degree-field'
        ];

        if ($fieldType === 'area') {
            $attributes['name'] = $this->getFieldName() . '[AREA]';
            $attributes['value'] = $value['AREA'];
            $attributes['placeholder'] = $settings['AREA_LABEL'];
            $attributes['min'] = $settings['AREA_MIN'];
            $attributes['max'] = $settings['AREA_MAX'];
        } else {
            $attributes['name'] = $this->getFieldName() . '[DEGREE]';
            $attributes['value'] = $value['DEGREE'];
            $attributes['placeholder'] = $settings['DEGREE_LABEL'];
            $attributes['min'] = $settings['DEGREE_MIN'];
            $attributes['max'] = $settings['DEGREE_MAX'];
        }

        if ($this->userField['EDIT_IN_LIST'] !== 'Y') {
            $attributes['readonly'] = 'readonly';
        }

        return $attributes;
    }

    /**
     * Генерирует HTML атрибуты из массива
     */
    public function buildAttributes(array $attributes): string
    {
        $html = [];
        foreach ($attributes as $key => $value) {
            if ($value !== null) {
                $html[] = $key . '="' . htmlspecialchars($value) . '"';
            }
        }
        return implode(' ', $html);
    }
}
EOF

# Создание шаблона по умолчанию
echo "📄 Создание шаблона по умолчанию..."
cat > "$MODULE_DIR/install/components/b24.academy/pollution.degree.field/templates/.default/.default.php" << 'EOF'
<?php

defined('B_PROLOG_INCLUDED') || die;

/**
 * @var array $arResult
 * @var PollutionDegreeFieldComponent $component
 */

print $component->formatValue($arResult['value']);
EOF

# Создание шаблона редактирования
echo "📄 Создание шаблона редактирования..."
cat > "$MODULE_DIR/install/components/b24.academy/pollution.degree.field/templates/main.edit/.default.php" << 'EOF'
<?php
defined('B_PROLOG_INCLUDED') || die;

/**
 * @var array $arResult
 * @var PollutionDegreeFieldComponent $component
 */

$settings = $component->getSettings();
$value = $component->getValue();
$fieldName = $arResult['fieldName'];
$areaAttributes = $component->getFieldAttributes('area');
$degreeAttributes = $component->getFieldAttributes('degree');
?>

<div class="pollution-degree-container" style="display: flex; gap: 10px; align-items: center; flex-wrap: wrap;">
    <div class="pollution-degree-area" style="display: flex; align-items: center; gap: 5px;">
        <label style="min-width: 60px; font-size: 12px;"><?= htmlspecialchars($settings['AREA_LABEL']) ?>:</label>
        <input <?= $component->buildAttributes($areaAttributes) ?> style="width: 80px;">
        <span style="font-size: 12px; color: #666;">м²</span>
    </div>
    
    <div class="pollution-degree-degree" style="display: flex; align-items: center; gap: 5px;">
        <label style="min-width: 80px; font-size: 12px;"><?= htmlspecialchars($settings['DEGREE_LABEL']) ?>:</label>
        <input <?= $component->buildAttributes($degreeAttributes) ?> style="width: 60px;">
    </div>
</div>

<style>
.pollution-degree-container input[type="number"] {
    padding: 4px 6px;
    border: 1px solid #ccc;
    border-radius: 3px;
    font-size: 12px;
}

.pollution-degree-container input[type="number"]:focus {
    outline: none;
    border-color: #0078d4;
    box-shadow: 0 0 0 1px rgba(0, 120, 212, 0.3);
}

.pollution-degree-container label {
    font-weight: 500;
    color: #333;
}

@media (max-width: 768px) {
    .pollution-degree-container {
        flex-direction: column;
        align-items: flex-start;
        gap: 8px;
    }
    
    .pollution-degree-area,
    .pollution-degree-degree {
        width: 100%;
    }
}
</style>
EOF

# Создание модификатора результатов для шаблона редактирования
echo "📄 Создание result_modifier для шаблона редактирования..."
cat > "$MODULE_DIR/install/components/b24.academy/pollution.degree.field/templates/main.edit/result_modifier.php" << 'EOF'
<?php

defined('B_PROLOG_INCLUDED') || die;

/**
 * @var CBitrixComponentTemplate $this
 * @var PollutionDegreeFieldComponent $component
 * @var array $arResult
 */

// Дополнительная логика обработки результатов для шаблона редактирования
// В данном случае используется базовая функциональность компонента
EOF

# Создание шаблона просмотра
echo "📄 Создание шаблона просмотра..."
cat > "$MODULE_DIR/install/components/b24.academy/pollution.degree.field/templates/main.view/.default.php" << 'EOF'
<?php
defined('B_PROLOG_INCLUDED') || die;

/**
 * @var array $arResult
 * @var PollutionDegreeFieldComponent $component
 */

$settings = $component->getSettings();
$value = $component->getValue();
?>

<div class="pollution-degree-view" style="display: inline-flex; gap: 15px; align-items: center;">
    <span class="pollution-area" style="display: flex; align-items: center; gap: 3px;">
        <strong><?= htmlspecialchars($settings['AREA_LABEL']) ?>:</strong>
        <span style="color: #0078d4; font-weight: 500;"><?= $value['AREA'] ?> м²</span>
    </span>
    
    <span class="pollution-degree" style="display: flex; align-items: center; gap: 3px;">
        <strong><?= htmlspecialchars($settings['DEGREE_LABEL']) ?>:</strong>
        <span style="color: #d83b01; font-weight: 500;"><?= $value['DEGREE'] ?></span>
    </span>
</div>
EOF

# Создание модификатора результатов для шаблона просмотра
echo "📄 Создание result_modifier для шаблона просмотра..."
cat > "$MODULE_DIR/install/components/b24.academy/pollution.degree.field/templates/main.view/result_modifier.php" << 'EOF'
<?php

defined('B_PROLOG_INCLUDED') || die;

/**
 * @var CBitrixComponentTemplate $this
 * @var PollutionDegreeFieldComponent $component
 * @var array $arResult
 */

// Дополнительная обработка для отображения
$component = $this->getComponent();
$value = $component->getValue();

// Проверяем, что значения корректные
if ($value['AREA'] < 0) $value['AREA'] = 0;
if ($value['DEGREE'] < 0) $value['DEGREE'] = 0;

$arResult['processedValue'] = $value;
EOF

# Создание шаблона настроек админки
echo "📄 Создание шаблона настроек админки..."
cat > "$MODULE_DIR/install/components/b24.academy/pollution.degree.field/templates/main.admin_settings/.default.php" << 'EOF'
<?php
use Bitrix\Main\Localization\Loc;
use Bitrix\Main\UI\Extension;

defined('B_PROLOG_INCLUDED') || die;

/**
 * @var array $arResult
 */

$additionalParameters = $arResult['additionalParameters'];
$settings = $arResult['settings'];

Extension::load('ui.hint');
?>

<tr>
    <td>
        <label for="pollution-area-label"><?= Loc::getMessage('B24_ACADEMY.UFTYPE_POLLUTION_DEGREE_AREA_LABEL_SETTING') ?></label>
    </td>
    <td>
        <input
            type="text"
            id="pollution-area-label"
            name="<?= $additionalParameters['NAME'] ?>[AREA_LABEL]"
            value="<?= htmlspecialchars($settings['AREA_LABEL']) ?>"
            size="30"
            maxlength="255"
        />
    </td>
</tr>

<tr>
    <td>
        <label for="pollution-degree-label"><?= Loc::getMessage('B24_ACADEMY.UFTYPE_POLLUTION_DEGREE_DEGREE_LABEL_SETTING') ?></label>
    </td>
    <td>
        <input
            type="text"
            id="pollution-degree-label"
            name="<?= $additionalParameters['NAME'] ?>[DEGREE_LABEL]"
            value="<?= htmlspecialchars($settings['DEGREE_LABEL']) ?>"
            size="30"
            maxlength="255"
        />
    </td>
</tr>

<tr>
    <td>
        <div>
            <label for="pollution-area-min"><?= Loc::getMessage('B24_ACADEMY.UFTYPE_POLLUTION_DEGREE_AREA_MIN_SETTING') ?></label>
            <span data-hint-html data-hint="<?= Loc::getMessage('B24_ACADEMY.UFTYPE_POLLUTION_DEGREE_AREA_MIN_SETTING_HINT') ?>"></span>
        </div>
    </td>
    <td>
        <input
            type="number"
            id="pollution-area-min"
            name="<?= $additionalParameters['NAME'] ?>[AREA_MIN]"
            value="<?= $settings['AREA_MIN'] ?>"
            step="0.01"
            min="0"
        />
    </td>
</tr>

<tr>
    <td>
        <div>
            <label for="pollution-area-max"><?= Loc::getMessage('B24_ACADEMY.UFTYPE_POLLUTION_DEGREE_AREA_MAX_SETTING') ?></label>
            <span data-hint-html data-hint="<?= Loc::getMessage('B24_ACADEMY.UFTYPE_POLLUTION_DEGREE_AREA_MAX_SETTING_HINT') ?>"></span>
        </div>
    </td>
    <td>
        <input
            type="number"
            id="pollution-area-max"
            name="<?= $additionalParameters['NAME'] ?>[AREA_MAX]"
            value="<?= $settings['AREA_MAX'] ?>"
            step="0.01"
            min="1"
        />
    </td>
</tr>

<tr>
    <td>
        <div>
            <label for="pollution-degree-min"><?= Loc::getMessage('B24_ACADEMY.UFTYPE_POLLUTION_DEGREE_DEGREE_MIN_SETTING') ?></label>
            <span data-hint-html data-hint="<?= Loc::getMessage('B24_ACADEMY.UFTYPE_POLLUTION_DEGREE_DEGREE_MIN_SETTING_HINT') ?>"></span>
        </div>
    </td>
    <td>
        <input
            type="number"
            id="pollution-degree-min"
            name="<?= $additionalParameters['NAME'] ?>[DEGREE_MIN]"
            value="<?= $settings['DEGREE_MIN'] ?>"
            step="0.01"
            min="0"
        />
    </td>
</tr>

<tr>
    <td>
        <div>
            <label for="pollution-degree-max"><?= Loc::getMessage('B24_ACADEMY.UFTYPE_POLLUTION_DEGREE_DEGREE_MAX_SETTING') ?></label>
            <span data-hint-html data-hint="<?= Loc::getMessage('B24_ACADEMY.UFTYPE_POLLUTION_DEGREE_DEGREE_MAX_SETTING_HINT') ?>"></span>
        </div>
    </td>
    <td>
        <input
            type="number"
            id="pollution-degree-max"
            name="<?= $additionalParameters['NAME'] ?>[DEGREE_MAX]"
            value="<?= $settings['DEGREE_MAX'] ?>"
            step="0.01"
            min="1"
        />
    </td>
</tr>

<script>
BX.ready(function () {
    BX.UI.Hint.init();
});
</script>
EOF

# Создание модификатора результатов для настроек
echo "📄 Создание result_modifier для настроек..."
cat > "$MODULE_DIR/install/components/b24.academy/pollution.degree.field/templates/main.admin_settings/result_modifier.php" << 'EOF'
<?php

defined('B_PROLOG_INCLUDED') || die;

/**
 * @var array $arResult
 */

$values = [];
if (isset($arResult['additionalParameters']['bVarsFromForm']) && $arResult['additionalParameters']['bVarsFromForm']) {
    $values['AREA_LABEL'] = $GLOBALS[$arResult['additionalParameters']['NAME']]['AREA_LABEL'] ?? 'Площадь (м²)';
    $values['DEGREE_LABEL'] = $GLOBALS[$arResult['additionalParameters']['NAME']]['DEGREE_LABEL'] ?? 'Степень загрязнения';
    $values['AREA_MIN'] = (float)($GLOBALS[$arResult['additionalParameters']['NAME']]['AREA_MIN'] ?? 0);
    $values['AREA_MAX'] = (float)($GLOBALS[$arResult['additionalParameters']['NAME']]['AREA_MAX'] ?? 999999);
    $values['DEGREE_MIN'] = (float)($GLOBALS[$arResult['additionalParameters']['NAME']]['DEGREE_MIN'] ?? 0);
    $values['DEGREE_MAX'] = (float)($GLOBALS[$arResult['additionalParameters']['NAME']]['DEGREE_MAX'] ?? 100);
} elseif (isset($arResult['userField']) && $arResult['userField']) {
    $values['AREA_LABEL'] = $arResult['userField']['SETTINGS']['AREA_LABEL'] ?? 'Площадь (м²)';
    $values['DEGREE_LABEL'] = $arResult['userField']['SETTINGS']['DEGREE_LABEL'] ?? 'Степень загрязнения';
    $values['AREA_MIN'] = (float)($arResult['userField']['SETTINGS']['AREA_MIN'] ?? 0);
    $values['AREA_MAX'] = (float)($arResult['userField']['SETTINGS']['AREA_MAX'] ?? 999999);
    $values['DEGREE_MIN'] = (float)($arResult['userField']['SETTINGS']['DEGREE_MIN'] ?? 0);
    $values['DEGREE_MAX'] = (float)($arResult['userField']['SETTINGS']['DEGREE_MAX'] ?? 100);
} else {
    $values = [
        'AREA_LABEL' => 'Площадь (м²)',
        'DEGREE_LABEL' => 'Степень загрязнения',
        'AREA_MIN' => 0,
        'AREA_MAX' => 999999,
        'DEGREE_MIN' => 0,
        'DEGREE_MAX' => 100,
    ];
}

$arResult['settings'] = $values;
EOF

# Создание файла установщика модуля
echo "📄 Создание установщика модуля..."
cat > "$MODULE_DIR/install/index.php" << 'EOF'
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

    function DoInstall()
    {
        ModuleManager::registerModule($this->MODULE_ID);
        $this->InstallEvents();
        $this->InstallFiles();
    }

    function DoUninstall()
    {
        $this->UnInstallEvents();
        $this->UnInstallFiles();
        ModuleManager::unRegisterModule($this->MODULE_ID);
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
    }

    function InstallFiles()
    {
        // Копирование компонентов
        CopyDirFiles(
            __DIR__ . '/components/',
            $_SERVER['DOCUMENT_ROOT'] . '/local/components/',
            true,
            true
        );
    }

    function UnInstallFiles()
    {
        // Удаление файлов компонентов
        DeleteDirFiles(
            __DIR__ . '/components/',
            $_SERVER['DOCUMENT_ROOT'] . '/local/components/'
        );
    }
}
EOF

# Создание файла версии
echo "📄 Создание файла версии..."
cat > "$MODULE_DIR/install/version.php" << 'EOF'
<?php

return [
    'VERSION' => '1.0.0',
    'VERSION_DATE' => '2023-12-05 15:00:00',
];
EOF

# Создание миграции
echo "📄 Создание миграции..."
cat > "$MODULE_DIR/install/migrations/2023_12_05_15_00_00.php" << 'EOF'
<?php

use B24\Academy\UserField\PollutionDegreeField;
use Bitrix\Main\Config\Option;
use Bitrix\Main\EventManager;
use Bitrix\Main\IO\Path;

// Копируем компоненты
CopyDirFiles(
    Path::combine(__DIR__, '/../components/b24.academy/pollution.degree.field'),
    Path::convertRelativeToAbsolute('/local/components/b24.academy/pollution.degree.field/'),
    true,
    true
);

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
EOF

# Создание русских языковых файлов
echo "📄 Создание русских языковых файлов..."
cat > "$MODULE_DIR/lang/ru/lib/UserField/PollutionDegreeField.php" << 'EOF'
<?php

$MESS['B24_ACADEMY.UFTYPE_POLLUTION_DEGREE_DESCRIPTION'] = 'Степень загрязнения';
$MESS['B24_ACADEMY.UFTYPE_POLLUTION_DEGREE_AREA_LABEL_SETTING'] = 'Подпись для поля площади';
$MESS['B24_ACADEMY.UFTYPE_POLLUTION_DEGREE_DEGREE_LABEL_SETTING'] = 'Подпись для поля степени загрязнения';
$MESS['B24_ACADEMY.UFTYPE_POLLUTION_DEGREE_AREA_MIN_SETTING'] = 'Минимальное значение площади';
$MESS['B24_ACADEMY.UFTYPE_POLLUTION_DEGREE_AREA_MIN_SETTING_HINT'] = 'Минимально допустимое значение для поля площади (м²)';
$MESS['B24_ACADEMY.UFTYPE_POLLUTION_DEGREE_AREA_MAX_SETTING'] = 'Максимальное значение площади';
$MESS['B24_ACADEMY.UFTYPE_POLLUTION_DEGREE_AREA_MAX_SETTING_HINT'] = 'Максимально допустимое значение для поля площади (м²)';
$MESS['B24_ACADEMY.UFTYPE_POLLUTION_DEGREE_DEGREE_MIN_SETTING'] = 'Минимальное значение степени загрязнения';
$MESS['B24_ACADEMY.UFTYPE_POLLUTION_DEGREE_DEGREE_MIN_SETTING_HINT'] = 'Минимально допустимое значение для поля степени загрязнения';
$MESS['B24_ACADEMY.UFTYPE_POLLUTION_DEGREE_DEGREE_MAX_SETTING'] = 'Максимальное значение степени загрязнения';
$MESS['B24_ACADEMY.UFTYPE_POLLUTION_DEGREE_DEGREE_MAX_SETTING_HINT'] = 'Максимально допустимое значение для поля степени загрязнения';
EOF

# Создание английских языковых файлов
echo "📄 Создание английских языковых файлов..."
cat > "$MODULE_DIR/lang/en/lib/UserField/PollutionDegreeField.php" << 'EOF'
<?php

$MESS['B24_ACADEMY.UFTYPE_POLLUTION_DEGREE_DESCRIPTION'] = 'Pollution Degree';
$MESS['B24_ACADEMY.UFTYPE_POLLUTION_DEGREE_AREA_LABEL_SETTING'] = 'Label for area field';
$MESS['B24_ACADEMY.UFTYPE_POLLUTION_DEGREE_DEGREE_LABEL_SETTING'] = 'Label for pollution degree field';
$MESS['B24_ACADEMY.UFTYPE_POLLUTION_DEGREE_AREA_MIN_SETTING'] = 'Minimum area value';
$MESS['B24_ACADEMY.UFTYPE_POLLUTION_DEGREE_AREA_MIN_SETTING_HINT'] = 'Minimum allowed value for area field (m²)';
$MESS['B24_ACADEMY.UFTYPE_POLLUTION_DEGREE_AREA_MAX_SETTING'] = 'Maximum area value';
$MESS['B24_ACADEMY.UFTYPE_POLLUTION_DEGREE_AREA_MAX_SETTING_HINT'] = 'Maximum allowed value for area field (m²)';
$MESS['B24_ACADEMY.UFTYPE_POLLUTION_DEGREE_DEGREE_MIN_SETTING'] = 'Minimum pollution degree value';
$MESS['B24_ACADEMY.UFTYPE_POLLUTION_DEGREE_DEGREE_MIN_SETTING_HINT'] = 'Minimum allowed value for pollution degree field';
$MESS['B24_ACADEMY.UFTYPE_POLLUTION_DEGREE_DEGREE_MAX_SETTING'] = 'Maximum pollution degree value';
$MESS['B24_ACADEMY.UFTYPE_POLLUTION_DEGREE_DEGREE_MAX_SETTING_HINT'] = 'Maximum allowed value for pollution degree field';
EOF

# Создание языковых файлов для модуля (русский)
echo "📄 Создание языковых файлов для установки модуля (русский)..."
cat > "$MODULE_DIR/lang/ru/install/index.php" << 'EOF'
<?php

defined('B_PROLOG_INCLUDED') || die;

$MESS['B24_ACADEMY.MODULE_NAME'] = 'Академия: Пользовательское поле "Степень загрязнения"';
$MESS['B24_ACADEMY.MODULE_DESC'] = 'Модуль предоставляет пользовательский тип поля для ввода площади и степени загрязнения.';
$MESS['B24_ACADEMY.PARTNER_NAME'] = 'Академия Битрикс24';
$MESS['B24_ACADEMY.PARTNER_URI'] = 'https://bitrix24.ru';
EOF

# Создание языковых файлов для модуля (английский)
echo "📄 Создание языковых файлов для установки модуля (английский)..."
cat > "$MODULE_DIR/lang/en/install/index.php" << 'EOF'
<?php

defined('B_PROLOG_INCLUDED') || die;

$MESS['B24_ACADEMY.MODULE_NAME'] = 'Academy: Pollution Degree Custom Field';
$MESS['B24_ACADEMY.MODULE_DESC'] = 'Module provides a custom field type for entering area and pollution degree.';
$MESS['B24_ACADEMY.PARTNER_NAME'] = 'Bitrix24 Academy';
$MESS['B24_ACADEMY.PARTNER_URI'] = 'https://bitrix24.com';
EOF

# Создание дополнительного шаблона для фильтра (если потребуется)
echo "📄 Создание шаблона для фильтра..."
mkdir -p "$MODULE_DIR/install/components/b24.academy/pollution.degree.field/templates/main.filter_html"
cat > "$MODULE_DIR/install/components/b24.academy/pollution.degree.field/templates/main.filter_html/.default.php" << 'EOF'
<?php

defined('B_PROLOG_INCLUDED') || die;

/**
 * @var array $arResult
 * @var PollutionDegreeFieldComponent $component
 */

$settings = $component->getSettings();
$value = $component->getValue();
$fieldName = $arResult['fieldName'];
?>

<div class="pollution-filter-container">
    <div class="pollution-filter-row">
        <span><?= htmlspecialchars($settings['AREA_LABEL']) ?>:</span>
        <input type="number" 
               name="<?= $fieldName ?>[AREA_FROM]" 
               placeholder="от" 
               step="0.01"
               style="width: 60px;">
        <span>—</span>
        <input type="number" 
               name="<?= $fieldName ?>[AREA_TO]" 
               placeholder="до" 
               step="0.01"
               style="width: 60px;">
        <span>м²</span>
    </div>
    
    <div class="pollution-filter-row">
        <span><?= htmlspecialchars($settings['DEGREE_LABEL']) ?>:</span>
        <input type="number" 
               name="<?= $fieldName ?>[DEGREE_FROM]" 
               placeholder="от" 
               step="0.01"
               style="width: 60px;">
        <span>—</span>
        <input type="number" 
               name="<?= $fieldName ?>[DEGREE_TO]" 
               placeholder="до" 
               step="0.01"
               style="width: 60px;">
    </div>
</div>

<style>
.pollution-filter-container {
    display: flex;
    flex-direction: column;
    gap: 8px;
}

.pollution-filter-row {
    display: flex;
    align-items: center;
    gap: 5px;
    font-size: 12px;
}

.pollution-filter-row input {
    padding: 2px 4px;
    border: 1px solid #ccc;
    border-radius: 2px;
}
</style>
EOF

# Создание шаблона для публичного отображения
echo "📄 Создание шаблона для публичного отображения..."
mkdir -p "$MODULE_DIR/install/components/b24.academy/pollution.degree.field/templates/main.public_text"
cat > "$MODULE_DIR/install/components/b24.academy/pollution.degree.field/templates/main.public_text/.default.php" << 'EOF'
<?php

defined('B_PROLOG_INCLUDED') || die;

/**
 * @var array $arResult
 * @var PollutionDegreeFieldComponent $component
 */

$value = $component->getValue();
$settings = $component->getSettings();

printf(
    '%s: %s м², %s: %s',
    $settings['AREA_LABEL'],
    $value['AREA'],
    $settings['DEGREE_LABEL'],
    $value['DEGREE']
);
EOF

# Создание README файла
echo "📄 Создание README файла..."
cat > "$MODULE_DIR/README.md" << 'EOF'
# Модуль "Степень загрязнения" для Bitrix24

## 🎯 Описание
Данный модуль добавляет новый тип пользовательского поля "Степень загрязнения", которое состоит из двух числовых полей:
- **Площадь (м²)** - для указания площади загрязненной территории
- **Степень загрязнения** - для указания степени/уровня загрязнения

## 📦 Установка
1. Скопируйте папку `b24.academy` в директорию `/local/modules/`
2. В административной панели перейдите в "Настройки" → "Настройки продукта" → "Модули"
3. Найдите модуль "Академия: Пользовательское поле 'Степень загрязнения'" и установите его

## 🚀 Использование
После установки модуля в списке типов пользовательских полей появится новый тип "Степень загрязнения". 
Его можно добавить к любой сущности CRM (лиды, сделки, компании, контакты).

## ⚙️ Настройки поля
- **Подписи для полей** - настраиваемые названия для площади и степени загрязнения
- **Минимальные значения** - ограничения снизу для каждого поля
- **Максимальные значения** - ограничения сверху для каждого поля
- **Валидация** - автоматическая проверка вводимых данных

## 💾 Структура данных
Данные хранятся в формате JSON:
```json
{
    "area": 100.5,
    "degree": 10.2
}
```

## 🎨 Отображение
- **В формах редактирования**: два числовых поля рядом с подписями
- **В режиме просмотра**: красиво оформленные значения с цветовым кодированием
- **В списках**: компактное отображение "площадь м² / степень"
- **В фильтрах**: диапазоны значений для поиска

## 📋 Примеры использования
- Экологический мониторинг
- Управление земельными участками
- Учет загрязнений в CRM
- Отчетность по экологическим показателям

## 🛠️ Техническая информация
- **Версия**: 1.0.0
- **Совместимость**: Bitrix24 
- **Тип поля в БД**: TEXT (JSON)
- **Базовый тип**: STRING
- **Компоненты**: полный набор шаблонов для всех режимов

## 📁 Структура файлов
```
b24.academy/
├── include.php
├── lib/UserField/PollutionDegreeField.php
├── install/
│   ├── index.php
│   ├── version.php
│   ├── migrations/2023_12_05_15_00_00.php
│   └── components/b24.academy/pollution.degree.field/
│       ├── class.php
│       └── templates/
│           ├── .default/
│           ├── main.edit/
│           ├── main.view/
│           ├── main.admin_settings/
│           ├── main.filter_html/
│           └── main.public_text/
├── lang/
│   ├── ru/ (русская локализация)
│   └── en/ (английская локализация)
└── README.md
```

## 🤝 Поддержка
Если у вас возникли вопросы или проблемы с модулем, обратитесь к разработчику или сообществу Bitrix24.

## 📄 Лицензия
Модуль распространяется в соответствии с условиями использования Bitrix24.
EOF

# Создание changelog
echo "📄 Создание CHANGELOG..."
cat > "$MODULE_DIR/CHANGELOG.md" << 'EOF'
# История изменений

## [1.0.0] - 2023-12-05

### Добавлено
- ✅ Базовый класс пользовательского поля PollutionDegreeField
- ✅ Компонент для отображения поля
- ✅ Шаблоны для всех режимов отображения:
  - Редактирование (main.edit)
  - Просмотр (main.view) 
  - Настройки админки (main.admin_settings)
  - Фильтр (main.filter_html)
  - Публичное отображение (main.public_text)
- ✅ Валидация входящих данных
- ✅ Настраиваемые подписи полей
- ✅ Ограничения min/max значений
- ✅ Русская и английская локализация
- ✅ Система установки и миграций
- ✅ Полная документация

### Технические особенности
- 🔧 Совместимость с BaseType из Bitrix
- 🔧 JSON хранение данных в БД
- 🔧 Responsive дизайн форм
- 🔧 Поддержка обязательных полей
- 🔧 Автоматическое форматирование отображения
EOF

echo ""
echo "✅ Структура модуля создана успешно!"
echo ""
echo "📁 Создана следующая полная структура:"
echo "$MODULE_DIR/"
echo "├── 📄 include.php"
echo "├── 📄 README.md"
echo "├── 📄 CHANGELOG.md"
echo "├── 📁 lib/UserField/"
echo "│   └── PollutionDegreeField.php"
echo "├── 📁 install/"
echo "│   ├── index.php"
echo "│   ├── version.php"
echo "│   ├── migrations/2023_12_05_15_00_00.php"
echo "│   └── components/b24.academy/pollution.degree.field/"
echo "│       ├── class.php"
echo "│       └── templates/"
echo "│           ├── .default/.default.php"
echo "│           ├── main.edit/.default.php + result_modifier.php"
echo "│           ├── main.view/.default.php + result_modifier.php"
echo "│           ├── main.admin_settings/.default.php + result_modifier.php"
echo "│           ├── main.filter_html/.default.php"
echo "│           └── main.public_text/.default.php"
echo "└── 📁 lang/"
echo "    ├── 📁 ru/"
echo "    │   ├── install/index.php"
echo "    │   └── lib/UserField/PollutionDegreeField.php"
echo "    └── 📁 en/"
echo "        ├── install/index.php"
echo "        └── lib/UserField/PollutionDegreeField.php"
echo ""
echo "🔧 Ключевые исправления в коде:"
echo "   ✅ getSettingsHTML → getSettingsHtml"
echo "   ✅ Убрана строгая типизация параметров"
echo "   ✅ Совместимость с BaseType"
echo "   ✅ Nullable параметры (?array)"
echo ""
echo "🚀 Для установки модуля:"
echo "1. Скопируйте папку '$MODULE_DIR' в /local/modules/"
echo "2. Установите модуль через административную панель Bitrix24"
echo "3. Добавьте новое пользовательское поле типа 'Степень загрязнения'"
echo ""
echo "🎯 Пример использования:"
echo "   Площадь: 100.5 м²"
echo "   Степень загрязнения: 8.7"
echo ""

# Делаем скрипт исполняемым
chmod +x "$0"

echo "🎉 Готово! Модуль полностью создан и готов к установке."