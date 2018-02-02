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

require 'websocket/driver'
require 'json'

module Async
	module WebSocket
		# This is a basic synchronous websocket client:
		class Client
			EVENTS = [:open, :message, :close]
			
			def initialize(socket, url: "ws://.")
				@socket = socket
				@url = url
				
				@driver = ::WebSocket::Driver.client(self)
				
				@queue = []
				
				@driver.on(:error) do |error|
					raise error
				end
				
				EVENTS.each do |event|
					@driver.on(event) do |data|
						@queue.push(data)
					end
				end
				
				@driver.start
			end
			
			attr :driver
			attr :url
			
			def next_event
				while @queue.empty?
					data = @socket.read(1024)
					
					if data and !data.empty?
						@driver.parse(data)
					else
						return nil
					end
				end
				
				@queue.shift
			rescue EOFError
				return nil
			end
			
			def next_message
				while event = next_event
					if event.is_a? ::WebSocket::Driver::MessageEvent
						return JSON.parse(event.data)
					elsif event.is_a? ::WebSocket::Driver::CloseEvent
						return nil
					end
				end
			end
			
			def write(data)
				@socket.write(data)
			end
			
			def close
				@driver.close
			end
		end
	end
end