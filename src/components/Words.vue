<template>
  <div :class="style">
    <span
      :class="{
        'yijianci': hasXiaoheJianmaHint && word.hintType === 'yijian',
        'erjian-1xuan-putong': hasXiaoheJianmaHint && word.hintType === 'erjian1Putong',
        'erjian-1xuan-zhongdian': hasXiaoheJianmaHint && word.hintType === 'erjian1Zhongdian',
        'erjian-2xuan': hasXiaoheJianmaHint && word.hintType === 'erjian2',
        'sizi': hasXiaoheJianmaHint && word.hintType === 'sizi',
        'sanzi': hasXiaoheJianmaHint && word.hintType === 'sanzi',
        'erzi': hasXiaoheJianmaHint && word.hintType === 'erzi'
      }"
    >{{ word.text }}</span>
    <label v-if="hasHint">{{ hintText }}</label>
  </div>
</template>

<script lang="ts">
import { Word } from '@/store/types'
import { Component, Prop, Vue } from 'vue-property-decorator'
import { namespace } from 'vuex-class'

const setting = namespace('setting')

@Component
export default class Words extends Vue {
  @Prop({ type: Word, required: true })
  readonly word!: Word

  @setting.State('hint')
  private hint!: boolean

  @setting.State('punctuationAutoSelectHint')
  private punctuationAutoSelectHint!: string

  @setting.State('hintOptions')
  private hintOptions!: Array<string>

  @setting.State('disableSingleHint')
  private disableSingleHint!: boolean

  @setting.State('hintXiaoheJianma')
  private hintXiaoheJianma!: boolean

  // 获取错字集合的大小
  get hasXiaoheJianmaHint (): boolean {
    return this.hintXiaoheJianma
  }

  get single (): boolean {
    const word = this.word
    const length = word.text.length
    return !this.disableSingleHint || length > (word.autoSelect ? 2 : 1)
  }

  get hasColorHint (): boolean {
    return (this.hintOptions.indexOf('color') >= 0 && this.single) || !this.word.type.startsWith('code')
  }

  get hasSelectHint (): boolean {
    return this.hintOptions.indexOf('select') >= 0 && !!this.word.select && this.single
  }

  get hasCodeHint (): boolean {
    const { codings } = this.word
    return this.hintOptions.indexOf('code') >= 0 && codings && codings.length > 0 && !!codings[0].code && this.single
  }

  get hasAutoSelectHint (): boolean {
    return this.hintOptions.indexOf('autoSelect') >= 0 && this.word.autoSelect && this.single
  }

  get style (): Array<string> {
    const styles = ['code']

    if (this.hasColorHint) {
      styles.push(this.word.type)
    } else {
      styles.push('pending')
    }

    return styles
  }

  get hasHint (): boolean {
    return this.hint && (this.hasCodeHint || this.hasSelectHint || this.hasAutoSelectHint)
  }

  get hintText (): string {
    let text = ''
    const { select, codings } = this.word
    if (this.hasCodeHint) {
      text += codings[0].code
    }
    if (this.hasSelectHint) {
      text += select
    }
    if (this.hasAutoSelectHint) {
      text += this.punctuationAutoSelectHint
    }
    return text
  }

  // mounted () {
  //   console.log('word.text:', this.word.text, 'isErjian1Xuan:', erjian1Set.has(this.word.text), 'isErjian2Xuan:', erjian2Set.has(this.word.text))
  // }
}
</script>

<style scoped>
.yijianci {
  text-decoration: underline;
  text-decoration-style: double;
  text-underline-offset: 4px;
  text-decoration-thickness: 4px;
  text-decoration-color: #19d22c;
}
.erjian-1xuan-putong {
  text-decoration: underline;
  text-underline-offset: 4px;
  text-decoration-thickness: 2px;
  text-decoration-color: #1976d2;
}
.erjian-1xuan-zhongdian {
  text-decoration: underline;
  text-underline-offset: 4px;
  text-decoration-thickness: 4px;
  text-decoration-color: #1976d2;
}
.erjian-2xuan {
  text-decoration: underline;
  text-decoration-style: wavy;
  text-underline-offset: 4px;
  text-decoration-thickness: 2px;
  text-decoration-color: #d219cf;
}
.sizi, .sanzi, .erzi {
  text-decoration: underline;
  text-decoration-style: dotted;
  text-underline-offset: 4px;
  text-decoration-thickness: 4px;
  text-decoration-color: #d28819;
}
</style>
