# Supabase Integration for Kampus Collab App

## Overview

This integration adds Supabase storage for handling post image uploads in the Kampus Collab App.

## Files Created

### Configuration
- **`lib/config/supabase_config.dart`** - Supabase credentials and configuration

### Services
- **`lib/services/supabase_service.dart`** - Supabase client initialization
- **`lib/services/supabase_storage_service.dart`** - Image upload/delete operations

## Files Modified

- **`pubspec.yaml`** - Added Supabase dependencies
- **`lib/pages/post/create_post_page.dart`** - Integrated Supabase image upload
- **`lib/services/post_creation_service.dart`** - Support for image URLs

## How It Works

### 1. Image Upload Flow

```
User selects images → Upload to Supabase → Get URLs → Create post with URLs
```

### 2. Create Post Flow

1. User adds text and selects images in CreatePostPage
2. User clicks "Post" button
3. App navigates to feed and shows "Uploading images..." progress
4. Images are uploaded to Supabase storage one by one
5. App receives public URLs for uploaded images
6. Progress changes to "Creating your post..."
7. Post is created via API with image URLs in `mediaUrls` field
8. Success message shown and feed refreshed

### 3. Error Handling

- If image upload fails:
  - Shows error message
  - No post is created
  
- If post creation fails after successful upload:
  - Uploaded images are automatically deleted from Supabase
  - User sees error message
  - Can retry without duplicate images

## Usage Example

```dart
// In create_post_page.dart

// Upload images to Supabase
final uploadedUrls = await _storageService.uploadPostImages(_selectedImages);

// Create post with image URLs
await _postService.createPost(
  _postController.text,
  _visibility,
  imageUrls: uploadedUrls, // Pass URLs from Supabase
);
```

## API Integration

The post endpoint expects:
```json
{
  "content": "Post text",
  "contentType": "Image",
  "mediaUrls": [
    "https://xxx.supabase.co/storage/v1/object/public/post-images/post_123.jpg"
  ],
  "audience": "Public",
  "postType": "Original"
}
```

## Features

✅ Multiple image upload support (up to 4 images)  
✅ Automatic file validation (type and size)  
✅ Unique filename generation  
✅ Progress tracking during upload  
✅ Automatic cleanup on failure  
✅ Public URL generation  
✅ Error handling with user-friendly messages  

## Configuration Required

Before using, you MUST:

1. Create a Supabase project
2. Create a `post-images` storage bucket
3. Set up storage policies
4. Update `lib/config/supabase_config.dart` with your credentials
5. Initialize Supabase in `main.dart`

See **SUPABASE_SETUP.md** in project root for detailed instructions.

## File Size & Type Limits

- **Maximum file size**: 10MB (configurable)
- **Allowed types**: Images only (jpg, jpeg, png, gif, webp)
- **Maximum images per post**: 4

## Storage Bucket Structure

```
Kampus-kollab/
  └── MediaContents/
      ├── post_1699999999999_abc12345.jpg
      ├── post_1700000000000_def67890.png
      └── ...
```

Storage path format: `MediaContents/post_{timestamp}_{randomId}.{ext}`

## Security

- Only authenticated users can upload
- Public read access for all images
- Users can delete their own uploads
- File type and size validation
- Unique filenames prevent collisions

## Future Enhancements

- [ ] Image compression before upload
- [ ] Image resizing/optimization
- [ ] CDN integration
- [ ] Video upload support
- [ ] Progress percentage during upload
- [ ] Drag & drop image upload
- [ ] Image editing tools

## Troubleshooting

### "Supabase not initialized"
- Check that `SupabaseService.initialize()` is called in `main.dart`
- Verify credentials in `supabase_config.dart`

### "Failed to upload image"
- Check Supabase dashboard for storage bucket
- Verify bucket name matches configuration
- Check storage policies

### API returns error with image URLs
- Verify your backend expects `mediaUrls` array
- Check that URLs are publicly accessible
- Ensure backend accepts full Supabase URLs

## Dependencies

```yaml
supabase_flutter: ^2.5.6  # Supabase client
path: ^1.9.0              # File path utilities
mime: ^1.0.5              # MIME type detection
```

## Support

For issues or questions:
- Review SUPABASE_SETUP.md
- Check Supabase documentation
- Verify console logs for detailed errors

