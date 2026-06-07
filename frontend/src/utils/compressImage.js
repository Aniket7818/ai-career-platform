export const compressImage = (file, { maxWidth = 800, maxHeight = 800, quality = 0.82 } = {}) => new Promise((resolve, reject) => {
  const reader = new FileReader()
  reader.onerror = () => reject(new Error('Could not read image.'))
  reader.onload = () => {
    const img = new Image()
    img.onerror = () => reject(new Error('Invalid image file.'))
    img.onload = () => {
      let { width, height } = img
      const ratio = Math.min(maxWidth / width, maxHeight / height, 1)
      width = Math.round(width * ratio)
      height = Math.round(height * ratio)
      const canvas = document.createElement('canvas')
      canvas.width = width
      canvas.height = height
      const ctx = canvas.getContext('2d')
      ctx.drawImage(img, 0, 0, width, height)
      resolve(canvas.toDataURL('image/jpeg', quality))
    }
    img.src = reader.result
  }
  reader.readAsDataURL(file)
})
