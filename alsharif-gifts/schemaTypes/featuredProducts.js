import {defineField, defineType} from 'sanity'

export default defineType({
  name: 'featuredProducts',
  title: 'المنتجات المميزة',
  type: 'object',
  fields: [
    defineField({
      name: 'heading',
      title: 'العنوان',
      type: 'string',
      initialValue: 'منتجات مميزة',
    }),
    defineField({
      name: 'products',
      title: 'المنتجات',
      type: 'array',
      of: [{type: 'reference', to: [{type: 'product'}]}],
    }),
  ],
  preview: {
    select: {title: 'heading'},
    prepare({title}) {
      return {title: title || 'المنتجات المميزة'}
    },
  },
})
