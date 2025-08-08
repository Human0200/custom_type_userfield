<?php
defined('B_PROLOG_INCLUDED') || die;

/** @var array $arResult */
$settings = $arResult['userField']['SETTINGS'];
$value = $arResult['value'];
echo "This file is part of the pollution degree field component.5";
?>

<div class="pollution-view-container">
    <div class="pollution-view-field">
        <span class="pollution-view-label">
            <?= htmlspecialcharsbx($settings['AREA_LABEL'] ?? 'Площадь') ?>:
        </span>
        <span class="pollution-view-value">
            <?= htmlspecialcharsbx($value['AREA'] ?? 0) ?> м²
        </span>
    </div>

    <div class="pollution-view-field">
        <span class="pollution-view-label">
            <?= htmlspecialcharsbx($settings['DEGREE_LABEL'] ?? 'Степень') ?>:
        </span>
        <span class="pollution-view-value">
            <?= htmlspecialcharsbx($value['DEGREE'] ?? 0) ?>%
        </span>
    </div>
</div>

<style>
.pollution-view-container {
    display: flex;
    flex-direction: column;
    gap: 8px;
}
.pollution-view-field {
    display: flex;
    gap: 10px;
}
.pollution-view-label {
    font-weight: bold;
    min-width: 100px;
}
.pollution-view-value {
    color: #2a5885;
}
</style>