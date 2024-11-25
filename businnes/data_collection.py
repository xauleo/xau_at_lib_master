import MetaTrader5 as mt5
import pandas as pd

def get_data_from_mt5(symbol, timeframe, num_bars):
    # Lê as credenciais do arquivo 'credentials'
    try:
        with open('credentials', 'r') as f:
            login, password = f.read().splitlines()
            login = int(login)
    except Exception as e:
        print(f"Erro ao ler as credenciais: {e}")
        return None

    server = 'Tradeview-Demo'  # Substitua pelo seu servidor, se necessário

    # Inicializa a conexão com o MT5 usando as credenciais
    if not mt5.initialize(login=login, password=password, server=server):
        print(f"Falha ao inicializar o MT5, erro: {mt5.last_error()}")
        return None
    print("Conexão com o MetaTrader 5 estabelecida com sucesso")

    # Seleciona o símbolo desejado
    if not mt5.symbol_select(symbol, True):
        print(f"Falha ao selecionar o símbolo {symbol}, erro: {mt5.last_error()}")
        mt5.shutdown()
        return None
    print(f"Símbolo {symbol} selecionado com sucesso")

    # Recupera os dados históricos
    rates = mt5.copy_rates_from_pos(symbol, timeframe, 0, num_bars)
    mt5.shutdown()

    if rates is None or len(rates) == 0:
        print("Falha ao recuperar os dados ou nenhum dado disponível.")
        return None
    print(f"Dados históricos recuperados com sucesso para {symbol}")

    # Cria o DataFrame
    data = pd.DataFrame(rates)
    data['time'] = pd.to_datetime(data['time'], unit='s')
    data.set_index('time', inplace=True)
    return data
