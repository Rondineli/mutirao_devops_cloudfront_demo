import unittest
import copy

from viewer_response.main import handler
from aws_lambda_context import LambdaContext


class TestOriginRequest(unittest.TestCase):
    def setUp(self):
        self.context = LambdaContext()
        self.context.function_name = 'function_name'
        self.context.function_version = 'function_version'
        self.context.invoked_function_arn = 'invoked_function_arn'
        self.context.memory_limit_in_mb = 'memory_limit_in_mb'
        self.context.aws_request_id = 'aws_request_id'
        self.context.log_group_name = 'log_group_name'
        self.context.log_stream_name = 'log_stream_name'
        self.event = {
            'Records': [
                {
                    'cf': {
                        'response': {
                            'headers': {
                                'cloudfront-viewer-country': [
                                    {
                                        'key': 'Cloudfront-Viewer-Country',
                                        'value': 'IE'
                                    }
                                ],
                                'x-locale': [
                                    {
                                        'key': 'x-locale',
                                        'value': 'en-IE'
                                    }
                                ],
                                'any-other-header': [
                                    {
                                        'key': 'any-other-header',
                                        'value': 'any-other-header'
                                    }
                                ]
                            }
                        },
                        'request': {
                            'headers': {
                                'accept-language': [
                                    {
                                        'key': 'Accept-Language',
                                        'value': 'en-IE,en-UK'
                                    }
                                ],
                                'cloudfront-viewer-country': [
                                    {
                                        'key': 'Cloudfront-Viewer-Country',
                                        'value': 'IE'
                                    }
                                ],
                                'x-user-agent-viewer': [
                                    {
                                        'key': 'X-User-Agent-Viewer',
                                        'value': 'myDummyUseragent'
                                    }
                                ]
                            }
                        }
                    }
                }
            ]
        }

    def test_origin_request_with_locale(self):
        response = handler(self.event, self.context)
        assert response['headers']['x-locale'] == [{'key': 'x-locale', 'value': 'en-IE'}] # noqa
        assert response['headers']['cloudfront-viewer-country'] == [{'key': 'Cloudfront-Viewer-Country', 'value': 'IE'}] # noqa
        assert len(list(response['headers'].keys())) == 3