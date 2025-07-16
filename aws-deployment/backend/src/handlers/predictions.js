'use strict';

/*
 * Predictions Lambda – placeholder implementation that would forward
 * requests to an internal ML micro-service (ECS/Fargate) or directly to
 * Amazon Bedrock once integrated.
 */
const buildResponse = (statusCode, body) => ({
  statusCode,
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify(body)
});

exports.handler = async (event) => {
  console.log('Predictions event', JSON.stringify(event));

  const mlServiceUrl = process.env.ML_SERVICE_URL;
  // TODO: call ML service or Bedrock here

  return buildResponse(200, {
    message: 'Predictions endpoint stub',
    mlServiceUrl,
    method: event.requestContext?.http?.method,
    path: event.rawPath
  });
};