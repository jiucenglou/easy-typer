
import { ActionTree, GetterTree, Module, MutationTree } from 'vuex'
import { QuickTypingState, KataState } from './types'
import { isMobile, shuffle, shuffleText2 } from './util/common'
import { Message } from 'element-ui'
import { kataHistory } from './util/KataHistory'

import { yijianci, yijianSet } from '../xiaoheJianma/yijianWords'
import { erjian1xuan, erjian1xuanZhongdian, erjian2xuan, erjian1Set, erjian1ZSet, erjian2Set } from '../xiaoheJianma/erjianWords'

const xiaoheJianmaSet = new Set([...yijianSet, ...erjian1Set, ...erjian2Set])

export interface KataArticle {
  content: string;
  title: string;
}

const state = new KataState()

const getters: GetterTree<KataState, QuickTypingState> = {
  currentMatch: state => state.articleTitle,
  paragraphCount: state => state.textType === 2 ? state.articleText.split('\n').length : Math.ceil(state.articleText.length / state.paragraphSize),
  nextParagraph: (state, getters) => {
    return {
      title: `${state.articleTitle}(${state.currentParagraphNo}/${getters.paragraphCount})`,
      number: state.currentParagraphNo + state.indentity - 1,
      content: state.currentContent
    }
  }
}

const mutations: MutationTree<KataState> = {
  init: (state) => {
    state.mode = 0
    state.isReading = false
    state.criteriaOpen = false
    state.achievedCount = 0
    if (isMobile()) {
      state.criteriaHitSpeed = 0
    }
  },

  article: (state, article: KataState) => {
    state.textType = article.textType
    const startIndex = (article.currentParagraphNo - 1) * article.paragraphSize

    state.articleText = article.articleText
    state.articleTitle = article.articleTitle
    state.currentParagraphNo = article.currentParagraphNo
    state.paragraphSize = article.paragraphSize
    state.indentity = article.indentity || 1

    if (state.textType === 2) {
      state.currentContent = state.articleText.split('\n')[article.currentParagraphNo - 1]
    } else {
      state.currentContent = state.articleText.slice(startIndex, startIndex + article.paragraphSize)
    }

    state.mode = 1
    state.isReading = article.isReading
  },
  prev: (state) => {
    state.currentParagraphNo -= 1
    const startIndex = (state.currentParagraphNo - 1) * state.paragraphSize

    if (state.textType === 2) {
      state.currentContent = state.articleText.split('\n')[state.currentParagraphNo - 1]
    } else {
      state.currentContent = state.articleText.slice(startIndex, startIndex + state.paragraphSize)
    }
  },
  next: (state) => {
    state.currentParagraphNo += 1
    const startIndex = (state.currentParagraphNo - 1) * state.paragraphSize

    if (state.textType === 2) {
      state.currentContent = state.articleText.split('\n')[state.currentParagraphNo - 1]
    } else {
      state.currentContent = state.articleText.slice(startIndex, startIndex + state.paragraphSize)
    }
  },

  random: (state) => {
    state.currentContent = shuffle(state.currentContent.split('')).join('')
  },

  random2: (state) => {
    state.currentContent = shuffleText2(state.currentContent, xiaoheJianmaSet)
  },

  mode: (state, newMode: number) => {
    state.mode = newMode
  },

  updateCriteria: (state, criteria) => {
    if (criteria) {
      Object.assign(state, criteria)
    }
  },

  load: (state, newState) => {
    if (newState) {
      Object.assign(state, newState)
    }
  },

  updateTipWarning: (state, isShow: boolean) => {
    state.hasTipWarning = isShow
  },

  achievedCount: (state, count: number) => {
    state.achievedCount = count
  }
}

const actions: ActionTree<KataState, QuickTypingState> = {
  init ({ commit }): void {
    commit('init')
  },
  load ({ commit }, newState): void {
    commit('load', newState)
  },
  updateAchievedCount ({ commit }, count: number): void {
    commit('achievedCount', count)
  },
  loadArticle ({ commit, state }, article: KataState): void {
    commit('article', article)
    kataHistory.insertOrUpdateHistory(state)
  },
  updateCriteria ({ commit, state, getters }, criteria): void {
    if (criteria) {
      commit('updateCriteria', criteria)
    }
  },
  updateTipWarning ({ commit }, isShow: boolean): void {
    commit('updateTipWarning', isShow)
  },
  prev ({ commit, state, getters }): void {
    if (state.mode === 1) {
      const mode = state.currentParagraphNo <= 1 ? 0 : 1
      // commit('mode', mode)
      // if (state.isReading) {
      //   this.dispatch('reading/updateProgress', state.currentContent.length)
      // }

      if (mode === 1) {
        commit('prev')
        this.dispatch('article/loadMatch', getters.nextParagraph)

        kataHistory.insertOrUpdateHistory(state)
      }
    }
  },
  next ({ commit, state, getters }, hideWanring = false): void {
    if (state.mode === 1) {
      const mode = state.currentParagraphNo >= getters.paragraphCount ? 2 : 1
      commit('mode', mode)
      if (state.isReading) {
        this.dispatch('reading/updateProgress', state.currentContent.length)
      }

      if (mode === 1) { // 2 已结束
        commit('next')
        this.dispatch('article/loadMatch', getters.nextParagraph)

        kataHistory.insertOrUpdateHistory(state)
      }
    } else if (!hideWanring) {
      commit('init')
      Message.warning({
        message: '当前不在发文状态，无法进入下一段'
      })
    }
  },
  random ({ commit, getters }): void {
    commit('random')
    this.dispatch('article/loadMatch', getters.nextParagraph)
  },
  random2 ({ commit, getters }): void {
    commit('random2')
    this.dispatch('article/loadMatch', getters.nextParagraph)
  }
}

export const kata: Module<KataState, QuickTypingState> = {
  namespaced: true,
  state,
  getters,
  mutations,
  actions
}
