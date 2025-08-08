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
