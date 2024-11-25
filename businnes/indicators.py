import pandas_ta as ta
from arch import arch_model

def calculate_indicators(data):
    # Manter apenas as colunas originais
    data = data[['open', 'high', 'low', 'close', 'tick_volume']].copy()

    # Médias Móveis
    data.ta.sma(length=50, append=True, col_names=('SMA_50',))
    data.ta.sma(length=200, append=True, col_names=('SMA_200',))

    # RSI
    data.ta.rsi(length=14, append=True, col_names=('RSI_14',))

    # Bandas de Bollinger
    data.ta.bbands(length=20, std=2, append=True, col_names=('BBL', 'BBM', 'BBU', 'BBB', 'BBP'))

    # Momentum
    data.ta.mom(length=10, append=True, col_names=('Momentum',))

    # MACD
    data.ta.macd(append=True, col_names=('MACD', 'MACD_hist', 'MACD_signal'))

    # ATR
    data.ta.atr(length=14, append=True, col_names=('ATR',))

    # Ichimoku Cloud
    data.ta.ichimoku(append=True, prefix='ICH_')

    # Parabolic SAR
    data.ta.psar(append=True, prefix='PSAR_')

    # Fibonacci Retracement Levels
    data = calculate_fibonacci_levels(data, period=14)

    return data

def calculate_fibonacci_levels(data, period=14):
    recent_high = data['high'].rolling(window=period).max()
    recent_low = data['low'].rolling(window=period).min()

    diff = recent_high - recent_low
    data['Fibo_23.6'] = recent_high - diff * 0.236
    data['Fibo_38.2'] = recent_high - diff * 0.382
    data['Fibo_50.0'] = recent_high - diff * 0.5
    data['Fibo_61.8'] = recent_high - diff * 0.618
    data['Fibo_78.6'] = recent_high - diff * 0.786
    data['Fibo_100'] = recent_low
    data['Fibo_0'] = recent_high
    return data

def calculate_mean_reversion_indicator(data):
    # Z-Score para Reversão à Média
    data['z_score'] = (data['close'] - data['close'].rolling(window=20).mean()) / data['close'].rolling(window=20).std()
    return data

def calculate_garch_volatility(data):
    # Calcula os retornos em porcentagem e rescale os dados
    returns = data['close'].pct_change().dropna() * 100  # Multiplica por 100 para converter em porcentagem

    # Verifica a escala dos dados e rescale se necessário
    scale = returns.std()
    if scale < 1:
        returns = returns * 100  # Multiplica por 100 para aumentar a escala

    am = arch_model(returns, vol='Garch', p=1, q=1, rescale=False)
    res = am.fit(disp='off')
    data.loc[returns.index, 'GARCH_Volatility'] = res.conditional_volatility
    return data
