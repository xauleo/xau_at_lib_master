# macro_data.py

import pandas as pd
import yfinance as yf
import os 
from fredapi import Fred

def initialize_fred(api_key):
    global fred
    fred = Fred(api_key=api_key)

def get_real_interest_rates():
    try:
        # Obter a taxa de juros nominal (Federal Funds Rate)
        nominal_rate = fred.get_series('FEDFUNDS').iloc[-1]
        # Obter a expectativa de inflação de 10 anos (T10YIE)
        inflation_expectation = fred.get_series('T10YIE').iloc[-1]
        # Calcular a taxa de juros real
        real_interest_rate = nominal_rate - inflation_expectation
        return real_interest_rate
    except Exception as e:
        print(f"Erro ao calcular a taxa de juros real: {e}")
        return None

def get_us_dollar_index():
    try:
        dxy_data = yf.download('DX-Y.NYB', period='1d')
        dxy = dxy_data['Close'].iloc[-1]
        return dxy
    except Exception as e:
        print(f"Erro ao recuperar dados do DXY: {e}")
        return None

def get_inflation_cpi():
    try:
        # Obter a série do CPI
        cpi_series = fred.get_series('CPIAUCSL')
        # Obter o último valor do CPI
        cpi = cpi_series.iloc[-1]
        # Obter o valor do CPI de 12 meses atrás
        cpi_prev = cpi_series.iloc[-13]
        # Calcular a variação percentual anual
        cpi_pct_change = ((cpi - cpi_prev) / cpi_prev) * 100
        return cpi_pct_change
    except Exception as e:
        print(f"Erro ao recuperar dados do CPI: {e}")
        return None

def get_ppi():
    try:
        # Obter a série do PPI
        ppi_series = fred.get_series('PPIACO')
        # Obter o último valor do PPI
        ppi = ppi_series.iloc[-1]
        # Obter o valor do PPI de 12 meses atrás
        ppi_prev = ppi_series.iloc[-13]
        # Calcular a variação percentual anual
        ppi_pct_change = ((ppi - ppi_prev) / ppi_prev) * 100
        return ppi_pct_change
    except Exception as e:
        print(f"Erro ao recuperar dados do PPI: {e}")
        return None

def get_initial_jobless_claims():
    try:
        # Obter o último valor dos Pedidos Iniciais de Seguro-Desemprego
        initial_claims = fred.get_series('ICSA').iloc[-1]
        return initial_claims
    except Exception as e:
        print(f"Erro ao recuperar dados do Initial Jobless Claims: {e}")
        return None

def get_jolts_job_openings():
    try:
        # Obter o último valor do JOLTS Job Openings
        jolts_openings = fred.get_series('JTSJOL').iloc[-1]
        return jolts_openings
    except Exception as e:
        print(f"Erro ao recuperar dados do JOLTS: {e}")
        return None

def get_fomc_statements():
    # Retorna o link para a página oficial dos comunicados do FOMC
    fomc_url = 'https://www.federalreserve.gov/monetarypolicy/fomccalendars.htm'
    return fomc_url

def get_gdp():
    try:
        # Obter o último valor do PIB real dos EUA (trimestral)
        gdp = fred.get_series('GDPC1').iloc[-1]
        return gdp
    except Exception as e:
        print(f"Erro ao recuperar dados do PIB: {e}")
        return None

def get_unemployment_rate():
    try:
        # Obter o último valor da taxa de desemprego (mensal)
        unemployment_rate = fred.get_series('UNRATE').iloc[-1]
        return unemployment_rate
    except Exception as e:
        print(f"Erro ao recuperar dados da taxa de desemprego: {e}")
        return None

def get_nonfarm_payroll():
    try:
        # Obter o último valor da folha de pagamento não-agrícola (mensal)
        nonfarm_payroll = fred.get_series('PAYEMS').iloc[-1]
        return nonfarm_payroll
    except Exception as e:
        print(f"Erro ao recuperar dados do Non-Farm Payroll: {e}")
        return None

def get_macro_data():
    macro_data = {
        'real_interest_rates': get_real_interest_rates(),
        'dxy': get_us_dollar_index(),
        'cpi_pct_change': get_inflation_cpi(),
        'ppi_pct_change': get_ppi(),
        'gdp': get_gdp(),
        'unemployment_rate': get_unemployment_rate(),
        'nonfarm_payroll': get_nonfarm_payroll(),
        'initial_jobless_claims': get_initial_jobless_claims(),
        'jolts_job_openings': get_jolts_job_openings(),
        'fomc': get_fomc_statements()
    }
    return macro_data

if __name__ == "__main__":
    # Substitua 'SUA_CHAVE_DE_API_DO_FRED' pela sua chave de API do FRED
    initialize_fred('b5f548f0447af52b9ff964705fc79dec')
    macro_data = get_macro_data()
    for key, value in macro_data.items():
        print(f"{key}: {value}")
