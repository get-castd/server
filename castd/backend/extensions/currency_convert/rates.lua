-- Copyright 2025 Vivian Voss. Licensed under the Apache License, Version 2.0.
-- SPDX-License-Identifier: Apache-2.0

--[[
    Exchange Rates Module

    Demonstrates how to split extension logic into separate modules
    using the sandboxed require() function.

    In production, these would be fetched via cn.io from an API.
]]

local M = {}

-- Hardcoded exchange rates (base: EUR)
M.data = {
    EUR = 1.0,
    USD = 1.08,
    GBP = 0.86,
    CHF = 0.94,
    JPY = 162.5,
    AUD = 1.65,
    CAD = 1.47,
    CNY = 7.82,
    INR = 90.2,
    BRL = 5.45
}

-- Get rate for a currency (returns nil if unknown)
function M.get(currency)
    return M.data[currency]
end

-- Convert amount from one currency to another
function M.convert(amount, from, to)
    local from_rate = M.get(from)
    local to_rate = M.get(to)

    if not from_rate then
        cn.log.warn("Unknown source currency: " .. from)
        return nil
    end

    if not to_rate then
        cn.log.warn("Unknown target currency: " .. to)
        return nil
    end

    -- Convert to EUR first, then to target
    local in_eur = amount / from_rate
    return in_eur * to_rate
end

return M
