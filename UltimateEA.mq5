//+------------------------------------------------------------------+
//| Ultimate Auto Trading EA with GUI                                 |
//+------------------------------------------------------------------+
#include <Trade\Trade.mqh>
#include <Charts\ChartObjects\ChartObjectsTxtControls.mqh>
CTrade trade;

// ---------------- INPUT EA ----------------
input int FastMAPeriod      = 10;
input int SlowMAPeriod      = 50;
input int TF1               = PERIOD_H1;   // Trend filter timeframe
input int TF2               = PERIOD_M15;  // Entry signal timeframe
input double RiskPercent    = 1.0;         // % risiko per trade
input double ATRMultiplier  = 1.5;         // untuk stop-loss/take-profit dinamis
input int TrailingStopATR   = 2;           // trailing stop berdasarkan ATR
input bool UseNewsFilter    = true;        // filter news (placeholder)
input string SymbolsList    = "EURUSD,GBPUSD,USDJPY";

// Panel Variables
bool EA_Active = true;

// ---------------- FUNGSI UTILITY ----------------
double GetATR(string symbol,int timeframe,int period)
{
   return iATR(symbol,timeframe,period,0);
}

double CalcLot(double stopLossPoints)
{
   double risk = AccountBalance()*RiskPercent/100.0;
   double lot = risk/(stopLossPoints*_Point*10);
   return MathMax(lot,0.01);
}

int GetTrend(string symbol)
{
   double maFast = iMA(symbol,TF1,FastMAPeriod,0,MODE_SMA,PRICE_CLOSE,0);
   double maSlow = iMA(symbol,TF1,SlowMAPeriod,0,MODE_SMA,PRICE_CLOSE,0);
   if(maFast>maSlow) return 1;
   if(maFast<maSlow) return -1;
   return 0;
}

bool NewsFilter()
{
   if(!UseNewsFilter) return true;
   // Bisa integrasi kalender berita nanti
   return true;
}

// ---------------- PANEL ----------------
void DrawPanel()
{
   string txt = "Ultimate EA\n";
   txt += "EA Status: "+string(EA_Active?"ON":"OFF")+"\n";
   txt += "Risk %: "+DoubleToString(RiskPercent,1)+"\n";
   txt += "Symbols: "+SymbolsList+"\n";
   
   if(ObjectFind(0,"UltimatePanel")<0)
   {
      ObjectCreate(0,"UltimatePanel",OBJ_LABEL,0,0,0);
      ObjectSetInteger(0,"UltimatePanel",OBJPROP_XDISTANCE,10);
      ObjectSetInteger(0,"UltimatePanel",OBJPROP_YDISTANCE,50);
      ObjectSetInteger(0,"UltimatePanel",OBJPROP_COLOR,clrLime);
      ObjectSetInteger(0,"UltimatePanel",OBJPROP_FONTSIZE,12);
   }
   ObjectSetString(0,"UltimatePanel",OBJPROP_TEXT,txt);
}

// ---------------- ONINIT ----------------
int OnInit()
{
   DrawPanel();
   Print("Ultimate EA MT5 siap auto trading!");
   return(INIT_SUCCEEDED);
}

// ---------------- ONTICK ----------------
void OnTick()
{
   DrawPanel(); // update panel
   if(!EA_Active) return;

   string symbols[];
   int count = StringSplit(SymbolsList,',',symbols);
   for(int s=0;s<count;s++)
   {
      string sym = symbols[s];
      if(!NewsFilter()) continue;

      int trend = GetTrend(sym);
      double maFast = iMA(sym,TF2,FastMAPeriod,0,MODE_SMA,PRICE_CLOSE,0);
      double maFastPrev = iMA(sym,TF2,FastMAPeriod,0,MODE_SMA,PRICE_CLOSE,1);
      double maSlow = iMA(sym,TF2,SlowMAPeriod,0,MODE_SMA,PRICE_CLOSE,0);
      double maSlowPrev = iMA(sym,TF2,SlowMAPeriod,0,MODE_SMA,PRICE_CLOSE,1);

      double atr = GetATR(sym,TF2,14);
      double stopLoss = atr*ATRMultiplier*_Point;
      double takeProfit = atr*ATRMultiplier*2*_Point;
      double lot = CalcLot(stopLoss);

      int totalPositions = PositionsTotal();

      // BUY
      if(maFastPrev<=maSlowPrev && maFast>maSlow && trend==1)
      {
         if(totalPositions==0 || (totalPositions>0 && PositionGetInteger(POSITION_TYPE)!=POSITION_TYPE_BUY))
            trade.Buy(lot,sym,Ask,stopLoss,takeProfit,"Ultimate Buy");
      }

      // SELL
      if(maFastPrev>=maSlowPrev && maFast<maSlow && trend==-1)
      {
         if(totalPositions==0 || (totalPositions>0 && PositionGetInteger(POSITION_TYPE)!=POSITION_TYPE_SELL))
            trade.Sell(lot,sym,Bid,stopLoss,takeProfit,"Ultimate Sell");
      }

      // Trailing Stop
      for(int i=PositionsTotal()-1;i>=0;i--)
      {
         if(PositionSelectByIndex(i))
         {
            string posSym = PositionGetString(POSITION_SYMBOL);
            if(posSym!=sym) continue;

            long type = PositionGetInteger(POSITION_TYPE);
            double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
            double sl = PositionGetDouble(POSITION_SL);
            double currentPrice = (type==POSITION_TYPE_BUY)? SymbolInfoDouble(sym,SYMBOL_BID):SymbolInfoDouble(sym,SYMBOL_ASK);
            double trail = TrailingStopATR*atr*_Point;

            if(type==POSITION_TYPE_BUY && currentPrice-openPrice>trail && currentPrice-trail>sl)
               trade.PositionModify(PositionGetInteger(POSITION_TICKET),currentPrice-trail,PositionGetDouble(POSITION_TP));

            if(type==POSITION_TYPE_SELL && openPrice-currentPrice>trail && currentPrice+trail<sl)
               trade.PositionModify(PositionGetInteger(POSITION_TICKET),currentPrice+trail,PositionGetDouble(POSITION_TP));
         }
      }
   }
}

// ---------------- PANEL CONTROL ----------------
// Klik chart untuk toggle EA ON/OFF
void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
{
   if(id==CHARTEVENT_CLICK)
   {
      EA_Active = !EA_Active;
      DrawPanel();
      Print("EA toggled: ",EA_Active?"ON":"OFF");
   }
}
