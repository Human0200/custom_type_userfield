<?php
defined('B_PROLOG_INCLUDED') || die;
echo "This file is part of the pollution degree field component.";
/** @var array $arResult */
$value = $arResult['value'];
$settings = $arResult['userField']['SETTINGS'];
?>
<div class="pollution-field-view">
    <?= htmlspecialcharsbx($settings['AREA_LABEL']) ?>: <?= $value['AREA'] ?> м²,
    <?= htmlspecialcharsbx($settings['DEGREE_LABEL']) ?>: <?= $value['DEGREE'] ?>%
</div>