<?php
defined('B_PROLOG_INCLUDED') || die;

/**
 * @var array $arResult
 * @var PollutionDegreeFieldComponent $component
 */

$settings = $component->getSettings();
$value = $component->getProcessedValue();

$areaFieldName = $arResult['fieldName'] . '[AREA]';
$degreeFieldName = $arResult['fieldName'] . '[DEGREE]';

$html = sprintf('
<div class="pollution-degree-container" style="display: flex; gap: 10px; align-items: center; flex-wrap: wrap;">
    <div class="pollution-degree-area" style="display: flex; align-items: center; gap: 5px;">
        <label style="min-width: 60px; font-size: 12px;">%s:</label>
        <input type="number" 
               name="%s" 
               value="%s" 
               step="0.01" 
               min="%s" 
               max="%s"
               placeholder="%s"
               class="pollution-degree-field"
               style="width: 80px; padding: 4px 6px; border: 1px solid #ccc; border-radius: 3px; font-size: 12px;">
        <span style="font-size: 12px; color: #666;">м²</span>
    </div>
    
    <div class="pollution-degree-degree" style="display: flex; align-items: center; gap: 5px;">
        <label style="min-width: 80px; font-size: 12px;">%s:</label>
        <input type="number" 
               name="%s" 
               value="%s" 
               step="0.01" 
               min="%s" 
               max="%s"
               placeholder="%s"
               class="pollution-degree-field"
               style="width: 60px; padding: 4px 6px; border: 1px solid #ccc; border-radius: 3px; font-size: 12px;">
    </div>
</div>

<style>
.pollution-degree-field:focus {
    outline: none;
    border-color: #0078d4;
    box-shadow: 0 0 0 1px rgba(0, 120, 212, 0.3);
}

@media (max-width: 768px) {
    .pollution-degree-container {
        flex-direction: column !important;
        align-items: flex-start !important;
        gap: 8px !important;
    }
    
    .pollution-degree-area,
    .pollution-degree-degree {
        width: 100%%;
    }
}
</style>',
    htmlspecialchars($settings['AREA_LABEL']),
    htmlspecialchars($areaFieldName),
    $value['AREA'],
    $settings['AREA_MIN'],
    $settings['AREA_MAX'],
    htmlspecialchars($settings['AREA_LABEL']),
    htmlspecialchars($settings['DEGREE_LABEL']),
    htmlspecialchars($degreeFieldName),
    $value['DEGREE'],
    $settings['DEGREE_MIN'],
    $settings['DEGREE_MAX'],
    htmlspecialchars($settings['DEGREE_LABEL'])
);

print $component->getHtmlBuilder()->wrapSingleField($html);