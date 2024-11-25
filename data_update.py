# data_update.py

import MetaTrader5 as mt5
import pandas as pd

def update_csv_from_mt5(symbol, timeframe, num_bars, csv_file):
    # Inicializa o MT5
    if not mt5.initialize():
        print(f"Falha ao inicializar o MT5, erro: {mt5.last_error()}")
        return False

    # Seleciona o símbolo
    if not mt5.symbol_select(symbol, True):
        print(f"Falha ao selecionar o símbolo {symbol}, erro: {mt5.last_error()}")
        mt5.shutdown()
        return False

    # Recupera os dados históricos
    rates = mt5.copy_rates_from_pos(symbol, timeframe, 0, num_bars)
    mt5.shutdown()

    if rates is None or len(rates) == 0:
        print("Falha ao recuperar os dados ou nenhum dado disponível.")
        return False

    # Cria o DataFrame
    data = pd.DataFrame(rates)
    data['Date'] = pd.to_datetime(data['time'], unit='s')
    data.rename(columns={'open': 'Open', 'high': 'High', 'low': 'Low', 'close': 'Close'}, inplace=True)
    data = data[['Date', 'Open', 'High', 'Low', 'Close']]

    # Calcula as mudanças em Pips e porcentagem
    data['Change(Pips)'] = data['Close'].diff() * 10000  # Multiplica por 10000 para converter em pips
    data['Change(%)'] = data['Close'].pct_change() * 100

    # Ordena os dados pela data
    data.sort_values('Date', inplace=True)

    # Salva os dados no CSV
    data.to_csv(csv_file, index=False)

    print(f"Dados do MT5 salvos em {csv_file}")
    return True
