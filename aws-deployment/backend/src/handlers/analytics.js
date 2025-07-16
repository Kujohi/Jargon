'use strict';

/*
 * Analytics Lambda – placeholder implementation.
 */
const buildResponse = (statusCode, body) => ({
  statusCode,
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify(body)
});

exports.handler = async (event) => {
  console.log('Analytics event', JSON.stringify(event));

  return buildResponse(200, {
    message: 'Analytics endpoint stub',
    method: event.requestContext?.http?.method,
    path: event.rawPath
  });
};