import { Request, Response, NextFunction } from 'express';
import multer from 'multer';
import cloudinary from '../config/cloudinary';

// Configure Multer in-memory storage
const storage = multer.memoryStorage();

/**
 * Multer middleware with explicit 5MB file size limit and error handler.
 */
export function uploadMiddleware(req: Request, res: Response, next: NextFunction) {
  const upload = multer({
    storage,
    limits: {
      fileSize: 5 * 1024 * 1024, // 5MB Limit
    },
  }).single('image');

  upload(req, res, (err: any) => {
    if (err instanceof multer.MulterError) {
      if (err.code === 'LIMIT_FILE_SIZE') {
        return res.status(400).json({ message: 'File size exceeds 5MB limit.' });
      }
      return res.status(400).json({ message: `Upload error: ${err.message}` });
    } else if (err) {
      return res.status(400).json({ message: err.message || 'File upload failed' });
    }
    next();
  });
}

const ALLOWED_MIMETYPES = ['image/jpeg', 'image/png', 'image/webp', 'image/jpg'];
const ALLOWED_FOLDERS = ['avatars', 'products', 'banners'];

/**
 * POST /api/admin/upload/image
 * Receives image file in memory, validates mimetype and size, uploads to Cloudinary.
 */
export async function uploadImage(req: Request, res: Response) {
  try {
    const file = req.file;

    if (!file) {
      return res.status(400).json({ message: 'No image file provided' });
    }

    // 1. Validate Mimetype
    if (!ALLOWED_MIMETYPES.includes(file.mimetype)) {
      return res.status(400).json({
        message: 'Invalid file type. Only JPEG, PNG, and WebP images are allowed.',
      });
    }

    // 2. Validate File Size (double-check)
    if (file.size > 5 * 1024 * 1024) {
      return res.status(400).json({
        message: 'File size exceeds 5MB limit.',
      });
    }

    // 3. Validate Folder
    const requestedFolder = (req.body.folder || 'products').toString().toLowerCase().trim();
    const folder = ALLOWED_FOLDERS.includes(requestedFolder) ? requestedFolder : 'products';

    // 4. Upload to Cloudinary via Data URI
    const cloudinaryFolder = `nextlook/${folder}`;
    const dataUri = `data:${file.mimetype};base64,${file.buffer.toString('base64')}`;

    const uploadResult = await cloudinary.uploader.upload(dataUri, {
      folder: cloudinaryFolder,
      resource_type: 'image',
    });

    return res.status(200).json({
      url: uploadResult.secure_url,
      publicId: uploadResult.public_id,
    });
  } catch (error: any) {
    console.error('Error in uploadImage controller:', error);
    return res.status(500).json({
      message: error.message || 'Failed to upload image to Cloudinary',
    });
  }
}

/**
 * DELETE /api/admin/upload/image
 * Body: { publicId }
 * Removes an image from Cloudinary.
 */
export async function deleteImage(req: Request, res: Response) {
  try {
    const { publicId } = req.body;

    if (!publicId || typeof publicId !== 'string') {
      return res.status(400).json({ message: 'publicId is required' });
    }

    const result = await cloudinary.uploader.destroy(publicId);

    return res.status(200).json({
      message: 'Image deleted successfully',
      result,
    });
  } catch (error: any) {
    console.error('Error in deleteImage controller:', error);
    return res.status(500).json({
      message: error.message || 'Failed to delete image from Cloudinary',
    });
  }
}

/**
 * Multer middleware for multiple files (up to 10 images, 5MB each).
 */
export function uploadMultipleMiddleware(req: Request, res: Response, next: NextFunction) {
  const upload = multer({
    storage,
    limits: {
      fileSize: 5 * 1024 * 1024,
    },
  }).array('images', 10);

  upload(req, res, (err: any) => {
    if (err instanceof multer.MulterError) {
      if (err.code === 'LIMIT_FILE_SIZE') {
        return res.status(400).json({ message: 'One or more files exceed the 5MB limit.' });
      }
      return res.status(400).json({ message: `Upload error: ${err.message}` });
    } else if (err) {
      return res.status(400).json({ message: err.message || 'File upload failed' });
    }
    next();
  });
}

/**
 * POST /api/admin/upload/images
 * Upload multiple images concurrently to Cloudinary.
 */
export async function uploadMultipleImages(req: Request, res: Response) {
  try {
    const files = req.files as Express.Multer.File[];
    if (!files || files.length === 0) {
      return res.status(400).json({ message: 'No image files provided' });
    }

    const requestedFolder = (req.body.folder || 'products').toString().toLowerCase().trim();
    const folder = ALLOWED_FOLDERS.includes(requestedFolder) ? requestedFolder : 'products';
    const cloudinaryFolder = `nextlook/${folder}`;

    for (const file of files) {
      if (!ALLOWED_MIMETYPES.includes(file.mimetype)) {
        return res.status(400).json({
          message: `Invalid file type for ${file.originalname}. Only JPEG, PNG, and WebP images are allowed.`,
        });
      }
      if (file.size > 5 * 1024 * 1024) {
        return res.status(400).json({
          message: `File size exceeds 5MB limit for ${file.originalname}.`,
        });
      }
    }

    const uploadPromises = files.map(async (file) => {
      const dataUri = `data:${file.mimetype};base64,${file.buffer.toString('base64')}`;
      const uploadResult = await cloudinary.uploader.upload(dataUri, {
        folder: cloudinaryFolder,
        resource_type: 'image',
      });
      return {
        url: uploadResult.secure_url,
        publicId: uploadResult.public_id,
      };
    });

    const results = await Promise.all(uploadPromises);
    return res.status(200).json({ images: results });
  } catch (error: any) {
    console.error('Error in uploadMultipleImages controller:', error);
    return res.status(500).json({
      message: error.message || 'Failed to upload images to Cloudinary',
    });
  }
}
