-- Copyright 2025 Vivian Voss. Licensed under the Apache License, Version 2.0.
-- SPDX-License-Identifier: Apache-2.0

--[[
    cmxt:currency_convert — Sample Extension for Currency Conversion

    Demonstrates:
    - Subfolder structure with init.lua entry point
    - Using require() to load local modules
    - fn() function for template use
    - Using cm.log for debugging
    - Using cm.format for number formatting

    Usage:
        {( cmxt:currency_convert[amount, from_currency, to_currency] )}
        {( cmxt:currency_convert[price_eur, "EUR", "USD"] )}
        {( cmxt:currency_convert[100, "GBP", "JPY"] )}

    Structure:
        extensions/currency_convert/
        ├── init.lua    ← This file (entry point)
        └── rates.lua   ← Exchange rates module
]]

-- Load the rates module from the same folder
local rates = require("rates")

-- fn() — called from templates via {( cmxt:currency_convert[amount, from, to] )}
-- Args are passed as positional: args["1"], args["2"], args["3"]
function fn(args)
    -- Positional arguments (1-indexed keys as strings)
    local amount = tonumber(args["1"]) or 0
    local from = args["2"] or "EUR"
    local to = args["3"] or "EUR"

    cm.log.debug("Converting " .. amount .. " " .. from .. " to " .. to)

    local result = rates.convert(amount, from, to)

    if result == nil then
        return "N/A"
    end

    return cm.format.currency(result, to)
end
