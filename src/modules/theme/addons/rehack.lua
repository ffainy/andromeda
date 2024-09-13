local F = unpack(select(2, ...))
local THEME = F:GetModule('Theme')

function THEME:ReskinREHack()
    if not ANDROMEDA_ADB.ReskinREHack then
        return
    end

    if not _G['REHack'] then
        return
    end

    if not C_AddOns.IsAddOnLoaded('REHack') then
        return
    end

    if HackListFrame then
        F.StripTextures(HackListFrame, true)
        F.SetBD(HackListFrame)
        F.ReskinClose(HackListFrameClose)
        F.ReskinCheckbox(HackSearchName, true)
        HackSearchName:SetSize(20, 20)
        F.ReskinCheckbox(HackSearchBody, true)
        HackSearchBody:SetSize(20, 20)
        F.ReskinEditbox(HackSearchEdit)
        HackSearchEdit:SetSize(120, 16)
        F.ReskinTab(HackListFrameTab1)
        F.ReskinTab(HackListFrameTab2)
        HackListFrameTab2:ClearAllPoints()
        HackListFrameTab2:SetPoint('LEFT', HackListFrameTab1, 'RIGHT', -4, 0)
    end

    if HackEditFrame then
        F.StripTextures(HackEditFrame, true)
        F.SetBD(HackEditFrame)
        F.ReskinClose(HackEditFrameClose)
        F.ReskinScroll(HackEditScrollFrameScrollBar)
        F.CreateBDFrame(HackEditScrollFrame, 0.25)
        HackEditBoxLineBG:SetColorTexture(0, 0, 0, 0.25)

        local SetPoint = HackEditFrame.SetPoint
        HackEditFrame.SetPoint = function(frame, point, relativeFrame, relativePoint, x, y)
            if point == 'TOPLEFT' and relativePoint == 'TOPRIGHT' and x and y == 0 then
                x = x + 6
            end
            SetPoint(frame, point, relativeFrame, relativePoint, x, y)
        end
        local tempPos = { HackEditFrame:GetPoint() }
        HackEditFrame:ClearAllPoints()
        HackEditFrame:SetPoint(unpack(tempPos))
    end
end
