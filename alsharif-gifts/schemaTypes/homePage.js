import {defineField, defineType} from 'sanity'

export default defineType({
  name: 'homePage',
  title: 'الصفحة الرئيسية',
  type: 'document',
  // Singleton — only one home page document
  __experimental_actions: ['update', 'publish'],
  fields: [
    defineField({
      name: 'sections',
      title: 'أقسام الصفحة',
      description: 'اسحب وأفلت لإعادة ترتيب الأقسام',
      type: 'array',
      of: [
        {type: 'heroBanner', title: 'البانر الرئيسي'},
        {type: 'featuredProducts', title: 'المنتجات المميزة'},
        {type: 'saleBanner', title: 'بانر العروض'},
      ],
    }),
  ],
  preview: {
    prepare() {
      return {title: 'الصفحة الرئيسية'}
    },
  },
})
