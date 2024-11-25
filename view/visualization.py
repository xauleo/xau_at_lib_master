# visualization.py

import streamlit as st
import plotly.graph_objects as go
from plotly.subplots import make_subplots

def display_plots(data):
    # Cria subplots: 3 linhas, 1 coluna
    fig = make_subplots(rows=3, cols=1, shared_xaxes=True,
                        vertical_spacing=0.02, subplot_titles=('Preço com Indicadores', 'RSI', 'MACD'))

    # Gráfico Candlestick
    fig.add_trace(go.Candlestick(
        x=data.index,
        open=data['open'],
        high=data['high'],
        low=data['low'],
        close=data['close'],
        name='Preço',
        increasing_line_color='green',
        decreasing_line_color='red',
        showlegend=False
    ), row=1, col=1)

    # Médias Móveis
    fig.add_trace(go.Scatter(
        x=data.index,
        y=data['SMA_50'],
        line=dict(color='blue', width=1),
        name='SMA 50'
    ), row=1, col=1)

    fig.add_trace(go.Scatter(
        x=data.index,
        y=data['SMA_200'],
        line=dict(color='purple', width=1),
        name='SMA 200'
    ), row=1, col=1)

    # Ichimoku Cloud
    fig.add_trace(go.Scatter(
        x=data.index,
        y=data['ICH_SSA'],
        line=dict(color='rgba(255, 0, 0, 0.5)', width=1),
        name='Senkou Span A',
        fill='tonexty',
        fillcolor='rgba(255, 0, 0, 0.1)'
    ), row=1, col=1)

    fig.add_trace(go.Scatter(
        x=data.index,
        y=data['ICH_SSB'],
        line=dict(color='rgba(0, 255, 0, 0.5)', width=1),
        name='Senkou Span B'
    ), row=1, col=1)

    # Parabolic SAR
    fig.add_trace(go.Scatter(
        x=data.index,
        y=data['PSARl_0.02_0.2'],
        mode='markers',
        marker=dict(size=4, color='black', symbol='triangle-up'),
        name='Parabolic SAR'
    ), row=1, col=1)

    # Níveis de Fibonacci (usando o último período)
    # Pegamos o último conjunto de níveis de Fibonacci
    last_fibo = data[['Fibo_0', 'Fibo_23.6', 'Fibo_38.2', 'Fibo_50.0', 'Fibo_61.8', 'Fibo_78.6', 'Fibo_100']].iloc[-1]
    fibo_levels = last_fibo.values
    fibo_names = last_fibo.index

    for level, name in zip(fibo_levels, fibo_names):
        fig.add_hline(y=level, line_dash='dash', line_color='gray',
                      annotation_text=name, annotation_position='right', row=1, col=1)

    # RSI (Subplot)
    fig.add_trace(go.Scatter(
        x=data.index,
        y=data['RSI_14'],
        line=dict(color='blue', width=1),
        name='RSI 14'
    ), row=2, col=1)

    # Adiciona linhas de sobrecompra e sobrevenda
    fig.add_hline(y=70, line_dash='dash', line_color='red', row=2, col=1)
    fig.add_hline(y=30, line_dash='dash', line_color='green', row=2, col=1)

    # MACD (Subplot)
    fig.add_trace(go.Scatter(
        x=data.index,
        y=data['MACD_12_26_9'],
        line=dict(color='blue', width=1),
        name='MACD'
    ), row=3, col=1)

    fig.add_trace(go.Scatter(
        x=data.index,
        y=data['MACDs_12_26_9'],
        line=dict(color='red', width=1),
        name='Signal Line'
    ), row=3, col=1)

    # Histograma do MACD
    fig.add_trace(go.Bar(
        x=data.index,
        y=data['MACDh_12_26_9'],
        marker_color='gray',
        name='MACD Histogram'
    ), row=3, col=1)

    # Layout geral
    fig.update_layout(
        title='Análise Técnica do XAU/USD',
        yaxis_title='Preço',
        xaxis_rangeslider_visible=False,
        height=900,
        legend=dict(orientation='h', yanchor='bottom', y=1.02, xanchor='right', x=1),
        hovermode='x unified'
    )

    # Ajuste de eixos
    fig.update_yaxes(title_text="Preço", row=1, col=1)
    fig.update_yaxes(title_text="RSI", row=2, col=1, range=[0, 100])
    fig.update_yaxes(title_text="MACD", row=3, col=1)

    # Exibir o gráfico no Streamlit
    st.plotly_chart(fig, use_container_width=True)
