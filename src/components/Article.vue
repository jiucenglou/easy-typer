<template>
  <div id="article-main">
    <el-row
      ref="board"
      :class="articleStyle"
      @mousemove.capture="handleMouseMove"
      @mouseover="handleCharHover"
      @mouseout="clearHoveredChar"
    >
      <Words v-for="word in words" :key="word.id" :word="word"/>
    </el-row>
    <el-divider class="article-info" content-position="right">
      <span>第{{ identity }}段</span>
      <span>{{ title || '未知' }}</span>
      <span>共{{ length }}字</span>
      <el-tooltip
        v-if="errorCharsSize > 0"
        :content="errorCharsTooltip"
        placement="top"
        effect="light"
        popper-class="error-chars-tooltip">
        <el-button
          type="text"
          @click="handleCreateErrorCharsPractice">
          &nbsp;  有错误（共{{ errorCharsSize }}字），点击练习
        </el-button>
      </el-tooltip>
    </el-divider>

    <!-- 小鹤音形码表提示 -->
    <!-- 使用teleport将tooltip移到body下，避免影响布局 -->
    <teleport to="body">
      <ArticleChaxingTooltip
        v-if="hoveredChar"
        :character="hoveredChar"
        :position="mousePosition"
        :enabled="true"
      />
    </teleport>
  </div>
</template>

<script lang="ts">
import { Word } from '@/store/types'
import { Edge, ShortestPath } from '@/store/util/Graph'
import { Component, Vue, Watch } from 'vue-property-decorator'
import { namespace } from 'vuex-class'
import Words from '@/components/Words.vue'
import ArticleChaxingTooltip from '@/components/ArticleChaxingTooltip.vue'

import { isYijianci } from '../xiaoheJianma/yijianWords' // 你的一简词列表
import { isErjian1XuanPutong, isErjian1XuanZhongdian, isErjian2Xuan } from '../xiaoheJianma/erjianWords' // 你的二简词列表
import { isSiziWord } from '../xiaoheJianma/siziWords'
import { isSanziWord } from '../xiaoheJianma/sanziWords'
import { isErziWord } from '../xiaoheJianma/erziWords'
import { ChaXing } from '../xiaoheJianma/zi'

const article = namespace('article')
const racing = namespace('racing')
const setting = namespace('setting')
const kata = namespace('kata')

@Component({
  components: { Words, ArticleChaxingTooltip }
})
export default class Article extends Vue {
  $refs!: {
    board: Vue & { $el: HTMLElement };
  }

  $store!: Vue['$store']
  @article.State('content')
  private content!: string

  @article.State('identity')
  private identity!: string

  @article.State('title')
  private title!: string

  @article.Getter('length')
  private length!: number

  @racing.State('input')
  private input!: string

  @article.State('shortest')
  private shortest!: ShortestPath<Word> | null;

  @racing.Getter('progress')
  private progress!: number

  @setting.State('hint')
  private hint!: boolean

  @setting.State('fontSize')
  private fontSize!: string

  @setting.State('articleRows')
  private articleRows!: number

  @setting.State('hintOptions')
  private hintOptions!: Array<string>

  // 小鹤音形码表提示相关
  private hoveredChar: string | null = null
  private mousePosition = { x: 0, y: 0 }

  // 全局错字集合
  @kata.State('errorChars')
  private errorChars!: string[]

  // 获取错字集合的大小
  get errorCharsSize (): number {
    return this.errorChars ? this.errorChars.join('').length : 0
  }

  // 格式化错字内容用于tooltip显示
  get errorCharsTooltip (): string {
    if (!this.errorChars || this.errorChars.length === 0) {
      return '无错误'
    }
    return `错误列表: ${this.errorChars.join(' ')}`
  }

  @kata.Action('createErrorCharsPractice')
  private createErrorCharsPractice!: Function

  get articleStyle (): Array<string> {
    let mode = 'inline'
    if (this.hint && this.shortest && (this.codeHint || this.selectHint || this.autoSelectHint)) {
      mode = 'grid'
    }
    return ['article', mode]
  }

  get selectHint (): boolean {
    return this.hintOptions.indexOf('select') >= 0
  }

  get codeHint (): boolean {
    return this.hintOptions.indexOf('code') >= 0
  }

  get autoSelectHint (): boolean {
    return this.hintOptions.indexOf('autoSelect') >= 0
  }

  get words (): Array<Word> {
    const length = this.content.length
    if (length === 0) {
      return []
    }

    const input = this.input
    const words: Array<Word> = []
    if (!this.hint || !this.shortest) {
      const inputLength = input.length
      const typed = this.content.substring(0, inputLength)
      this.check(0, input, typed, words)
      const pending = this.content.substring(inputLength)
      // words.push(new Word(inputLength, pending, 'pending'))
      // 未打部分按一简词和二简词分割
      // 为了改善布局，不再保存为可能含多个字的 span，而是保存为仅含单字的 span：首先，标记每个字属于哪个词组
      const hintMap = new Map<number, string>()
      let i = 0
      while (i < pending.length) {
        let found = false
        for (let len = 4; len >= 2; len -= 1) {
          const part = pending.substr(i, len)
          let hintType = ''
          if (isSiziWord(part)) hintType = 'sizi'
          else if (isSanziWord(part)) hintType = 'sanzi'
          else if (isYijianci(part)) hintType = 'yijian'
          else if (isErjian1XuanPutong(part)) hintType = 'erjian1Putong'
          else if (isErjian1XuanZhongdian(part)) hintType = 'erjian1Zhongdian'
          else if (isErjian2Xuan(part)) hintType = 'erjian2'
          else if (isErziWord(part)) hintType = 'erzi'
          if (hintType) {
            for (let j = 0; j < len; j++) {
              hintMap.set(i + j, hintType)
            }
            i += len
            found = true
            break
          }
        }
        if (!found) {
          i += 1
        }
      }

      // 为了改善布局，不再保存为可能含多个字的 span，而是保存为仅含单字的 span：然后，pending部分始终单字分割，并附加 hintType
      for (let k = 0; k < pending.length; k++) {
        const char = pending[k]
        const hintType = hintMap.get(k)
        const word = new Word(inputLength + k, char, 'pending')
        if (hintType) word.hintType = hintType
        words.push(word)
      }
    } else {
      const { path, vertices } = this.shortest
      for (let i = 0; i < length;) {
        // TODO: 扩折号会报错，如：老去——致爸
        const vertice = vertices[path[i]]
        const edge = vertice?.get(i)
        if (!edge) {
          i++
          continue
        }
        const next = this.addPhrase(input, edge, words)
        i = next === 0 ? path[i] : next
      }
    }

    // console.log(words.map(w => w.text))

    return words
  }

  /**
   * 自动调整滚动条位置
   */
  @Watch('progress')
  autoScroll (progress: number) {
    const el = (this.$refs.board as Vue).$el
    const { clientHeight, scrollHeight } = el
    const scrollDistance = scrollHeight - clientHeight
    if (scrollDistance <= 0) {
      return
    }

    if (progress === 0) {
      el.scrollTop = 0
      return
    }

    const suffixOffset = this.hint ? 2 : 1
    const baseOffset = (parseFloat(this.fontSize) + suffixOffset) * 12

    const fixed = this.hint ? Math.max(0, baseOffset * (this.articleRows - 1) - 0.5 * baseOffset) : baseOffset * (this.articleRows - 1)

    const pending = document.querySelector('.code1,.code2,.code3,.code4,.pending') as HTMLElement
    if (pending) {
      el.scrollTop = Math.max(0, pending.offsetTop - fixed)
    } else {
      el.scrollTop = Math.min(progress * scrollDistance, scrollDistance)
    }
  }

  check (index: number, input: string, target: string, words: Array<Word>): void {
    const length = target.length
    const targetWords = target.split('')
    const inputWords = input.split('')
    let lastCorrect = targetWords[0] === inputWords[0]
    let text = ''

    inputWords.forEach((v, i) => {
      if (i >= length) {
        return
      }

      const target = targetWords[i]
      const correct = v === target

      // 收集打错的字符 - 添加到全局错字集合
      // 也可以提前到 racing.ts 中的 accept action 中收集（这也是 AI 给的建议），
      // 但是这里已经进行了错字的判断，所以直接在这里收集～
      if (!correct) {
        this.$store.dispatch('kata/addErrorChar', target)
      }

      if (correct !== lastCorrect) {
        words.push(new Word(index + i - text.length, text, lastCorrect ? 'correct' : 'error'))
        text = ''
        lastCorrect = correct
      }
      text = text.concat(target)
    })

    if (text.length > 0) {
      words.push(new Word(index + input.length - text.length, text, lastCorrect ? 'correct' : 'error'))
    }
  }

  addPhrase (content: string, edge: Edge<Word>, words: Array<Word>): number {
    const { from, to, value } = edge

    if (content.length <= to) {
      // 输入长度小于当前词首，未打
      words.push(value)
      return 0
    } else {
      // 输入长度大于当前词尾，已打, 否则部分已打
      const length = content.length
      const source = content.substring(to, Math.min(from, length))
      this.check(to, source, value.text, words)
      return length > from ? 0 : length
    }
  }

  // 处理创建错字练习
  handleCreateErrorCharsPractice () {
    this.createErrorCharsPractice()
  }

  // 小鹤音形查形提示的相关方法

  mounted () {
    const el = this.$refs.board?.$el
    if (el) {
      // 移除所有Vue绑定的事件监听器
      el.removeEventListener('mousemove', this.handleMouseMove)
      el.removeEventListener('mouseover', this.handleCharHover)
      el.removeEventListener('mouseout', this.clearHoveredChar)

      // 直接绑定原生事件
      el.addEventListener('mousemove', this.handleMouseMove, { passive: true })
      el.addEventListener('mouseover', this.handleCharHover, { passive: true })
      el.addEventListener('mouseout', this.clearHoveredChar, { passive: true })

      console.log('已重新绑定原生事件监听器')
    }
  }

  /**
   * 处理鼠标移动事件，更新鼠标位置
   */
  private debounceTimer: number | null = null

  private lastUpdateTime = 0

  handleMouseMove (event: MouseEvent) {
    const now = Date.now()
    // 限制更新频率为每秒60次
    if (now - this.lastUpdateTime < 16) return

    this.lastUpdateTime = now
    const newPos = {
      x: event.clientX + 20,
      y: event.clientY + 20
    }

    // 强制触发响应式更新
    this.mousePosition = JSON.parse(JSON.stringify(newPos))
    console.log('更新位置:', this.mousePosition)
  }

  /**
   * 处理字符悬停事件
   */
  private hoverTimer: number | null = null

  async handleCharHover (event: MouseEvent) {
    // 清除之前的计时器
    if (this.hoverTimer !== null) {
      window.clearTimeout(this.hoverTimer)
    }

    const target = event.target as HTMLElement
    if (!target) return

    // 获取最接近的字符元素
    const charElement = target.closest('span') || target
    const text = charElement.textContent?.trim() || ''

    // 记录鼠标位置
    const viewportWidth = window.innerWidth
    const viewportHeight = window.innerHeight
    const position = {
      x: Math.min(event.clientX + 20, viewportWidth - 220),
      y: Math.min(event.clientY + 20, viewportHeight - 140)
    }

    // 设置 0.5 秒延迟
    this.hoverTimer = window.setTimeout(async () => {
      // 确保码表已加载
      if (!ChaXing.getInstance().isLoaded) {
        await ChaXing.getInstance().loadChaxingData()
      }

      // 0.5 秒后设置悬停字符和位置
      this.hoveredChar = text
      this.mousePosition = position
      // // 只处理单字符
      // if (text.length === 1) {
      //   const viewportWidth = window.innerWidth
      //   const viewportHeight = window.innerHeight
      //   this.hoveredChar = text
      //   this.mousePosition = {
      //     x: Math.min(event.clientX + 20, viewportWidth - 220),
      //     y: Math.min(event.clientY + 20, viewportHeight - 140)
      //   }
      //   console.log('显示提示:', text, '位置:', this.mousePosition)
      // } else {
      //   this.hoveredChar = null
      // }
    }, 500)
  }

  /**
   * 清除悬停字符
   */
  clearHoveredChar () {
    // 清除计时器
    if (this.hoverTimer !== null) {
      window.clearTimeout(this.hoverTimer)
      this.hoverTimer = null
    }
    this.hoveredChar = null
  }
}
</script>

<style lang="scss">
  #article-main {
    word-break: break-all;
  }
</style>

<style>
/* 全局样式，用于错字提示 */
.error-chars-tooltip {
  font-family: var(--racing-font) !important;
  font-size: max(1.2rem, var(--font-size)) !important;
  max-width: 400px;
  line-height: 1.5;
}
</style>
