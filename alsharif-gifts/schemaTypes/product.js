import {defineField, defineType} from 'sanity'

export default defineType({
  name: 'product',
  title: 'المنتجات',
  type: 'document',
  fields: [
    defineField({
      name: 'name',
      title: 'اسم المنتج',
      type: 'string',
      validation: (Rule) => Rule.required(),
    }),
    defineField({
      name: 'slug',
      title: 'الرابط المختصر',
      type: 'slug',
      options: {source: 'name', maxLength: 96},
      validation: (Rule) => Rule.required(),
    }),
    defineField({
      name: 'category',
      title: 'التصنيف',
      type: 'reference',
      to: [{type: 'category'}],
    }),
    defineField({
      name: 'images',
      title: 'الصور',
      type: 'array',
      of: [{type: 'image', options: {hotspot: true}}],
    }),
    defineField({
      name: 'description',
      title: 'الوصف',
      type: 'text',
      rows: 4,
    }),
    defineField({
      name: 'price',
      title: 'السعر',
      type: 'number',
      validation: (Rule) => Rule.required().min(0),
    }),
    defineField({
      name: 'onSale',
      title: 'في عرض؟',
      type: 'boolean',
      initialValue: false,
    }),
    defineField({
      name: 'discountPercent',
      title: 'نسبة الخصم (%)',
      type: 'number',
      description: 'مثال: 20 تعني خصم 20%',
      validation: (Rule) => Rule.min(0).max(100),
      hidden: ({document}) => !document?.onSale,
    }),
    defineField({
      name: 'saleEndDate',
      title: 'تاريخ انتهاء العرض',
      type: 'datetime',
      hidden: ({document}) => !document?.onSale,
    }),
    defineField({
      name: 'isBestSeller',
      title: 'الأكثر مبيعاً؟',
      type: 'boolean',
      initialValue: false,
    }),
    defineField({
      name: 'isNew',
      title: 'وصول جديد؟',
      type: 'boolean',
      initialValue: false,
    }),
    defineField({
      name: 'inStock',
      title: 'متوفر في المخزون؟',
      type: 'boolean',
      initialValue: true,
    }),
    defineField({
      name: 'tags',
      title: 'الوسوم',
      type: 'array',
      of: [{type: 'string'}],
      options: {layout: 'tags'},
    }),
  ],
  preview: {
    select: {
      title: 'name',
      media: 'images.0',
      price: 'price',
      onSale: 'onSale',
      discountPercent: 'discountPercent',
    },
    prepare({title, media, price, onSale, discountPercent}) {
      const finalPrice =
        onSale && discountPercent
          ? (price * (1 - discountPercent / 100)).toFixed(2)
          : price

      const subtitle =
        price != null
          ? onSale && discountPercent
            ? `${finalPrice} د.إ (خصم ${discountPercent}%)`
            : `${price} د.إ`
          : 'لا يوجد سعر'

      return {title, media, subtitle}
    },
  },
})
