import { KataOptions } from '@/models/articleModels'

export const freeOption: KataOptions = {
  value: 'free',
  label: '自由',
  id: 1,
  children: [
    {
      id: 57,
      value: 'freeText',
      label: '手动输入',
      isRemote: 0,
      children: []
    }
  ]
}
