import logging

logger = logging.getLogger()
logger.setLevel("DEBUG")


def handler(event, context):
    logger.debug(f"Initiated instrumentation {event['Records'][0]['cf']}")
    request = event['Records'][0]['cf']['request']

    if request['uri'] == '/redirect-to-home':
        return {
            'status': '302',
            'statusDescription': 'Found',
            'headers': {
                'location': [{
                    'key': 'Location',
                    'value': 'https://cf-demo.rondi.ninja/'
                }]
            }
        }

    logger.debug("Request Headers: {}".format(request['headers']))

    return request
