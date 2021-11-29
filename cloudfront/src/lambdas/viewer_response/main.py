import logging

logger = logging.getLogger()
logger.setLevel("DEBUG")


def handler(event, context):
    logger.debug(f"Initiated instrumentation {event['Records'][0]['cf']}")
    response = event['Records'][0]['cf']['response']

    logger.debug("Response Headers: {}".format(response['headers']))

    return response
