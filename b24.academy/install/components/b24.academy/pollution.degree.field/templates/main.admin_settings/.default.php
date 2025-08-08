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
