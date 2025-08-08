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
    public function formatValue($value = null): string
    {
        if ($value === null) {
            $value = $this->arResult['value'] ?? '';
        }
        return PollutionDegreeField::formatValue($this->userField, $value);
    }

    /**
     * Получает обработанные данные значения
     */
    public function getProcessedValue()
    {
        $value = $this->arResult['value'] ?? '';
        return PollutionDegreeField::onAfterFetch($this->userField, $value);
    }

    /**
     * Проверяет, является ли поле множественным
     */
    public function isMultiple(): bool
    {
        return $this->userField['MULTIPLE'] === 'Y';
    }
}