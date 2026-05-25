--[[ Patch to add progress percentage badges in top right corner of cover ]]
--
-- created combining the "disable fullyread progress bar" patch by joshuacant & the "percent badge" patch by SeriousHornet
-- stylua: ignore start
--========================== [[Edit your preferences here]] ================================
local move_on_x = 10		-- Adjust how far left the badge should sit. 
local move_on_y = -1	-- Adjust how far up the badge should sit.
local trophy_w = 55		-- Adjust badge width
local trophy_h = 30		-- Adjust badge height
local bump_up = 1		-- Adjust text position  
--==========================================================================================
-- stylua: ignore end

local userpatch = require("userpatch")
local Screen = require("device").screen
local Blitbuffer = require("ffi/blitbuffer")
local IconWidget = require("ui/widget/iconwidget")
local logger = require("logger")
local FrameContainer = require("ui/widget/container/framecontainer")
local Size = require("ui/size")
local DataStorage = require("datastorage")
local Device = require("device")
local Screen = Device.screen
local plugin_path = DataStorage:getFullDataDir() .. "/plugins/projecttitle.koplugin"

local function patchCoverBrowserProgressPercent(plugin)
    local MosaicMenu = require("mosaicmenu")
    local MosaicMenuItem = userpatch.getUpValue(MosaicMenu._updateItemsBuildUI, "MosaicMenuItem")
    local orig_MosaicMenuItem_paintTo = MosaicMenuItem.paintTo
    MosaicMenuItem.paintTo = function(self, bb, x, y)
        if self.status == "complete" or self.percent_finished == 1 then
            self.show_progress_bar = false
            self.been_opened = false -- this lie will also hide the text-based progress box
        end
        orig_MosaicMenuItem_paintTo(self, bb, x, y)

        -- Do not add badge for directories or completed items or items without percent_finished
        if self.status == "complete" or self.percent_finished == 1 then
            self.show_progress_bar = false
            self.been_opened = false -- this lie will also hide the text-based progress box
        end

        -- Get the cover image widget
        local target = self[1][1][1]
        if not target or not target.dimen then
            return
        end

        if
            self.status == "complete"
            or self.percent_finished == 1
        then
            local trophy_widget = IconWidget:new({
                icon = "trophy.bookmark",
                alpha = true,
                width = TROPHY_W,
                height = TROPHY_H,
            })
                
            local TROPHY_W = Screen:scaleBySize(trophy_w) -- badge width
            local TROPHY_H = Screen:scaleBySize(trophy_h) -- badge height
            local INSET_X = Screen:scaleBySize(move_on_x) -- push inward from the right edge
            local INSET_Y = Screen:scaleBySize(move_on_y) -- sit on the inner top edge
            local TEXT_PAD = Screen:scaleBySize(6)

            -- Outer frame
            local fx = x + math.floor((self.width - target.dimen.w) / 2)
            local fy = y + math.floor((self.height - target.dimen.h) / 2)
            local fw = target.dimen.w

            local bx = fx + fw - TROPHY_W - INSET_X
            local by = fy + INSET_Y
            bx, by = math.floor(bx), math.floor(by)

            
            local ts = trophy_widget:getSize()
            trophy_widget:paintTo(bb, bx, by)
        end
    end
end
userpatch.registerPatchPluginFunc("coverbrowser", patchCoverBrowserProgressPercent)
