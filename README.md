# AUTO-TRADE-MT5-EA
Ultimate EA MT5 Installation & Setup (English)

1. Save the EA file
File name: UltimateEA.mq5
Location on your computer:
Salin kode

MetaTrader 5 → File → Open Data Folder → MQL5 → Experts
Copy the UltimateEA.mq5 file into this folder.

2. Compile the EA
Open MetaEditor (comes with MT5).
Open the file UltimateEA.mq5.
Press F7 or click Compile.
If no errors appear, a compiled file UltimateEA.ex5 will be created in the same folder.

3. Open a chart
Open MT5.
Open the chart for the symbol you want to trade, e.g., EURUSD.
Make sure the timeframe matches your EA settings (or EA can run on any timeframe, depending on its logic).

4. Attach the EA to the chart
Open Navigator → Expert Advisors → UltimateEA.
Drag UltimateEA onto the chart.
In the EA settings window, make sure to check:
Allow automated trading
Allow DLL imports (not required for this EA, but optional if needed later)
Click OK.

5. Enable Auto Trading
Make sure the AutoTrading button (green play button on the top of MT5) is active.
The panel should appear on the chart showing:
EA Status: ON/OFF
Risk %
Symbols list
You can click the panel on the chart to toggle EA ON or OFF.

6. Test on Demo Account First
Use a demo account before trying real money.
Start with a small risk %, e.g., 0.5–1%.
Check if trades are opened automatically and trailing stop / TP/SL works.

7. Optional: 24/7 Auto Trading
EA works 24/7 only if MT5 is running continuously.
For real auto trading, use a VPS (Virtual Private Server) running MT5.
You can monitor the EA on Android or PC remotely via TeamViewer / AnyDesk / Chrome Remote Desktop.
✅ Summary
Copy .mq5 to MQL5/Experts → Compile → .ex5.
Open chart → Drag EA → Allow AutoTrading.
Monitor panel → EA automatically executes trades with MA crossover + ATR-based TP/SL + trailing stop + risk management.
