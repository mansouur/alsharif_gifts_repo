import {defineField, defineType} from 'sanity'

export default defineType({
  name: 'heroBanner',
  title: 'البانر الرئيسي',
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
      title: 'العنوان الرئيسي',
      type: 'string',
      validation: (Rule) => Rule.required(),
    }),
    defineField({
      name: 'subHeading',
      title: 'العنوان الفرعي',
      type: 'string',
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
    select: {title: 'heading', media: 'image'},
    prepare({title, media}) {
      return {title: title || 'البانر الرئيسي', media}
    },
  },
})
