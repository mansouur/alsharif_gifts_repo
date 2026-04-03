import {defineField, defineType} from 'sanity'

export default defineType({
  name: 'saleBanner',
  title: 'بانر العروض',
  type: 'object',
  fields: [
    defineField({
      name: 'image',
      title: 'الصورة',
      type: 'image',
      options: {hotspot: true},
      validation: (Rule) => Rule.required(),
    }),
    defineField({
      name: 'heading',
      title: 'العنوان',
      type: 'string',
      validation: (Rule) => Rule.required(),
    }),
    defineField({
      name: 'subHeading',
      title: 'العنوان الفرعي',
      type: 'string',
    }),
    defineField({
      name: 'discount',
      title: 'نسبة الخصم (%)',
      type: 'number',
      description: 'مثال: 20 تعني خصم 20%',
      validation: (Rule) => Rule.min(0).max(100),
    }),
    defineField({
      name: 'buttonText',
      title: 'نص الزر',
      type: 'string',
    }),
    defineField({
      name: 'buttonLink',
      title: 'رابط الزر',
      type: 'string',
    }),
  ],
  preview: {
    select: {title: 'heading', media: 'image', discount: 'discount'},
    prepare({title, media, discount}) {
      return {
        title: title || 'بانر العروض',
        media,
        subtitle: discount ? `خصم ${discount}%` : undefined,
      }
    },
  },
})
