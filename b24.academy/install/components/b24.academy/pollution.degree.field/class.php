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
