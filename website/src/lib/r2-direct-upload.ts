/**
 * Chunked upload via R2 multipart API.
 * Client splits large files into ≤50MB chunks, each sent to the Worker
 * individually (well under the 100MB Worker body limit). R2 assembles them.
 */

export interface UploadSession {
  uploadId: string;
  key: string;
  filename: string;
}

// Start a multipart upload — returns session info the client uses for each chunk
export async function startMultipartUpload(
  bucket: R2Bucket,
  deviceModel: string,
  section: string,
): Promise<UploadSession> {
  const timestamp = Date.now();
  const sanitizedModel = (deviceModel || 'unknown')
    .replace(/[^a-zA-Z0-9 ]/g, '')
    .replace(/\s+/g, '_');
  const filename = `${timestamp}_${sanitizedModel}_${section}.mp4`;
  const key = `tester-videos/${filename}`;

  const upload = await bucket.createMultipartUpload(key, {
    httpMetadata: { contentType: 'video/mp4' },
  });

  return { uploadId: upload.uploadId, key, filename };
}

// Upload one chunk
export async function uploadPart(
  bucket: R2Bucket,
  key: string,
  uploadId: string,
  partNumber: number,
  chunk: Blob,
): Promise<{ partNumber: number; etag: string }> {
  const upload = bucket.resumeMultipartUpload(key, uploadId);
  const uploaded = await upload.uploadPart(partNumber, chunk);
  return { partNumber: uploaded.partNumber, etag: uploaded.etag };
}

// Complete the upload with all part ETags
export async function completeMultipartUpload(
  bucket: R2Bucket,
  key: string,
  uploadId: string,
  parts: { partNumber: number; etag: string }[],
): Promise<void> {
  const upload = bucket.resumeMultipartUpload(key, uploadId);
  await upload.complete(parts);
}

// Abort a failed upload
export async function abortMultipartUpload(
  bucket: R2Bucket,
  key: string,
  uploadId: string,
): Promise<void> {
  const upload = bucket.resumeMultipartUpload(key, uploadId);
  await upload.abort();
}
