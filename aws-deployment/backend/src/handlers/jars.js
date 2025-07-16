'use strict';

/*
 * Jars Lambda – placeholder implementation.
 */
const buildResponse = (statusCode, body) => ({
  statusCode,
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify(body)
});

exports.handler = async (event) => {
  console.log('Jars event', JSON.stringify(event));

  return buildResponse(200, {
    message: 'Jars endpoint stub',
    method: event.requestContext?.http?.method,
    path: event.rawPath
  });
};