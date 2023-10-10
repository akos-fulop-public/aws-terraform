# Example serverless application
## Thumbnail creator

1. Endpoint to upload images to
2. Store in S3
3. Trigger Lamdba
4. Lambda transforms the image
5. Store thumbdail in s3
6. Delete original file from s3
7. Create temporary public URL
8. Send the URL to user
9. Delete thumbdail in 5 minutes
