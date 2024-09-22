local F = unpack(select(2, ...))
local UNITFRAME = F:GetModule('UnitFrame')

local tier = 11
local inst = 1273 -- 尼鲁巴尔王宫
local boss

function UNITFRAME:RegisterNerubarSpells()
    boss = 2607                                        -- 噬灭者乌格拉克斯
    UNITFRAME:RegisterInstanceSpell(tier, inst, boss, 370648) -- 熔岩涌流 -- 示例
    UNITFRAME:RegisterInstanceSpell(tier, inst, boss, 434705) -- 暴捶
    UNITFRAME:RegisterInstanceSpell(tier, inst, boss, 439037) -- 开膛破肚

    boss = 2611                                        -- 血缚恐魔

    boss = 2599                                        -- 苏雷吉队长席克兰
    UNITFRAME:RegisterInstanceSpell(tier, inst, boss, 434705) -- 相位之刃
    UNITFRAME:RegisterInstanceSpell(tier, inst, boss, 454721) -- 相位之刃
    UNITFRAME:RegisterInstanceSpell(tier, inst, boss, 434860) -- 诛灭
    UNITFRAME:RegisterInstanceSpell(tier, inst, boss, 439191) -- 暴露
    UNITFRAME:RegisterInstanceSpell(tier, inst, boss, 438845) -- 相位贯突

    boss = 2609                                        -- 拉夏南
    UNITFRAME:RegisterInstanceSpell(tier, inst, boss, 435410) -- 喷射丝线

    boss = 2612                                        -- 虫巢扭曲者欧维纳克斯
    UNITFRAME:RegisterInstanceSpell(tier, inst, boss, 440421) -- 试验性剂量
    UNITFRAME:RegisterInstanceSpell(tier, inst, boss, 441368) -- 不稳定的混合物
    UNITFRAME:RegisterInstanceSpell(tier, inst, boss, 446349) -- 粘性之网

    boss = 2601                                        -- 节点女亲王凯威扎
    UNITFRAME:RegisterInstanceSpell(tier, inst, boss, 436870) -- 奇袭
    UNITFRAME:RegisterInstanceSpell(tier, inst, boss, 437343) -- 女王之灾
    UNITFRAME:RegisterInstanceSpell(tier, inst, boss, 440576) -- 深凿重创

    boss = 2608                                        -- 流丝之庭

    boss = 2602                                        -- 安苏雷克女王
    UNITFRAME:RegisterInstanceSpell(tier, inst, boss, 438218) -- 穿刺打击
    UNITFRAME:RegisterInstanceSpell(tier, inst, boss, 440001) -- 束缚之网
    UNITFRAME:RegisterInstanceSpell(tier, inst, boss, 438200) -- 毒液箭

    boss = 2602                                        -- 安苏雷克女王
    UNITFRAME:RegisterInstanceSpell(tier, inst, boss, 437586) -- 活性毒素
    UNITFRAME:RegisterInstanceSpell(tier, inst, boss, 436800) -- 液化
    UNITFRAME:RegisterInstanceSpell(tier, inst, boss, 441958) -- 勒握流丝
    UNITFRAME:RegisterInstanceSpell(tier, inst, boss, 447532) -- 麻痹毒液
    UNITFRAME:RegisterInstanceSpell(tier, inst, boss, 447967) -- 晦暗之触
    UNITFRAME:RegisterInstanceSpell(tier, inst, boss, 438974) -- 皇谕责罚
    UNITFRAME:RegisterInstanceSpell(tier, inst, boss, 443656) -- 感染
    UNITFRAME:RegisterInstanceSpell(tier, inst, boss, 441865) -- 皇家镣铐
end
