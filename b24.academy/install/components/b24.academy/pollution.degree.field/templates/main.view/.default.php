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
