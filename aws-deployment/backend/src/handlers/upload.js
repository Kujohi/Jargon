'use strict';

/*
 * Upload Lambda – placeholder implementation.
 */
const buildResponse = (statusCode, body) => ({
  statusCode,
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify(body)
});

exports.handler = async (event) => {
  console.log('Upload event', JSON.stringify(event));

  // TODO: parse multipart/form-data and upload to S3 bucket

  return buildResponse(200, {
    message: 'Upload endpoint stub',
    method: event.requestContext?.http?.method,
    path: event.rawPath
  });
};