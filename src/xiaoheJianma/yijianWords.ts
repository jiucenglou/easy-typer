// https://flypy.cc/help/#/jm

export const yijianci: string[] = [
  '其他', '位置', '嗯嗯', '然后', '提供', '有时', '时候', '重新', '哦哦', '便宜',
  '安装', '所有', '大概', '复杂', '关系', '忽略', '键盘', '可以', '理解',
  '自动', '显示', '词库', '直接', '比较', '内容', '目录'
]

export const yijianSet = new Set(yijianci)

export function isYijianci (text: string): boolean {
  return yijianSet.has(text)
}
