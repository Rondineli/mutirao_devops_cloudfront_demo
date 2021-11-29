import logging

logger = logging.getLogger()
logger.setLevel("DEBUG")


def handler(event, context):
    logger.debug(f"Initiated instrumentation {event['Records'][0]['cf']}")
    response = event['Records'][0]['cf']['response']
    """
    response['headers'].update({
        'x-example-§-header': [{
            'key': 'X-Example-Response-Header',
            'value': 'X-Header-Response-Value'
        }]
    })
    """
    logger.debug("Response Headers: {}".format(response['headers']))

    return response