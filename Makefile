.PHONY: make-dev-cert

dev-cert:
	mkdir -p ./dev/tmp/certs
	mkcert -key-file ./dev/tmp/certs/key.pem -cert-file ./dev/tmp/certs/cert.pem rosterbater.test
