
from OpenSSL import crypto, SSL
import time

def create_self_signed_cert(cert_path, key_path, cert_subject):
    # Create a key pair
    k = crypto.PKey()
    k.generate_key(crypto.TYPE_RSA, 2048)

    # Create a self-signed certificate
    cert = crypto.X509()
    cert.get_subject().CN = cert_subject
    cert.set_serial_number(int(time.time()))
    cert.gmtime_adj_notBefore(0)
    cert.gmtime_adj_notAfter(10*365*24*60*60) # Expires in 10 years
    cert.set_issuer(cert.get_subject())
    cert.set_pubkey(k)
    cert.sign(k, 'sha256')

    # Write certificate and private key to files in PEM format
    with open(cert_path, "w") as f:
        f.write(crypto.dump_certificate(crypto.FILETYPE_PEM, cert).decode('utf-8'))
    with open(key_path, "w") as f:
        f.write(crypto.dump_privatekey(crypto.FILETYPE_PEM, k).decode('utf-8'))

# Define paths for certificate and key
cert_path = 'cert_path/server.pem'
key_path = 'key_path/server.pem'

# Generate self-signed certificate
create_self_signed_cert(cert_path, key_path, "localhost")
