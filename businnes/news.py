# news.py

import requests
from datetime import datetime, timedelta

def get_news():
    # Sua chave de API da NewsAPI
    API_KEY = '5f92e858aa0c47babc2545c39b16ee85'  # Substitua pela sua chave de API
    
    # Endpoint da API
    url = 'https://newsapi.org/v2/everything'
    
    # Calcula as datas de início e fim (últimas 48 horas)
    data_atual = datetime.utcnow()
    data_inicio = data_atual - timedelta(days=2)  # Últimas 48 horas
    
    # Parâmetros da requisição
    parametros = {
        'q': (
            '("US dollar" OR "USD" OR "gold" OR "Federal Reserve" OR "Fed" OR '
            '"monetary policy" OR "interest rate" OR "interest rates" OR "central bank" OR "war" OR "World War") '
            'AND ("market" OR "economy" OR "investment" OR "inflation" OR "exchange rate" OR "war" OR "world war")'
        ),
        'language': 'en',
        'sortBy': 'relevancy',
        'from': data_inicio.isoformat("T") + "Z",
        'to': data_atual.isoformat("T") + "Z",
        'pageSize': 100,
        'apiKey': API_KEY,
        'domains': (
            'wsj.com, '
            'bloomberg.com, '
            'reuters.com, '
            'cnbc.com, '
            'financialtimes.com, '
            'marketwatch.com, '
            'investing.com, '
            'finance.yahoo.com, '
            'forbes.com, '
            'businessinsider.com'
        )
    }
    
    # Faz a requisição à API
    try:
        resposta = requests.get(url, params=parametros)
        resposta.raise_for_status()
        dados = resposta.json()
    
        if dados['status'] == 'ok':
            artigos = dados['articles']
            return artigos  # Retorna a lista de artigos
        else:
            print("Erro na resposta da API:", dados.get('message', 'Erro desconhecido'))
            return None
    except requests.exceptions.HTTPError as errh:
        print("Erro HTTP:", errh)
    except requests.exceptions.ConnectionError as errc:
        print("Erro de Conexão:", errc)
    except requests.exceptions.Timeout as errt:
        print("Timeout:", errt)
    except requests.exceptions.RequestException as err:
        print("Erro na Requisição:", err)
    
    return None
