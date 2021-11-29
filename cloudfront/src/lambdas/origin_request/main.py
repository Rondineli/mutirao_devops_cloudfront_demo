import logging

logger = logging.getLogger()
logger.setLevel("DEBUG")


def handler(event, context):
    logger.debug(f"Initiated instrumentation {event['Records'][0]['cf']}")
    request = event['Records'][0]['cf']['request']

    """
    request['headers'].update({
        'x-example-header': [{
            'key': 'X-Example-Header',
            'value': 'X-Header-Value'
        }]
    })
    """
    logger.debug("Request Headers: {}".format(request))
    return request
