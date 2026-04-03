import {defineField, defineType} from 'sanity'

export default defineType({
  name: 'category',
  title: 'التصنيفات',
  type: 'document',
  fields: [
    defineField({
      name: 'title',
      title: 'اسم التصنيف',
      type: 'string',
      validation: (Rule) => Rule.required(),
    }),
    defineField({
      name: 'slug',
      title: 'الرابط المختصر',
      type: 'slug',
      options: {source: 'title', maxLength: 96},
      validation: (Rule) => Rule.required(),
    }),
    defineField({
      name: 'image',
      title: 'الصورة',
      type: 'image',
      options: {hotspot: true},
    }),
    defineField({
      name: 'description',
      title: 'الوصف',
      type: 'text',
      rows: 3,
    }),
  ],
  preview: {
    select: {title: 'title', media: 'image'},
  },
})
