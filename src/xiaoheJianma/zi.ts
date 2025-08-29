/**
 * 小鹤音形收录的通规字的码表类
 * 用于管理和查询汉字的小鹤音形编码、鹤形、拆分、和拼音信息
 */

// 单个通用规范字的信息
export interface TongGuiZiInfo {
  '1': string; // 编码
  '2': string; // 鹤形
  '3': string; // 拆分
  '4': string; // 拼音
}

// 所有通用规范字的信息的表
interface TongGuiZiBiao {
  [zi: string]: TongGuiZiInfo;
}

export class ChaXing {
  private static instance: ChaXing

  private all8105zi: TongGuiZiBiao
  private loading = false
  private loadPromise: Promise<boolean> | null = null

  private constructor () {
    this.all8105zi = {}
    this.loading = false
    this.loadPromise = null
  }

  public static getInstance (): ChaXing {
    if (!ChaXing.instance) {
      ChaXing.instance = new ChaXing()
    }
    return ChaXing.instance
  }

  public async loadChaxingData (path = 'static/chaxing_data.json'): Promise<boolean> {
    if (this.loading) return this.loadPromise as Promise<boolean>

    this.loading = true

    try {
      const response = await fetch(`${path}?t=${Date.now()}`)
      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`)
      }

      const data = await response.json()

      // 添加数据验证
      if (!data || typeof data !== 'object') {
        throw new Error('Invalid data format')
      }

      this.all8105zi = data
      const count = data instanceof Array ? data.length : Object.keys(data).length
      console.log(`小鹤音形码表加载成功，共 ${count} 个字符`)

      return true
    } catch (error) {
      console.error('加载小鹤音形码表失败:', error)
      return false
    } finally {
      this.loading = false
    }
  }

  public get isLoaded (): boolean {
    // chaxing_data.json 的最后一个字 霋
    return this.all8105zi['霋'] != null
  }

  public hasCode (zi: string): boolean {
    return this.all8105zi[zi] != null
  }

  /**
   * 获取字符的编码
   * @param character 要查询的字符
   * @returns string | null 字符的编码，如果未找到则返回null
   */
  public getCode (zi: string): string | null {
    const ziInfo = this.all8105zi[zi] || null
    return ziInfo ? ziInfo['1'] : null
  }

  /**
   * 获取字符的鹤形
   * @param character 要查询的字符
   * @returns string | null 字符的鹤形，如果未找到则返回null
   */
  public getShape (zi: string): string | null {
    const ziInfo = this.all8105zi[zi] || null
    return ziInfo ? ziInfo['2'] : null
  }

  /**
   * 获取字符的拆分
   * @param character 要查询的字符
   * @returns string | null 字符的拆分，如果未找到则返回null
   */
  public getComponents (zi: string): string | null {
    const ziInfo = this.all8105zi[zi] || null
    return ziInfo ? ziInfo['3'] : null
  }

  /**
   * 获取字符的拼音
   * @param character 要查询的字符
   * @returns string | null 字符的拼音，如果未找到则返回null
   */
  public getPinyin (zi: string): string | null {
    const ziInfo = this.all8105zi[zi] || null
    return ziInfo ? ziInfo['4'] : null
  }

  /**
   * 获取码表中的字符数量
   * @returns number 字符数量
   */
  public get size (): number {
    return Object.keys(this.all8105zi).length
  }
}

/**
 * 初始化小鹤音形码表
 */
export function initXiaoheChaxing (path = 'static/chaxing_data.json'): Promise<boolean> {
  return ChaXing.getInstance().loadChaxingData(path)
}

// 导出单例实例
export default ChaXing.getInstance()
