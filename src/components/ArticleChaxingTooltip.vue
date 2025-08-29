<template>
  <div class="article-chaxing-tooltip">
    <slot></slot>
    <div v-if="showTooltip" class="chaxing-tooltip" :style="tooltipStyle" :show="showTooltip">
      <div v-for="(line, index) in chaxingLines" :key="index" class="chaxing-line">
        {{ line }}
      </div>
    </div>
  </div>
</template>

<script>
import ChaXing from '../xiaoheJianma/zi'

export default {
  name: 'ArticleChaxingTooltip',
  props: {
    character: {
      type: String,
      required: true
    },
    enabled: {
      type: Boolean,
      default: true
    },
    position: {
      type: Object,
      default: () => ({ x: 0, y: 0 })
    }
  },
  data () {
    return {
      showTooltip: false
    }
  },
  computed: {
    chaxingLines () {
      return [
        `编码: ${ChaXing.getCode(this.character)}`,
        `鹤形: ${ChaXing.getShape(this.character)}`,
        `拆分: ${ChaXing.getComponents(this.character)}`,
        `拼音: ${ChaXing.getPinyin(this.character)}`
      ].filter(line => !line.includes('undefined'))
    },
    tooltipStyle () {
      const style = {
        top: `${this.position.y}px`,
        left: `${this.position.x}px`,
        transform: 'translateZ(0)',
        willChange: 'left, top'
      }

      // 边界检查
      const viewportWidth = window.innerWidth
      const viewportHeight = window.innerHeight
      const tooltipWidth = 200
      const tooltipHeight = 120

      if (this.position.x + tooltipWidth > viewportWidth) {
        style.left = `${viewportWidth - tooltipWidth - 10}px`
      }
      if (this.position.y + tooltipHeight > viewportHeight) {
        style.top = `${viewportHeight - tooltipHeight - 10}px`
      }

      return style
    }
  },
  watch: {
    character: {
      immediate: true,
      handler (newVal) {
        this.showTooltip = !!newVal && ChaXing.hasCode(newVal)
      }
    },
    position: {
      immediate: true,
      handler (newVal) {
        console.log('位置更新:', newVal)
      }
    }
  }
  // ,
  // async mounted () {
  //   if (!ChaXing.isLoaded) {
  //     await XiaoheCodeHelper.loadCodeTable()
  //   }
  //   if (this.character && ChaXing.getCode(this.character)) {
  //     this.showTooltip = true
  //   }
  // }
}
</script>

<style scoped>
.article-chaxing-tooltip {
  position: relative;
  display: inline-block;
}

.chaxing-tooltip {
  position: fixed;
  z-index: 1000;
  background-color: rgba(0, 0, 0, 0.8);
  color: white;
  padding: 8px 12px;
  border-radius: 4px;
  font-size: max(14px, var(--font-size));
  pointer-events: none;
  min-width: 180px;
  box-shadow: 0 3px 6px rgba(0,0,0,0.16);
  transition: opacity 0.2s, transform 0.2s;
  transform-origin: left bottom;
}
.chaxing-tooltip[show] {
  opacity: 1;
  transform: scale(1);
}
.chaxing-tooltip:not([show]) {
  opacity: 0;
  transform: scale(0.95);
}
.chaxing-line {
  margin: 4px 0;
  line-height: 1.4;
}
</style>
