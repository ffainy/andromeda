local F = unpack(select(2, ...))
local uf = F:GetModule('UnitFrame')

local tierID
local instID

function uf:RegisterDungeonSpells()
    -- tww S1

    tierID = 4
    instID = 71 -- 格瑞姆巴托
    uf:RegisterSeasonSpell(tierID, instID)
    uf:RegisterInstanceSpell(tierID, instID, 0, 451395) -- 腐蚀
    uf:RegisterInstanceSpell(tierID, instID, 0, 451378) -- 劈裂
    uf:RegisterInstanceSpell(tierID, instID, 0, 447261) -- 碎颅打击
    uf:RegisterInstanceSpell(tierID, instID, 0, 451241) -- 暗影烈焰斩
    uf:RegisterInstanceSpell(tierID, instID, 0, 449474) -- 熔浆火花
    uf:RegisterInstanceSpell(tierID, instID, 0, 451613) -- 暮光烈焰
    uf:RegisterInstanceSpell(tierID, instID, 0, 448057) -- 深渊腐蚀
    uf:RegisterInstanceSpell(tierID, instID, 0, 456719) -- 暗影之伤

    tierID = 8
    instID = 1023 -- 围攻伯拉勒斯
    uf:RegisterSeasonSpell(tierID, instID)
    uf:RegisterInstanceSpell(tierID, instID, 0, 257169) -- 恐惧咆哮
    uf:RegisterInstanceSpell(tierID, instID, 0, 257168) -- 诅咒挥砍
    uf:RegisterInstanceSpell(tierID, instID, 0, 272588) -- 腐烂伤口
    uf:RegisterInstanceSpell(tierID, instID, 0, 272571) -- 窒息之水
    uf:RegisterInstanceSpell(tierID, instID, 0, 274991) -- 腐败之水
    uf:RegisterInstanceSpell(tierID, instID, 0, 275835) -- 钉刺之毒覆膜
    uf:RegisterInstanceSpell(tierID, instID, 0, 273930) -- 妨害切割
    uf:RegisterInstanceSpell(tierID, instID, 0, 257292) -- 沉重挥砍
    uf:RegisterInstanceSpell(tierID, instID, 0, 261428) -- 刽子手的套索
    uf:RegisterInstanceSpell(tierID, instID, 0, 256897) -- 咬合之颚
    uf:RegisterInstanceSpell(tierID, instID, 0, 272874) -- 践踏
    uf:RegisterInstanceSpell(tierID, instID, 0, 273470) -- 一枪毙命
    uf:RegisterInstanceSpell(tierID, instID, 0, 272834) -- 粘稠的口水
    uf:RegisterInstanceSpell(tierID, instID, 0, 272713) -- 碾压重击
    uf:RegisterInstanceSpell(tierID, instID, 0, 463182) -- 炽烈弹射

    tierID = 9
    instID = 1184 -- 塞兹仙林的迷雾
    uf:RegisterSeasonSpell(tierID, instID)
    uf:RegisterInstanceSpell(tierID, instID, 0, 325027) -- 荆棘爆发
    uf:RegisterInstanceSpell(tierID, instID, 0, 323043) -- 放血
    uf:RegisterInstanceSpell(tierID, instID, 0, 322557) -- 灵魂分裂
    uf:RegisterInstanceSpell(tierID, instID, 0, 331172) -- 心灵连接
    uf:RegisterInstanceSpell(tierID, instID, 0, 322563) -- 被标记的猎物
    uf:RegisterInstanceSpell(tierID, instID, 0, 341198) -- 易燃爆炸
    uf:RegisterInstanceSpell(tierID, instID, 0, 325418) -- 不稳定的酸液
    uf:RegisterInstanceSpell(tierID, instID, 0, 326092) -- 衰弱毒药
    uf:RegisterInstanceSpell(tierID, instID, 0, 325021) -- 纱雾撕裂
    uf:RegisterInstanceSpell(tierID, instID, 0, 325224) -- 心能注入
    uf:RegisterInstanceSpell(tierID, instID, 0, 322486) -- 过度生长
    uf:RegisterInstanceSpell(tierID, instID, 0, 322487) -- 过度生长
    uf:RegisterInstanceSpell(tierID, instID, 0, 323137) -- 迷乱花粉
    uf:RegisterInstanceSpell(tierID, instID, 0, 328756) -- 憎恨之容
    uf:RegisterInstanceSpell(tierID, instID, 0, 321828) -- 肉饼蛋糕
    uf:RegisterInstanceSpell(tierID, instID, 0, 340191) -- 再生辐光
    uf:RegisterInstanceSpell(tierID, instID, 0, 321891) -- 鬼抓人锁定

    instID = 1182 -- 通灵战潮
    uf:RegisterSeasonSpell(tierID, instID)
    uf:RegisterInstanceSpell(tierID, instID, 0, 321821) -- 作呕喷吐
    uf:RegisterInstanceSpell(tierID, instID, 0, 323365) -- 黑暗纠缠
    uf:RegisterInstanceSpell(tierID, instID, 0, 338353) -- 瘀液喷撒
    uf:RegisterInstanceSpell(tierID, instID, 0, 333485) -- 疾病之云
    uf:RegisterInstanceSpell(tierID, instID, 0, 338357) -- 暴锤
    uf:RegisterInstanceSpell(tierID, instID, 0, 328181) -- 冷冽之寒
    uf:RegisterInstanceSpell(tierID, instID, 0, 320170) -- 通灵箭
    uf:RegisterInstanceSpell(tierID, instID, 0, 323464) -- 黑暗脓液
    uf:RegisterInstanceSpell(tierID, instID, 0, 323198) -- 黑暗放逐
    uf:RegisterInstanceSpell(tierID, instID, 0, 327401) -- 共受苦难
    uf:RegisterInstanceSpell(tierID, instID, 0, 327397) -- 严酷命运
    uf:RegisterInstanceSpell(tierID, instID, 0, 322681) -- 肉钩
    uf:RegisterInstanceSpell(tierID, instID, 0, 333492) -- 通灵粘液
    uf:RegisterInstanceSpell(tierID, instID, 0, 321807) -- 白骨剥离
    uf:RegisterInstanceSpell(tierID, instID, 0, 323347) -- 黑暗纠缠
    uf:RegisterInstanceSpell(tierID, instID, 0, 320788) -- 冻结之缚
    uf:RegisterInstanceSpell(tierID, instID, 0, 320839) -- 衰弱
    uf:RegisterInstanceSpell(tierID, instID, 0, 343556) -- 病态凝视
    uf:RegisterInstanceSpell(tierID, instID, 0, 338606) -- 病态凝视
    uf:RegisterInstanceSpell(tierID, instID, 0, 343504) -- 黑暗之握
    uf:RegisterInstanceSpell(tierID, instID, 0, 324381) -- 霜寒之镰
    uf:RegisterInstanceSpell(tierID, instID, 0, 320573) -- 暗影之井
    uf:RegisterInstanceSpell(tierID, instID, 0, 334748) -- 排干体液
    uf:RegisterInstanceSpell(tierID, instID, 0, 333489) -- 通灵吐息
    uf:RegisterInstanceSpell(tierID, instID, 0, 320717) -- 鲜血饥渴

    tierID = 12
    instID = 1274 -- 千丝之城
    uf:RegisterSeasonSpell(tierID, instID)
    uf:RegisterInstanceSpell(tierID, instID, 0, 452151) -- 严酷戳刺
    uf:RegisterInstanceSpell(tierID, instID, 0, 451295) -- 虚空奔袭
    uf:RegisterInstanceSpell(tierID, instID, 0, 440107) -- 飞刀投掷
    uf:RegisterInstanceSpell(tierID, instID, 0, 441298) -- 冰冻之血
    uf:RegisterInstanceSpell(tierID, instID, 0, 451239) -- 残暴戳刺
    uf:RegisterInstanceSpell(tierID, instID, 0, 443509) -- 贪婪之虫
    uf:RegisterInstanceSpell(tierID, instID, 0, 446718) -- 晦幽纺纱
    uf:RegisterInstanceSpell(tierID, instID, 0, 439341) -- 捻接

    instID = 1269 -- 矶石宝库
    uf:RegisterSeasonSpell(tierID, instID)
    uf:RegisterInstanceSpell(tierID, instID, 0, 449154) -- 熔岩迫击炮
    uf:RegisterInstanceSpell(tierID, instID, 0, 427361) -- 破裂
    uf:RegisterInstanceSpell(tierID, instID, 0, 423572) -- 不稳定的能量
    uf:RegisterInstanceSpell(tierID, instID, 0, 427329) -- 虚空腐蚀
    uf:RegisterInstanceSpell(tierID, instID, 0, 424805) -- 折光射线
    uf:RegisterInstanceSpell(tierID, instID, 0, 424913, 6) -- 不稳定的爆炸
    uf:RegisterInstanceSpell(tierID, instID, 0, 443494) -- 结晶喷发

    instID = 1270 -- 破晨号
    uf:RegisterSeasonSpell(tierID, instID)
    uf:RegisterInstanceSpell(tierID, instID, 0, 431365) -- 折磨光束
    uf:RegisterInstanceSpell(tierID, instID, 0, 451119) -- 深渊轰击
    uf:RegisterInstanceSpell(tierID, instID, 0, 451107) -- 迸发虫茧
    uf:RegisterInstanceSpell(tierID, instID, 0, 431350) -- 折磨喷发
    uf:RegisterInstanceSpell(tierID, instID, 0, 434668) -- 火花四射的阿拉希炸弹
    uf:RegisterInstanceSpell(tierID, instID, 0, 434113) -- 喷射丝线

    instID = 1271 -- 艾拉-卡拉，回响之城
    uf:RegisterSeasonSpell(tierID, instID)
    uf:RegisterInstanceSpell(tierID, instID, 0, 434083) -- 伏击(减速)
    uf:RegisterInstanceSpell(tierID, instID, 0, 439070) -- 撕咬
    uf:RegisterInstanceSpell(tierID, instID, 0, 433740) -- 感染
    uf:RegisterInstanceSpell(tierID, instID, 0, 433781) -- 无休虫群
    uf:RegisterInstanceSpell(tierID, instID, 0, 433662) -- 抓握之血(小怪)
    uf:RegisterInstanceSpell(tierID, instID, 0, 432031) -- 抓握之血(BOSS战)
end
