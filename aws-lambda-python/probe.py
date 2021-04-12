#!/usr/bin/env python

import requests
from bs4 import BeautifulSoup

if __name__ == '__main__':
    url = 'YOUR_APP_URL'
    # initiate session
    session = requests.session()
    # GET request on the main app URL
    response = session.get(url)
    # parse the response to fetch the SSO URL found in form tag
    soup = BeautifulSoup(response.content, 'lxml')
    sso_url = soup.find('form').get('action')
    # and parse the SAMLRequest and RelayState found in hidden input tags
    login_payload = {}
    for i in soup.find_all('input', type='hidden'):
        login_payload[i['name']] = i['value']
    creds = {
        'username': 'YOUR_USERNAME',
        'password': 'YOUR_PASSWORD'
    }
    # concatenate creds and the SAML payload
    login_payload.update(creds)
    # POST request to log in
    response = session.post(sso_url, data=login_payload)
    # the login should be successfull at this point and you can query any other URL