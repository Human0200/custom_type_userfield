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
