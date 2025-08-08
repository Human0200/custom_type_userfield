#!/bin/bash

MODULE_DIR="b24.academy"

echo "Создание модуля пользовательского поля 'Степень загрязнения'..."

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

cat > "$MODULE_DIR/include.php" << 'EOF'
<?php

defined('B_PROLOG_INCLUDED') || die;
EOF

cat > "$MODULE_DIR/lib/UserField/PollutionDegreeField.php" << 'EOF'
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

    public static function prepareSettings(array $userField): array
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

    public static function getAdminListViewHTML(array $userField, array $additionalParameters): string
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

    public static function getAdminListEditHTML(array $userField, array $additionalParameters): string
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

    public static function getSettingsHTML(array $userField, array $additionalParameters, $varsFromForm): string
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
EOF

cat > "$MODULE_DIR/install/components/b24.academy/pollution.degree.field/class.php" << 'EOF'
<?php

use B24\Academy\UserField\PollutionDegreeField;
use Bitrix\Main\Component\BaseUfComponent;

defined('B_PROLOG_INCLUDED') || die;

class PollutionDegreeFieldComponent extends BaseUfComponent
{
    protected static function getUserTypeId(): string
    {
        return PollutionDegreeField::USER_TYPE_ID;
    }

    public function getSettings(): array
    {
        return PollutionDegreeField::prepareSettings($this->userField);
    }

    public function formatValue($value): string
    {
        return PollutionDegreeField::formatValue($this->userField, $value);
    }

    public function getValue()
    {
        return PollutionDegreeField::onAfterFetch($this->userField, $this->value);
    }

    public function isMultiple(): bool
    {
        return $this->userField['MULTIPLE'] === 'Y';
    }

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

cat > "$MODULE_DIR/install/components/b24.academy/pollution.degree.field/templates/.default/.default.php" << 'EOF'
<?php

defined('B_PROLOG_INCLUDED') || die;

print $component->formatValue($arResult['value']);
EOF

cat > "$MODULE_DIR/install/components/b24.academy/pollution.degree.field/templates/main.edit/.default.php" << 'EOF'
<?php
defined('B_PROLOG_INCLUDED') || die;

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

cat > "$MODULE_DIR/install/components/b24.academy/pollution.degree.field/templates/main.view/.default.php" << 'EOF'
<?php
defined('B_PROLOG_INCLUDED') || die;

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

cat > "$MODULE_DIR/install/components/b24.academy/pollution.degree.field/templates/main.admin_settings/.default.php" << 'EOF'
<?php
use Bitrix\Main\Localization\Loc;
use Bitrix\Main\UI\Extension;

defined('B_PROLOG_INCLUDED') || die;

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
        CopyDirFiles(
            __DIR__ . '/components/',
            $_SERVER['DOCUMENT_ROOT'] . '/local/components/',
            true,
            true
        );
    }

    function UnInstallFiles()
    {
        DeleteDirFiles(
            __DIR__ . '/components/',
            $_SERVER['DOCUMENT_ROOT'] . '/local/components/'
        );
    }
}
EOF

cat > "$MODULE_DIR/install/version.php" << 'EOF'
<?php

return [
    'VERSION' => '1.0.0',
    'VERSION_DATE' => '2023-12-05 15:00:00',
];
EOF

cat > "$MODULE_DIR/install/migrations/2023_12_05_15_00_00.php" << 'EOF'
<?php

use B24\Academy\UserField\PollutionDegreeField;
use Bitrix\Main\Config\Option;
use Bitrix\Main\EventManager;
use Bitrix\Main\IO\Path;

CopyDirFiles(
    Path::combine(__DIR__, '/../components/b24.academy/pollution.degree.field'),
    Path::convertRelativeToAbsolute('/local/components/b24.academy/pollution.degree.field/'),
    true,
    true
);

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

cat > "$MODULE_DIR/lang/en/lib/UserField/PollutionDegreeField.php" << 'EOF'
<?php

$MESS['B24_ACADEMY.UFTYPE_POLLUTION_DEGREE_DESCRIPTION'] = 'Pollution degree';
$MESS['B24_ACADEMY.UFTYPE_POLLUTION_DEGREE_AREA_LABEL_SETTING'] = 'Area field label';
$MESS['B24_ACADEMY.UFTYPE_POLLUTION_DEGREE_DEGREE_LABEL_SETTING'] = 'Pollution degree field label';
$MESS['B24_ACADEMY.UFTYPE_POLLUTION_DEGREE_AREA_MIN_SETTING'] = 'Minimum area value';
$MESS['B24_ACADEMY.UFTYPE_POLLUTION_DEGREE_AREA_MIN_SETTING_HINT'] = 'Minimum allowed value for area field (m²)';
$MESS['B24_ACADEMY.UFTYPE_POLLUTION_DEGREE_AREA_MAX_SETTING'] = 'Maximum area value';
$MESS['B24_ACADEMY.UFTYPE_POLLUTION_DEGREE_AREA_MAX_SETTING_HINT'] = 'Maximum allowed value for area field (m²)';
$MESS['B24_ACADEMY.UFTYPE_POLLUTION_DEGREE_DEGREE_MIN_SETTING'] = 'Minimum pollution degree value';
$MESS['B24_ACADEMY.UFTYPE_POLLUTION_DEGREE_DEGREE_MIN_SETTING_HINT'] = 'Minimum allowed value for pollution degree field';
$MESS['B24_ACADEMY.UFTYPE_POLLUTION_DEGREE_DEGREE_MAX_SETTING'] = 'Maximum pollution degree value';
$MESS['B24_ACADEMY.UFTYPE_POLLUTION_DEGREE_DEGREE_MAX_SETTING_HINT'] = 'Maximum allowed value for pollution degree field';
EOF

echo "Модуль успешно создан в директории $MODULE_DIR"