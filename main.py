# main.py

import streamlit as st
import MetaTrader5 as mt5
import pandas as pd
import logging
import os
from businnes.data_collection import get_data_from_mt5
from businnes.indicators import calculate_indicators, calculate_mean_reversion_indicator, calculate_garch_volatility
from businnes.macro_data import initialize_fred, get_macro_data
from businnes.sentiment_data import get_sentiment_data
from businnes.llm_analysis import initialize_openai, generate_analysis
from businnes.news import get_news
from view.visualization import display_plots
from view.report_generator import display_analysis
from reportlab.lib.pagesizes import letter
from datetime import datetime
from reportlab.pdfgen import canvas
from dotenv import load_dotenv
import io

# Carregar as chaves de API
load_dotenv()

# Configurar o logging
logging.basicConfig(level=logging.INFO)

# Lista para armazenar análises anteriores
analysis_history = []

def run_analysis():

    symbol = 'XAUUSD'
    timeframe = mt5.TIMEFRAME_H4  # Ajuste conforme necessário
    num_bars = 1000

    # Chaves de API (use variáveis de ambiente ou arquivos de configuração)
    openai_api_key = os.environ.get('OPENAI_API_KEY')  
    fred_api_key = os.environ.get('FRED_API_KEY')      

    # Verifica se as chaves de API foram fornecidas
    if not openai_api_key or not fred_api_key:
        st.error("As chaves de API do OpenAI ou do FRED não foram fornecidas.")
        logging.error("Chaves de API faltando.")
        return

    # Inicializa a API do OpenAI
    initialize_openai(openai_api_key)
    logging.info("API do OpenAI inicializada.")

    # Inicializa a API do FRED
    initialize_fred(fred_api_key)
    logging.info("API do FRED inicializada.")

    # Inicializa o MetaTrader 5
    if not mt5.initialize():
        st.error("Falha ao inicializar o MetaTrader 5.")
        logging.error(f"Falha ao inicializar o MT5: {mt5.last_error()}")
        return
    logging.info("Conexão com o MetaTrader 5 estabelecida.")

    try:
        # Exibe mensagem de status
        st.info("Gerando análise...")
        logging.info("Iniciando coleta de dados do MT5.")

        # Coleta de dados do MT5 para outros módulos
        data = get_data_from_mt5(symbol, timeframe, num_bars)
        if data is None or data.empty:
            st.error("Falha ao obter dados do MT5 ou dados vazios.")
            logging.error("Dados do MT5 são None ou vazios.")
            return
        logging.info("Dados do MT5 coletados com sucesso.")

        # Resetar o índice do DataFrame e manter o índice original como coluna
        data.reset_index(inplace=True)
        logging.info("Índice do DataFrame resetado.")

        # Verificar se a coluna 'time' está presente
        if 'time' not in data.columns:
            st.error("A coluna 'time' não está presente nos dados.")
            logging.error("Coluna 'time' ausente no DataFrame.")
            return

        # Selecionar apenas as colunas necessárias
        data = data[['time', 'open', 'high', 'low', 'close', 'tick_volume']].copy()
        logging.info("Colunas selecionadas: time, open, high, low, close, tick_volume.")

        # Converter a coluna 'time' para o tipo datetime, se ainda não estiver
        if not pd.api.types.is_datetime64_any_dtype(data['time']):
            data['time'] = pd.to_datetime(data['time'])
            logging.info("Coluna 'time' convertida para datetime.")

        # Calcula indicadores técnicos
        data = calculate_indicators(data)
        logging.info("Indicadores técnicos calculados.")
        data = calculate_mean_reversion_indicator(data)
        logging.info("Indicador de reversão à média calculado.")
        data = calculate_garch_volatility(data)
        logging.info("Volatilidade GARCH calculada.")

        # Coleta de dados macroeconômicos
        macro_data = get_macro_data()
        if macro_data is None:
            macro_data = {}
            logging.warning("Dados macroeconômicos são None.")
        else:
            logging.info("Dados macroeconômicos coletados.")

        # Coleta de dados de sentimento
        sentiment_data = get_sentiment_data()
        if sentiment_data is None:
            sentiment_data = {}
            logging.warning("Dados de sentimento são None.")
        else:
            logging.info("Dados de sentimento coletados.")

        # Obter as notícias
        news_articles = get_news()
        if news_articles is None:
            news_articles = []
            logging.warning("Nenhuma notícia obtida.")
        else:
            logging.info(f"{len(news_articles)} notícias obtidas.")

        # Gera análise usando LLM
        analysis = generate_analysis(data, macro_data, sentiment_data, news_articles)
        if analysis:
            st.success("Análise concluída.")
            logging.info("Análise gerada e exibida.")
            display_analysis(analysis)
            analysis_history.append(analysis)
        else:
            st.error("Falha ao gerar a análise da IA.")
            logging.error("Falha ao gerar a análise com o LLM.")
            return

        # Interface Streamlit
        st.title("Análise de Mercado XAU/USD")

        # Seção para seleção de parâmetros
        st.sidebar.header("Parâmetros do Gráfico")

        # Obter as datas mínima e máxima da coluna 'time'
        min_date = data['time'].min().date()
        max_date = data['time'].max().date()
        logging.info(f"Data mínima: {min_date}, Data máxima: {max_date}")

        # Solicitar ao usuário para selecionar as datas
        start_date = st.sidebar.date_input(
            "Data Inicial",
            value=min_date,
            min_value=min_date,
            max_value=max_date
        )
        end_date = st.sidebar.date_input(
            "Data Final",
            value=max_date,
            min_value=min_date,
            max_value=max_date
        )

        # Garantir que start_date e end_date sejam do tipo datetime.date
        if isinstance(start_date, datetime):
            start_date = start_date.date()
            logging.info(f"start_date convertido para date: {start_date}")
        if isinstance(end_date, datetime):
            end_date = end_date.date()
            logging.info(f"end_date convertido para date: {end_date}")

        # Filtrar dados com base nas datas selecionadas
        filtered_data = data[
            (data['time'].dt.date >= start_date) &
            (data['time'].dt.date <= end_date)
        ]
        logging.info(f"Dados filtrados: {len(filtered_data)} registros.")

        # Verificar se há dados filtrados
        if filtered_data.empty:
            st.warning("Nenhum dado encontrado para o intervalo de datas selecionado.")
            logging.warning("Nenhum dado encontrado para o intervalo de datas selecionado.")
        else:
            # Opcional: Mostrar as primeiras linhas do filtered_data para depuração
            st.write(filtered_data.head())
            logging.info("Exibindo os primeiros registros dos dados filtrados.")

            # Exibe os gráficos com os dados filtrados
            display_plots(filtered_data)
            logging.info("Gráficos exibidos.")

    except Exception as e:
        st.error(f"Ocorreu um erro: {e}")
        logging.exception("Exceção capturada durante a execução da análise.")
    finally:
        # Encerra o MetaTrader 5
        mt5.shutdown()
        logging.info("Conexão com o MetaTrader 5 encerrada.")
        
# Interface Streamlit
st.title("Análise de Mercado XAU/USD")

# Obter a data e hora atuais
current_datetime = datetime.now().strftime("%d/%m/%Y %H:%M:%S")

# Exibir a data e hora próximos ao título
st.subheader(f"Data e Hora Atual: {current_datetime}")

# Botão para gerar a análise
if st.button("Gerar Análise"):
    run_analysis()

# Função para gerar o PDF usando reportlab
def generate_pdf(analysis_text):
    buffer = io.BytesIO()
    c = canvas.Canvas(buffer, pagesize=letter)
    text_object = c.beginText(50, 750)
    text_object.setFont("Helvetica", 12)

    # Quebrar o texto em linhas
    lines = analysis_text.split('\n')
    for line in lines:
        text_object.textLine(line)
    c.drawText(text_object)
    c.showPage()
    c.save()
    pdf_data = buffer.getvalue()
    buffer.close()
    return pdf_data
