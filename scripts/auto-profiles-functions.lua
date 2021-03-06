
local utils = require 'mp.utils'
local msg = require 'mp.msg'

local HIGH = 1
local MID  = 2
local LOW  = 3


local function determine_profile(width, height, fps)
    if is_laptop() then
        if on_battery() then
            return LOW
        end
        if width > 1920 then
            return LOW
        end
        if fps > 58 then
            return LOW
        end

        return MID
    elseif is_desktop() then
        if width >= 3840 then
            return MID
        end
        if width >= 1920 and fps > 58 then
            return MID
        end

        return HIGH
    end

    print("ERROR could not determine profile")
    return LOW
end

function is_high(width, height, fps)
    return determine_profile(width, height, fps) == HIGH
end

function is_mid(width, height, fps)
    return determine_profile(width, height, fps) == MID
end

function is_low(width, height, fps)
    return determine_profile(width, height, fps) == LOW
end


local function exec(process)
    p_ret = utils.subprocess({args = process})
    if p_ret.error and p_ret.error == "init" then
        print("ERROR executable not found: " .. process[1])
    end
    return p_ret
end

-- location (assumed to be immutable)
-- local loc = exec({"bash", "-c", 'source "$HOME"/local/shell/location-detection && is-desktop'})

function is_desktop()
    --local loc = exec({"bash", "-c", 'source "$HOME"/local/shell/location-detection && is-desktop'})
    if loc.error then
        msg.error("ERROR location detection failed")
        loc.status = 255
    end
    return loc.status == 0
end

function is_laptop()
    --local loc = exec({"bash", "-c", 'source "$HOME"/local/shell/location-detection && is-desktop'})
    if loc.error then
        msg.error("ERROR location detection failed")
        loc.status = 255
    end
    return loc.status == 1
end

function on_battery()
    local bat = exec({"/usr/bin/pmset", "-g", "ac"})
    return bat.stdout == "No adapter attached.\n"
end

function display_res_height()
    local sp_ret = exec({"/usr/local/bin/resolution", "unscaled-height"})
    if sp_ret.error then
        sp_ret.stdout = math.huge
    end
    return to_number(sp_ret.stdout)
end

function display_res_width()
    local sp_ret = exec({"/usr/local/bin/resolution", "unscaled-width"})
    if sp_ret.error then
        sp_ret.stdout = math.huge
    end
    return to_number(sp_ret.stdout)
end

function display_scale_factor()
    local sp_ret = exec({"/usr/local/bin/resolution", "scale"})
    if sp_ret.error then
        sp_ret.stdout = 1.0
    end
    return to_number(sp_ret.stdout)
end
