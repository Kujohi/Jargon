'use strict';

/*
 * Webhook Lambda – placeholder implementation for real-time notifications or integrations.
 */
const buildResponse = (statusCode, body) => ({
  statusCode,
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify(body)
});

exports.handler = async (event) => {
  console.log('Webhook event', JSON.stringify(event));

  // TODO: verify signature & process payload

  return buildResponse(200, {
    message: 'Webhook endpoint stub',
    method: event.requestContext?.http?.method,
    path: event.rawPath
  });
};