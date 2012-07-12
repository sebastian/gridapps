import socket, ssl, json, struct, binascii

# device token returned when the iPhone application
# registers to receive alerts

#deviceToken = 'XXXXXXXX XXXXXXXX XXXXXXXX XXXXXXXX XXXXXXXX XXXXXXXX XXXXXXXX XXXXXXXX' 
deviceToken = "ddcff3dbf0eb69aC12k1eZ\xabj\x04\x1aJ\xc4\x86\xa0\x15r\xdc\xa1\xcc\xb2\xe1\x1e"

thePayLoad = {
     'aps': {
          'alert':'Make tea not war!',
          }
     }

# Certificate issued by apple and converted to .pem format with openSSL
theCertfile = 'ChrisElsmore.pem'
# 

#theHost = ( 'gateway.sandbox.push.apple.com', 2195 )

# 
data = json.dumps( thePayLoad )

# Clear out spaces in the device token and convert to hex
deviceToken = deviceToken.replace(' ','')
byteToken = binascii.unhexlify(deviceToken)
#byteToken = bytes.fromhex( deviceToken )

theFormat = '!BH32sH%ds' % len(data)
theNotification = struct.pack( theFormat, 0, 32, byteToken, len(data), data )

# Create our connection using the certfile saved locally
ssl_sock = ssl.wrap_socket( socket.socket( socket.AF_INET, socket.SOCK_STREAM ), certfile = theCertfile )
#ssl_sock.connect( theHost )

# Write out our data
#ssl_sock.write( theNotification )

# Close the connection -- apple would prefer that we keep
# a connection open and push data as needed.
#ssl_sock.close()
