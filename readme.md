# ADS8694 HANDLER


  _Sistema en VHDL que gestiona la comunicación con un ADC ADS8694 y con un software de visualización y procesamiento de datos (Signal Plotter)_

## Diagrama en bloques simplificado del sistema

![Diagrama en bloques simplificado del sistema.](/image/diagrama_FPGA.png)

## Breve descripción de cada bloque

| Bloque | Descripción |
| ------ | ------ |
| ADS8694_top.vhd | Bloque top level, en donde se instancian los demás bloques y se realiza su interconexión|
| pulse_stretcher.vhd | Se utiliza para generar el clock del filtro digital pasa bajos IIR |
| ADS8694.vhd | Se encarga de la gestión de comunicación con el conversor ADS8694 |
| Data_Buffer.vhd |Recibe el dato de 16 bits (proveniente del filtro o del ADC directo) y lo envía en dos bytes consecutivos hacia el bloque UART_Handler |
| divisor.vhd | Divide el clock para generar uno de menor frecuencia. Utilizado para el clock de SPI (SCLK)|
| fsm_da1.vhd | Se encarga de la implementación de la comunicación SPI |
| mod_7seg_bis.vhd | Gestiona los displays 7-segmentos presentes en la placa de desarrollo Nexys3 |
| FILTERS/filter.vhd | Filtro pasa bajos IIR (Butterworth) de orden 5, implementado en 3 secciones de segundo orden |
| UART/UART_Handler.vhd | Se encarga de la gestión de la comunicación por UART, instanciando el bloque Comm_Control y uart_module |
| UART/Comm_Control.vhd | Se encarga de gestionar el protocolo de establecimiento de comunicación con el software Signal Plotter |
| UART/uart_module.vhd | Se encarga de la implementación de la comunicación UART |
