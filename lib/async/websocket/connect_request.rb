# frozen_string_literals: true
#
# Copyright, 2015, by Samuel G. D. Williams. <http://www.codeotaku.com>
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

require 'async/http/middleware'
require 'async/http/request'
require 'protocol/http/headers'

module Async
	module WebSocket
		# This is required for HTTP/1.x to upgrade the connection to the WebSocket protocol.
		# See https://tools.ietf.org/html/rfc8441 for more details.
		class ConnectRequest < HTTP::Request
			def initialize(request, protocols: [], version: 13)
				request.body ||= Async::HTTP::Body::Writable.new
				
				headers = []
				
				headers << ['sec-websocket-version', version]
				
				if protocols.any?
					headers << ['sec-websocket-protocol', protocols.join(',')]
				end
				
				merged_headers = ::Protocol::HTTP::Headers::Merged.new(request.headers, headers)
				
				super(request.scheme, request.authority, HTTP::CONNECT, request.path, nil, merged_headers, request.body, PROTOCOL)
			end
		end
	end
end