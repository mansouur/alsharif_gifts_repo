export default {
  name: 'storeSettings',
  title: 'إعدادات المتجر',
  type: 'document',
  fields: [
    {
      name: 'storeName',
      title: 'اسم المتجر',
      type: 'string',
      validation: Rule => Rule.required(),
    },
    {
      name: 'storeSubtitle',
      title: 'الشعار / الوصف المختصر',
      type: 'string',
    },
    {
      name: 'logo',
      title: 'الشعار (Logo)',
      type: 'image',
      options: { hotspot: true },
    },
    {
      name: 'whatsappNumber',
      title: 'رقم الواتساب (بدون + مثال: 971503565455)',
      type: 'string',
      validation: Rule => Rule.required(),
    },
    {
      name: 'workingHours',
      title: 'ساعات العمل',
      type: 'string',
    },
    {
      name: 'address',
      title: 'العنوان / الموقع',
      type: 'string',
    },
    {
      name: 'about',
      title: 'نبذة عن المتجر',
      type: 'text',
      rows: 4,
    },
    {
      name: 'coverImage',
      title: 'صورة صفحة من نحن',
      type: 'image',
      options: { hotspot: true },
    },
  ],
  preview: {
    select: { title: 'storeName' },
    prepare({ title }) {
      return { title: title || 'إعدادات المتجر' }
    },
  },
}
