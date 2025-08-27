import { KataOptions } from '@/models/articleModels'

import { yijianci, yijianSet } from '../xiaoheJianma/yijianWords'
import { erjian1xuan, erjian1xuanZhongdian, erjian2xuan, erjian1Set, erjian1ZSet, erjian2Set } from '../xiaoheJianma/erjianWords'

export const xiaoheJianma: KataOptions = {
  value: 'xiaoheJianma',
  label: '小鹤简码',
  id: 101,
  children: [{
    id: 1011,
    value: '菜少僧多佛无肉车新帅老将有云深山谁能弄风月水里咋让虐黄牛白龙森林闹天地黑熊大户催嫩排' +
    '阿翁恰好说空话爱女当面色从容怒撒红米她先笑穷困绿囊贼也完为何楼高汤更暖凭啥桥坏应对难' +
    '目光绕得亲体软装问跑来您眼前两间长草各内外几行热搜求安全藏传真如修本主上元太岁共双恩' +
    '桌边混吃仍需乐村中走动且请跟长路正顺或行久报表群读谈分成样图古怪撇粗乱陈某特强蹦窜戳' +
    '配料过关调算法窗口那处叫生抽昂头每次旁若定顿额经年只等盘曾早数日听鸟梦但因差点总卷然' +
    '四下帮凑含宁散最后推却跌碰贴超贵追买怕卡疼放浪还看该干吗亚奥比赛忙参与想哭接连被灭团' +
    '费用加增够快否民调占据很慢么普系吹落抓进组受到肯夸找靠所并列均宽纯况转再而以测滚剖剋' +
    '破产另论刚做事挖坑则选横滨区藏着换代别给我错字怎办要任其毛亏送些同学们开设冲丢都冷啦' +
    '品类套票盆克秒名片副部段批扎挂拽抗拴拨拆扩摸捏挪擦扫把拖刘苏岑欧周王反嗯欸喔哟嘎哈呢' +
    '你得会',
    label: '二简字',
    children: [],
    isRemote: 0
  }, {
    id: 1012,
    value: yijianci.join(''),
    label: '一简词',
    children: [],
    isRemote: 0
  }, {
    id: 1013,
    value: erjian1xuan.join(''),
    label: '二简词（首选）',
    children: [],
    isRemote: 0
  }, {
    id: 1014,
    value: erjian1xuanZhongdian.join(''),
    label: '二简词（首选，前三排）',
    children: [],
    isRemote: 0
  }, {
    id: 1015,
    value: erjian2xuan.join(''),
    label: '二简词（次选）',
    children: [],
    isRemote: 0
  }]
}
