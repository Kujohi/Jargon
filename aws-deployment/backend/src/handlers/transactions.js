'use strict';

/*
 * Transactions Lambda – placeholder implementation.
 * Replace with real CRUD logic that talks to DynamoDB & RDS.
 */
const buildResponse = (statusCode, body) => ({
  statusCode,
  headers: {
    'Content-Type': 'application/json'
  },
  body: JSON.stringify(body)
});

exports.handler = async (event) => {
  console.log('Transactions event', JSON.stringify(event));

  // TODO: implement real logic
  return buildResponse(200, {
    message: 'Transactions endpoint stub',
    method: event.requestContext?.http?.method,
    path: event.rawPath
  });
};