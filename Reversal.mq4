//+------------------------------------------------------------------+
//|                                                          300.mq4 |
//|                                             Theofanis Pantelides |
//|                                   theofanis.pantelides@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Theofanis Pantelides"
#property link      "theofanis.pantelides@gmail.com"
#property version   "1.00"
#property strict

//--- input parameters
input int MinBars = 1;
input int MaxBars = 10;
input int MinMove = 30;
input int MaxMove = 65;

input int StopLoss = 45;
input int TakeProfit = 75;
input int Slippage = 1;

double __Point__;
int __Deviation__;
datetime lastTime = Time[Bars - 1];

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   //Checking for unconvetional Point digits number
   if ((Point == 0.00001) || (Point == 0.001))
   {
      __Point__ = Point * 10;
      __Deviation__ = Slippage * 10;
   }
   else
   {
      __Point__ = Point; //Normal
      __Deviation__ = Slippage;
   }
   
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{

}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
   if(lastTime == Time[0])
      return;
      
   lastTime = Time[0];

   int i = 1;
   bool nowLong = Open[1] < Close[1];
   
   for(i = 1; i <= MaxBars - 1; i++)
   {
      bool wasLong = Open[i + 1] < Close[i + 1];
      
      if(wasLong == nowLong)
         break;
   }
   
   if(i < MinBars || i > MaxBars)
   {
      Print("Bars: ", i, " MinBars: ", MinBars, " MaxBars: ", MaxBars);
      return;
   }
      
   double MarketMove = MathAbs(Open[i] - Close[2]);
   
   if(MarketMove < MinMove * __Point__ || MarketMove > MaxMove * __Point__)
      return;
   
   bool shouldFollow = true;
   
   /* Add rules as necessary */
   //shouldFollow |= nowLong ? (Open[1] < Close[2] && Close[1] > Open[2]) : (Open[1] > Close[2] && Close[1] < Open[2]);
   /* Add rules as necessary */
   
   int oResult = 0;
   int Lots = AccountEquity() / 100;
   if((nowLong && !shouldFollow) || (!nowLong && shouldFollow))
      oResult = OrderSend(Symbol(), OP_BUY, Lots / 100.0, Ask, __Deviation__, Ask - (StopLoss * __Point__), Ask + (TakeProfit * __Point__));
   else
      oResult = OrderSend(Symbol(), OP_SELL, Lots / 100.0, Bid, __Deviation__, Bid + (StopLoss * __Point__), Bid - (TakeProfit * __Point__));
      
   Print("MarketMove: ", DoubleToStr(MarketMove, Digits), 
         " Bars: ", i,
         " nowLong: ", nowLong,
         " shouldFollow: ", shouldFollow,
         " MinMove: ", DoubleToStr(MinMove * __Point__, Digits), 
         " MaxMove: ", DoubleToStr(MaxMove * __Point__, Digits));
      
   if (oResult == -1)
	{
		int e = GetLastError();
		Print(e);
	}
	else
	   Print("Order: ", oResult);
}

//+------------------------------------------------------------------+
