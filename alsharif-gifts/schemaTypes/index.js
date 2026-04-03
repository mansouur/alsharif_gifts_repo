import category from './category'
import product from './product'
import heroBanner from './heroBanner'
import saleBanner from './saleBanner'
import featuredProducts from './featuredProducts'
import homePage from './homePage'
import storeSettings from './storeSettings'

export const schemaTypes = [
  // Documents
  category,
  product,
  homePage,
  storeSettings,
  // Objects (used inside documents)
  heroBanner,
  saleBanner,
  featuredProducts,
]
