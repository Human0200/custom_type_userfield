<?php
defined('B_PROLOG_INCLUDED') || die;
echo "This file is part of the pollution degree field component.3";
/** @var array $arResult */
$value = $arResult['value'];
$settings = $arResult['userField']['SETTINGS'];
$fieldName = $arResult['fieldName'];
?>
<div class="pollution-field-edit">
    <div class="field-row">
        <label><?= htmlspecialcharsbx($settings['AREA_LABEL']) ?>:</label>
        <input type="number" 
               name="<?= $fieldName ?>[AREA]" 
               value="<?= $value['AREA'] ?>"
               min="<?= $settings['AREA_MIN'] ?>"
               max="<?= $settings['AREA_MAX'] ?>"
               step="0.01">
        <span>м²</span>
    </div>
    
    <div class="field-row">
        <label><?= htmlspecialcharsbx($settings['DEGREE_LABEL']) ?>:</label>
        <input type="number" 
               name="<?= $fieldName ?>[DEGREE]" 
               value="<?= $value['DEGREE'] ?>"
               min="<?= $settings['DEGREE_MIN'] ?>"
               max="<?= $settings['DEGREE_MAX'] ?>"
               step="0.01">
        <span>%</span>
    </div>
</div>