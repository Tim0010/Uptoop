# 🖼️ Supabase Storage Setup Guide

## ✅ What Was Fixed

Your app was using `Image.asset()` to load images from local assets, but your database contains Supabase Storage URLs. I've updated the code to:

1. **Auto-detect** if the image path is a URL (starts with `http://` or `https://`)
2. Use **`Image.network()`** for URLs from Supabase Storage
3. Use **`Image.asset()`** for local assets
4. Added **loading indicators** while images are being fetched
5. Added **error handling** with fallback icons

### Files Updated:
- ✅ `lib/widgets/program_card.dart` - Program cards now support network images
- ✅ `lib/widgets/program_details_popup.dart` - Program details now support network images

---

## 📋 Step-by-Step: Setting Up Supabase Storage

### Step 1: Create Storage Buckets

1. Go to your **Supabase Dashboard**: https://supabase.com/dashboard
2. Select your project
3. Click **Storage** in the left sidebar
4. Click **"New bucket"**

Create these buckets:
- **Bucket Name:** `university-logos`
  - **Public:** ✅ Yes (check this box)
  - **File size limit:** 5 MB
  - **Allowed MIME types:** `image/png, image/jpeg, image/jpg, image/webp`

- **Bucket Name:** `program-brochures`
  - **Public:** ✅ Yes (check this box)
  - **File size limit:** 10 MB
  - **Allowed MIME types:** `application/pdf`

### Step 2: Upload Images

1. Click on the **`university-logos`** bucket
2. Click **"Upload file"**
3. Upload your university logo images:
   - `shoolini_logo.png`
   - `chandigarh_logo.png`
   - `amity_logo.png`
   - `manipal_logo.png`

4. Click on the **`program-brochures`** bucket
5. Upload your brochure PDFs

### Step 3: Get Public URLs

After uploading, click on each file and copy the **Public URL**. It will look like:
```
https://hndxhixadfhrgfrkshjy.supabase.co/storage/v1/object/public/university-logos/shoolini_logo.png
```

### Step 4: Update Database with URLs

Go to **SQL Editor** in Supabase and run this query to update your programs:

```sql
-- Update Shoolini University programs
UPDATE public.programs
SET logo_url = 'https://YOUR_PROJECT_ID.supabase.co/storage/v1/object/public/university-logos/shoolini_logo.png'
WHERE university_id = '11111111-1111-1111-1111-111111111111';

-- Update Chandigarh University programs
UPDATE public.programs
SET logo_url = 'https://YOUR_PROJECT_ID.supabase.co/storage/v1/object/public/university-logos/chandigarh_logo.png'
WHERE university_id = '22222222-2222-2222-2222-222222222222';

-- Update Amity University programs
UPDATE public.programs
SET logo_url = 'https://YOUR_PROJECT_ID.supabase.co/storage/v1/object/public/university-logos/amity_logo.png'
WHERE university_id = '33333333-3333-3333-3333-333333333333';

-- Update Manipal University programs
UPDATE public.programs
SET logo_url = 'https://YOUR_PROJECT_ID.supabase.co/storage/v1/object/public/university-logos/manipal_logo.png'
WHERE university_id = '44444444-4444-4444-4444-444444444444';
```

**Replace** `YOUR_PROJECT_ID` with your actual Supabase project ID from the URL.

### Step 5: Update Brochure URLs

```sql
-- Update brochure URLs (example)
UPDATE public.programs
SET brochure_url = 'https://YOUR_PROJECT_ID.supabase.co/storage/v1/object/public/program-brochures/shoolini-bba.pdf'
WHERE id = '11111111-aaaa-aaaa-aaaa-111111111111';
```

---

## 🧪 Testing

1. **Run your app:**
   ```bash
   flutter run
   ```

2. **Check the programs screen** - Images should now load from Supabase Storage

3. **Look for:**
   - ✅ Loading indicators while images are fetching
   - ✅ Images displaying correctly
   - ✅ Fallback icons if images fail to load

---

## 🔧 Alternative: Using Supabase Storage Paths

If you want to store just the file path (not the full URL) in the database, you can create a helper function:

```dart
// In lib/services/supabase_service.dart
static String getStorageUrl(String bucketName, String filePath) {
  if (!isConfigured) return '';
  return client!.storage.from(bucketName).getPublicUrl(filePath);
}
```

Then use it like:
```dart
final imageUrl = SupabaseService.getStorageUrl('university-logos', 'shoolini_logo.png');
```

---

## 📝 Database Schema Update (Optional)

If you want to separate bucket and path:

```sql
ALTER TABLE public.programs 
ADD COLUMN logo_bucket text,
ADD COLUMN logo_path text;
```

---

## ✅ What's Working Now

- ✅ **Network images** from Supabase Storage load correctly
- ✅ **Local assets** still work as fallback
- ✅ **Loading indicators** show while images are fetching
- ✅ **Error handling** with fallback icons
- ✅ **Auto-detection** of URL vs local asset paths

---

## 🎯 Next Steps

1. Create the storage buckets in Supabase
2. Upload your images
3. Update the database with the public URLs
4. Test the app!

Your images should now display correctly! 🎉

