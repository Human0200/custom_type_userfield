<?php

use B24\Academy\UserField\PollutionDegreeField;
use Bitrix\Main\Component\BaseUfComponent;

defined('B_PROLOG_INCLUDED') || die;

class PollutionDegreeFieldComponent extends BaseUfComponent
{
    /**
     * Возвращает ID типа пользовательского поля
     */
    protected static function getUserTypeId(): string
    {
        return PollutionDegreeField::USER_TYPE_ID;
    }

    /**
     * Возвращает настройки поля
     */
    public function getSettings(): array
    {
        return PollutionDegreeField::prepareSettings($this->userField);
    }

    /**
     * Форматирует значение для отображения
     */
    public function formatValue($value): string
    {
        return PollutionDegreeField::formatValue($this->userField, $value);
    }

    /**
     * Получает данные значения
     */
    public function getValue()
    {
        return PollutionDegreeField::onAfterFetch($this->userField, $this->value);
    }

    /**
     * Проверяет, является ли поле множественным
     */
    public function isMultiple(): bool
    {
        return $this->userField['MULTIPLE'] === 'Y';
    }

    /**
     * Возвращает атрибуты для HTML полей
     */
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

    /**
     * Генерирует HTML атрибуты из массива
     */
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
