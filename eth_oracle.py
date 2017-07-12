'''Methodology
Price is volume weighted average of last hour (1500-1600 EST) of five select exchanges
Exchange list is examined and updated at beginning of every month
Current List:
Bitfinex
GDAX
Bitstamp
Poloniex
Gemini


The oracle is currently updated on a one hour delay(1700 EST)
	-as testing continues this will go down
	-this allows multiple or manual attempts if API is non-responsive

Top and Bottom exchanges are dropped from calculation

Math:
Price = sum(volume * price) at each exchange / sum (volume at each exchange)
'''


#Bitfinex

import requests,json



def Bitfinex():
	url = "https://api.bitfinex.com/v1/pubticker/ETHUSD"
	response = requests.request("GET", url)
	price = response.json()['last_price'] 
	volume = response.json()['volume'] 
	print(price,volume)
	return [price,volume]

def GDAX():

	url = "https://api.gdax.com/products/ETH-USD/ticker"
	response = requests.request("GET", url)
	price = response.json()['price'] 
	volume = response.json()['volume'] 
	print(price,volume)
	return [price,volume]
	

def Kraken():
	url = "https://api.kraken.com/0/public/Ticker"
	blah = url + "?pair=" + 'XETHZUSD'
	response = requests.get(blah)
	price = response.json()['result']['XETHZUSD']['c'][0]
	volume = response.json()['result']['XETHZUSD']['v'][1]
	print(price,volume)
	return [price,volume]


def Poloniex():
	url = 'https://poloniex.com/public?command=returnTicker'
	url2 =  'https://poloniex.com/public?command=return24hVolume'
	response = requests.request("GET", url)
	response2 = requests.request("GET", url2)
	price = response.json()['USDT_ETH']['last'] 
	volume = response2.json()['USDT_ETH']['ETH']
	print(price,volume)
	return [price,volume]

def Gemini():
	url = "https://api.gemini.com/v1/pubticker/ethusd"
	response = requests.request("GET", url)
	price = response.json()['last'] 
	volume = response.json()['volume']["ETH"]
	print(price,volume)
	return [price,volume]

def CalculatePrice():
	bfx = Bitfinex()
	gdax = GDAX()
	krkn = Kraken()
	polx =Poloniex()
	gem = Gemini()
	exlist = (bfx,gdax,krkn,polx,gem)
	prices = sorted([bfx[0],gdax[0],krkn[0],polx[0],gem[0]])
	print(prices)
	print(prices[1:4])
	mid3 =prices[1:4]
	numerator = 0
	denominator = 0
	for i in exlist:
		if i[0] in mid3:
			numerator += (float(i[0])*float(i[1]))
			denominator += float(i[1])
			print (i,i[0],i[1])
	price = numerator / denominator
	print(price)
	return (price)


def DeploytoOracle(key_date,product,price):
	pass
CalculatePrice()
